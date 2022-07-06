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
function [wantedSystem, interferingSystem] = getSystems()
% Defines the wanted GSO and interfering LEO systems

  % Assign simulation constants

  epoch_0 = datenum(2014, 10, 20, 19, 5, 0); % Epoch date number
  
  % Define the wanted system
  
  wantedSpaceStation = define_gso_leo.getWntGsoSpaceSegment(epoch_0);
  wantedEarthStation = define_gso_leo.getWntGsoEarthSegment(wantedSpaceStation);
  
  losses = {};
  
  wantedSystem = System(wantedEarthStation, wantedSpaceStation, ...
                        losses, epoch_0, 'testAngleFromGsoArc', 0);
  
  % Define the interfering system
  
  interferingSpaceStations = define_gso_leo.getIntLeoSpaceSegment(epoch_0);
  interferingEarthStations = define_gso_leo.getIntLeoEarthSegment(wantedSpaceStation);
  
  losses = {};
  
  interferingSystem = System(interferingEarthStations, interferingSpaceStations, ...
                             losses, epoch_0);
  
end % getSystems()
