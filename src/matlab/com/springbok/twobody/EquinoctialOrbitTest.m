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
classdef EquinoctialOrbitTest < TestUtility
% Tests methods of EquinoctialOrbit class.
  
  properties (Constant = true)
    
    % Direct or retrograde orbit indicator [-]
    j = 1;
    % Semi-major axis [er]
    a = EarthConstants.a_gso;
    % Epoch date number
    epoch = datenum('01/01/2000 12:00:00');
    
    % Method to solve Kepler's equation: 'newton' or 'halley'
    method = 'halley';
    
    % Eccentricity [-]
    e = eps;
    % Inclination [rad]
    i = 1 * pi / 180;
    % Right ascension of the ascending node [rad]
    Omega = pi / 4;
    % Argument of perigee [rad]
    omega = pi / 4
    % Mean anomaly [rad]
    M = pi / 4;
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % Y component of the eccentricity vector [-]
    h;
    % X component of the eccentricity  [-]
    k;
    % Y component of the nodal vector [-]
    p;
    % X component of the nodal vector [-]
    q;
    % Mean longitude [rad]
    lambda;
    
    % An equinoctial orbit
    equinoctial_orbit;
    
  end % properties
  
  methods
    
    function this = EquinoctialOrbitTest(logFId, testMode)
    % Constructs a EquinoctialOrbitTest.
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
      
      % Compute derived properties
      this.h = this.e * sin(this.Omega + this.omega);
      this.k = this.e * cos(this.Omega + this.omega);
      this.p = tan(this.i / 2) * sin(this.Omega);
      this.q = tan(this.i / 2) * cos(this.Omega);
      this.lambda = this.Omega + this.omega + this.M;
      
      this.equinoctial_orbit = EquinoctialOrbit(this.j, ...
                                                this.a, ...
                                                this.h, ...
                                                this.k, ...
                                                this.p, ...
                                                this.q, ...
                                                this.lambda, ...
                                                this.epoch, ...
                                                this.method);
      
    end % EquinoctialOrbitTest()
    
    function test_EquinoctialOrbit(this)
    % Tests EquinotialOrbit method.
      
      n_expected = sqrt(EarthConstants.GM_oplus / (EarthConstants.R_oplus * this.a)^3);
      T_expected = 2 * pi * sqrt((EarthConstants.R_oplus * this.a)^3 / EarthConstants.GM_oplus);
      
      is_expected_ne = 0;

      is_actual_ne = this.equinoctial_orbit.isEmpty;
      
      eo = EquinoctialOrbit;
      
      is_expected_e = 1;

      is_actual_e = eo.isEmpty;
      
      t = [];
      t = [t; isequal(this.equinoctial_orbit.j, this.j)];
      t = [t; isequal(this.equinoctial_orbit.a, this.a)];
      t = [t; isequal(this.equinoctial_orbit.h, this.h)];
      t = [t; isequal(this.equinoctial_orbit.k, this.k)];
      t = [t; isequal(this.equinoctial_orbit.p, this.p)];
      t = [t; isequal(this.equinoctial_orbit.q, this.q)];
      t = [t; isequal(this.equinoctial_orbit.lambda, this.lambda)];
      t = [t; isequal(this.equinoctial_orbit.epoch, this.epoch)];
      t = [t; isequal(this.equinoctial_orbit.method, this.method)];
      t = [t; abs(this.equinoctial_orbit.n - n_expected) < this.HIGH_PRECISION];
      t = [t; abs(this.equinoctial_orbit.T - T_expected) < this.HIGH_PRECISION];
      t = [t; isequal(is_actual_ne, is_expected_ne) && isequal(is_actual_e, is_expected_e)];
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'EquinoctialOrbit', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_EquinoctialOrbit()
    
    function test_meanMotion(this)
    % Tests meanMotion method.
      
      n_expected = sqrt(EarthConstants.GM_oplus / (EarthConstants.R_oplus * this.a)^3);
      
      n_actual = this.equinoctial_orbit.meanMotion;
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'meanMotion', ...
          this.HIGH_PRECISION_DESC, ...
          abs(n_actual - n_expected) < this.HIGH_PRECISION);
      
    end % test_meanMotion()
    
    function test_meanPosition(this)
    % Tests meanPosition method.
      
      delta_dNm = this.equinoctial_orbit.T / 86400;
      dNm = this.epoch + delta_dNm;
      
      lambda_expected = this.lambda;
      
      lambda_actual = this.equinoctial_orbit.meanPosition(dNm);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'meanPosition', ...
          this.LOW_PRECISION_DESC, ...
          abs(lambda_actual - lambda_expected) < this.LOW_PRECISION);
      
    end % test_meanPosition()
    
    function test_orbitalPeriod(this)
    % Tests orbitalPeriod method.
      
      T_expected = 2 * pi * sqrt((EarthConstants.R_oplus * this.a)^3 / EarthConstants.GM_oplus);
      
      T_actual = this.equinoctial_orbit.orbitalPeriod;
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'orbitalPeriod', ...
          this.HIGH_PRECISION_DESC, ...
          abs(T_actual - T_expected) < this.HIGH_PRECISION);
      
    end % test_orbitalPeriod()
    
    function test_keplersEquation(this)
      
      F_expected = this.lambda; % for GSO, e = 0, so F = lambda
      
      F_actual = this.equinoctial_orbit.keplersEquation(this.lambda);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'keplersEquation', ...
          this.HIGH_PRECISION_DESC, ...
          abs(F_actual - F_expected) < this.HIGH_PRECISION);
      
    end % test_keplersEquation()
    
    function test_r_goi(this)
    % Tests r_goi method.
      
      r_goi_expected = ...
          EarthConstants.a_gso ...
          * [-sin(pi / 4)
             +cos(pi / 4)
             0
            ]; % e = 0, so r = a, equinoctial coordinate system
      
      r_goi_actual = ...
          this.equinoctial_orbit.r_goi(this.equinoctial_orbit.keplersEquation(this.lambda));
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'r_goi', ...
          this.HIGH_PRECISION_DESC, ...
          sqrt((r_goi_actual - r_goi_expected)' ...
               * (r_goi_actual - r_goi_expected)) < this.HIGH_PRECISION);
      
    end % test_r_goi()
    
    function test_r_gei(this)
    % Tests r_gei method.
      
      r_gei_expected = ...
          (1 / 2) ...
          * [+1 - cos(this.i), -1 - cos(this.i), +sqrt(2) * sin(this.i)
             +1 + cos(this.i), -1 + cos(this.i), -sqrt(2) * sin(this.i)
             sqrt(2) * sin(this.i), sqrt(2) * sin(this.i), 2 * cos(this.i)
            ] ...
          * EarthConstants.a_gso ...
          * [cos(pi / 4)
             sin(pi / 4)
             0
            ]; % e = 0, so r = a, Keplerian coordinate system
      
      r_gei_actual = this.equinoctial_orbit.r_gei(this.epoch);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'r_gei', ...
          this.HIGH_PRECISION_DESC, ...
          sqrt((r_gei_actual - r_gei_expected)' ...
               * (r_gei_actual - r_gei_expected)) < this.HIGH_PRECISION);
      
    end % test_r_gei()
    
    function test_set_a(this)
    % Tests set_a method.
      
      this.equinoctial_orbit.set_a(this.a);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'set_a', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.equinoctial_orbit.a, this.a));
      
    end % test_set_a()
    
    function test_set_h(this)
    % Test set_h method.
      
      this.equinoctial_orbit.set_h(this.h);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'set_h', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.equinoctial_orbit.h, this.h));
      
    end % test_set_h()
    
    function test_set_k(this)
    % Tests set_k method.
      
      this.equinoctial_orbit.set_k(this.k);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'set_k', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.equinoctial_orbit.k, this.k));
      
    end % test_set_k()
    
    function test_set_p(this)
    % Test set_p method.
      
      this.equinoctial_orbit.set_p(this.p);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'set_p', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.equinoctial_orbit.p, this.p));
      
    end % test_set_p()
    
    function test_set_q(this)
    % Test set_q method.
      
      this.equinoctial_orbit.set_q(this.q);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'set_q', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.equinoctial_orbit.q, this.q));
      
    end % test_set_q()
    
    function test_set_lambda(this)
    % Tests set_lambda method.
      
      this.equinoctial_orbit.set_lambda(this.lambda);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'set_lambda', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.equinoctial_orbit.lambda, this.lambda));
      
    end % test_set_lambda()
    
    function test_set_epoch(this)
    % Tests set_epoch method.
      
      this.equinoctial_orbit.set_epoch(this.epoch);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'set_epoch', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.equinoctial_orbit.epoch, this.epoch));
      
    end % test_set_epoch()
    
    % TODO: Test set methods side effects
    
    function test_set_method(this)
    % Tests set_method method.
      
      this.equinoctial_orbit.set_method(this.method);
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'set.method', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.equinoctial_orbit.method, this.method));
      
    end % test_set_method()
    
    function test_isEmpty(this)
    % Tests isEmpty method.
      
      is_expected_ne = 0;
      
      is_actual_ne = this.equinoctial_orbit.isEmpty;
      
      eo = EquinoctialOrbit;
      
      is_expected_e = 1;
      
      is_actual_e = eo.isEmpty;
      
      this.assert_true( ...
          'EquinoctialOrbit', ...
          'isEmpty', ...
          this.IS_EQUAL_DESC, ...
          isequal(is_actual_ne, is_expected_ne) && isequal(is_actual_e, is_expected_e));
      
    end % test_isEmpty()
    
    % TODO: Test function is = isEqual(this, that)

  end % methods
  
end % classdef
