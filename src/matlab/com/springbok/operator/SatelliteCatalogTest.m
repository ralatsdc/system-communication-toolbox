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
classdef SatelliteCatalogTest < TestUtility
% Tests methods of SatelliteCatalog class.
  
  properties (Constant = true)
    
    % Directory containing catalog file
    catDir = 'dat/matlab/com/springbok/operator';
    % File containing two line element sets
    catFNm = 'tles.txt';
    
    % Semi-major axis [er]
    a = 2 * EarthConstants.R_oplus;
    % Eccentricity [-]
    e = 0.001;
    % Inclination [rad]
    i = 0;
    % Right ascension of the ascending node [rad]
    Omega = 0;
    % Argument of perigee [rad]
    omega = 0;
    % Mean anomaly [rad]
    M = 0;
    % Epoch date number
    epoch = datenum('01/01/2000 12:00:00');
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % Structure containing Keplerian and Equinoctial orbit
    % parameters constructed from the file
    catalog
    
  end % properties (Access = private)
  
  methods
    
    function this = SatelliteCatalogTest(logFId, testMode)
    % Constructs a SatelliteCatalogTest.
    %
    % Parameters
    %   logFId -Log file identifier
    %   testMode - Test mode, if 'interactive' then beeps and pauses
      
    % Invoke superclass constructor
      if nargin == 0
        superArgs = {};
        
      else
        superArgs{1} = logFId;
        superArgs{2} = testMode;
        
      end % if
      this@TestUtility(superArgs{:});
      
      % Assign properties
      nObj = 2;
      
      this.catalog(nObj).id = [];
      
      this.catalog(nObj).a = [];
      this.catalog(nObj).e = [];
      this.catalog(nObj).i = [];
      this.catalog(nObj).Omega = [];
      this.catalog(nObj).omega = [];
      this.catalog(nObj).M = [];
      % Keplarian elements.
      
      this.catalog(nObj).dNm = [];
      this.catalog(nObj).rcs = [];
      
      this.catalog(nObj).j = [];
      this.catalog(nObj).h = [];
      this.catalog(nObj).k = [];
      this.catalog(nObj).p = [];
      this.catalog(nObj).q = [];
      this.catalog(nObj).lambda = [];
      % Equinoctial elements.
      
      iObj = 1;
      
      this.catalog(iObj).id = 5;
      n = 18.04384562 * (2 * pi) * (1 / (24 * 60 * 60));
      % [rad/s] = [rev/day] * [rad/rev] * (1 / ([h/d] * [m/h] * [s/m]))
      a = (EarthConstants.GM_oplus / n^2)^(1/3);
      % [km] = [ [km^3/s^2] / [rad/s]^2 ]^(1/3)
      
      this.catalog(iObj).a = a / EarthConstants.R_oplus;
      % [er] = [km] / [km/er]
      this.catalog(iObj).e = 0.1848534;
      % [-]
      this.catalog(iObj).i = (pi / 180) * 32.4486;
      % [rad]
      this.catalog(iObj).Omega = (pi / 180) * 331.6386;
      % [rad]
      this.catalog(iObj).omega = (pi / 180) * 087.8835;
      % [rad]
      this.catalog(iObj).M = (pi / 180) * 292.2681;
      % [rad]
      % Keplarian elements.
      
      this.catalog(iObj).dNm = datenum(2014, 1, 1) - 1 + 224.13195843;
      
      this.catalog(iObj).j = 1;
      this.catalog(iObj).h = ...
          this.catalog(iObj).e * sin(this.catalog(iObj).omega + this.catalog(iObj).Omega);
      this.catalog(iObj).k = ...
          this.catalog(iObj).e * cos(this.catalog(iObj).omega + this.catalog(iObj).Omega);
      this.catalog(iObj).p = tan(this.catalog(iObj).i / 2) * sin(this.catalog(iObj).Omega);
      this.catalog(iObj).q = tan(this.catalog(iObj).i / 2) * cos(this.catalog(iObj).Omega);
      this.catalog(iObj).lambda = ...
          this.catalog(iObj).M + this.catalog(iObj).omega + this.catalog(iObj).Omega;
      % Equinoctial elements.
      
      iObj = 2;
      
      this.catalog(iObj).id = 40114;
      n = 16.39284109 * (2 * pi) * (1 / (24 * 60 * 60));
      % [rad/s] = [rev/day] * [rad/rev] * (1 / ([h/d] * [m/h] * [s/m]))
      a = (EarthConstants.GM_oplus / n^2)^(1/3);
      % [km] = [ [km^3/s^2] / [rad/s]^2 ]^(1/3)
      
      this.catalog(iObj).a = a / EarthConstants.R_oplus;
      % [er] = [km] / [km/er]
      this.catalog(iObj).e = 0.0140909;
      % [-]
      this.catalog(iObj).i = (pi / 180) * 64.3596;
      % [rad]
      this.catalog(iObj).Omega = (pi / 180) * 351.0056;
      % [rad]
      this.catalog(iObj).omega = (pi / 180) * 28.2938;
      % [rad]
      this.catalog(iObj).M = (pi / 180) * 338.7343;
      % [rad]
      % Keplarian elements.
      
      this.catalog(iObj).dNm = datenum(2014, 1, 1) - 1 + 228.17412853;
      
      this.catalog(iObj).j = 1;
      this.catalog(iObj).h = ...
          this.catalog(iObj).e * sin(this.catalog(iObj).omega + this.catalog(iObj).Omega);
      this.catalog(iObj).k = ...
          this.catalog(iObj).e * cos(this.catalog(iObj).omega + this.catalog(iObj).Omega);
      this.catalog(iObj).p = tan(this.catalog(iObj).i / 2) * sin(this.catalog(iObj).Omega);
      this.catalog(iObj).q = tan(this.catalog(iObj).i / 2) * cos(this.catalog(iObj).Omega);
      this.catalog(iObj).lambda = ...
          this.catalog(iObj).M + this.catalog(iObj).omega + this.catalog(iObj).Omega;
      % Equinoctial elements.
      
    end % SatelliteCatalogTest()
    
    function test_readCatalog(this)
    % Tests readCatalog method. Note that readCatalog invoked
    % private method fixed_window, which is therefore tested
    % implicitly.
      
      warning('off');
      
      catalog_actual = SatelliteCatalog.readCatalog(this.catDir, this.catFNm);
      
      warning('on');
      
      iObj = 1;
      
      t = [];
      
      t = [t; isequal(catalog_actual(iObj).id, this.catalog(iObj).id)];
      
      t = [t; isequal(catalog_actual(iObj).a, this.catalog(iObj).a)];
      t = [t; isequal(catalog_actual(iObj).e, this.catalog(iObj).e)];
      t = [t; isequal(catalog_actual(iObj).i, this.catalog(iObj).i)];
      t = [t; isequal(catalog_actual(iObj).Omega, this.catalog(iObj).Omega)];
      t = [t; isequal(catalog_actual(iObj).omega, this.catalog(iObj).omega)];
      t = [t; isequal(catalog_actual(iObj).M, this.catalog(iObj).M)];
      
      t = [t; isequal(catalog_actual(iObj).dNm, this.catalog(iObj).dNm)];
      
      t = [t; isequal(catalog_actual(iObj).j, this.catalog(iObj).j)];
      t = [t; isequal(catalog_actual(iObj).h, this.catalog(iObj).h)];
      t = [t; isequal(catalog_actual(iObj).k, this.catalog(iObj).k)];
      t = [t; isequal(catalog_actual(iObj).p, this.catalog(iObj).p)];
      t = [t; isequal(catalog_actual(iObj).q, this.catalog(iObj).q)];
      t = [t; isequal(catalog_actual(iObj).lambda, this.catalog(iObj).lambda)];
      
      nObj = length(catalog_actual);
      iObj = 2;
      
      t = [t; isequal(catalog_actual(nObj).id, this.catalog(iObj).id)];
      
      t = [t; isequal(catalog_actual(nObj).a, this.catalog(iObj).a)];
      t = [t; isequal(catalog_actual(nObj).e, this.catalog(iObj).e)];
      t = [t; isequal(catalog_actual(nObj).i, this.catalog(iObj).i)];
      t = [t; isequal(catalog_actual(nObj).Omega, this.catalog(iObj).Omega)];
      t = [t; isequal(catalog_actual(nObj).omega, this.catalog(iObj).omega)];
      t = [t; isequal(catalog_actual(nObj).M, this.catalog(iObj).M)];
      
      t = [t; isequal(catalog_actual(nObj).dNm, this.catalog(iObj).dNm)];
      
      t = [t; isequal(catalog_actual(nObj).j, this.catalog(iObj).j)];
      t = [t; isequal(catalog_actual(nObj).h, this.catalog(iObj).h)];
      t = [t; isequal(catalog_actual(nObj).k, this.catalog(iObj).k)];
      t = [t; isequal(catalog_actual(nObj).p, this.catalog(iObj).p)];
      t = [t; isequal(catalog_actual(nObj).q, this.catalog(iObj).q)];
      t = [t; isequal(catalog_actual(nObj).lambda, this.catalog(iObj).lambda)];
      
      this.assert_true( ...
          'SatelliteCatalog', ...
          'readCatalog', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_readCatalog()
    
    function test_writeCatalog(this)
    % Tests writeCatalog method.
      
      warning('off');
      
      [catalog, records] = SatelliteCatalog.readCatalog(this.catDir, this.catFNm);
      
      warning('on');
      
      catFNm_output = strrep(this.catFNm, '.txt', '.dat');
      
      SatelliteCatalog.writeCatalog(catalog, records, this.catDir, catFNm_output);
      
      [status, result] = system( ...
          ['diff ', ...
           this.catDir, '/', this.catFNm, ...
           ' ', ...
           this.catDir, '/', catFNm_output]);
      
      this.assert_true( ...
          'SatelliteCatalog', ...
          'writeCatalog', ...
          this.IS_EQUAL_DESC, ...
          isequal(result, ''));
      
    end % test_writeCatalog()
    
  end % methods
  
  % TODO: Test function writeTLE(objId, lnchId, satOrb, outFId)

end % classdef
