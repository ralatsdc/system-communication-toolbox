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
classdef (Sealed = true) Coordinates
% Provides transformations between coordinate systems following Satellite
% Orbits by Montenbruck and Gill.
  
  methods (Static = true)
    
    function R_Matrix = R_x(phi)
    % Computes orthogonal transformation matrix for a rotation about
    % the x axis. (MG-p.27)
    % 
    % Note that for all transformation matrices, a positive phi
    % corresponds to a positive (counterclockwise) rotation of the
    % reference axes as viewed from the positive end of the rotation
    % axis toward the origin.
    %
    % Parameters
    %   phi - Angle of rotation [rad]
    % 
    % Returns
    %   R_Matrix - Orthogonal transformation matrix

      R_Matrix = [1,         0,         0; ...
                  0, +cos(phi), +sin(phi); ...
                  0, -sin(phi), +cos(phi)];
      
    end % R_x()
    
    function R_Matrix = R_y(phi)
    % Computes orthogonal transformation matrix for a rotation about
    % the y axis. (MG-p.27)
    %
    % Parameters
    %   phi - Angle of rotation [rad]
    % 
    % Returns
    %   R_Matrix - Orthogonal transformation matrix

      R_Matrix = [+cos(phi), 0, -sin(phi); ...
                  0,         1,         0; ...
                  +sin(phi), 0, +cos(phi)];
      
    end % R_y()
    
    function R_Matrix = R_z(phi)
    % Computes orthogonal transformation matrix for a rotation about
    % the z axis. (MG-p.27)
    %
    % Parameters
    %   phi - Angle of rotation [rad]
    % 
    % Returns
    %   R_Matrix - Orthogonal transformation matrix

      persistent last_phi
      persistent last_R_Matrix

      if ~isequal(phi, last_phi)
        last_phi = phi;
        last_R_Matrix = [+cos(phi), +sin(phi), 0; ...
                         -sin(phi), +cos(phi), 0; ...
                         0,         0,         1];

      end % if
      R_Matrix = last_R_Matrix;
      
    end % R_z()
    
    function E_Matrix = E_e2t(earthStation)
    % Computes the orthogonal transformation matrix from geocentric
    % equatorial rotating coordinates to local tangent coordinates
    % for a given Earth station. (MG-2.93)
    %
    % Parameters
    %   earthStation - Earth station at which position vectors apply
    %
    % Returns
    %   E_Matrix - Orthogonal transformation matrix

      persistent last_earthStation
      persistent last_E_Matrix
      
      if ~isequal(earthStation, last_earthStation)
        last_earthStation = earthStation;
        last_E_Matrix = [Coordinates.e_E(earthStation), ...
                         Coordinates.e_N(earthStation), ...
                         Coordinates.e_Z(earthStation)]';

      end % if
      E_Matrix = last_E_Matrix;
      
    end % E_e2t()
    
    function E_Matrix = E_t2e(earthStation)
    % Computes the orthogonal transformation matrix from local
    % tangent coordinates to geocentric equatorial rotating
    % coordinates for a given Earth station. (MG-2.93)
    %
    % Parameters
    %   earthStation - Earth station at which position vectors apply
    %
    % Returns
    %   E_Matrix - Orthogonal transformation matrix

      E_Matrix = Coordinates.E_e2t(earthStation)';
      
    end % E_t2e()
    
    function [r_ger, v_ger] = gei2ger(r_gei, dNm, v_gei)
    % Computes the geocentric equatorial rotating position and
    % velocity vectors of a satellite given the geocentric
    % equatorial inertial position and velocity vectors at a
    % date. (MG-2.89)
    %
    % Parameters
    %   r_gei - Geocentric equatorial inertial position vector [er]
    %   v_gei - Geocentric equatorial inertial velocity vector [er/s]
    %   dNm - Date number at which the position vectors occur
    %
    % Returns
    %   r_ger - Geocentric equatorial rotating position vector [er]
    %   v_ger - Geocentric equatorial rotating velocity vector [er/s]
      Theta = EarthConstants.Theta(dNm);
      R_z = Coordinates.R_z(Theta);
      r_ger = R_z * r_gei;
      % [er]
      if nargin == 3
        R_z_dot = [-sin(Theta), +cos(Theta), 0; ...
                   -cos(Theta), -sin(Theta), 0; ...
                   0,                     0, 0] * EarthConstants.Theta_dot / 86400;
        % [rad/s]
        v_ger = R_z * v_gei + R_z_dot * r_gei;
        % [er/s] = [er/s] + [er] * [rad/day] * [day/s]
      else
        v_ger = [];
      end % if
      
    end % gei2ger()
    
    function [r_gei, v_gei] = ger2gei(r_ger, dNm, v_ger)
    % Computes the geocentric equatorial inertial position and
    % velocity vectors of a satellite given the geocentric
    % equatorial rotating position and velocity vectors at a
    % date. (MG-2.89)
    %
    % Parameters
    %   r_ger - Geocentric equatorial rotating position vector [er]
    %   v_ger - Geocentric equatorial rotating velocity vector [er/s]
    %   dNm - Date number at which the position vectors occur
    %
    % Returns
    %   r_gei - Geocentric equatorial inertial position vector [er]
    %   v_gei - Geocentric equatorial inertial velocity vector [er/s]
      Theta = EarthConstants.Theta(dNm);
      R_z = Coordinates.R_z(Theta);
      r_gei = R_z' * r_ger;
      % [er]
      if nargin == 3
        R_z_dot = [-sin(Theta), +cos(Theta), 0; ...
                   -cos(Theta), -sin(Theta), 0; ...
                   0,                     0, 0] * EarthConstants.Theta_dot / 86400;
        % [rad/s]
        v_gei = R_z' * v_ger + R_z_dot' * r_ger;
        % [er/s] = [er/s] + [er] * [rad/day] * [day/s]
      else
        v_gei = [];
      end % if
      
    end % ger2gei()
    
    function r_lla = gei2lla(r_gei, dNm)
    % Computes the geocentric latitude, longitude, and altitude of a
    % satellite given the geocentric equatorial inertial position
    % vector at a date. (Inverse of MG-2.90 modified for arbitrary
    % altitude, See also MG-5.88)
    %
    % Parameters
    %   r_gei - Geocentric equatorial inertial position vector [er]
    %   dNm - Date number at which the position vectors occur
    %
    % Returns
    %   r_lla - Geocentric latitude, longitude, and altitude [rad, rad, er]
      
    % Compute the Earth fixed geocentric equatorial position
    % vector in Earth radii of a satellite
      r_ger = Coordinates.gei2ger(r_gei, dNm);
      
      % Compute the latitude and longitude in radians, and altitude
      % in Earth radii of a satellite
      lat = atan2(r_ger(3), sqrt(r_ger(1)^2 + r_ger(2)^2)); % (-pi, pi)
      lon = Coordinates.check_wrap(atan2(r_ger(2), r_ger(1))); % (0, 2 * pi)
      alt = sqrt(r_ger(1)^2 + r_ger(2)^2 + r_ger(3)^2) - 1;
      
      r_lla = [lat; ...
               lon; ...
               alt];
      
    end % gei2lla()
    
    function r_gei = lla2gei(r_lla, dNm)
    % Computes the geocentric equatorial inertial position vector
    % given the geocentric latitude, longitude, and altitude of a satellite at a
    % date. (MG-2.90 modified for arbitrary altitude)
    %
    % Parameters
    %   r_lla - Geocentric latitude, longitude, and altitude [rad, rad, er]
    %   dNm - Date number at which the position vectors occur
    %
    % Returns
    %   r_gei - Geocentric equatorial inertial position vector [er]

      R = 1 + r_lla(3);
      x = R * cos(r_lla(1)) * cos(r_lla(2));
      y = R * cos(r_lla(1)) * sin(r_lla(2));
      z = R * sin(r_lla(1));
      r_ger = [x; ...
               y; ...
               z];
      r_gei = Coordinates.ger2gei(r_ger, dNm);
      
    end % lla2gei()

    function r_ger = glla2ger(r_glla)
    % Computes the geocentric equatorial rotating position vector
    % given the geodetic latitude, longitude, and altitude of a
    % satellite date. (MG-5.83)
    %
    % Parameters
    %   r_glla - Geodetic latitude, longitude, and altitude [rad, rad, er]
    %
    % Returns
    %   r_ger - Geocentric equatorial rotating position vector [er]

      varphi = r_glla(1);
      lambda = r_glla(2);
      h = r_glla(3);
      N = 1.0 ...
          / sqrt(1 - EarthConstants.f * (2 - EarthConstants.f) * sin(varphi)^2);
      r_ger = [(N + h) * cos(varphi) * cos(lambda); ...
               (N + h) * cos(varphi) * sin(lambda); ...
               ((1.0 - EarthConstants.f)^2 * N + h) * sin(varphi)];

    end % glla2ger()

    function r_ltp = gei2ltp(r_gei, earthStation, dNm)
    % Computes the local tangent position vector of a satellite
    % observed by an Earth station given the geocentric equatorial inertial
    % position vector at a date. (MG-2.94)
    %
    % Parameters
    %   r_gei - Geocentric equatorial inertial position vector [er]
    %   earthStation - Earth station at which position vectors apply
    %   dNm - Date number at which the position vectors occur
    % 
    % Returns
    %   r_ltp - Local tangent position vector [er]

      r_ltp = Coordinates.E_e2t(earthStation) ...
              * (Coordinates.R_z(EarthConstants.Theta(dNm)) * r_gei - earthStation.compute_r_ger(dNm));
      
    end % gei2ltp()
    
    function r_rae = ltp2rae(r_ltp)
    % Computes the range, azimuth, and elevation of a satellite given
    % the local tangent position vector. (MG-2.95)
    %
    % Parameters
    %   r_ltp - Local tangent position vector [er]
    %
    % Returns
    %   r_rae - Range, azimuth, and elevation [er, rad, rad]

      rng = sqrt(r_ltp' * r_ltp);
      azm = Coordinates.check_wrap(atan2(r_ltp(1),  r_ltp(2))); % (0, 2 * pi)
      elv = atan2(r_ltp(3), sqrt(r_ltp(1:2)' * r_ltp(1:2))); % (-pi, pi)
      r_rae = [rng; ...
               azm; ...
               elv];
      
    end % ltp2rae()
    
    function r_ltp = rae2ltp(r_rae)
    % Computes the local tangent position vector of a satellite given
    % range, azimuth, and elevation. (Inverse of MG-2.95)
    %
    % Parameters
    %   r_rae - Range, azimuth, and elevation [er, rad, rad]
    %
    % Returns
    %   r_ltp - Local tangent position vector [er]

      rng = r_rae(1);
      azm = r_rae(2);
      elv = r_rae(3);
      r_ltp = rng * [cos(elv) * sin(azm); ...
                     cos(elv) * cos(azm); ...
                     sin(elv)];
      
    end % rae2ltp()
    
    function r_gei = ltp2gei(r_ltp, earthStation, dNm)
    % Computes the geocentric equatorial inertial position vector of a
    % satellite given the local tangent position vector observed at a
    % date by a given Earth station. (Inverse of MG-2.94)
    %
    % Parameters
    %   r_ltp - Local tangent position vector [er]
    %   earthStation - Earth station at which position vectors apply
    %   dNm - Date number at which the position vectors occur
    %
    % Returns
    %   r_gei - Geocentric equatorial inertial position vector [er]

      r_gei = Coordinates.R_z(EarthConstants.Theta(dNm))' ...
              * (Coordinates.E_t2e(earthStation) * r_ltp + earthStation.compute_r_ger(dNm));
      
    end % ltp2gei()
    
    function phi = check_wrap(phi)
    % Ensures the angle phi lies within the interval (0, 2 * pi).
    %
    % Parameters
    %   phi - Angle [rad]
    %
    % Returns
    %   phi - Angle in the interval (0, 2 * pi) [rad]

      nPhi = length(phi);
      for iPhi = 1:nPhi
        if phi(iPhi) > 2 * pi
          % Preserve sign
          phi(iPhi) = rem(phi(iPhi), 2 * pi);
          
        elseif phi(iPhi) < 0
          phi(iPhi) = rem(phi(iPhi), 2 * pi) + 2 * pi;
          
        end % if
        
      end % for
      
    end % check_wrap()
    
    function c = cross(a, b)
    % Computes the cross product of two vectors.
    %
    % Parameters
    %   a - Column vector
    %   b - Column vector
    %
    % Returns
    %   c - a x b, Column vector
    %
    % MATLAB provided function.
    end % cross()
    
  end % methods (Static = true)
  
  methods (Static = true, Access = private)
    
    function e_Vector = e_E(earthStation)
    % Computes the East unit vector in geocentric equatorial rotating
    % coordinates for a given Earth station. (MG-2.92)
    %
    % Parameters
    %   earthStation - Earth station at which the unit vector applies
    %
    % Returns
    %   e_Vector - Orthogonal transformation matrix

      e_Vector = [-sin(earthStation.lambda); ...
                  +cos(earthStation.lambda); ...
                  0];
      
    end % e_E()
    
    function n_Vector = e_N(earthStation)
    % Computes the North unit vector in geocentric equatorial
    % rotating coordinates for a given Earth station. (MG-2.92)
    %
    % Parameters
    %   earthStation - Earth station at which the unit vector applies
    %
    % Returns
    %   n_Vector - Unit vector

      n_Vector = [-sin(earthStation.varphi) * cos(earthStation.lambda); ...
                  -sin(earthStation.varphi) * sin(earthStation.lambda); ...
                  +cos(earthStation.varphi)];
      
    end % e_N()
    
    function z_Vector = e_Z(earthStation)
    % Computes the Zenith unit vector in geocentric equatorial
    % rotating coordinates for a given Earth station. (MG-2.92)
    %
    % Parameters
    %   earthStation - Earth station at which the unit vector applies
    %
    % Returns
    %   z_Vector - Unit vector

      z_Vector = [+cos(earthStation.varphi) * cos(earthStation.lambda); ...
                  +cos(earthStation.varphi) * sin(earthStation.lambda); ...
                  +sin(earthStation.varphi)];
      
    end % e_Z()
    
  end % methods (Static = true, Access = private)
  
end % classdef
