% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

% Assign a run label

run_label = input('Enter a run label [yyyy-mm-dd-HHMMSS]: ');
if isempty(run_label)
  run_label = datestr(now, 'yyyy-mm-dd-HHMMSS');

end % if
fprintf('run_label: %s\n', run_label);

reply = input('Continue? Y/N [Y]: ', 's');
if isempty(reply)
  reply = 'Y';

else
  reply = upper(reply);
  
end % if
if ~strcmp(reply, 'Y')
  return;

end % if

% tic

% == Simulation constants

epoch_0 = datenum(2014, 10, 20, 19, 5, 0); % Epoch date number

% = Wanted system

% == Space station

% === Transmit Pattern

% Maximum antenna gain [dB]
GainMax = 38;
% Cross-sectional half-power beamwidth, degrees
Phi0 = 2;

% Transmit space pattern
pattern = PatternSREC408V01(Phi0);

% === Transmit antenna

% Antenna name
name = 'GSO SS Tx';
% Antenna gain
gain = GainMax;
% Antenna pattern identifier
pattern_id = 1;

% Transmit space station antenna
transmitAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);

% Gain function options
options = {'GainMax', GainMax};
transmitAntenna.set_options(options);

% === Receive Pattern

% Maximum antenna gain [dB]
GainMax = 40;
% Cross-sectional half-power beamwidth, degrees
Phi0 = 1.7;

% Receive space pattern
pattern = PatternSREC408V01(Phi0);

% === Receive antenna

% Antenna name
name = 'GSO SS Rx';
% Antenna gain
gain = GainMax;
% Antenna feeder loss
feeder_loss = 0;
% Antenna noise temperature
noise_t = 1000;
% Antenna pattern identifier
pattern_id = 2;

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
pwr_ds_max = -58;
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
Omega     = 30.0 * pi / 180;      % Right ascension of the ascending node [rad]
omega     = 60.0 * pi / 180;      % Argument of perigee [rad]
M         = 120.0 * pi / 180;     % Mean anomaly [rad]
epoch     = epoch_0;              % Epoch date number
method    = 'halley';             % Method to solve Kepler's equation: 'newton' or 'halley'

wnt_spaceStation = SpaceStation( ...
    stationId, transmitAntenna, receiveAntenna, emission, beam, ...
    KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method));

% == Earth station

% === Transmit Pattern

% Maximum antenna gain [dB]
GainMax = 50;
% Antenna efficiency, fraction
Efficiency = 0.7;

% Transmit Earth pattern
pattern = PatternEREC013V01(GainMax, Efficiency);

% === Transmit antenna

% Antenna name
name = 'GSO ES Tx';
% Antenna gain
gain = GainMax;
% Antenna pattern identifier
pattern_id = 1;

% Transmit Earth station antenna
transmitAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);

% === Receive Pattern

% Maximum antenna gain [dB]
GainMax = NaN;
% Diameter of an earth antenna, m
Diameter = 1.2;
% Frequency for which a gain is calculated, MHz
Frequency = 11200;

% Receive Earth pattern
pattern = PatternERR_020V01(Diameter, Frequency);

% === Receive antenna

% Antenna name
name = 'GSO ES Rx';
% Antenna gain
gain = GainMax;
% Antenna feeder loss
feeder_loss = 0;
% Antenna noise temperature
noise_t = 150;
% Antenna pattern identifier
pattern_id = 2;

% Receive Earth station antenna
receiveAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
receiveAntenna.set_feeder_loss(feeder_loss);
receiveAntenna.set_noise_t(noise_t);

% === Emission

% Emission designator
design_emi = '1K20G1D--';
% Maximum power density
pwr_ds_max = -42;
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

stationId      = 'wanted'; % Identifier for station
varphi         = 0;        % Geodetic latitude [rad]
lambda         = lla(2);   % Longitude [rad]
doMultiplexing = 0;        % Flag indicating whether to do multiplexing, or not

wnt_earthStation = EarthStation( ...
    stationId, transmitAntenna, receiveAntenna, emission, beam, ...
    varphi, lambda, doMultiplexing);

% = Wanted system

losses = {};

wnt_system = System(wnt_earthStation, wnt_spaceStation, losses, ...
                    epoch_0, 'testAngleFromGsoArc', 0);

% = Interfering system

% == Space stations

% === Transmit Pattern

% Maximum antenna gain [dB]
GainMax = 28;
% Cross-sectional half-power beamwidth, degrees
Phi0 = 6.6;

% Transmit space pattern
pattern = PatternSREC408V01(Phi0);

% === Transmit antenna

% Antenna name
name = 'NGSO SS Tx';
% Antenna gain
gain = GainMax;
% Antenna pattern identifier
pattern_id = 1;

% Transmit space station antenna
transmitAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);

% Gain function options
options = {'GainMax', GainMax};
transmitAntenna.set_options(options);

% === Receive Pattern

% Maximum antenna gain [dB]
GainMax = 30;
% Cross-sectional half-power beamwidth, degrees
Phi0 = 5.3;

% Receive space pattern
pattern = PatternSREC408V01(Phi0);

% === Receive antenna

% Antenna name
name = 'NGSO SS Rx';
% Antenna gain
gain = GainMax;
% Antenna feeder loss
feeder_loss = 0;
% Antenna noise temperature
noise_t = 1000;
% Antenna pattern identifier
pattern_id = 2;

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
pwr_ds_max = -73;
% Minimum power density
pwr_ds_min = NaN;
% Center frequency
freq_mhz = 11200;
% Required C/N
c_to_n = NaN;
    
emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);

% === Beam

beam = Beam();

% == Space stations

stationId = 'interfering';                     % Identifier for station
a         = 1 + 1500 / EarthConstants.R_oplus; % Semi-major axis [er]
e         = 0.001;                             % Eccentricity [-]
i         = 80.0 * pi / 180;                   % Inclination [rad]
Omega     = 30.0 * pi / 180;                   % Right ascension of the ascending node [rad]
omega     = 60.0 * pi / 180;                   % Argument of perigee [rad]
M         = 130.0 * pi / 180;                  % Mean anomaly [rad]
epoch     = epoch_0;                           % Epoch date number
method    = 'halley';                          % Method to solve Kepler's equation: 'newton' or 'halley'

int_spaceStations = [];
d_angle = 24;
for d_Omega = [0 : d_angle : 360 - d_angle] * (pi / 180)
  for d_omega = [0 : d_angle : 360 - d_angle] * (pi / 180)
    int_spaceStations = [int_spaceStations; SpaceStation( ...
        stationId, transmitAntenna, receiveAntenna, emission, beam, ...
        KeplerianOrbit(a, e, i, Omega + d_Omega, omega + d_omega, M, epoch, method))];

  end % for

end % for

% == Earth stations

% === Transmit Pattern

% Maximum antenna gain [dB]
GainMax = 34;
% Antenna efficiency, fraction
Efficiency = 0.7;

% Transmit Earth pattern
pattern = PatternEREC013V01(GainMax, Efficiency);

% === Transmit antenna

% Antenna name
name = 'NGSO ES Tx';
% Antenna gain
gain = GainMax;
% Antenna pattern identifier
pattern_id = 1;

% Transmit Earth station antenna
transmitAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);

% === Receive Pattern

% Maximum antenna gain [dB]
GainMax = 32;
% Antenna efficiency, fraction
Efficiency = 0.7;

% Receive Earth pattern
pattern = PatternEREC013V01(GainMax, Efficiency);

% === Receive antenna

% Antenna name
name = 'NGSO ES Rx';
% Antenna gain
gain = GainMax;
% Antenna feeder loss
feeder_loss = 0;
% Antenna noise temperature
noise_t = 150;
% Antenna pattern identifier
pattern_id = 2;

% Receive Earth station antenna
receiveAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
receiveAntenna.set_feeder_loss(feeder_loss);
receiveAntenna.set_noise_t(noise_t);

% === Emission

% Emission designator
design_emi = '1K20G1D--';
% Maximum power density
pwr_ds_max = -60;
% Minimum power density
pwr_ds_min = NaN;
% Center frequency
freq_mhz = 13000;
% Required C/N
c_to_n = NaN;
    
emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);

% === Beam

beam = Beam();

% == Earth stations

% Contiguous United States bounding box
% See: https://answers.yahoo.com/question/index?qid=20070729220301AA6Ct4s
%
% Northernmost point
% Northwest Angle, Minnesota (49°23'4.1" N)
% 
% Southernmost point
% Ballast Key, Florida ( 24°31′15″ N)
% 
% Easternmost point
% Sail Rock, just offshore of West Quoddy Head, Maine
% (66°57' W)
% 
% Westernmost point
% Bodelteh Islands offshore from Cape Alava, Washington
% (124°46' W) 

stationId      = 'wanted'; % Identifier for station
varphi         = 0;        % Geodetic latitude [rad]
lambda         = lla(2);   % Longitude [rad]
doMultiplexing = 0;        % Flag indicating whether to do multiplexing, or not

int_earthStations = [];
d_angle = 12;
for d_varphi = ([0 : d_angle : 24] - d_angle) * (pi / 180)
  for d_lambda = ([0 : d_angle : 60] - d_angle) * (pi / 180)
    int_earthStations = [int_earthStations; EarthStation( ...
        stationId, transmitAntenna, receiveAntenna, emission, beam, ...
        varphi + d_varphi, lambda + d_lambda, doMultiplexing)];

  end % for

end % for

% = Interfering system

losses = {};

int_system = System(int_earthStations, int_spaceStations, losses, epoch_0);

% toc

tic

% == Compute performance

% Article 22 reference bandwith [kHz]
ref_bw = 40;

wnt_system.assignBeams([], [], epoch_0, 'method', 'random');

nSec = 8640;

parfor idx = [1 : nSec]
  
  warning('off');
  
  epoch(idx) = epoch_0 + idx / 86400;
  
  if ~mod(idx, 10)
    int_system.assignBeams([], [], epoch(idx), 'method', 'random');
    
  end % if

  indexes{idx} = int_system.indexes;

  up_P(idx) = wnt_system.computeUpLinkPerformance( ...
      epoch(idx), int_system, 1, 1, ref_bw);
  is_P(idx) = wnt_system.computeUpLinkPerformance( ...
      epoch(idx), int_system, 1, 1, ref_bw, 'doIS', 1);
  dn_P(idx) = wnt_system.computeDownLinkPerformance( ...
      epoch(idx), int_system, 1, 1, ref_bw);

end % for

warning('on');

toc

save(sprintf('mat/Simulation-%s.mat', run_label));
