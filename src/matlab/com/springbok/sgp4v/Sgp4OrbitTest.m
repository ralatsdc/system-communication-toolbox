classdef Sgp4OrbitTest < TestUtility
% Tests methods of Sgp4Orbit class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    % Input semi-major axis [er]
    a = EarthConstants.a_gso;
    % Input eccentricity [-]
    e = eps;
    % Input inclination [rad]
    i = 1 * pi / 180;
    % Input right ascension of the ascending node [rad]
    Omega = pi / 4;
    % Input argument of perigee [rad]
    omega = pi / 4;
    % Input mean anomaly [rad]
    M = pi / 4;
    % Input epoch date number
    epoch = datenum('01/01/2000 12:00:00');
    
    % Input method to solve Kepler's equation: 'newton' or 'halley'
    method = 'halley';
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % An Sgp4 orbit
    sgp4_orbit
    
    % A Keplerian orbit
    kep_orbit
    
  end % properties (Access = private)
  
  methods
    
    function this = Sgp4OrbitTest(logFId, testMode)
    % Constructs an Sgp4OrbitTest.
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
      this.sgp4_orbit = Sgp4Orbit(this.a, ...
                                  this.e, ...
                                  this.i, ...
                                  this.Omega, ...
                                  this.omega, ...
                                  this.M, ...
                                  this.epoch, ...
                                  this.method);
      
      this.kep_orbit = KeplerianOrbit(this.a, ...
                                      this.e, ...
                                      this.i, ...
                                      this.Omega, ...
                                      this.omega, ...
                                      this.M, ...
                                      this.epoch, ...
                                      this.method);
      
    end % Sgp4OrbitTest()
    
    function test_Sgp4Orbit(this)
    % Tests Sgp4Orbit method.
      
      n_expected = sqrt(EarthConstants.GM_oplus / (this.a * EarthConstants.R_oplus)^3);
      T_expected = 2 * pi * sqrt((this.a * EarthConstants.R_oplus)^3 / EarthConstants.GM_oplus);
      
      is_expected_ne = 0;

      is_actual_ne = this.sgp4_orbit.isEmpty();
      
      so = Sgp4Orbit;
      
      is_expected_e = 1;

      is_actual_e = so.isEmpty();
      
      t = [];
      t = [t; isequal(this.sgp4_orbit.a, this.a)];
      t = [t; isequal(this.sgp4_orbit.e, this.e)];
      t = [t; isequal(this.sgp4_orbit.i, this.i)];
      t = [t; isequal(this.sgp4_orbit.Omega, this.Omega)];
      t = [t; isequal(this.sgp4_orbit.omega, this.omega)];
      t = [t; isequal(this.sgp4_orbit.M, this.M)];
      t = [t; isequal(this.sgp4_orbit.epoch, this.epoch)];
      t = [t; isequal(this.sgp4_orbit.method, this.method)];
      t = [t; abs(this.sgp4_orbit.n - n_expected) < this.HIGH_PRECISION];
      t = [t; abs(this.sgp4_orbit.T - T_expected) < this.HIGH_PRECISION];
      t = [t; isequal(is_actual_ne, is_expected_ne) && isequal(is_actual_e, is_expected_e)];
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'Sgp4Orbit', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_Sgp4Orbit()
    
    function test_meanMotion(this)
    % Tests meanMotion method.
      
      n_expected = sqrt(EarthConstants.GM_oplus / (this.a * EarthConstants.R_oplus)^3);
      
      n_actual = this.sgp4_orbit.meanMotion();
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'meanMotion', ...
          this.HIGH_PRECISION_DESC, ...
          abs(n_actual - n_expected) < this.HIGH_PRECISION);
      
    end % test_meanMotion()
    
    function test_meanPosition(this)
    % Tests meanPosition method.
      
      delta_dNm = this.sgp4_orbit.T / 86400;
      dNm = this.epoch + delta_dNm;
      
      M_actual = this.sgp4_orbit.meanPosition(dNm);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'meanPosition', ...
          this.LOW_PRECISION_DESC, ...
          abs(M_actual - this.M) < this.LOW_PRECISION);
      
    end % test_meanPosition()
    
    function test_orbitalPeriod(this)
    % Tests orbitalPeriod method.
      
      T_expected = 2 * pi * sqrt((this.a * EarthConstants.R_oplus)^3 / EarthConstants.GM_oplus);
      
      T_actual = this.sgp4_orbit.orbitalPeriod();
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'orbitalPeriod', ...
          this.HIGH_PRECISION_DESC, ...
          abs(T_actual - T_expected) < this.HIGH_PRECISION);
      
    end % test_orbitalPeriod()
    
    function test_r_gei(this)
    % Tests r_gei method.
      
    % TODO: Need an independent value, otherwise the
    % following test is for reproducibility only
      r_gei_expected = ...
          [-4.674474166473236
           4.672893574069736
           0.117269676930363
          ];
      
      r_gei_actual = this.sgp4_orbit.r_gei(this.epoch);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'r_gei', ...
          this.HIGH_PRECISION_DESC, ...
          sqrt((r_gei_actual - r_gei_expected)' ...
               * (r_gei_actual - r_gei_expected)) < this.HIGH_PRECISION);
      
      r_gei_expected = this.kep_orbit.r_gei(this.epoch);
      
      r_gei_actual = this.sgp4_orbit.r_gei(this.epoch);
      
      % TODO: Need to confirm this difference is reasonable
      this.assert_true( ...
          'Sgp4Orbit', ...
          'r_gei:keplerian', ...
          'Within 20 km', ...
          sqrt((r_gei_actual - r_gei_expected)' ...
               * (r_gei_actual - r_gei_expected)) < 20 / EarthConstants.R_oplus);
      
    end % test_r_gei()
    
    function test_v_gei(this)
    % Tests v_gei method.
      
    % TODO: Need an independent value, otherwise the
    % following test is for reproducibility only
      v_gei_expected = ...
          [-0.340823152695732
           -0.340935555465286
           -0.000094591588823
          ] * 1.0e-03;
      
      v_gei_actual = this.sgp4_orbit.v_gei(this.epoch);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'v_gei', ...
          this.HIGH_PRECISION_DESC, ...
          sqrt((v_gei_actual - v_gei_expected)' ...
               * (v_gei_actual - v_gei_expected)) < this.HIGH_PRECISION);
      
      v_gei_expected = this.kep_orbit.v_gei(this.epoch);
      
      v_gei_actual = this.sgp4_orbit.v_gei(this.epoch);
      
      % TODO: Need to confirm this difference is reasonable
      this.assert_true( ...
          'Sgp4Orbit', ...
          'v_gei:keplerian', ...
          'Within 1 m/s', ...
          sqrt((v_gei_actual - v_gei_expected)' ...
               * (v_gei_actual - v_gei_expected)) < 0.001 / EarthConstants.R_oplus);
      
    end % test_v_gei()
    
    function test_set_a(this)
    % Tests set_a method.
      
      this.sgp4_orbit.set_a(this.a);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'set_a', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.sgp4_orbit.a, this.a));
      
    end % test_set_a()
    
    function test_set_e(this)
    % Tests set_e method.
      
      this.sgp4_orbit.set_e(this.e);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'set_e', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.sgp4_orbit.e, this.e));
      
    end % test_set_e()
    
    function test_set_i(this)
    % Tests set_i method.
      
      this.sgp4_orbit.set_i(this.i);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'set_i', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.sgp4_orbit.i, this.i));
      
    end % test_set_i()
    
    function test_set_Omega(this)
    % Tests set_Omega method.
      
      this.sgp4_orbit.set_Omega(this.Omega);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'set_Omega', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.sgp4_orbit.Omega, this.Omega));
      
    end % test_set_Omega()
    
    function test_set_omega(this)
    % Tests set_omega method.
      
      this.sgp4_orbit.set_omega(this.omega);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'set_omega', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.sgp4_orbit.omega, this.omega));
      
    end % test_set_omega()
    
    function test_set_M(this)
    % Tests set_M method.
      
      this.sgp4_orbit.set_M(this.M);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'set_M', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.sgp4_orbit.M, this.M));
      
    end % test_set_M()
    
    function test_set_epoch(this)
    % Tests set_epoch method.
      
      this.sgp4_orbit.set_epoch(this.epoch);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'set_epoch', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.sgp4_orbit.epoch, this.epoch));
      
    end % test_set_epoch()
    
    function test_set_method(this)
    % Tests set_method method.
      
      this.sgp4_orbit.set_method(this.method);
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'set.method', ...
          this.IS_EQUAL_DESC, ...
          isequal(this.sgp4_orbit.method, this.method));
      
    end % test_set_method()
    
    function test_isEmpty(this)
    % Tests isEmpty method.
      
      is_expected_ne = 0;
      
      is_actual_ne = this.sgp4_orbit.isEmpty();
      
      so = Sgp4Orbit;
      
      is_expected_e = 1;
      
      is_actual_e = so.isEmpty();
      
      this.assert_true( ...
          'Sgp4Orbit', ...
          'isEmpty', ...
          this.IS_EQUAL_DESC, ...
          isequal(is_actual_ne, is_expected_ne) && isequal(is_actual_e, is_expected_e));
      
    end % test_isEmpty()
    
    % TODO: Test function sgp4Orb = fitSgp4OrbitFromKeplerianOrbit(kepOrb)
    % TODO: Test function sgp4Orb = fitSgp4OrbitFromKeplerianOrbit(kepOrb)

  end % methods
  
end % classdef
