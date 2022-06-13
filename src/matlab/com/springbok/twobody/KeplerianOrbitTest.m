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
classdef KeplerianOrbitTest < TestUtility
% Tests methods of KeplerianOrbit class.
  
  properties (Constant = true)
    
    % Semi-major axis [er]
    a = EarthConstants.a_gso;
    % Eccentricity [-]
    e = eps;
    % Inclination [rad]
    i = 1 * pi / 180;
    % Right ascension of the ascending node [rad]
    Omega = pi / 4;
    % Argument of perigee [rad]
    omega = pi / 4;
    % Mean anomaly [rad]
    M = pi / 4;
    % Epoch date number
    epoch = datenum('01/01/2000 12:00:00');
    
    % Method to solve Kepler's equation: 'newton' or 'halley'
    method = 'halley';
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % A Keplerian orbit
    keplerian_orbit
    
  end % properties (Access = private)
  
  methods
    
    function this = KeplerianOrbitTest(logFId, testMode)
    % Constructs a KeplerianOrbitTest.
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
      this.keplerian_orbit = KeplerianOrbit(this.a, ...
                                            this.e, ...
                                            this.i, ...
                                            this.Omega, ...
                                            this.omega, ...
                                            this.M, ...
                                            this.epoch, ...
                                            this.method);
      
    end % KeplerianOrbitTest()
    
    function test_KeplerianOrbit(this)
    % Tests KeplerianOrbit method.
      
      n_expected = sqrt(EarthConstants.GM_oplus / (this.a * EarthConstants.R_oplus)^3);
      T_expected = 2 * pi * sqrt((this.a * EarthConstants.R_oplus)^3 / EarthConstants.GM_oplus);
      
      is_actual_ne = this.keplerian_orbit.isEmpty;

      is_expected_ne = 0;
      
      ko = KeplerianOrbit;
      
      is_expected_e = 1;

      is_actual_e = ko.isEmpty;
      
      t = [];
      t = [t; isequal(this.keplerian_orbit.a, this.a)];
      t = [t; isequal(this.keplerian_orbit.e, this.e)];
      t = [t; isequal(this.keplerian_orbit.i, this.i)];
      t = [t; isequal(this.keplerian_orbit.Omega, this.Omega)];
      t = [t; isequal(this.keplerian_orbit.omega, this.omega)];
      t = [t; isequal(this.keplerian_orbit.M, this.M)];
      t = [t; isequal(this.keplerian_orbit.epoch, this.epoch)];
      t = [t; isequal(this.keplerian_orbit.method, this.method)];
      t = [t; abs(this.keplerian_orbit.n - n_expected) < this.HIGH_PRECISION];
      t = [t; abs(this.keplerian_orbit.T - T_expected) < this.HIGH_PRECISION];
      t = [t; isequal(is_actual_ne, is_expected_ne) && isequal(is_actual_e, is_expected_e)];
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'KeplerianOrbit', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_KeplerianOrbit()
    
    function test_meanMotion(this)
    % Tests meanMotion method.
      
      n_expected = sqrt(EarthConstants.GM_oplus / (this.a * EarthConstants.R_oplus)^3);
      
      n_actual = this.keplerian_orbit.meanMotion;
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'meanMotion', ...
          this.HIGH_PRECISION_DESC, ...
          abs(n_actual - n_expected) < this.HIGH_PRECISION);
      
    end % test_meanMotion()
    
    function test_meanPosition(this)
    % Tests meanPosition method.
      
      delta_dNm = this.keplerian_orbit.T / 86400;
      dNm = this.epoch + delta_dNm;
      
      M_expected = this.M;
      
      M_actual = this.keplerian_orbit.meanPosition(dNm);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'meanPosition', ...
          this.LOW_PRECISION_DESC, ...
          abs(M_actual - M_expected) < this.LOW_PRECISION);
      
    end % test_meanPosition()
    
    function test_orbitalPeriod(this)
    % Tests orbitalPeriod method.
      
      T_expected = 2 * pi * sqrt((this.a * EarthConstants.R_oplus)^3 / EarthConstants.GM_oplus);
      
      T_actual = this.keplerian_orbit.orbitalPeriod;
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'orbitalPeriod', ...
          this.HIGH_PRECISION_DESC, ...
          abs(T_actual - T_expected) < this.HIGH_PRECISION);
      
    end % test_orbitalPeriod()
    
    function test_visVivaLaw(this)
    % Tests visVivaLaw method.
      
      v_expected = sqrt(EarthConstants.GM_oplus / (this.a * EarthConstants.R_oplus)) ...
          / EarthConstants.R_oplus; % e = 0, so r = a
      
      v_actual = this.keplerian_orbit.visVivaLaw(this.M); % e = 0, so E = M
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'visVivaLaw', ...
          this.HIGH_PRECISION_DESC, ...
          abs(v_actual - v_expected) < this.HIGH_PRECISION);
      
    end % test_visVivaLaw()
    
    function test_secularPerturbations(this)
    % Tests secularPerturbations method.
      
      p = this.a; % e = 0, so p = a
      n = this.keplerian_orbit.meanMotion;
      
      Omega_dot_expected = ...
          -(3 / 2) * (EarthConstants.J_2 / p^2) * cos(this.i) * n;
      omega_dot_expected = ...
          +(3 / 2) * (EarthConstants.J_2 / p^2) * (2 - (5 / 2) * sin(this.i)^2) * n;
      M_0_dot_expected = ...
          +(3 / 2) * (EarthConstants.J_2 / p^2) * (1 - (3 / 2) * sin(this.i)^2) * n; % e = 0, 1 - e^2 = 1
      
      [Omega_dot_actual, omega_dot_actual, M_0_dot_actual] ...
          = this.keplerian_orbit.secularPerturbations;
      
      t = [];
      t = [t; abs(Omega_dot_actual - Omega_dot_expected) < this.HIGH_PRECISION];
      t = [t; abs(omega_dot_actual - omega_dot_expected) < this.HIGH_PRECISION];
      t = [t; abs(M_0_dot_actual - M_0_dot_expected) < this.HIGH_PRECISION];
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'secularPerturbations', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_secularPerturbations()
    
    function test_keplersEquation(this)
    % Tests keplersEquation method.
      
      E_expected = this.M; % e = 0, so E = M
      
      E_actual = this.keplerian_orbit.keplersEquation(this.M);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'keplersEquation', ...
          this.HIGH_PRECISION_DESC, ...
          abs(E_actual - E_expected) < this.HIGH_PRECISION);
      
    end % test_keplersEquation()
    
    function test_r_goi(this)
    % Tests r_goi method.
      
      r_goi_expected = ...
          EarthConstants.a_gso ...
          * [cos(pi / 4)
             sin(pi / 4)
             0
            ]; % e = 0, so r = a
      
      r_goi_actual = ...
          this.keplerian_orbit.r_goi(this.keplerian_orbit.keplersEquation(this.M));
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'r_goi', ...
          this.HIGH_PRECISION_DESC, ...
          sqrt((r_goi_actual - r_goi_expected)' ...
               * (r_goi_actual - r_goi_expected)) < this.HIGH_PRECISION);
      
    end % test_r_goi()
    
    function test_v_goi(this)
    % tests v_goi method.
      
      v_goi_expected = ...
          sqrt(EarthConstants.GM_oplus / (this.a * EarthConstants.R_oplus)) / EarthConstants.R_oplus ...
          * [-sin(pi / 4)
             +cos(pi / 4)
             0
            ]; % e = 0, so v = sqrt(GM_oplus / a)
      
      v_goi_actual = this.keplerian_orbit.v_goi(this.M);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'v_goi', ...
          this.HIGH_PRECISION_DESC, ...
          sqrt((v_goi_actual - v_goi_expected)' ...
               * (v_goi_actual - v_goi_expected)) < this.HIGH_PRECISION);
      
    end % test_v_goi()
    
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
            ]; % e = 0, so r = a
      
      r_gei_actual = this.keplerian_orbit.r_gei(this.epoch);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'r_gei', ...
          this.HIGH_PRECISION_DESC, ...
          sqrt((r_gei_actual - r_gei_expected)' ...
               * (r_gei_actual - r_gei_expected)) < this.HIGH_PRECISION);
      
    end % test_r_gei()
    
    function test_v_gei(this)
    % Tests v_gei method.
      
      v_gei_expected = ...
          (1 / 2) ...
          * [+1 - cos(this.i), -1 - cos(this.i), +sqrt(2) * sin(this.i)
             +1 + cos(this.i), -1 + cos(this.i), -sqrt(2) * sin(this.i)
             sqrt(2) * sin(this.i), sqrt(2) * sin(this.i), 2 * cos(this.i)
            ] ...
          * sqrt(EarthConstants.GM_oplus / (this.a * EarthConstants.R_oplus)) / EarthConstants.R_oplus ...
          * [-sin(pi / 4)
             +cos(pi / 4)
             0
            ]; % e = 0, so v = sqrt(GM_oplus / a)
      
      v_gei_actual = this.keplerian_orbit.v_gei(this.epoch);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'v_gei', ...
          this.HIGH_PRECISION_DESC, ...
          sqrt((v_gei_actual - v_gei_expected)' ...
               * (v_gei_actual - v_gei_expected)) < this.HIGH_PRECISION);
      
    end % test_v_gei()
    
    function test_element_set(this);
    % Tests element_set method.
      
      e = 0.001; % Method does not work well for small eccentricity
      keplerian_orbit = KeplerianOrbit(this.a, ...
                                       e, ...
                                       this.i, ...
                                       this.Omega, ...
                                       this.omega, ...
                                       this.M, ...
                                       this.epoch, ...
                                       this.method);
      
      element_set_expected = ...
          [this.a, e, this.i, ...
           this.Omega, this.omega, this.M];
      
      element_set_actual = keplerian_orbit.element_set( ...
          keplerian_orbit.r_gei(this.epoch), ...
          keplerian_orbit.v_gei(this.epoch));
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'element_set', ...
          this.MEDIUM_PRECISION_DESC, ...
          sqrt((element_set_actual - element_set_expected)' ...
               * (element_set_actual - element_set_expected)) < this.MEDIUM_PRECISION);
      
    end % test_element_set()
    
    function test_set_a(this)
    % Tests set_a method.
      
      this.keplerian_orbit.set_a(this.a);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'set_a', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.keplerian_orbit.a, this.a));
      
    end % test_set_a()
    
    function test_set_e(this)
    % Tests set_e method.
      
      this.keplerian_orbit.set_e(this.e);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'set_e', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.keplerian_orbit.e, this.e));
      
    end % test_set_e()
    
    function test_set_i(this)
    % Tests set_i method.
      
      this.keplerian_orbit.set_i(this.i);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'set_i', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.keplerian_orbit.i, this.i));
      
    end % test_set_i()
    
    function test_set_Omega(this)
    % Tests set_Omega method.
      
      this.keplerian_orbit.set_Omega(this.Omega);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'set_Omega', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.keplerian_orbit.Omega, this.Omega));
      
    end % test_set_Omega()
    
    function test_set_omega(this)
    % Tests set_omega method.
      
      this.keplerian_orbit.set_omega(this.omega);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'set_omega', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.keplerian_orbit.omega, this.omega));
      
    end % test_set_omega()
    
    function test_set_M(this)
    % Tests set_M method.
      
      this.keplerian_orbit.set_M(this.M);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'set_M', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.keplerian_orbit.M, this.M));
      
    end % test_set_M()
    
    function test_set_epoch(this)
    % Tests set_epoch method.
      
      this.keplerian_orbit.set_epoch(this.epoch);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'set_epoch', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.keplerian_orbit.epoch, this.epoch));
      
    end % test_set_epoch()
    
    % TODO: Test set methods side effects

    function test_set_method(this)
    % Tests set_method method.
      
      this.keplerian_orbit.set_method(this.method);
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'set.method', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.keplerian_orbit.method, this.method));
      
    end % test_set_method()
    
    function test_isEmpty(this)
    % Tests isEmpty method.
      
      is_expected_ne = 0;
      
      is_actual_ne = this.keplerian_orbit.isEmpty;
      
      ko = KeplerianOrbit;
      
      is_expected_e = 1;
      
      is_actual_e = ko.isEmpty;
      
      this.assert_true( ...
          'KeplerianOrbit', ...
          'isEmpty', ...
          this.IS_EQUAL_DESC, ...
          isequal(is_actual_ne, is_expected_ne) && isequal(is_actual_e, is_expected_e));
      
    end % test_isEmpty()
    
    % TODO: Test function is = isEqual(this, that)

  end % methods
  
end % classdef
