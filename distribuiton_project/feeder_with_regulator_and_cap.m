function mpc = feeder_with_regulator_and_cap
%FEEDER_WITH_REGULATOR_AND_CAP  6-bus feeder with regulator and capacitor
%   Voltage regulator on line between Bus 2-3 (tap = 0.95)
%   Capacitor bank at Bus 5 (2.0 MVAR)
%
%   Capacitor modeling per MATPOWER standard:
%   - Capacitors inject reactive power (provide VARs to the system)
%   - Modeled as NEGATIVE Qd (load demand)
%   - Bus 5 has 1.75 MVAR load demand, 2.0 MVAR capacitor supply
%   - Net: Qd = 1.75 - 2.0 = -0.25 MVAR (capacitor over-compensates slightly)

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 10;  % 10 MVA base

%% bus data - CAPACITOR MODELED AT BUS 5
% Per MATPOWER documentation:
% "Pd, real power demand (MW)"
% "Qd, reactive power demand (MVAr)"
% Negative Qd represents reactive power INJECTION (generation/capacitor)
%
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	    0	     0	0	1	1.00	0	12.47	1	1.05	0.95;  % Slack (substation)
	2	1	2.0	    1.0	     0	0	1	1.00	0	12.47	1	1.05	0.95;  % 2.0 MW, 1.0 MVAR load
	3	1	3.0	    1.5	     0	0	1	1.00	0	12.47	1	1.05	0.95;  % 3.0 MW, 1.5 MVAR load
	4	1	2.5	    1.25     0	0	1	1.00	0	12.47	1	1.05	0.95;  % 2.5 MW, 1.25 MVAR load
	5	1	3.5	    -0.25    0	0	1	1.00	0	12.47	1	1.05	0.95;  % 3.5 MW load, 2.0 MVAR cap, net = 1.75-2.0 = -0.25 MVAR
	6	1	4.0	    2.0	     0	0	1	1.00	0	12.47	1	1.05	0.95;  % 4.0 MW, 2.0 MVAR load
];
% Note: Bus 5 Qd = -0.25 MVAR means net reactive injection
% Physical interpretation: Load needs 1.75 MVAR, capacitor supplies 2.0 MVAR

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin
mpc.gen = [
	1	0	0	9999	-9999	1.00	10	1	9999	0;  % Slack generator
];

%% branch data - REGULATOR ON LINE 2-3
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0.015	0.020	0	9999	0	0	0	    0	1	-360	360;  % Line 1-2
	2	3	0.024	0.032	0	9999	0	0	0.95	0	1	-360	360;  % Line 2-3 with REGULATOR (tap=0.95, ~5% boost)
	3	4	0.030	0.040	0	9999	0	0	0	    0	1	-360	360;  % Line 3-4
	4	5	0.027	0.036	0	9999	0	0	0	    0	1	-360	360;  % Line 4-5
	5	6	0.024	0.032	0	9999	0	0	0	    0	1	-360	360;  % Line 5-6
];