% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function system = getIntGsoSystem()
  
  % == Simulation constants

  % Date near reference where Greenwich hour angle is zero
  epoch_0 = datenum(2000, 1, 1, 12, 0, 0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot;
  % [decimal day] = [decimal day] - [rad] / [rad / day]

  % = Interfering system
  
  % == Space station
  
  spaceStation = gso_gso.getIntGsoSpaceSegment(epoch_0);
  
  % == Earth station
  
  lla = Coordinates.gei2lla( ...
      spaceStation.orbit.r_gei( ...
          spaceStation.orbit.epoch), spaceStation.orbit.epoch);

  varphi = 20.0 * pi / 180; % Geodetic latitude [rad]
  lambda = lla(2);          % Longitude [rad]
  
  earthStation = gso_gso.getIntGsoEarthSegment(varphi, lambda);
  
  % = Interfering system
  
  losses = {};
  
  system = System(earthStation, spaceStation, losses, ...
                  epoch_0, 'testAngleFromGsoArc', 0);
  
end % getInterferingSystem()
