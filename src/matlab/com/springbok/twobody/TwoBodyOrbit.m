classdef TwoBodyOrbit < Orbit
% Defines methods required to describe a two-body orbit using
% either Keplerian or Equinoctial elements and two-body
% propagation.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    % The difference in successive values of eccentric anomaly at
    % which iterative solution of Kepler's equation ends.
    precision_E = 1e-6;
    
    % The maximum number of iterations permitted in solving Kepler's
    % equation.
    max_iteration = 10000;
    
  end % properties (Constant = true)
  
  methods (Abstract = true)
    
    MP = meanPosition(this, dNm)
    % Computes mean position at the given date.
    %
    % Parameters
    %   date - Date number at which mean position occurs
    %
    % Returns
    %   MP - Mean position (anomaly or longitude) [rad]
    
    EP = keplersEquation(this, MP)
    % Solves conventional or generalized Kepler's equation using
    % Newton's or Halley's method for the eccentric position.
    %
    % Parameters
    %   MP - Mean position (anomaly or longitude) [rad]
    %
    % Returns
    %   EP - Eccentric position (anomaly or longitude) [rad]
    
    r_goi = r_goi(this, EP)
    % Computes orbital plane inertial position vector.
    %
    % Parameters
    %   EP - Eccentric position (anomaly or longitude) [rad]
    %
    % Returns
    %   r_goi - Orbital plane inertial position vector [er]
    
    is = isEmpty(this)
    % Determines if orbit properties are empty, or not.
    
  end % methods (Abstract = true)
  
end % classdef
