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
classdef TwoBodyOrbit < Orbit
% Defines methods required to describe a two-body orbit using
% either Keplerian or Equinoctial elements and two-body
% propagation.
  
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
