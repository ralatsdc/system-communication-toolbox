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
classdef (Sealed = true) EarthConstants 
% Defines Earth physical constants.
  
  properties (Constant = true)
    
    % The radius of the Earth [km]
    R_oplus = 6378.137;
    % R_oplus = 6371.005076123;
    
    % The flattening of the Earth [-]
    f = 1.0 / 298.257223563;
    
    % The gravitational constant of the Earth [km^3/s^2]
    GM_oplus = 398600.4415;
    
    % The leading zonal harmonic coefficient [-]
    J_2 = 0.0010826269
    
    % The rotational period of the Earth [s]
    T_oplus = (360 / 360.9856473) * 86400;
    % [s] = ([deg/rev] / [deg/day]) * ([h/day] * [m/h] * [s/m])                                               
    
    % Greenwich hour angle intercept [rad]
    Theta_0 = 280.4606 * pi / 180;
    % [rad] = [deg] * [rad/deg]
    
    % Greenwich hour angle slope [rad/day]
    Theta_dot = 360.9856473 * pi / 180;
    % [rad/day] = [deg/day] * [rad/deg]
    
    % The period [s] and semi-major axis of a circular
    % geostationary orbit [er]
    T_gso = EarthConstants.T_oplus;
    a_gso = (EarthConstants.GM_oplus ...
             * (EarthConstants.T_gso / (2 * pi))^2)^(1/3) ...
            / EarthConstants.R_oplus
    % [er] = ([km^3/s^2] * ([s/rev] / [rad/rev])^2)^(1/3) / [km/er]
    
    % The period [s], semi-major axis [er], and inclination
    % [rad] of a circular GPS orbit
    T_gps = EarthConstants.T_oplus / 2;
    a_gps = (EarthConstants.GM_oplus ...
             * (EarthConstants.T_gps / (2 * pi))^2)^(1/3) ...
            / EarthConstants.R_oplus
    % [er] = ([km^3/s^2] * ([s/rev] / [rad/rev])^2)^(1/3) / [km/er]
    i_gps = 55 * pi / 180;
    
    % The period [s], semi-major axis [er], inclination [rad],
    % eccentricity, and argument of perigee of a Molniya orbit
    T_molniya = EarthConstants.T_oplus / 2;
    a_molniya = (EarthConstants.GM_oplus ...
                 * (EarthConstants.T_gps / (2 * pi))^2)^(1/3) ...
        / EarthConstants.R_oplus
    % [er] = ([km^3/s^2] * ([s/rev] / [rad/rev])^2)^(1/3) / [km/er]
    e_molniya = 0.75;
    i_molniya = 63.4 * pi / 180;
    omega_molniya = -90 * pi / 180;
    
  end % properties (Constant = true)
  
  methods (Static = true)
    
    function gha = Theta(dNm)
    % Computes the Greenwich hour angle. (MG-2.85)
    %
    % Parameters
    %   dNm - Date number at which the angle coincides
    %
    % Returns
    %   gha - Greenwich hour angle [rad]
      gha = (EarthConstants.Theta_0 + EarthConstants.Theta_dot ...
             * (dNm - datenum(2000, 1, 1, 12, 0, 0)));
      % [rad] = [rad] + [rad / day] * [decimal day]
      
    end % Theta()
    
  end % methods (Static = true)
  
end % classdef
