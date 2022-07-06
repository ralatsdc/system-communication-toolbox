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
function spaceStations = getIntLeoSpaceSegment(epoch_0)
% Defines the interfering LEO space segments.
%
% Parameters
%   epoch_0 - The epoch of the space station orbits
%
% Returns
%   spaceStations - The space stations of the interfering LEO system
  
  % == Space stations
  
  % === Transmit Pattern
  
  % Maximum antenna gain [dB]
  GainMax = 27;
  % Cross-sectional half-power beamwidth, degrees
  Phi0 = 6.9;
  
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
  noise_t = 600;
  % Antenna pattern identifier
  pattern_id = 1;
  
  % Receive space station antenna
  receiveAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);
  receiveAntenna.set_feeder_loss(feeder_loss);
  receiveAntenna.set_noise_t(noise_t);

  % Gain function options
  options = {'GainMax', GainMax};
  receiveAntenna.set_options(options);
  
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
  
  spaceStations = [];
  d_angle = 24;
  iBm = 0;
  for d_Omega = [0 : d_angle : 360 - d_angle] * (pi / 180)
    for d_omega = [0 : d_angle : 360 - d_angle] * (pi / 180)

      % === Beam
  
      iBm = iBm + 1;
      beam = Beam(sprintf('IntLeoSpaceSegment-%d', iBm), 1, 100);
  
      % == Space stations

      spaceStations = [spaceStations; SpaceStation( ...
          stationId, transmitAntenna, receiveAntenna, emission, beam, ...
          KeplerianOrbit(a, e, i, Omega + d_Omega, omega + d_omega, M, epoch, method))];
      
    end % for
    
  end % for

end % getLeoSpaceSegment()
