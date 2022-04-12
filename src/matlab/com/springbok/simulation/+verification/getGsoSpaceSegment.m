% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function spaceStation = getGsoSpaceSegment(epoch_0)
  
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
  name = 'GSO SS Tx';
  % Antenna gain
  gain = GainMax;
  % Antenna pattern identifier
  pattern_id = 1;
  
  % Transmit space station antenna
  transmitAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);
  
  % Gain function options
  options = {'GainMax', GainMax, 'DoValidate', false};
  transmitAntenna.set_options(options);
  
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
  
  beam = Beam('GSO SS', 1, 100);
  
  % === Receive pattern
  
  % Maximum antenna gain [dB]
  GainMax = 40;
  % Cross-sectional half-power beamwidth, degrees
  Phi0 = 4;
  
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
  pattern_id = 1;
  
  % Receive space station antenna
  receiveAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);
  receiveAntenna.set_feeder_loss(feeder_loss);
  receiveAntenna.set_noise_t(noise_t);
  
  % Gain function options
  options = {'GainMax', GainMax, 'DoValidate', false};
  receiveAntenna.set_options(options);
  
  % == Space station
  
  stationId = 'GSO SS';             % Identifier for station
  a         = EarthConstants.a_gso; % Semi-major axis [er]
  e         = 0.000001;             % Eccentricity [-]
  i         = 0.001 * pi / 180;     % Inclination [rad]
  Omega     = 0.0 * pi / 180;       % Right ascension of the ascending node [rad]
  omega     = 0.0 * pi / 180;       % Argument of perigee [rad]
  M         = 10.0 * pi / 180;       % Mean anomaly [rad]
  epoch     = epoch_0;              % Epoch date number
  method    = 'halley';             % Method to solve Kepler's equation: 'newton' or 'halley'

  spaceStation = SpaceStation( ...
      stationId, transmitAntenna, receiveAntenna, emission, beam, ...
      KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method));

end % getGeoSpaceSegment()
