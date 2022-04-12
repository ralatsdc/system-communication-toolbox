classdef HohmannTransferTest < TestUtility
% Tests methods of HohmannTransfer class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    % Initial orbit semi-major axis [er]
    a_1 = 1 + 300 / EarthConstants.R_oplus;
    % Initial orbit eccentricity [-]
    e_1 = 0.001;
    % Initial orbit inclination [rad]
    i_1 = 1 * pi / 180;
    % Initial orbit right ascension of the ascending node [rad]
    Omega_1 = pi / 4;
    % Initial orbit argument of perigee [rad]
    omega_1 = 0.0;
    % Initial orbit mean anomaly [rad]
    M_1 = 0.0;
    % Initial orbit epoch date number
    epoch_1 = datenum('01/01/2000 12:00:00');
    % Initial orbit method to solve Kepler's equation: 'newton' or 'halley'
    method_1 = 'halley';
    
    % Final orbit semi-major axis [er]
    a_2 = EarthConstants.a_gso;
    % Final orbit eccentricity [-]
    e_2 = 0.001;
    % Final orbit inclination [rad]
    i_2 = 1 * pi / 180;
    % Final orbit right ascension of the ascending node [rad]
    Omega_2 = pi / 4;
    % Final orbit argument of perigee [rad]
    omega_2 = 0.0;
    % Final orbit mean anomaly [rad]
    M_2 = 0.0;
    % Final orbit epoch date number
    epoch_2 = datenum('01/01/2000 12:00:00');
    % Final orbit method to solve Kepler's equation: 'newton' or 'halley'
    method_2 = 'halley';
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % Initial Keplerian orbit
    kep_orb_1
    % Final Keplerian orbit
    kep_orb_2
    % A HohmannTransfer
    hohmann_transfer
    
  end % properties (Access = private)
  
  methods
    
    function this = HohmannTransferTest(logFId, testMode)
    % Constructs a HohmannTransferTest.
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
      this.kep_orb_1 = KeplerianOrbit( ...
          this.a_1, this.e_1, this.i_1, this.Omega_1, this.omega_1, ...
          this.M_1, this.epoch_1, this.method_1);
      this.kep_orb_2 = KeplerianOrbit( ...
          this.a_2, this.e_2, this.i_2, this.Omega_2, this.omega_2, ...
          this.M_2, this.epoch_2, this.method_2);
      
      % Compute derived properties
      this.hohmann_transfer = HohmannTransfer(this.kep_orb_1, this.kep_orb_2);
      
    end % HohmannTransferTest()
    
    function test_HohmannTransfer(this)
    % Tests HohmannTransfer method. Note that the
    % HohmannTransfer method invokes the computeTransferOrbit
    % method, which is therefore tested implicitly.
      
      % Initial orbit perigee
      r_1 = this.kep_orb_1.a * (1 - this.kep_orb_1.e);
      % Final orbit apogee
      r_2 = this.kep_orb_2.a * (1 + this.kep_orb_2.e);
      
      % Transfer orbit semi-major axis [er]
      a_t = (r_2 + r_1) / 2;
      % Transfer orbit eccentricity [-]
      e_t = (r_2 - r_1) / (r_2 + r_1);
      % Transfer orbit inclination [rad]
      i_t = 1 * pi / 180;
      % Transfer orbit right ascension of the ascending node [rad]
      Omega_t = pi / 4;
      % Transfer orbit argument of perigee [rad]
      omega_t = 0.0;
      % Transfer orbit mean anomaly [rad]
      M_t = 0.0; % perigee
                 % Transfer orbit epoch date number
                 % epoch_t = this.kep_orb_1.epoch + (2 * pi - this.kep_orb_1.M) / this.kep_orb_1.n / 86400;
      epoch_t = this.kep_orb_1.epoch;
      % Transfer orbit method to solve Kepler's equation: 'newton' or 'halley'
      method_t = 'halley';
      
      % Transfer Keplerian orbit
      kep_orb_t_expected = KeplerianOrbit( ...
          a_t, e_t, i_t, Omega_t, omega_t, M_t, epoch_t, method_t);
      
      % Final orbit epoch date number
      epoch_2 = kep_orb_t_expected.epoch + (1 / 2) * (kep_orb_t_expected.T / (60 * 60 * 24));
      % Final orbit mean anomaly [rad]
      M_2 = pi; % apogee
      this.kep_orb_2.set_epoch(epoch_2);
      this.kep_orb_2.set_M(M_2);
      
      % Velocities of object in the initial and transfer orbit at
      % perigee of the transfer orbit, and in the transfer and
      % final orbit at apogee of the transfer orbit
      GM_oplus = EarthConstants.GM_oplus / EarthConstants.R_oplus^3;
      % [er^3/s^2] = [km^3/s^2] / [km/er]^3
      % v_1_expected = 0.001214505806978;
      v_1_expected = sqrt(GM_oplus / r_1);
      % v_t_p_expected = 0.001595372542303;
      v_t_p_expected = sqrt(GM_oplus * (2 / r_1 - 1 / a_t));
      % v_t_a_expected = 2.519085977508362e-04;
      v_t_a_expected = sqrt(GM_oplus  * (2 / r_2 - 1 / a_t));
      % v_2_expected = 4.821206569111397e-04;
      v_2_expected = sqrt(GM_oplus  / r_2);
      
      % Change in velocity required to enter and exit the transfer
      % orbit
      % delta_v_p_expected = 3.808667353253259e-04;
      delta_v_p_expected = v_t_p_expected - v_1_expected;
      % delta_v_a_expected = 2.302120591603035e-04;
      delta_v_a_expected = v_2_expected - v_t_a_expected;
      
      t = [];
      
      t = [t, this.isEqualKepOrb(this.hohmann_transfer.kep_orb_1, this.kep_orb_1, this.HIGH_PRECISION)];
      t = [t, this.isEqualKepOrb(this.hohmann_transfer.kep_orb_2, this.kep_orb_2, this.HIGH_PRECISION)];
      t = [t, this.isEqualKepOrb(this.hohmann_transfer.kep_orb_t, kep_orb_t_expected, this.HIGH_PRECISION)];
      
      t = [t, abs(this.hohmann_transfer.v_1 - v_1_expected) < SimulationConstants.precision_E];
      t = [t, abs(this.hohmann_transfer.v_t_p - v_t_p_expected) < this.HIGH_PRECISION];
      t = [t, abs(this.hohmann_transfer.v_t_a - v_t_a_expected) < this.HIGH_PRECISION];
      t = [t, abs(this.hohmann_transfer.v_2 - v_2_expected) < SimulationConstants.precision_E];
      
      t = [t, abs(this.hohmann_transfer.delta_v_p - delta_v_p_expected) < SimulationConstants.precision_E];
      t = [t, abs(this.hohmann_transfer.delta_v_a - delta_v_a_expected) < SimulationConstants.precision_E];
      
      this.assert_true( ...
          'HohmannTransfer', ...
          'HohmannTransfer', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_HohmannTransfer()
    
    function test_simulateTransferOrbit(this)
    % Tests simulateTransferOrbit method. Note that the
    % simulateTransferOrbit method invokes the simulateManeuver
    % method, which is therefore tested implicitly.
      
      kep_orb_s_1_expected = KeplerianOrbit( ...
          1.047035678286622, 1.000000000000000e-03, ...
          0.017453292519943,  0.785398163397448, 0, 0, ...
          7.304865000000000e+05, 'halley');
      
      
      kep_orb_s_n_expected = KeplerianOrbit( ...
          6.551475690203933, 0.032125516186132, 0.017453292519943, ...
          0.785398163397448, 1.469735441958401, 1.639834091986445, ...
          7.304867200339150e+05, 'halley');
      
      kep_orb_s = this.hohmann_transfer.simulateTransferOrbit( ...
          100, 50, 'velocity-to-be-gained', 0);
      
      t = [];
      
      t = [t, this.isEqualKepOrb(kep_orb_s(1), kep_orb_s_1_expected, this.MEDIUM_PRECISION)];
      t = [t, this.isEqualKepOrb(kep_orb_s(end), kep_orb_s_n_expected, this.MEDIUM_PRECISION)];
      
      this.assert_true( ...
          'HohmannTransfer', ...
          'simulateTransferOrbit', ...
          this.MEDIUM_PRECISION_DESC, ...
          min(t));
      
    end % test_simulateTransferOrbit()
    
    function test_set_kep_orb_1(this)
    % Tests set_kep_orb_1 method.
      
      kep_orb_1_expected = KeplerianOrbit( ...
          this.a_1 + 1, this.e_1, this.i_1, this.Omega_1, this.omega_1, ...
          this.M_1, this.epoch_1, this.method_1);
      
      hohmann_transfer_actual = HohmannTransfer(this.kep_orb_1, this.kep_orb_2);
      
      % The set_kep_orb_1 method invokes the computeTransferOrbit
      % method, which is tested above, implicitly.
      hohmann_transfer_actual.set_kep_orb_1(kep_orb_1_expected);
      
      t = [];
      
      t = [t, this.isEqualKepOrb(hohmann_transfer_actual.kep_orb_1, kep_orb_1_expected, this.HIGH_PRECISION)];
      
      this.assert_true( ...
          'HohmannTransfer', ...
          'set_kep_orb_1', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_set_kep_orb_1()
    
    function test_set_kep_orb_2(this)
    % Tests set_kep_orb_2 method.
      
      kep_orb_2_expected = KeplerianOrbit( ...
          this.a_2 + 1, this.e_2, this.i_2, this.Omega_2, this.omega_2, ...
          this.M_2, this.epoch_2, this.method_2);
      
      hohmann_transfer_actual = HohmannTransfer(this.kep_orb_1, this.kep_orb_2);
      
      % The set_kep_orb_2 method invokes the computeTransferOrbit
      % method, which is tested above, implicitly.
      hohmann_transfer_actual.set_kep_orb_2(kep_orb_2_expected);
      
      epoch_2 = hohmann_transfer_actual.kep_orb_t.epoch ...
                + (1 / 2) * (hohmann_transfer_actual.kep_orb_t.T / (60 * 60 * 24));
      M_2 = pi; % apogee
      kep_orb_2_expected.set_epoch(epoch_2);
      kep_orb_2_expected.set_M(M_2);
      
      t = [];
      
      t = [t, this.isEqualKepOrb(hohmann_transfer_actual.kep_orb_2, kep_orb_2_expected, this.HIGH_PRECISION)];
      
      this.assert_true( ...
          'HohmannTransfer', ...
          'set_kep_orb_2', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_set_kep_orb_2()
    
    function t = isEqualKepOrb(this, kep_orb_1, kep_orb_2, precision)
    % Tests equality of two KeplerianOrbits with the specified
    % precision.
      
      t = [];
      t = [t, abs(kep_orb_2.a - kep_orb_1.a) < precision];
      t = [t, abs(kep_orb_2.e - kep_orb_1.e) < precision];
      t = [t, abs(kep_orb_2.i - kep_orb_1.i) < precision];
      t = [t, abs(kep_orb_2.Omega - kep_orb_1.Omega) < precision];
      t = [t, abs(kep_orb_2.omega - kep_orb_1.omega) < precision];
      t = [t, abs(kep_orb_2.M - kep_orb_1.M) < precision];
      t = [t, abs(kep_orb_2.epoch - kep_orb_1.epoch) < precision];
      t = [t, strcmp(kep_orb_2.method, kep_orb_1.method)];
      
    end % isEqualKepOrb()
    
    % TODO: Test function [kep_orb_s, sgp4_orb_s, delta_v_t] = simulateManeuver( ...
    %   kep_orb_i, kep_orb_f, t_0, t_cut_off, delta_v, n_impulse, mode, do_circ, do_fit)

  end % methods
  
end % classdef
