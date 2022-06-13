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
classdef Orbit < handle
% Defines methods required to describe an orbit using either
% Keplerian or Equinoctial elements, and two-body or SGP4
% propagation.
  
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
