% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function earthStation = getWntGsoEarthSegment(varphi, lambda)
% Defines the wanted GSO Earth segment.
%
% Parameters
%   varphi - Geodetic latitude of the Earth station [rad]
%   lambda - Geodectic longitude of the Earth station [rad]
%
% Returns
%   earthStation - The Earth station of the wanted GSO system
  
  % = Wanted system
  
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
  name = 'GSO ES Tx';
  % Antenna gain
  gain = GainMax;
  % Antenna pattern identifier
  pattern_id = 1;
  
  % Transmit Earth station antenna
  transmitAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
  
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
  
  beam = Beam('WntGsoEarthSegment', 1, 100);
  
  % === Receive pattern
  
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
  pattern_id = 1;
  
  % Receive Earth station antenna
  receiveAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
  receiveAntenna.set_feeder_loss(feeder_loss);
  receiveAntenna.set_noise_t(noise_t);
  
  % == Earth station
  
  % Identifier for station
  stationId = 'wanted';
  % Geodetic latitude [rad]
  % varphi
  % Longitude [rad]
  % lambda
  % Flag indicating whether to do multiplexing, or not
  doMultiplexing = 0;
  
  earthStation = EarthStation( ...
      stationId, transmitAntenna, receiveAntenna, emission, beam, ...
      varphi, lambda, doMultiplexing);
  
end % getWantedEarthSegment()
