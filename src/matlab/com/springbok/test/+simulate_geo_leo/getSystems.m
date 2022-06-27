% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function [wantedSystem, interferingSystem] = getSystems()
% Defines the wanted GSO and interfering LEO systems
  
  % Assign simulation constants
  
  epoch_0 = datenum(2014, 10, 20, 19, 5, 0); % Epoch date number
  
  % Define the wanted system
  
  wantedSpaceStation = example.getWntGsoSpaceSegment(epoch_0);
  wantedEarthStation = example.getWntGsoEarthSegment(wantedSpaceStation);
  
  losses = {};
  
  wantedSystem = System(wantedEarthStation, wantedSpaceStation, ...
                        losses, epoch_0, 'testAngleFromGsoArc', 0);
  
  % Define the interfering system
  
  interferingSpaceStations = example.getIntLeoSpaceSegment(epoch_0);
  interferingEarthStations = example.getIntLeoEarthSegment(wantedSpaceStation);
  
  losses = {};
  
  interferingSystem = System(interferingEarthStations, interferingSpaceStations, ...
                             losses, epoch_0);
  
end % getSystems()
