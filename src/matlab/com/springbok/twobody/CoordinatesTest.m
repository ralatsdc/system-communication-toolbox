classdef CoordinatesTest < TestUtility
% Tests methods of Coordinates class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    % Position vector [er]
    r = [1, 1, 1];
    % Rotation angle [rad]
    phi = 45 * (pi / 180);
    
    % Date number at which the position vectors occur
    dNm = datenum('01/01/2000 12:00:00');
    % Geocentric equatorial inertial position vector [er]
    r_gei = 2 * [-1; 1; -1];
    % Geocentric equatorial rotating position vector [er]
    r_ger_a = ...
        [-2.329878657530266;
         -1.603641306896578;
         -2.000000000000000
        ]; % (MG-2.89)
           %
           % Coordinates.R_z(EarthConstants.Theta(CoordinatesTest.dNm))
           % * CoordinatesTest.r_gei
    % Geocentric latitude, longitude, and altitude [rad, rad, er]
    r_lla = ...
        [-0.615479708670387;
         +3.744418905253123;
         +2.464101615137754
        ]; % (Inverse of MG-2.90 modified for arbitrary
           % altitude, See also MG-5.88)
           %
           % atan2(CoordinatesTest.r_ger(3),
           % sqrt(CoordinatesTest.r_ger(1:2)' *
           % CoordinatesTest.r_ger(1:2)))
           %
           % Coordinates.check_wrap(atan2(CoordinatesTest.r_ger(2),
           % CoordinatesTest.r_ger(1)))
           %
           % sqrt(CoordinatesTest.r_ger' *
           % CoordinatesTest.r_ger) - 1

    % Geodetic latitude, longitude, and altitude [rad, rad, er]
    r_glla = ...
        [+39.2240867222 * (pi / 180.0); ...  % [rad] = [deg] * [rad / deg]
         -98.5421515000 * (pi / 180.0); ...  % [rad] = [deg] * [rad / deg]
         +3000.0 / (1000.0 * EarthConstants.R_oplus)];  % [er] = [m] / ([m / km] * [km / er])
    % Geocentric equatorial rotating position vector [er]
    r_ger_b = ...
        [-735.251723; ...
         -4895.047044; ...
         +4013.516929] / EarthConstants.R_oplus;  % [er] = [km] / [km / er]
    % https://geodesy.noaa.gov/NCAT/

    % East unit vector in geocentric equatorial rotating
    % coordinates for the input Earth station
    e_E = ...
        [-0.833976634492313
         +0.551799758173990
         +0.0
        ]; % (MG-2.92)
           % North unit vector in geocentric equatorial rotating
           % coordinates for the input Earth station
    e_N = ...
        [-0.135457558746091
         -0.204727235353353
         -0.969400850465442
        ]; % (MG-2.92)
           % Zenith unit vector in geocentric equatorial rotating
           % coordinates for the input Earth station
    e_Z = ...
        [-0.534915154860491
         -0.808457658745156
         +0.245483178887837
        ]; % (MG-2.92)
    
    % Local tangent position vector [er]
    r_ltp = ...
        [+1.058175476239208;
         +2.581117033547451;
         +1.051998870244891]; % (MG-2.94)
                              %
                              % earthStation =
                              % EarthStation('test',
                              % CoordinatesTest.varphi,
                              % CoordinatesTest.lambda);
                              %
                              % Coordinates.E_e2t(earthStation)
                              % *
                              % (Coordinates.R_z(EarthConstants.Theta(CoordinatesTest.dNm))
                              % * CoordinatesTest.r_gei -
                              % earthStation.R_ger)
                              % Range, azimuth, and elevation [er, rad, rad]
    rng = 2.981375874052011;
    azm = 0.389069865097019;
    elv = 0.360622584861772; % (MG-2.95)
                             %
                             % sqrt(r_ltp' * r_ltp)
                             %
                             % atan2(r_ltp(1),
                             % r_ltp(2))
                             %
                             % atan2(r_ltp(3),
                             % sqrt(r_ltp(1:2)' *
                             % r_ltp(1:2)))
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % An Earth station
    earthStation

    % Expected range, azimuth, and elevation [er, rad, rad]
    r_rae_expected        
    
  end % properties (Access = private)
  
  methods
    
    function this = CoordinatesTest(logFId, testMode)
    % Constructs a CoordinatesTest.
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
      
      % Set up
      this.earthStation = this.setUp();
      
      % Compute derived properties
      this.r_rae_expected = [this.rng; this.azm; this.elv];
      
    end % CoordinatesTest()
    
    function earthStation = setUp(this)
      
      % == Earth station
      
      varphi = -22.239166666666666; % Geodetic latitude [rad]
      lambda = 114.0836111111111;   % Longitude [rad]
      
      earthStation = gso_gso.getWntGsoEarthSegment(varphi, lambda);
      
    end % setUp()

    function test_R_x(this)
    % Tests R_x method. (MG-p.27)
      
      r_expected = [1, 0, sqrt(2)];
      
      r_actual = this.r * Coordinates.R_x(this.phi);
      
      this.assert_true( ...
          'Coordinates', ...
          'R_x', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_actual - r_expected)) < this.HIGH_PRECISION);
      
    end % test_R_x()
    
    function test_R_y(this)
    % Tests R_y method. (MG-p.27)
      
      r_expected = [sqrt(2), 1, 0];
      
      r_actual = this.r * Coordinates.R_y(this.phi);
      
      this.assert_true( ...
          'Coordinates', ...
          'R_y', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_actual - r_expected)) < this.HIGH_PRECISION);
      
    end % test_R_y()
    
    function test_R_z(this)
    % Tests R_z method. (MG-p.27)
      
      r_expected = [0, sqrt(2), 1];
      
      r_actual = this.r * Coordinates.R_z(this.phi);
      
      this.assert_true( ...
          'Coordinates', ...
          'R_z', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_actual - r_expected)) < this.HIGH_PRECISION);
      
    end % test_R_z()
    
    function test_E_e2t(this)
    % Tests E_e2t method. (MG-2.93)
      
      E_e2t_expected = [this.e_E, this.e_N, this.e_Z]';
      
      E_e2t_actual = Coordinates.E_e2t(this.earthStation);
      
      this.assert_true( ...
          'Coordinates', ...
          'E_e2t', ...
          this.HIGH_PRECISION_DESC, ...
          max(max(abs(E_e2t_actual - E_e2t_expected))) < this.HIGH_PRECISION);
      
    end % test_E_e2t()
    
    function test_E_t2e(this)
    % Tests E_t2e method. (MG-2.93)
      
      E_t2e_expected = [this.e_E, this.e_N, this.e_Z];
      
      E_t2e_actual = Coordinates.E_t2e(this.earthStation);
      
      this.assert_true( ...
          'Coordinates', ...
          'E_t2e', ...
          this.HIGH_PRECISION_DESC, ...
          max(max(abs(E_t2e_actual - E_t2e_expected))) < this.HIGH_PRECISION);
      
    end % test_E_t2e()
    
    function test_gei2ger(this)
    % Tests gei2ger method. (MG-2.89)
      
      r_ger_expected = this.r_ger_a;
      
      r_ger_actual = Coordinates.gei2ger(this.r_gei, this.dNm);
      
      this.assert_true( ...
          'Coordinates', ...
          'gei2ger:r_only', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_ger_actual - r_ger_expected)) < this.HIGH_PRECISION);
      
      r_gei = [0.739662856554726; ...
                     0.739662856554726; ...
                     0];
      
      dNm = 7.304865000000000e+05;
      
      v_gei = [-0.858654494744699; ...
                     +0.858654494744699; ...
                     +0.021196048963813] * 1.0e-03;
      
      r_ger_expected = [-0.593076954974138; ...
                        +0.861662351627364; ...
                        +0];
      
      v_ger_expected = [-0.937446973798365; ...
                        -0.645239049402607; ...
                        +0.021196048963813] * 1.0e-03;
      
      [r_ger_actual, v_ger_actual] = Coordinates.gei2ger(r_gei, dNm, v_gei);
      
      t(1) = max(abs(r_ger_actual - r_ger_expected)) < this.HIGH_PRECISION;
      t(2) = max(abs(v_ger_actual - v_ger_expected)) < this.HIGH_PRECISION;
      
      this.assert_true( ...
          'Coordinates', ...
          'gei2ger:r_and_v', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      dNm = datenum(2014, 11, 23, 19, 49, 11.5);
      
      options = optimoptions('fminunc', 'Display', 'none', 'TolX', 1e-14);
      
      warning('off')
      dNm = fminunc(@(dNm)(Coordinates.check_wrap(EarthConstants.Theta(dNm))), dNm, options);
      warning('on')
      
      a = EarthConstants.a_gso;
      e = 0;
      i = 0;
      Omega = 0;
      omega = 0;
      M = 0;
      epoch = dNm;
      method = 'halley';
      
      ko = KeplerianOrbit( ...
          a, e, i, Omega, omega, M, epoch, method);
      
      r_gei = ko.r_gei(ko.epoch);
      v_gei = ko.v_gei(ko.epoch);
      [r_ger_actual, v_ger_actual] = Coordinates.gei2ger(r_gei, ko.epoch, v_gei);
      
      v_ger_expected = [0; ...
                        0; ...
                        0];
      
      this.assert_true( ...
          'Coordinates', ...
          'gei2ger:i=0', ...
          this.HIGH_PRECISION_DESC, ...
          sqrt((v_ger_actual - v_ger_expected)' * (v_ger_actual - v_ger_expected)) < this.HIGH_PRECISION);
      
      i = 90 * pi / 180;
      
      ko = KeplerianOrbit( ...
          a, e, i, Omega, omega, M, epoch, method);
      
      r_gei = ko.r_gei(ko.epoch);
      v_gei = ko.v_gei(ko.epoch);
      [r_ger_actual, v_ger_actual] = Coordinates.gei2ger(r_gei, ko.epoch, v_gei);
      
      v_ger_expected = [0; ...
                        -v_gei(3); ...
                        +v_gei(3)];
      
      this.assert_true( ...
          'Coordinates', ...
          'gei2ger:i=90', ...
          this.MEDIUM_PRECISION_DESC, ...
          sqrt((v_ger_actual - v_ger_expected)' * (v_ger_actual - v_ger_expected)) < this.MEDIUM_PRECISION);
      
      
    end % test_gei2ger()
    
    function test_ger2gei(this)
    % Tests ger2gei method. (MG-2.89)
      
      r_gei_expected = this.r_gei;
      
      r_gei_actual = Coordinates.ger2gei(this.r_ger_a, this.dNm);
      
      this.assert_true( ...
          'Coordinates', ...
          'ger2gei:r_only', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_gei_actual - r_gei_expected)) < this.HIGH_PRECISION);
      
      r_ger = [-0.593076954974138; ...
                     +0.861662351627364; ...
                     +0];
      
      dNm = 7.304865000000000e+05;
      
      v_ger = [-0.937446973798365; ...
                     -0.645239049402607; ...
                     +0.021196048963813] * 1.0e-03;
      
      r_gei_expected = [+0.739662856554726; ...
                        +0.739662856554726; ...
                        +0];
      
      v_gei_expected = [-0.858654494744699; ...
                        +0.858654494744699; ...
                        +0.021196048963813] * 1.0e-03;
      
      [r_gei_actual, v_gei_actual] = Coordinates.ger2gei(r_ger, dNm, v_ger);
      
      t(1) = max(abs(r_gei_actual - r_gei_expected)) < this.HIGH_PRECISION;
      t(2) = max(abs(v_gei_actual - v_gei_expected)) < this.HIGH_PRECISION;
      
      this.assert_true( ...
          'Coordinates', ...
          'ger2gei:r_and_v', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_ger2gei()
    
    function test_gei2lla(this)
    % Tests gei2lla method. (Inverse of MG-2.90 modified for
    % arbitrary altitude, See also MG-5.88)
      
      r_lla_expected = this.r_lla;
      
      r_lla_actual = Coordinates.gei2lla(this.r_gei, this.dNm);
      
      this.assert_true( ...
          'Coordinates', ...
          'gei2lla', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_lla_actual - r_lla_expected)) < this.HIGH_PRECISION);
      
    end % test_gei2lla()
    
    function test_lla2gei(this)
    % Tests lla2gei method. (MG-2.90 modified for arbitrary
    % altitude)
      
      r_gei_expected = this.r_gei;
      
      r_gei_actual = Coordinates.lla2gei(this.r_lla, this.dNm);
      
      this.assert_true( ...
          'Coordinates', ...
          'lla2gei', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_gei_actual - r_gei_expected)) < this.HIGH_PRECISION);
      
    end % test_lla2gei()
    
    function test_glla2ger(this)
    % Tests glla3ger method. (MG-5.83)

      r_ger_expected = this.r_ger_b;

      r_ger_actual = Coordinates.glla2ger(this.r_glla);

      this.assert_true( ...
          'Coordinates', ...
          'glla2ger', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_ger_actual - r_ger_expected)) < this.LOW_PRECISION);

    end % test_glla2ger()

    function test_gei2ltp(this)
    % Tests gei2ltp method. (MG-2.94)
      
      r_ltp_expected = this.r_ltp;
      
      r_ltp_actual = Coordinates.gei2ltp(this.r_gei, this.earthStation, this.dNm);
      
      this.assert_true( ...
          'Coordinates', ...
          'gei2ltp', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_ltp_actual - r_ltp_expected)) < this.HIGH_PRECISION);
      
    end % test_gei2ltp()
    
    function test_ltp2rae(this)
    % Tests ltp2rae method. (MG-2.95)
      
      r_rae_actual = Coordinates.ltp2rae(this.r_ltp);
      
      this.assert_true( ...
          'Coordinates', ...
          'ltp2rae', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_rae_actual - this.r_rae_expected)) < this.HIGH_PRECISION);
      
    end % test_ltp2rae()
    
    function test_rae2ltp(this)
    % Tests rae2ltp method. (Inverse of MG-2.95)
      
      r_ltp_expected = this.r_ltp;
      
      r_ltp_actual = Coordinates.rae2ltp(this.r_rae_expected);
      
      this.assert_true( ...
          'Coordinates', ...
          'rae2ltp', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_ltp_actual - r_ltp_expected)) < this.HIGH_PRECISION);
      
    end % test_rae2ltp()
    
    function test_ltp2gei(this)
    % Tests ltp2gei method. (Inverse of MG-2.94)
      
      r_gei_expected = this.r_gei;
      
      r_ltp_actual = Coordinates.rae2ltp(this.r_rae_expected);
      
      r_gei_actual = Coordinates.ltp2gei(r_ltp_actual, this.earthStation, this.dNm);
      
      this.assert_true( ...
          'Coordinates', ...
          'ltp2gei', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(r_gei_actual - r_gei_expected)) < this.HIGH_PRECISION);
      
    end % test_ltp2gei()
    
    function test_check_wrap(this)
    % Tests check_wrap method.
      
      phi_expected = 4;
      
      phi = [phi_expected + round(10 * rand) * 2 * pi;
             phi_expected - round(10 * rand) * 2 * pi];
      
      phi_actual = Coordinates.check_wrap(phi);
      
      this.assert_true( ...
          'Coordinates', ...
          'check_wrap', ...
          this.HIGH_PRECISION_DESC, ...
          max(abs(phi_actual - phi_expected)) < this.HIGH_PRECISION);
      
    end % test_check_wrap()
    
  end % methods
  
end % classdef
