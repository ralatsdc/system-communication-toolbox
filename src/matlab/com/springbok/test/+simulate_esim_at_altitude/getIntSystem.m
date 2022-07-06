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
function [interferingSystem, interferingEarthStations, interferingSpaceStations] = getIntSystem(h_start, baseStation)
% Defines the interfering LEO system.
%
% Parameters
%   h_start - Altitude at the ESIM track start [km]
%   baseStation - The base station of the wanted terrestrial system
%
% Returns
%   interferingSystem - The interfering LEO system
%   interferingEarthStations - The Earth stations of the interfering
%     LEO system
%   interferingSpaceStations - The space stations of the interfering
%     LEO system

  % Define the interfering system

  interferingEarthStations = simulate_esim_at_altitude.getIntLeoEarthSegment(h_start, baseStation);

  epoch_0 = interferingEarthStations.dNm_s(1);  % Use the start of the track

  interferingSpaceStations = simulate_esim_at_altitude.getIntLeoSpaceSegment(epoch_0);

  losses = {};

  interferingSystem = System( ...
      interferingEarthStations, interferingSpaceStations, losses, epoch_0, ...
      'TestAngleFromGsoArc', 1, 'AngleFromGsoArc', 10, ...
      'TestAngleFromZenith', 1, 'AngleFromZenith', 55);

end % getSystems()
