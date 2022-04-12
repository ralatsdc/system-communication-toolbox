classdef OrbitDeterminationTest < TestUtility
% Tests methods of OrbitDetermination class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    % Semi-major axis [er]
    a = 6.618108053001019;
    % Eccentricity [-]
    e = 0.1 % eps;
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
    method = 'halley'; % = 'halley' expected from podGuass()
    
    % First date number
    dNm_a = datenum('01/01/2000 12:00:00'); % = epoch expected from podGuass()
    % Second date number
    dNm_b = datenum('01/01/2000 14:00:00');
    
  end % properties (Constant = true)
  
  properties % (Access = private)
    
    % A Keplerian orbit
    kep_orb
    
    % First inertial geocentric position vector
    kep_r_a
    % Second inertial geocentric position vector
    kep_r_b
    
    % The preliminary Keplerian orbit
    kep_orb_p
    
    % Date numbers of measured position
    kep_obs_dNm
    % Measured geocentric equatorial inertial position
    kep_obs_gei
    
    % A corrected orbit
    kep_orb_c
    
    % A Sgp4 orbit
    sgp4_orb
    
    % First inertial geocentric position vector
    sgp4_r_a
    % Second inertial geocentric position vector
    sgp4_r_b
    
    % The preliminary Sgp4 orbit
    sgp4_orb_p
    
    % Date numbers of measured position
    sgp4_obs_dNm
    % Measured geocentric equatorial inertial position
    sgp4_obs_gei
    
    % A corrected orbit
    sgp4_orb_c
    
    % The numerical technique used: 'Levenberg-Marquardt' or 'Guass-Newton'
    option
    % A status message
    status
    
  end % properties (Access = private)
  
  methods
    
    function this = OrbitDeterminationTest(logFId, testMode)
    % Constructs an OrbitDeterminationTest.
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
      this.kep_orb = KeplerianOrbit(this.a, ...
                                    this.e, ...
                                    this.i, ...
                                    this.Omega, ...
                                    this.omega, ...
                                    this.M, ...
                                    this.epoch, ...
                                    this.method);
      
      this.kep_r_a = this.kep_orb.r_gei(this.dNm_a);
      this.kep_r_b = this.kep_orb.r_gei(this.dNm_b);
      
      this.kep_orb_p = this.kep_orb;
      
      for dNm = this.dNm_a : (2.0 / 24.0) / (4 * 6) : this.dNm_b
        this.kep_obs_dNm = [this.kep_obs_dNm, dNm];
        this.kep_obs_gei = [this.kep_obs_gei, this.kep_orb.r_gei(dNm)];
      end % for
      
      this.kep_orb_c = this.kep_orb;
      
      this.sgp4_orb = Sgp4Orbit(this.a, ...
                                this.e, ...
                                this.i, ...
                                this.Omega, ...
                                this.omega, ...
                                this.M, ...
                                this.epoch, ...
                                this.method);
      
      this.sgp4_r_a = this.sgp4_orb.r_gei(this.dNm_a);
      this.sgp4_r_b = this.sgp4_orb.r_gei(this.dNm_b);
      
      this.sgp4_orb_p = this.sgp4_orb;
      
      for dNm = this.dNm_a : (2.0 / 24.0) / (4 * 6) : this.dNm_b
        this.sgp4_obs_dNm = [this.sgp4_obs_dNm, dNm];
        this.sgp4_obs_gei = [this.sgp4_obs_gei, this.sgp4_orb.r_gei(dNm)];
      end % for
      
      this.sgp4_orb_c = this.sgp4_orb;
      
      this.option = 'Levenberg-Marquardt';
      this.status = 'differential correction successful';
      
    end % EquinoctialOrbitTest()
    
    function test_podGauss(this)
    % Tests podGuass method. Calls, directly or indirectly, f_ and
    % W_, which are tested implicitly.
      
      kep_orb_p_actual = OrbitDetermination.podGauss(this.dNm_a, ...
                                              this.kep_r_a, ...
                                              this.dNm_b, ...
                                              this.kep_r_b);
      
      t = [];
      t = [t, abs(kep_orb_p_actual.a - this.kep_orb_p.a) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_p_actual.e - this.kep_orb_p.e) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_p_actual.i - this.kep_orb_p.i) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_p_actual.Omega - this.kep_orb_p.Omega) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_p_actual.omega - this.kep_orb_p.omega) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_p_actual.M - this.kep_orb_p.M) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_p_actual.epoch - this.kep_orb_p.epoch) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_p_actual.method - this.kep_orb_p.method) < this.HIGH_PRECISION];

      this.assert_true( ...
          'OrbitDetermination', ...
          'podGauss', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_podGauss()
    
    function test_docLSqNonlin(this)
    % Tests docLSqNonlin method. Calls, directly or indirectly,
    % funLSqNonlin, which is tested implicitly.
      
      [kep_orb_c_actual, status_actual] = OrbitDetermination.docLSqNonlin( ...
          this.kep_orb_p, this.kep_obs_dNm, this.kep_obs_gei);
      
      t = [];
      t = [t, abs(kep_orb_c_actual.a - this.kep_orb_c.a) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.e - this.kep_orb_c.e) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.i - this.kep_orb_c.i) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.Omega - this.kep_orb_c.Omega) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.omega - this.kep_orb_c.omega) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.M - this.kep_orb_c.M) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.epoch - this.kep_orb_c.epoch) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.method - this.kep_orb_c.method) < this.HIGH_PRECISION];
      t = [t, isequal(status_actual, this.status)];
      
      this.assert_true( ...
          'OrbitDetermination', ...
          'docLSqNonlin:keplerian', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [sgp4_orb_c_actual, status_actual] = OrbitDetermination.docLSqNonlin( ...
          this.sgp4_orb_p, this.sgp4_obs_dNm, this.sgp4_obs_gei);
      
      t = [];
      t = [t, abs(sgp4_orb_c_actual.a - this.sgp4_orb_c.a) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.e - this.sgp4_orb_c.e) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.i - this.sgp4_orb_c.i) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.Omega - this.sgp4_orb_c.Omega) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.omega - this.sgp4_orb_c.omega) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.M - this.sgp4_orb_c.M) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.epoch - this.sgp4_orb_c.epoch) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.method - this.sgp4_orb_c.method) < this.HIGH_PRECISION];
      t = [t, isequal(status_actual, this.status)];
      
      this.assert_true( ...
          'OrbitDetermination', ...
          'docLSqNonlin:sgp4', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_docLSqNonlin()
    
    function test_docNumerical(this)
    % Tests docNumerical method. Calls, directly or indirectly,
    % searchLine, computeCorrection, applyCorrection, and
    % jacobianNumerical, which are tested implicitly.
      
      [kep_orb_c_actual, status_actual] = OrbitDetermination.docNumerical( ...
          this.kep_orb_p, this.kep_obs_dNm, this.kep_obs_gei, this.option);
      
      t = [];
      t = [t, abs(kep_orb_c_actual.a - this.kep_orb_c.a) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.e - this.kep_orb_c.e) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.i - this.kep_orb_c.i) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.Omega - this.kep_orb_c.Omega) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.omega - this.kep_orb_c.omega) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.M - this.kep_orb_c.M) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.epoch - this.kep_orb_c.epoch) < this.HIGH_PRECISION];
      t = [t, abs(kep_orb_c_actual.method - this.kep_orb_c.method) < this.HIGH_PRECISION];
      t = [t, isequal(status_actual, this.status)];
      
      this.assert_true( ...
          'OrbitDetermination', ...
          'docNumerical:keplerian', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [sgp4_orb_c_actual, status_actual] = OrbitDetermination.docNumerical( ...
          this.sgp4_orb_p, this.sgp4_obs_dNm, this.sgp4_obs_gei, this.option);
      
      t = [];
      t = [t, abs(sgp4_orb_c_actual.a - this.sgp4_orb_c.a) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.e - this.sgp4_orb_c.e) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.i - this.sgp4_orb_c.i) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.Omega - this.sgp4_orb_c.Omega) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.omega - this.sgp4_orb_c.omega) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.M - this.sgp4_orb_c.M) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.epoch - this.sgp4_orb_c.epoch) < this.HIGH_PRECISION];
      t = [t, abs(sgp4_orb_c_actual.method - this.sgp4_orb_c.method) < this.HIGH_PRECISION];
      t = [t, isequal(status_actual, this.status)];
      
      this.assert_true( ...
          'OrbitDetermination', ...
          'docNumerical:sgp4', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_docNumerical()
    
  end % methods
  
end % classdef
