% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

% == Simulation constants

epoch_0 = datenum(2014, 10, 20, 19, 5, 0); % Epoch date number

% == Space station

% === Pattern

% Maximum antenna gain [dB]
GainMax = 54;
% Cross-sectional half-power beamwidth, degrees
Phi0 = 2;

% Transmit and receive space pattern
pattern = PatternSNOR605V01(GainMax, Phi0);

% === Antenna

% Antenna name
name = 'RAMBOUILLET';
% Antenna gain
gain = GainMax;
% Antenna feeder loss
feeder_loss = 0;
% Antenna noise temperature
noise_t = 290;
% Antenna pattern identifier
pattern_id = 1;

% Transmit and receive space station antennas
transmitAntenna = SpaceStationAntenna(name, 'T', gain, pattern_id, pattern);
receiveAntenna = SpaceStationAntenna(name, 'R', gain, pattern_id, pattern);
receiveAntenna.set_feeder_loss(feeder_loss);
receiveAntenna.set_noise_t(noise_t);

% === Emission

% Emission designator
design_emi = '1K20G1D--';
% Maximum power density
pwr_ds_max = -24.799999237060547;
% Minimum power density
pwr_ds_min = NaN;
% Center frequency
freq_mhz = 1;
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
Omega     = 30.0 * pi / 180;      % Right ascension of the ascending node [rad]
omega     = 60.0 * pi / 180;      % Argument of perigee [rad]
M         = 120.0 * pi / 180;     % Mean anomaly [rad]
epoch     = epoch_0;              % Epoch date number
method    = 'halley';             % Method to solve Kepler's equation: 'newton' or 'halley'

spaceStation = SpaceStation( ...
    stationId, transmitAntenna, receiveAntenna, emission, beam, ...
    KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method));

% == Earth station

% === Pattern

% Maximum antenna gain [dB]
GainMax = 57;

% Transmit and receive Earth pattern
pattern = PatternEND_099V01(GainMax);

% === Antenna

% Antenna name
name = 'RAMBOUILLET';
% Antenna gain
gain = GainMax;
% Antenna feeder loss
feeder_loss = 0;
% Antenna noise temperature
noise_t = 290;
% Antenna pattern identifier
pattern_id = 1;

% Transmit and receive space station antennas
transmitAntenna = EarthStationAntenna(name, 'T', gain, pattern_id, pattern);
receiveAntenna = EarthStationAntenna(name, 'R', gain, pattern_id, pattern);
receiveAntenna.set_feeder_loss(feeder_loss);
receiveAntenna.set_noise_t(noise_t);

% === Emission

% Emission designator
design_emi = '1K20G1D--';
% Maximum power density
pwr_ds_max = -24.799999237060547;
% Minimum power density
pwr_ds_min = NaN;
% Center frequency
freq_mhz = 1;
% Required C/N
c_to_n = NaN;
    
emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);

% === Beam

beam = Beam();

% == Earth station

lla = Coordinates.gei2lla( ...
    spaceStation.orbit.r_gei( ...
        spaceStation.orbit.epoch), spaceStation.orbit.epoch);

stationId = 'wanted'; % Identifier for station
varphi    = 0;        % Geodetic latitude [rad]
lambda    = lla(2);   % Longitude [rad]

earthStation = EarthStation( ...
    stationId, transmitAntenna, receiveAntenna, emission, beam, varphi, lambda);

d_epoch = 10 / 86400;
		
tic

for i_epoch = 0 : 100000

  epoch = epoch + d_epoch;

  r_gei_es = earthStation.compute_r_gei(epoch);

  r_gei_ss = spaceStation.compute_r_gei(epoch);

  r_ltp_ss = Coordinates.gei2ltp(r_gei_ss, earthStation, epoch);

end % for

toc
