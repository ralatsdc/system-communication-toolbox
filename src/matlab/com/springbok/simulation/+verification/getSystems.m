% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function [wantedSystem, interferingSystem] = getSystems(orbits, cells, epoch_0)

  % Get the wanted stations
  wantedSpaceStation = verification.getGsoSpaceSegment(epoch_0);
  wantedEarthStation = verification.getGsoEarthSegment(wantedSpaceStation);

  % Construct the wanted system
  losses = {};
  wantedSystem = System(wantedEarthStation, ...
                        wantedSpaceStation, ...
                        losses, epoch_0, ...
                        'testAngleFromGsoArc', 0);
    
  % Get the interfering stations
  [interferingSpaceStations] = verification.getLeoSpaceSegment(orbits);
  [interferingEarthStations] = verification.getLeoEarthSegment(cells, epoch_0);

  % Construct the interfering system
  losses = {};
  interferingSystem = System(interferingEarthStations, ...
                             interferingSpaceStations, ...
                             losses, epoch_0);

end % getSystems()
