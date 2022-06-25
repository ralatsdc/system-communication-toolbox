% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

% == Simulation constants

% Date near reference where Greenwich hour angle is zero
epoch_0 = datenum(2000, 1, 1, 12, 0, 0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot;
% [decimal day] = [decimal day] - [rad] / [rad / day]

% = Wanted system

% == Space station

wnt_spaceStation = gso_gso.getWntGsoSpaceSegment(epoch_0);

% == Earth station

lla = Coordinates.gei2lla( ...
    wnt_spaceStation.orbit.r_gei( ...
        wnt_spaceStation.orbit.epoch), wnt_spaceStation.orbit.epoch);

varphi = 10.0 * pi / 180; % Geodetic latitude [rad]
lambda = lla(2);          % Longitude [rad]

wnt_earthStation = gso_gso.getWntGsoEarthSegment(varphi, lambda);

% = Wanted system

losses = {};

wnt_system = System(wnt_earthStation, wnt_spaceStation, losses, ...
                    epoch_0, 'testAngleFromGsoArc', 0);

% = Interfering system

% == Space station

int_spaceStation = gso_gso.getIntGsoSpaceSegment(epoch_0);

% == Earth station

lla = Coordinates.gei2lla( ...
    int_spaceStation.orbit.r_gei( ...
        int_spaceStation.orbit.epoch), int_spaceStation.orbit.epoch);

varphi = 20.0 * pi / 180; % Geodetic latitude [rad]
lambda = lla(2);          % Longitude [rad]

int_earthStation = gso_gso.getIntGsoEarthSegment(varphi, lambda);

% = Interfering system

losses = {};

int_system = System(int_earthStation, int_spaceStation, losses, ...
                    epoch_0, 'testAngleFromGsoArc', 0);

% == Compute performance

% Article 22 reference bandwith [kHz]
ref_bw = 40;

wnt_system.assignBeams([], [], epoch_0);
int_system.assignBeams([], [], epoch_0);

up_Performance = wnt_system.computeUpLinkPerformance( ...
    epoch_0, int_system, 1, 1, ref_bw)
dn_Performance = wnt_system.computeDownLinkPerformance( ...
    epoch_0, int_system, 1, 1, ref_bw)
