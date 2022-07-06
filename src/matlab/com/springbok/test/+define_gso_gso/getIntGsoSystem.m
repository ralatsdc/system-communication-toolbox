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
function system = getIntGsoSystem()
% Defines the interfering GSO system
%
% Returns
%   system - The interfering GSO system
  
  % == Simulation constants

  % Date near reference where Greenwich hour angle is zero
  epoch_0 = datenum(2000, 1, 1, 12, 0, 0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot;
  % [decimal day] = [decimal day] - [rad] / [rad / day]

  % = Interfering system
  
  % == Space station
  
  spaceStation = define_gso_gso.getIntGsoSpaceSegment(epoch_0);
  
  % == Earth station
  
  lla = Coordinates.gei2lla( ...
      spaceStation.orbit.r_gei( ...
          spaceStation.orbit.epoch), spaceStation.orbit.epoch);

  varphi = 20.0 * pi / 180; % Geodetic latitude [rad]
  lambda = lla(2);          % Longitude [rad]
  
  earthStation = define_gso_gso.getIntGsoEarthSegment(varphi, lambda);
  
  % = Interfering system
  
  losses = {};
  
  system = System(earthStation, spaceStation, losses, ...
                  epoch_0, 'testAngleFromGsoArc', 0);
  
end % getInterferingSystem()
