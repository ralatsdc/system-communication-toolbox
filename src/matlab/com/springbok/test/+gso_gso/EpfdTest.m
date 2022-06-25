% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

% == Simulation constants

% Date near reference where Greenwich hour angle is zero
epoch_0 = datenum(2000, 1, 1, 12, 0, 0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot;
% [decimal day] = [decimal day] - [rad] / [rad / day]

% = Wanted system

% == Space station

% === Transmit pattern

% Maximum antenna gain [dB]
GainMax = 38;
% Cross-sectional half-power beamwidth, degrees
Phi0 = 4;

% Transmit space pattern
pattern = PatternSREC408V01(Phi0);

% === Transmit antenna

% Antenna name
name = 'RAMBOUILLET';
% Antenna gain
gain = GainMax;
% Antenna pattern identifier
pattern_id = 1;

% Transmit space station antenna
transmitAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);

% Gain function options
options = {'GainMax', GainMax};
transmitAntenna.set_options(options);

% === Receive pattern

% Maximum antenna gain [dB]
GainMax = 40;
% Cross-sectional half-power beamwidth, degrees
Phi0 = 4;

% Receive space pattern
pattern = PatternSREC408V01(Phi0);

% === Receive antenna

% Antenna name
name = 'RAMBOUILLET';
% Antenna gain
gain = GainMax;
% Antenna feeder loss
feeder_loss = 0;
% Antenna noise temperature
noise_t = 1000;
% Antenna pattern identifier
pattern_id = 1;

% Receive space station antenna
receiveAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);
receiveAntenna.set_feeder_loss(feeder_loss);
receiveAntenna.set_noise_t(noise_t);

% Gain function options
options = {'GainMax', GainMax};
receiveAntenna.set_options(options);

% === Emission

% Emission designator
design_emi = '1K20G1D--';
% Maximum power density
pwr_ds_max = -58.0;
% Minimum power density
pwr_ds_min = NaN;
% Center frequency
freq_mhz = 11200;
% Required C/N
c_to_n = NaN;
    
emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);

% === Beam

beam = Beam();

% == Space station

stationId = 'wanted';             % Identifier for station
a         = EarthConstants.a_gso; % Semi-major axis [er]
e         = 0.001;                % Eccentricity [-]
i         = 0.01 * pi / 180;      % Inclination [rad]
Omega     = 0.0 * pi / 180;       % Right ascension of the ascending node [rad]
omega     = 0.0 * pi / 180;       % Argument of perigee [rad]
M         = 0.0 * pi / 180;       % Mean anomaly [rad]
epoch     = epoch_0;              % Epoch date number
method    = 'halley';             % Method to solve Kepler's equation: 'newton' or 'halley'

wnt_spaceStation = SpaceStation( ...
    stationId, transmitAntenna, receiveAntenna, emission, beam, ...
    KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method));

% == Earth station

% === Transmit pattern

% Maximum antenna gain [dB]
GainMax = 50;
% Antenna efficiency, fraction
Efficiency = 0.7;
    
% Transmit Earth pattern
pattern = PatternEREC013V01(GainMax, Efficiency);

% === Transmit antenna

% Antenna name
name = 'RAMBOUILLET';
% Antenna gain
gain = GainMax;
% Antenna pattern identifier
pattern_id = 1;

% Transmit Earth station antenna
transmitAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);

% === Receive pattern

% Maximum antenna gain [dB]
GainMax = -Inf;
% Diameter of an earth antenna, m
Diameter = 1.2;
% Frequency for which a gain is calculated, MHz
Frequency = 11200;

% Receive Earth pattern
pattern = PatternERR_020V01(Diameter, Frequency);

% === Receive antenna

% Antenna name
name = 'RAMBOUILLET';
% Antenna gain
gain = GainMax;
% Antenna feeder loss
feeder_loss = 0;
% Antenna noise temperature
noise_t = 150;
% Antenna pattern identifier
pattern_id = 1;

% Receive Earth station antenna
receiveAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
receiveAntenna.set_feeder_loss(feeder_loss);
receiveAntenna.set_noise_t(noise_t);

% === Emission

% Emission designator
design_emi = '1K20G1D--';
% Maximum power density
pwr_ds_max = -42.0;
% Minimum power density
pwr_ds_min = NaN;
% Center frequency
freq_mhz = 13000;
% Required C/N
c_to_n = NaN;
    
emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);

% === Beam

beam = Beam();

% == Earth station

lla = Coordinates.gei2lla( ...
    wnt_spaceStation.orbit.r_gei( ...
        wnt_spaceStation.orbit.epoch), wnt_spaceStation.orbit.epoch);

stationId      = 'wanted';        % Identifier for station
varphi         = 10.0 * pi / 180; % Geodetic latitude [rad]
lambda         = lla(2);          % Longitude [rad]
doMultiplexing = 0;               % Flag indicating whether to do multiplexing, or not

wnt_earthStation = EarthStation( ...
    stationId, transmitAntenna, receiveAntenna, emission, beam, ...
    varphi, lambda, doMultiplexing);

% = Wanted system

losses = {};

wnt_system = System(wnt_earthStation, wnt_spaceStation, losses, ...
                    epoch_0, 'testAngleFromGsoArc', 0);

% = Interfering system

% == Space station

% === Transmit pattern

% Maximum antenna gain [dB]
GainMax = 38;
% Cross-sectional half-power beamwidth, degrees
Phi0 = 4;

% Transmit space pattern
pattern = PatternSREC408V01(Phi0);

% === Transmit antenna

% Antenna name
name = 'RAMBOUILLET';
% Antenna gain
gain = GainMax;
% Antenna pattern identifier
pattern_id = 1;

% Transmit space station antenna
transmitAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);

% Gain function options
options = {'GainMax', GainMax};
transmitAntenna.set_options(options);

% === Receive pattern

% Maximum antenna gain [dB]
GainMax = 40;
% Cross-sectional half-power beamwidth, degrees
Phi0 = 4;

% Receive space pattern
pattern = PatternSREC408V01(Phi0);

% === Receive antenna

% Antenna name
name = 'RAMBOUILLET';
% Antenna gain
gain = GainMax;
% Antenna feeder loss
feeder_loss = 0;
% Antenna noise temperature
noise_t = 1000;
% Antenna pattern identifier
pattern_id = 1;

% Receive space station antenna
receiveAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);
receiveAntenna.set_feeder_loss(feeder_loss);
receiveAntenna.set_noise_t(noise_t);

% Gain function options
options = {'GainMax', GainMax};
receiveAntenna.set_options(options);

% === Emission

% Emission designator
design_emi = '1K20G1D--';
% Maximum power density
pwr_ds_max = -58.0;
% Minimum power density
pwr_ds_min = NaN;
% Center frequency
freq_mhz = 11200;
% Required C/N
c_to_n = NaN;
    
emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);

% === Beam

beam = Beam();

% == Space station

stationId = 'interfering';        % Identifier for station
a         = EarthConstants.a_gso; % Semi-major axis [er]
e         = 0.001;                % Eccentricity [-]
i         = 0.01 * pi / 180;      % Inclination [rad]
Omega     = 5.0 * pi / 180;       % Right ascension of the ascending node [rad]
omega     = 0.0 * pi / 180;       % Argument of perigee [rad]
M         = 0.0 * pi / 180;       % Mean anomaly [rad]
epoch     = epoch_0;              % Epoch date number
method    = 'halley';             % Method to solve Kepler's equation: 'newton' or 'halley'

int_spaceStation = SpaceStation( ...
    stationId, transmitAntenna, receiveAntenna, emission, beam, ...
    KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method));

% == Earth station

% === Transmit pattern

% Maximum antenna gain [dB]
GainMax = 50;
% Antenna efficiency, fraction
Efficiency = 0.7;
    
% Transmit Earth pattern
pattern = PatternEREC013V01(GainMax, Efficiency);

% === Transmit antenna

% Antenna name
name = 'RAMBOUILLET';
% Antenna gain
gain = GainMax;
% Antenna pattern identifier
pattern_id = 1;

% Transmit Earth station antenna
transmitAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);

% === Receive pattern

% Maximum antenna gain [dB]
GainMax = -Inf;
% Diameter of an earth antenna, m
Diameter = 1.2;
% Frequency for which a gain is calculated, MHz
Frequency = 11200;

% Receive Earth pattern
pattern = PatternERR_020V01(Diameter, Frequency);

% === Receive antenna

% Antenna name
name = 'RAMBOUILLET';
% Antenna gain
gain = GainMax;
% Antenna feeder loss
feeder_loss = 0;
% Antenna noise temperature
noise_t = 150;
% Antenna pattern identifier
pattern_id = 1;

% Receive Earth station antenna
receiveAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
receiveAntenna.set_feeder_loss(feeder_loss);
receiveAntenna.set_noise_t(noise_t);

% === Emission

% Emission designator
design_emi = '1K20G1D--';
% Maximum power density
pwr_ds_max = -42.0;
% Minimum power density
pwr_ds_min = NaN;
% Center frequency
freq_mhz = 13000;
% Required C/N
c_to_n = NaN;
    
emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);

% === Beam

beam = Beam();

% == Earth station

lla = Coordinates.gei2lla( ...
    int_spaceStation.orbit.r_gei( ...
        int_spaceStation.orbit.epoch), int_spaceStation.orbit.epoch);

stationId      = 'interfering';   % Identifier for station
varphi         = 20.0 * pi / 180; % Geodetic latitude [rad]
lambda         = lla(2);          % Longitude [rad]
doMultiplexing = 0;               % Flag indicating whether to do multiplexing, or not

int_earthStation = EarthStation( ...
    stationId, transmitAntenna, receiveAntenna, emission, beam, ...
    varphi, lambda, doMultiplexing);

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
    epoch_0, int_system, 1, 1, ref_bw);
dn_Performance = wnt_system.computeDownLinkPerformance( ...
    epoch_0, int_system, 1, 1, ref_bw);
