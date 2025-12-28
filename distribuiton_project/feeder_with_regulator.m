function mpc = feeder_with_regulator
%FEEDER_WITH_REGULATOR  6-bus feeder with voltage regulator
%   Regulator placed between Bus 2 and Bus 3

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 10;  % 10 MVA base

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	    0	    0	0	1	1.00	0	12.47	1	1.05	0.95;
	2	1	2.0	    1.0	    0	0	1	1.00	0	12.47	1	1.05	0.95;
	3	1	3.0	    1.5	    0	0	1	1.00	0	12.47	1	1.05	0.95;
	4	1	2.5	    1.25	0	0	1	1.00	0	12.47	1	1.05	0.95;
	5	1	3.5	    1.75	0	0	1	1.00	0	12.47	1	1.05	0.95;
	6	1	4.0	    2.0	    0	0	1	1.00	0	12.47	1	1.05	0.95;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin
mpc.gen = [
	1	0	0	9999	-9999	1.00	10	1	9999	0;
];

%% branch data - REGULATOR BETWEEN BUS 2-3
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0.015	0.020	0	9999	0	0	0	    0	1	-360	360;
	2	3	0.024	0.032	0	9999	0	0	0.95	0	1	-360	360;  % REGULATOR: tap = 0.95 (5% boost)
	3	4	0.030	0.040	0	9999	0	0	0	    0	1	-360	360;
	4	5	0.027	0.036	0	9999	0	0	0	    0	1	-360	360;
	5	6	0.024	0.032	0	9999	0	0	0	    0	1	-360	360;
];