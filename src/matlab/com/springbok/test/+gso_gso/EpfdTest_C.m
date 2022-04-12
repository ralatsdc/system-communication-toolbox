% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

% = Wanted system

wantedSystem = gso_gso.getWntGsoSystem();

% = Interfering system

interferingSystem = gso_gso.getIntGsoSystem();

% == Compute performance

epoch_0 = wantedSystem.spaceStations.orbit.epoch;

% Article 22 reference bandwith [kHz]
ref_bw = 40;

wantedSystem.assignBeams([], [], epoch_0);
interferingSystem.assignBeams([], [], epoch_0);

up_Performance = wantedSystem.computeUpLinkPerformance( ...
    epoch_0, interferingSystem, 1, 1, ref_bw)
dn_Performance = wantedSystem.computeDownLinkPerformance( ...
    epoch_0, interferingSystem, 1, 1, ref_bw)
