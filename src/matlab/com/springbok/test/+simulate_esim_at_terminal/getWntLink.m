% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

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

  % Define the wanted link

  userEquipment = simulate_esim_at_terminal.getWntTerUserEquipment();  % Transmit station
  baseStation = simulate_esim_at_terminal.getWntTerBaseStation();  % Receive station

  losses = {'fuselage-loss'};

  wantedUserEquipmentLink = Link(baseStation, baseStation.beam, userEquipment, losses, 'doCheck', doCheck);
  wantedBaseStationLink = Link(userEquipment, userEquipment.beam, baseStation, losses, 'doCheck', doCheck);

end % getWntLink()
