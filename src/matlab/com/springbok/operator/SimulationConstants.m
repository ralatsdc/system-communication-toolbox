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
classdef (Sealed = true) SimulationConstants 
% Simulation constants.
  
  properties (Constant = true)
    
    precision_E = 1e-6;
    % The difference in successive values of eccentric anomaly at which
    % iterative solution of Kepler's equation ends.
    
    max_iteration = 10000;
    % The maximum number of iterations permitted in solving Kepler's
    % equation.
    
    precision_eta = 1e-9;  
    % The maximum number of iterations permitted in estimating the ratio
    % of the areas of the sector and triangle defined by the two position
    % vectors.
    
    decimal_delta = 1e-6;
    % Differential modification of each property of the orbit used in
    % computing the elements of the Jacobian matrix.
    
    max_time_diff = 1.0; % [s]
    % Maximum difference between the preliminary orbit and the
    % corrected orbit
    
  end % properties (Constant = true)
  
end % classdef
