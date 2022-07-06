% Copyright (C) 2022 Springbok LLC
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or (at
% your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
% 
function earthStation = getWntGsoEarthSegment(spaceStation)
% Defines the wanted GSO Earth segment.
%
% Parameters
%   spaceStation - the space station of the wanted GSO system
%
% Returns
%   earthStation - the Earth station of the wanted GSO system
  
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
  
  beam = Beam('WntGsoEarthSegment', 1, 100);
  
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
  pattern_id = 1;
  
  % Receive Earth station antenna
  receiveAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
  receiveAntenna.set_feeder_loss(feeder_loss);
  receiveAntenna.set_noise_t(noise_t);
  
  % == Earth station
  
  lla = Coordinates.gei2lla( ...
      spaceStation.orbit.r_gei( ...
          spaceStation.orbit.epoch), spaceStation.orbit.epoch);
  
  stationId      = 'wanted'; % Identifier for station
  varphi         = 0;        % Geodetic latitude [rad]
  lambda         = lla(2);   % Longitude [rad]
  doMultiplexing = 0;        % Flag indicating whether to do multiplexing, or not
  
  earthStation = EarthStation( ...
      stationId, transmitAntenna, receiveAntenna, emission, beam, ...
      varphi, lambda, doMultiplexing);
  
end % getGeoEarthSegment()
