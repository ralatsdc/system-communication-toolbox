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
classdef SatelliteCatalog < handle
% Provides satellite catalog functions. Methods are provided for
% reading, and writing a catalog of two line element sets, and
% converting between two and four digit years.

  properties (SetAccess = private, GetAccess = public)
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods (Static = true)
    
    function [catalog, records] = readCatalog(catDir, catFNm)
    % Reads a file containing two line element sets downloaded from
    % the Space Track site.
    % 
    % Note:
    %   The file format conforms to the following:
    % 
    %   Line 1
    %   Columns    Example           Description
    %   ------------------------------------------------------------------------
    %   1          1                 Line Number
    %   3-7        25544             Object Identification Number
    %   8          U                 Elset Classification
    %   10-17      98067A            International Designator
    %   19-32      04236.56031392    Element Set Epoch
    %   34-43      .00020137         First Time Derivative of Mean Motion
    %   45-52      00000-0           Second Time Derivative of Mean Motion
    %                                  (decimal point assumed)
    %   54-61      16538-3           B* Drag Term
    %   63         0                 Element Set Type
    %   65-68      513               Element Number
    %   69         5                 Checksum
    % 
    %   Line 2
    %   Columns    Example           Description
    %   ------------------------------------------------------------------------
    %   1          2                 Line Number
    %   3-7        25544             Object Identification Number
    %   9-16       51.6335           Orbit Inclination (degrees)
    %   18-25      344.7760          Right Ascension of Ascending Node (degrees)
    %   27-33      0007976           Eccentricity
    %                                  (decimal point assumed)
    %   35-42      126.2523          Argument of Perigee (degrees)
    %   44-51      325.9359          Mean Anomaly (degrees)
    %   53-63      15.70406856       Mean Motion (revolutions/day)
    %   64-68      32890             Revolution Number at Epoch
    %   69         3                 Checksum
    %
    % Parameters
    %   catDir - Directory containing catalog file
    %   catFNm - File containing two line element sets
    %
    % Returns
    %   catalog - Structure containing Keplerian and Equinoctial
    %     orbit parameters constructed from the file
    %   records - Structure containing orbit parameters parameters
    %     constructed as is from the file
      
    % Load or create and save catalog structure.
      matFNm = strrep(strrep(catFNm, '.txt', '.mat'), '.dat', '.mat');
      if exist([catDir, '/', matFNm], 'file')
        
        % The mat file exists, so load the catalog structure.
        
        logMsg = sprintf('Loading catalog structure for %s.', ...
                         [catDir, '/', matFNm]);
        Logger.printMsg('FINE', logMsg);
        
        load([catDir, '/', matFNm], 'catalog', 'records');
        
      elseif exist([catDir, '/', catFNm], 'file')
        
        % The mat file doesn't exist, but the data file does, so read the
        % data.
        logMsg = sprintf('Reading catalog data for %s.', ...
                         [catDir, '/', catFNm]);
        Logger.printMsg('FINE', logMsg);
        
        tles = textread([catDir, '/', catFNm], ...
                        '%s', 'delimiter', '\n', 'whitespace', '');
        
        % Find and parse lines one.
        logMsg = sprintf('Finding and parsing lines one for %s.', ...
                         [catDir, '/', catFNm]);
        Logger.printMsg('FINE', logMsg);
        
        ln_1 = tles(find(strncmp('1', tles, 1)));
        
        nLn_1 = length(ln_1);
        for iLn_1 = 1:nLn_1
          curLn_1 = ln_1{iLn_1};
          
          records.object_str{iLn_1, 1} = curLn_1(3:7);
          records.class_str{iLn_1, 1} = curLn_1(8);
          records.int_des_str{iLn_1, 1} = curLn_1(10:17);
          records.epoch_str{iLn_1, 1} = curLn_1(19:32);
          records.n_dot_str{iLn_1, 1} = curLn_1(34:43);
          records.n_ddot_str{iLn_1, 1} = curLn_1(45:52);
          records.b_star_str{iLn_1, 1} = curLn_1(54:61);
          records.els_type_str{iLn_1, 1} = curLn_1(63);
          records.els_nmbr_str{iLn_1, 1} = curLn_1(65:68);
          records.chk_sum_1_str{iLn_1, 1} = curLn_1(69);
          
          records.object(iLn_1, 1) = str2double(curLn_1(3:7));
          % Note that the day of year (DOY) for January 1 is, uh,
          % 1, so 1 must be subtracted from the epoch DOY when
          % adding the additional days, with fraction, to the start
          % of the year serial date number to obtain the epoch
          % serial date number
          records.epoch(iLn_1, 1) ...
              = datenum(SatelliteCatalog.fixed_window( ...
                  str2double(curLn_1(19:20))), 1, 1, 0, 0, 0) ...
              + str2double(curLn_1(21:32)) - 1;
          records.n_dot(iLn_1, 1) = str2double(curLn_1(34:43));
          records.n_ddot(iLn_1, 1) ...
              = str2double(strrep(strrep(curLn_1(45:52), '+', 'e+'), '-', 'e-'));
          records.b_star(iLn_1, 1) ...
              = str2double(strrep(strrep(curLn_1(54:61), '+', 'e+'), '-', 'e-'));
          
        end % for iLn_1
        
        % Find and parse lines two.
        logMsg = sprintf('Finding and parsing lines two for %s.', ...
                         [catDir, '/', catFNm]);
        Logger.printMsg('FINE', logMsg);
        
        ln_2 = tles(find(strncmp('2', tles, 1)));
        
        nLn_2 = length(ln_2);
        if nLn_2 ~= nLn_1
          MEx = MException('Synterein:IOException', ...
                           'Number of lines one and two differ.');
          throw(MEx);
          
        end % if
        
        for iLn_2 = 1:nLn_2
          curLn_2 = ln_2{iLn_2};
          
          records.i_str{iLn_2, 1}       = curLn_2(9:16);
          records.Omega_str{iLn_2, 1}   = curLn_2(18:25);
          records.e_str{iLn_2, 1}       = curLn_2(27:33);
          records.omega_str{iLn_2, 1}   = curLn_2(35:42);
          records.M_str{iLn_2, 1}       = curLn_2(44:51);
          records.n_str{iLn_2, 1}       = curLn_2(53:63);
          records.revs_str{iLn_2, 1}    = curLn_2(64:68);
          records.chk_sum_2_str{iLn_2, 1} = curLn_2(69);
          
          records.i(iLn_2, 1)     = str2double(curLn_2(9:16));
          records.Omega(iLn_2, 1) = str2double(curLn_2(18:25));
          records.e(iLn_2, 1)     = str2double(curLn_2(27:33));
          records.omega(iLn_2, 1) = str2double(curLn_2(35:42));
          records.M(iLn_2, 1)     = str2double(curLn_2(44:51));
          records.n(iLn_2, 1)     = str2double(curLn_2(53:63));
          records.revs(iLn_2, 1)  = str2double(curLn_2(64:68));
          
        end % for iLn_2
        
        % Find and parse lines three.
        logMsg = sprintf('Finding and parsing lines three for %s.', ...
                         [catDir, '/', catFNm]);
        Logger.printMsg('FINE', logMsg);
        
        ln_3 = tles(setdiff([1:length(tles)], ...
                            find(strncmp('1', tles, 1) | strncmp('2', tles, 1))));
        
        nLn_3 = length(ln_3);
        if nLn_3 ~= nLn_1
          warning('%s %s: Number of lines one and three differ.', ...
                  datestr(now), mfilename);
          
        else
          records.satellite = ln_3;
          
        end % if
        
        % Allocate memory for output structure.
        numObj = length(records.object);
        catalog(numObj).id = [];
        
        catalog(numObj).a     = [];
        catalog(numObj).e     = [];
        catalog(numObj).i     = [];
        catalog(numObj).Omega = [];
        catalog(numObj).omega = [];
        catalog(numObj).M     = [];
        % Keplerian elements.
        
        catalog(numObj).dNm = [];
        catalog(numObj).rcs   = [];
        
        catalog(numObj).j      = [];
        catalog(numObj).h      = [];
        catalog(numObj).k      = [];
        catalog(numObj).p      = [];
        catalog(numObj).q      = [];
        catalog(numObj).lambda = [];
        % Equinoctial elements.
        
        % Assign element set from catalog and convert delivered to
        % standard units.
        for iObj = 1:numObj
          catalog(iObj).id = records.object(iObj);
          n = records.n(iObj) * (2 * pi) * (1 / (24 * 60 * 60));
          % [rad/s] = [rev/day] * [rad/rev] * (1 / ([h/d] * [m/h] * [s/m]))
          a = (EarthConstants.GM_oplus / n^2)^(1/3);
          % [km] = [ [km^3/s^2] / [rad/s]^2 ]^(1/3)
          
          catalog(iObj).a     = a / EarthConstants.R_oplus;
          % [er] = [km] / [km/er]
          catalog(iObj).e     = records.e(iObj) / 10^7;
          % [-]
          catalog(iObj).i     = (pi / 180) * records.i(iObj);
          % [rad]
          catalog(iObj).Omega = (pi / 180) * records.Omega(iObj);
          % [rad]
          catalog(iObj).omega = (pi / 180) * records.omega(iObj);
          % [rad]
          catalog(iObj).M     = (pi / 180) * records.M(iObj);
          % [rad]
          % Keplerian elements.
          
          catalog(iObj).dNm = records.epoch(iObj);
          
          % Convert Keplerian to equinoctial elements (LCVF-3-266-271 and
          % note following LCVF-3-238).
          if 0 <= catalog(iObj).i && catalog(iObj).i <= pi / 2 % direct (posigrade)
            catalog(iObj).j      = 1;
            catalog(iObj).h      = ...
                catalog(iObj).e * sin(catalog(iObj).omega + catalog(iObj).Omega);
            catalog(iObj).k      = ...
                catalog(iObj).e * cos(catalog(iObj).omega + catalog(iObj).Omega);
            catalog(iObj).p      = tan(catalog(iObj).i / 2) * sin(catalog(iObj).Omega);
            catalog(iObj).q      = tan(catalog(iObj).i / 2) * cos(catalog(iObj).Omega);
            catalog(iObj).lambda = ...
                catalog(iObj).M + catalog(iObj).omega + catalog(iObj).Omega;
            
          elseif pi / 2 < catalog(iObj).i && catalog(iObj).i <= pi % retrograde
            catalog(iObj).j      = -1;
            catalog(iObj).h      = ...
                catalog(iObj).e * sin(catalog(iObj).omega - catalog(iObj).Omega);
            catalog(iObj).k      = ...
                catalog(iObj).e * cos(catalog(iObj).omega - catalog(iObj).Omega);
            catalog(iObj).p      = cot(catalog(iObj).i / 2) * sin(catalog(iObj).Omega);
            catalog(iObj).q      = cot(catalog(iObj).i / 2) * cos(catalog(iObj).Omega);
            catalog(iObj).lambda = ...
                catalog(iObj).M + catalog(iObj).omega - catalog(iObj).Omega;
            
          end % if
          
          % Print occasionally.
          if mod(iObj, 1000) == 0
            logMsg = sprintf('Converted: %5.1f%%.', ...
                             100 * iObj / numObj);
            Logger.printMsg('FINE', logMsg);
            
          end % if
          
        end % for iObj
        
        % Save converted data.
        logMsg = sprintf('Saving catalog structure for %s.', ...
                         [catDir, '/', matFNm]);
        Logger.printMsg('FINE', logMsg);
        
        save([catDir, '/', matFNm], 'catalog', 'records');
        
      else
        MEx = MException('Synterein:FileNotFoundException', ...
                         sprintf('Catalog file %s not found.', [catDir, '/', catFNm]));
        throw(MEx);
        
      end % if
      
    end % readCatalog()
    
    function writeCatalog(catalog, records, catDir, catFNm)
    % Writes file containing two line element sets.
    % 
    % Note:
    %   The file format conforms to the following:
    % 
    %   Line 1
    %   Columns    Example           Description
    %   ------------------------------------------------------------------------
    %   1          1                 Line Number
    %   3-7        25544             Object Identification Number
    %   8          U                 Elset Classification
    %   10-17      98067A            International Designator
    %   19-32      04236.56031392    Element Set Epoch
    %   34-43      .00020137         First Time Derivative of Mean Motion
    %   45-52      00000-0           Second Time Derivative of Mean Motion
    %                                  (decimal point assumed)
    %   54-61      16538-3           B* Drag Term
    %   63         0                 Element Set Type
    %   65-68      513               Element Number
    %   69         5                 Checksum
    % 
    %   Line 2
    %   Columns    Example           Description
    %   ------------------------------------------------------------------------
    %   1          2                 Line Number
    %   3-7        25544             Object Identification Number
    %   9-16       51.6335           Orbit Inclination (degrees)
    %   18-25      344.7760          Right Ascension of Ascending Node (degrees)
    %   27-33      0007976           Eccentricity
    %                                  (decimal point assumed)
    %   35-42      126.2523          Argument of Perigee (degrees)
    %   44-51      325.9359          Mean Anomaly (degrees)
    %   53-63      15.70406856       Mean Motion (revolutions/day)
    %   64-68      32890             Revolution Number at Epoch
    %   69         3                 Checksum
    %
    % Parameters
    %   catalog - Structure containing Keplerian and Equinoctial
    %     orbit parameters constructed from the file
    %   catDir - Directory containing catalog file
    %   catFNm - File containing two line element sets
      
    % Ensure catalog and records object numbers agree
      if ~isequal([catalog(:).id]', records.object)
        MEx = MException('Synterein:IllegalArgumentException', ...
                         'Catalog and records objects do not agree.');
        throw(MEx);
        
      end % if
      
      % Consider each object
      FId = fopen([catDir, '/', catFNm], 'w');
      nObj = length(records.object);
      for iObj = 1:nObj
        
        % Print line one to a string
        % Note that the day of year (DOY) for January 1 is, uh,
        % 1, so 1 must be added to the serial date number
        % difference from the start of the year to obtain the
        % epoch DOY, with fraction
        line_1 = sprintf('1 %s%s %s %s%012.8f %s %s %s %s %s%s\n', ...
                         records.object_str{iObj}, ...
                         records.class_str{iObj}, ...
                         records.int_des_str{iObj}, ...
                         datestr(catalog(iObj).dNm, 'yy'), ...
                         catalog(iObj).dNm - ...
                         datenum(str2double(datestr(catalog(iObj).dNm, 'yyyy')), 1, 1, 0, 0, 0) + 1, ...
                         records.n_dot_str{iObj}, ...
                         records.n_ddot_str{iObj}, ...
                         records.b_star_str{iObj}, ...
                         records.els_type_str{iObj}, ...
                         records.els_nmbr_str{iObj});
        % records.chk_sum_1_str{iObj});
        
        % Compute line one check sum
        checksum_1 = SatelliteCatalog.checkSum(line_1);
        
        % Print line one to a file
        fprintf(FId, '%s%d\n', line_1, checksum_1);
        
        % Compute mean motion
        n = sqrt(EarthConstants.GM_oplus / (catalog(iObj).a * EarthConstants.R_oplus)^3) * 86400 / (2 * pi);
        % [rev/day] = ([km^3/s^2] / ([er] * [km/er])^3)^(1/2) * [s/day] / [rad/rev]
        
        % Print line two
        line_2 = sprintf('2 %s %08.4f %08.4f %07d %08.4f %08.4f %011.8f%s%s\n', ...
                         records.object_str{iObj}, ...
                         catalog(iObj).i * (180 / pi), ...
                         catalog(iObj).Omega * (180 / pi), ...
                         round(catalog(iObj).e * 10^7), ...
                         catalog(iObj).omega * (180 / pi), ...
                         catalog(iObj).M * (180 / pi), ...
                         n, ...
                         records.revs_str{iObj});
        % records.chk_sum_2_str{iObj});
        
        % Compute line two check sum
        checksum_2 = SatelliteCatalog.checkSum(line_2);
        
        % Print line two to a file
        fprintf(FId, '%s%d\n', line_2, checksum_2);
        
      end % for
      fclose(FId);
      
    end % writeCatalog()
    
    function checksum = checkSum(card)
    % Computes the checksum of one line of a two-line element
    % set. The first 68 characters are scanned and "summed" to
    % compute the checksum.Taken from: sgp4v/SatElset.Java.
    %
    % Parameters
    %   card - the String containing the line
    %
    % Returns
    %   checksum - the int containing the checksum [0,9]
      checksum = 0;
      for i = [1 : 68]
        switch card(i)
          case '1'
            checksum = checksum + 1;
            
          case '-'
            checksum = checksum + 1;
            
          case '2'
            checksum = checksum + 2;
            
          case '3'
            checksum = checksum + 3;
            
          case '4'
            checksum = checksum + 4;
            
          case '5'
            checksum = checksum + 5;
            
          case '6'
            checksum = checksum + 6;
            
          case '7'
            checksum = checksum + 7;
            
          case '8'
            checksum = checksum + 8;
            
          case '9'
            checksum = checksum + 9;
            
          otherwise
            % do nothing
            
        end % switch
        
      end % for
      checksum = mod(checksum, 10);
      
    end % checkSum()
    
    function writeTLE(objId, lnchId, satOrb, outFId)
    % Writes a satellite orbit to a file as a two line element set.
    % 
    % Note:
    %   The file format conforms to the following:
    % 
    %   Line 1
    %   Columns    Example           Description
    %   ------------------------------------------------------------------------
    %   1          1                 Line Number
    %   3-7        25544             Object Identification Number
    %   8          U                 Elset Classification
    %   10-17      98067A            International Designator
    %   19-32      04236.56031392    Element Set Epoch
    %   34-43      .00020137         First Time Derivative of Mean Motion
    %   45-52      00000-0           Second Time Derivative of Mean Motion
    %                                  (decimal point assumed)
    %   54-61      16538-3           B* Drag Term
    %   63         0                 Element Set Type
    %   65-68      513               Element Number
    %   69         5                 Checksum
    % 
    %   Line 2
    %   Columns    Example           Description
    %   ------------------------------------------------------------------------
    %   1          2                 Line Number
    %   3-7        25544             Object Identification Number
    %   9-16       51.6335           Orbit Inclination (degrees)
    %   18-25      344.7760          Right Ascension of Ascending Node (degrees)
    %   27-33      0007976           Eccentricity
    %                                  (decimal point assumed)
    %   35-42      126.2523          Argument of Perigee (degrees)
    %   44-51      325.9359          Mean Anomaly (degrees)
    %   53-63      15.70406856       Mean Motion (revolutions/day)
    %   64-68      32890             Revolution Number at Epoch
    %   69         3                 Checksum
    %
    % Parameters
    %   objId - The object identification number
    %   lnchId - The incrementing launch number
    %   satOrb - A satellite orbit (a KeplerianOrbit or Sgp4Orbit)
    %   outFId - An open file identifier
      
    % Print line one
    % Note that the day of year (DOY) for January 1 is, uh, 1,
    % so 1 must be added to the serial date number difference
    % from the start of the year to obtain the epoch DOY, with
    % fraction
      fprintf(outFId, '1 %05d%1s %2s%03d%1s %4s%012.8f %10s %8s %8s %1s %4s%1s\n', ...
              objId, ...
              'U', ...
              datestr(satOrb.epoch, 'yy'), lnchId, 'A', ...
              datestr(satOrb.epoch, 'yy'), satOrb.epoch - datenum(str2double(datestr(satOrb.epoch, 'yyyy')), 1, 1, 0, 0, 0) + 1, ...
              '.00000000', ...
              '00000-0', ...
              '00000+0', ...
              '0', ...
              '0', ...
              '0');
      
      % Compute mean motion
      n = sqrt(EarthConstants.GM_oplus / (satOrb.a * EarthConstants.R_oplus)^3) * 86400 / (2 * pi);
      % [rev/day] = ([km^3/s^2] / ([er] * [km/er])^3)^(1/2) * [s/day] / [rad/rev]
      
      % Print line two
      fprintf(outFId, '2 %05d %08.4f %08.4f %07d %08.4f %08.4f %011.8f%5s%1s\n', ...
              objId, ...
              satOrb.i * (180 / pi), ...
              satOrb.Omega * (180 / pi), ...
              round(satOrb.e * 10^7), ...xo
      satOrb.omega * (180 / pi), ...
          satOrb.M * (180 / pi), ...
          n, ...
          '100', ...
          '0');
      
    end % writeTLE()
    
  end % methods (Static = true)
  
  methods (Static = true, Access = private)
    
    function YYYY = fixed_window(YY)
    % Converts a two digit year to a four digit year.
    %
    % Parameters
    %   YY - Two digit year
    %
    % Returns
    %   YYYY - Four digit year using a fixed window with pivot year
    %     1970
      
      [nRow, nCol] = size(YY);
      YYYY = zeros(nRow, nCol);
      
      vld_idx = find(YY < 70);
      YYYY(vld_idx) = YY(vld_idx) + 2000;
      
      vld_idx = find(70 <= YY && YY < 100);
      YYYY(vld_idx) = YY(vld_idx) + 1900;
      
    end % fixed_window()
    
  end % methods (Static = true, Access = private)
  
end % classdef
