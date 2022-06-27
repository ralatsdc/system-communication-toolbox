% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

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
