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
function earthStations = getIntLeoEarthSegment(spaceStation)
% Defines the interfering LEO Earth segments.
%
% Parameters
%   spaceStation - The space station of the wanted GSO system
%
% Returns
%   earthStations - The Earth stations of the interfering LEO system
  
  % = Interfering system
    
  % == Earth stations
  
  % === Transmit pattern

  % Maximum antenna gain [dB]
  GainMax = 54;
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
  
  % Gain function options
  options = {'DoValidate', false};
  transmitAntenna.set_options(options);

  % === Emission
  
  % Emission designator
  design_emi = '1K20G1D--';
  % Maximum power density
  pwr_ds_max = -74;
  % Minimum power density
  pwr_ds_min = NaN;
  % Center frequency
  freq_mhz = 13000;
  % Required C/N
  c_to_n = NaN;
  
  emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);
  
  % === Receive pattern
  
  % Maximum antenna gain [dB]
  GainMax = 27;
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
  noise_t = 440;
  % Antenna pattern identifier
  pattern_id = 1;
  
  % Receive Earth station antenna
  receiveAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
  receiveAntenna.set_feeder_loss(feeder_loss);
  receiveAntenna.set_noise_t(noise_t);
  
  % Gain function options
  options = {'DoValidate', false};
  receiveAntenna.set_options(options);

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
  
  lla = Coordinates.gei2lla( ...
      spaceStation.orbit.r_gei( ...
          spaceStation.orbit.epoch), spaceStation.orbit.epoch);

  stationId      = 'wanted'; % Identifier for station
  varphi         = 0;        % Geodetic latitude [rad]
  lambda         = lla(2);   % Longitude [rad]
  doMultiplexing = 0;        % Flag indicating whether to do multiplexing, or not
  
  earthStations = [];
  d_angle = 12;
  for d_varphi = ([0 : d_angle : 24] - d_angle) * (pi / 180)
    for d_lambda = ([0 : d_angle : 60] - d_angle) * (pi / 180)

      % === Beam
  
      beam = Beam('IntLeoEarthSegment', 1, 100);
  
      % == Earth stations

      earthStations = [earthStations; EarthStation( ...
          stationId, transmitAntenna, receiveAntenna, emission, beam, ...
          varphi + d_varphi, lambda + d_lambda, doMultiplexing)];
      
    end % for
    
  end % for

end % getLeoEarthSegment()
