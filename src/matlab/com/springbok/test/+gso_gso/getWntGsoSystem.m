% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function system = getWntGsoSystem()
  
  % == Simulation constants

  % Date near reference where Greenwich hour angle is zero
  epoch_0 = datenum(2000, 1, 1, 12, 0, 0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot;
  % [decimal day] = [decimal day] - [rad] / [rad / day]

  % = Wanted system
  
  % == Space station
  
  spaceStation = gso_gso.getWntGsoSpaceSegment(epoch_0);
  
  % == Earth station
  
  lla = Coordinates.gei2lla( ...
      spaceStation.orbit.r_gei( ...
          spaceStation.orbit.epoch), spaceStation.orbit.epoch);

  varphi = 10.0 * pi / 180; % Geodetic latitude [rad]
  lambda = lla(2);          % Longitude [rad]
  
  earthStation = gso_gso.getWntGsoEarthSegment(varphi, lambda);
  
  % = Wanted system
  
  losses = {};
  
  system = System(earthStation, spaceStation, losses, ...
                  epoch_0, 'testAngleFromGsoArc', 0);
  
end % getWantedSystem()
