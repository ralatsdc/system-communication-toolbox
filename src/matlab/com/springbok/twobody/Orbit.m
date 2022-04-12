classdef Orbit < handle
% Defines methods required to describe an orbit using either
% Keplerian or Equinoctial elements, and two-body or SGP4
% propagation.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  methods (Abstract = true)
    
    n = meanMotion(this)
    % Computes mean motion.
    %
    % Returns
    %   n - Mean motion [rad/s]
    
    T = orbitalPeriod(this)
    % Computes orbital period.
    %
    % Returns
    %   T - Orbital period [s]
    
    r_gei = r_gei(this, dNm)
    % Computes geocentric equatorial inertial position vector.
    %
    % Parameters
    %   date - Date number at which the position vector occurs
    %
    % Returns
    %   r_gei - Geocentric equatorial inertial position vector [er]
    
    is = isEmpty(this)
    % Determines if orbit properties are empty, or not.
    
  end % methods (Abstract = true)
  
end % classdef
