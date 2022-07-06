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
function [wantedUserEquipmentLink, wantedBaseStationLink, userEquipment, baseStation] = getWntLink(doCheck)
% Defines the wanted user equipment and base stations and
% corresponding links of the terrestrial network.
%
% Parmaters
%   doCheck - Flag to perform additional input validity checks
%
% Returns
%   wantedUserEquipmentLink - Wanted user equipment link
%   wantedBaseStationLink - Wanted base station link
%   userEquipment - The user equipment of the wanted terrestrial
%     network
%   baseStation - The wanted base station of the terrestrial network

  % Define the wanted user equipment and base station
  userEquipment = simulate_esim_at_altitude.getWntTerUserEquipment();  % Transmit station
  baseStation = simulate_esim_at_altitude.getWntTerBaseStation();  % Receive station

  % Define the links of the terrestrial network
  losses = {'fuselage-loss'};
  wantedUserEquipmentLink = Link(baseStation, baseStation.beam, userEquipment, losses, 'doCheck', doCheck);
  wantedBaseStationLink = Link(userEquipment, userEquipment.beam, baseStation, losses, 'doCheck', doCheck);

end % getWntLink()
