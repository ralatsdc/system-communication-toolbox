classdef (Sealed = true) SimulationConstants 
% Simulation constants.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

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
