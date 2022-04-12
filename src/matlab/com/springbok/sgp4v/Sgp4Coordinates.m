classdef (Sealed = true) Sgp4Coordinates
% Provides transformations between coordinate systems. The
% following acronyms are used:
%   TEMED - True Equator Mean Equinox of Date (Earth Centered,
%      precession and less accurate nutation modeled)
%   TETED - True Equator True Equinox of Date (Earth Centered,
%     precession and more accurate nutation modeled)
%   CIRS - Celestial Intermediate Reference System (Earth
%     Centered, precession and more accurate nutation modeled)
%   TIRS - Terrestrial Intermediate Reference System (Earth
%     Centered and fixed, precession and more accurate nutation
%     modeled)
%   ITRS - International Terrestrial Reference System (Earth
%     Centered and fixed, precession, more accurate nutation,
%     and polar motion modeled)
%   SEZ - South–East–Zenith
% See doc/matlab/com/synterein/sgp4v/Time-Space-Coordinate-Conventions.pdf.
% 
% Author: Raymond LeClair
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  methods (Static = true)
    
    function r_ltp = gei2ltp(r_gei, sensor, dNm)
    % Computes the local tangent position vector of a satellite
    % observed by a sensor given the geocentric equatorial
    % inertial position vector at a date.
    % 
    % Parameters
    %   r_gei - Geocentric equatorial inertial position vector [er]
    %   sensor - Sensor at which position vectors apply
    %   dNm -Date number at which the position vectors occur
    %
    % Returns
    %   r_ltp - Local tangent position vector [er]
      [y, m, d, H, M, S] = datevec(dNm);
      mjd = TimeUtility.date2mjd(y, m, d, H, M, S);
      TEMED = r_gei; % Returned by SGP4
      TETED = TEMED; % Ignores difference due to less
                     % accurate nutation model
      CIRS = Sgp4Coordinates.TETEDToCIRS(mjd, TETED);
      TIRS = Sgp4Coordinates.CIRSToTIRS(mjd, CIRS);
      ITRS = TIRS; % Ignores polar motion
      ITRS_0 = sensor.R_ger();
      geodetic_latitude = sensor.varphi;
      longitude = sensor.lambda;
      SEZ = Sgp4Coordinates.ITRSToSEZ(ITRS, ITRS_0, geodetic_latitude, longitude);
      r_ltp = Coordinates.R_z(pi / 2.0) * SEZ;
      
    end % gei2ltp
    
    function CIRS = TETEDToCIRS(mjd, TETED)
    % Converts TETED to CIRS.
    % 
    % Parameters
    %   mjd - Modified Julian day
    %   TETED - Position vector in the True Equator True Equinox of
    %     Date coordinate system (Earth Centered, precession and
    %     more accurate nutation modeled)
    %
    % Returns
    %   CIRS - Position vector in the Celestial Intermediate
    %     Reference System (Earth Centered, precession and more
    %     accurate nutation modeled)
      T = (mjd - 51544.5) / 36525.0;
      epsilon = (pi / (180.0 * 3600.0)) ...
                * (-0.014506 - 4612.156534 * T - 1.3915817 * T^2 ...
                   + 0.00000044 * T^3 + 0.000029956 * T^4 + 0.0000000368 * T^5);
      CIRS = Coordinates.R_z(-epsilon) * TETED;
      
    end % TETEDToCIRS
    
    function TIRS = CIRSToTIRS(mjd, CIRS)
    % Converts CIRS to TIRS
    % 
    % Parameters
    %   mjd - Modified Julian day
    %   CIRS - Position vector in the Celestial Intermediate
    %     Reference System (Earth Centered, precession and more
    %     accurate nutation modeled)
    %
    % Returns
    %   TIRS - Position vector Terrestrial Intermediate Reference
    %     System  Earth Centered and fixed, precession and more
    %     accurate nutation modeled)
      
      T = mjd - 51544.5;
      angle = 2 * pi * (0.7790572732640 + 1.00273781191135448 * T);
      TIRS = Coordinates.R_z(angle) * CIRS;
      
    end % CIRSToTIRS
    
    function SEZ = ITRSToSEZ(ITRS, ITRS_0, geodetic_latitude, longitude)
    % Converts ITRS to SEZ.
    % 
    % Parameters
    %   ITRS - Position vector in the International Terrestrial
    %     Reference System Earth Centered and fixed, precession, more
    %     accurate nutation, and polar motion modeled)
    %   ITRS_0 - Site position vector in the International
    %     Terrestrial Reference System (Earth Centered and fixed,
    %     precession, more accurate nutation, and polar motion
    %     modeled)
    %   geodetic_latitude - Site geodetic latitude [rad]
    %   longitude - Site longitude [rad]
    %
    % Returns
    %   SEZ - Position vector in the South–East–Zenith coordinate
    %     system
      X1 = ITRS - ITRS_0;
      X2 = Coordinates.R_z(longitude) * X1;
      SEZ = Coordinates.R_y(pi / 2 - geodetic_latitude) * X2;
      
    end % ITRSToSEZ
    
    function ITRS = SEZToITRS(SEZ, ITRS_0, geodetic_latitude, longitude)
    % Converts SEZ to ITRS.
    % 
    % Parameters
    %   SEZ - Position vector in the South–East–Zenith coordinate
    %     system
    %   ITRS_0 - Site position vector in the International
    %     Terrestrial Reference System (Earth Centered and fixed,
    %     precession, more accurate nutation, and polar motion
    %     modeled)
    %   geodetic_latitude - Site geodetic latitude [rad]
    %   longitude - Site longitude [rad]
    %
    % Returns
    %   ITRS - Position vector in the International Terrestrial
    %     Reference System Earth Centered and fixed, precession, more
    %     accurate nutation, and polar motion modeled)
      X1 = Coordinates.R_y(geodetic_latitude - pi / 2.0) * SEZ;
      X2 = Coordinates.R_z(-longitude) * X1;
      ITRS = X2 + ITRS_0;
      
    end % SEZToITRS                
    
    function CIRS = TIRSToCIRS(mjd, TIRS)
    % Converts CIRS to TIRS
    % 
    % Parameters
    %   mjd - Modified Julian day
    %   TIRS - Position vector in the Terrestrial Intermediate
    %     Reference System Earth Centered and fixed, precession and
    %     more accurate nutation modeled)
    %
    % Returns
    %   CIRS - Position vector in the Celestial Intermediate
    %     Reference System (Earth Centered, precession and more
    %     accurate nutation modeled)
      T = mjd - 51544.5;
      angle = 2.0 * pi * (0.7790572732640 + 1.00273781191135448 * T);
      CIRS = Coordinates.R_z(-angle) * TIRS;
      
    end % TIRSToCIRS
    
    function TETED = CIRSToTETED(mjd, CIRS)
    % Converts TETED to CIRS.
    % 
    % Parameters
    %   mjd - Modified Julian day
    %   CIRS - Position vector in the Celestial Intermediate
    %     Reference System (Earth Centered, precession and more
    %     accurate nutation modeled)
    %
    % Returns
    %   TETED - Position vector in the True Equator True Equinox of
    %     Date coordinate system (Earth Centered, precession and more
    %     accurate nutation modeled)
      T = (mjd - 51544.5) / 36525.0;
      epsilon = (pi / (180.0 * 3600.0)) ...
                * (-0.014506 - 4612.156534 * T - 1.3915817 * T^2 ...
                   + 0.00000044 * T^3 + 0.000029956 * T^4 + 0.0000000368 * T^5);
      TETED = Coordinates.R_z(epsilon) * CIRS;
      
    end % CIRSToTETED
    
    function r_gei = ltp2gei(r_ltp, sensor, dNm)
    % Computes the inertial geocentric equatorial position
    % vector of a satellite given the local tangent position
    % vector observed at a date by a given sensor.
    % 
    % Parameters
    %   r_ltp - Local tangent position vector [er]
    %   sensor - Sensor at which position vectors apply
    %   dNm - Date number at which the position vectors occur
    %
    % Returns
    %   r_gei - Inertial geocentric equatorial position vector [er]
      [y, m, d, H, M, S] = datevec(dNm);
      mjd = TimeUtility.date2mjd(y, m, d, H, M, S);
      SEZ = Coordinates.R_z(-pi / 2.0) * r_ltp;
      ITRS_0 = sensor.R_ger();
      geodetic_latitude = sensor.varphi;
      longitude = sensor.lambda;
      ITRS = Sgp4Coordinates.SEZToITRS(SEZ, ITRS_0, geodetic_latitude, longitude);
      TIRS = ITRS; % Ignores polar motion
      CIRS = Sgp4Coordinates.TIRSToCIRS(mjd, TIRS);
      TETED = Sgp4Coordinates.CIRSToTETED(mjd, CIRS);
      TEMED = TETED; % Ignores difference due to less
                     % accurate nutation model
      r_gei = TEMED; % Returned by SGP4
      
    end % ltp2gei
    
  end % methods (Static = true)
  
end % classdef
