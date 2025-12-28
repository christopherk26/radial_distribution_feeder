function mpc = feeder_base_case
%FEEDER_BASE_CASE  6-bus radial distribution feeder
%   Base case with no voltage regulation
%
%   This file follows the MATPOWER case format standard where:
%   - Pd and Qd are specified in MW and MVAR (NOT per-unit)
%   - Voltage magnitudes (Vm) are in per-unit
%   - Impedances (r, x) are in per-unit on the baseMVA base
%   - baseMVA is used internally by MATPOWER for per-unit conversion
%
%   Reference: MATPOWER documentation - caseformat.m
%   "Pd, real power demand (MW)"
%   "Qd, reactive power demand (MVAr)"

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
% baseMVA is the system base for per-unit calculations
% Used to normalize impedances and convert internal calculations
mpc.baseMVA = 10;  % 10 MVA base

%% bus data
% Columns:
%  1: bus_i - bus number (positive integer)
%  2: type - bus type (1=PQ load, 2=PV generator, 3=slack/reference, 4=isolated)
%  3: Pd - real power demand in MW (NOT per-unit, per MATPOWER standard)
%  4: Qd - reactive power demand in MVAR (NOT per-unit, per MATPOWER standard)
%  5: Gs - shunt conductance (MW at V=1.0 pu)
%  6: Bs - shunt susceptance (MVAR at V=1.0 pu)
%  7: area - area number
%  8: Vm - voltage magnitude initial guess (per-unit)
%  9: Va - voltage angle initial guess (degrees)
% 10: baseKV - base voltage (kV)
% 11: zone - loss zone
% 12: Vmax - maximum voltage magnitude (per-unit)
% 13: Vmin - minimum voltage magnitude (per-unit)
%
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	    0	    0	0	1	1.00	0	12.47	1	1.05	0.95;  % Slack bus
	2	1	2.0	    1.0	    0	0	1	1.00	0	12.47	1	1.05	0.95;  % 2.0 MW, 1.0 MVAR
	3	1	3.0	    1.5	    0	0	1	1.00	0	12.47	1	1.05	0.95;  % 3.0 MW, 1.5 MVAR
	4	1	2.5	    1.25	0	0	1	1.00	0	12.47	1	1.05	0.95;  % 2.5 MW, 1.25 MVAR
	5	1	3.5	    1.75	0	0	1	1.00	0	12.47	1	1.05	0.95;  % 3.5 MW, 1.75 MVAR
	6	1	4.0	    2.0	    0	0	1	1.00	0	12.47	1	1.05	0.95;  % 4.0 MW, 2.0 MVAR
];
% Total load: 15.0 MW, 7.5 MVAR

%% generator data
% Columns:
%  1: bus - bus number where generator is connected
%  2: Pg - real power output (MW) - for slack bus, this is calculated by solver
%  3: Qg - reactive power output (MVAR) - for slack bus, this is calculated by solver
%  4: Qmax - maximum reactive power output (MVAR)
%  5: Qmin - minimum reactive power output (MVAR)
%  6: Vg - voltage magnitude setpoint (per-unit)
%  7: mBase - machine MVA base (defaults to baseMVA if not specified)
%  8: status - 1=in service, 0=out of service
%  9: Pmax - maximum real power output (MW)
% 10: Pmin - minimum real power output (MW)
%
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin
mpc.gen = [
	1	0	0	9999	-9999	1.00	10	1	9999	0;
];
% Pg=0 is a placeholder; the slack bus will generate whatever is needed
% to balance load + losses (calculated by power flow solver)

%% branch data (lines)
% Columns:
%  1: fbus - "from" bus number
%  2: tbus - "to" bus number
%  3: r - resistance (per-unit on baseMVA base)
%  4: x - reactance (per-unit on baseMVA base)
%  5: b - total line charging susceptance (per-unit)
%  6: rateA - MVA rating A (long term)
%  7: rateB - MVA rating B (short term)
%  8: rateC - MVA rating C (emergency)
%  9: ratio - transformer off-nominal turns ratio (0 = transmission line)
% 10: angle - transformer phase shift angle (degrees)
% 11: status - 1=in service, 0=out of service
% 12: angmin - minimum angle difference (degrees)
% 13: angmax - maximum angle difference (degrees)
%
% Note: r and x are in PER-UNIT on the baseMVA base
% To convert from physical ohms: Z_pu = Z_ohms / Z_base
% where Z_base = (baseKV)^2 / baseMVA = (12.47)^2 / 10 = 15.55 ohms
%
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0.015	0.020	0	9999	0	0	0	0	1	-360	360;  % Line 1-2: 0.5 miles
	2	3	0.024	0.032	0	9999	0	0	0	0	1	-360	360;  % Line 2-3: 0.8 miles
	3	4	0.030	0.040	0	9999	0	0	0	0	1	-360	360;  % Line 3-4: 1.0 miles
	4	5	0.027	0.036	0	9999	0	0	0	0	1	-360	360;  % Line 4-5: 0.9 miles
	5	6	0.024	0.032	0	9999	0	0	0	0	1	-360	360;  % Line 5-6: 0.8 miles
];
% Line impedances based on 0.3 Ω/mile resistance, 0.4 Ω/mile reactance
% ratio=0 means these are transmission lines (not transformers)