classdef EarthStationInMotionTest < TestUtility
% Tests methods of EarthStationInMotion class.
  
% Copyright (C) 2021 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    % Identifier for station
    stationId = 'one';
    % Transmit antenna gain, and pattern
    transmitAntenna = EarthStationAntenna( ...
        'transmit', 50, 1, PatternELUX201V01(50));
    % Receive antenna gain, pattern, and noise temperature
    receiveAntenna = EarthStationAntenna( ...
        'transmit', 50, 1, PatternELUX202V01());
    noise_t = 290;
    % Signal power, frequency, and requirement
    emission = Emission();
    % Beam
    beam = Beam('one', 1, 100);
    % Flag indicating whether to do multiplexing, or not
    doMultiplexing = 1;

    % O'Hare International Airport (Chicago)
    dNm = datenum(2020, 7, 27);
    varphi_start = +41.97772775231409;  % [deg]
    lambda_start = -87.90496385987021;  % [deg]
    h_start = 35000;  % [ft]

    % Logan International Airport (Boston)
    speed = 450;  % [nm/hr]
    varphi_stop = +42.36053962612626;  % [deg]
    lambda_stop = -70.98947582227271;  % [deg]
    h_stop = 35000;  % [ft]

  end % properties (Constant = true)
  
  properties (Access = private)
    
    % An Earth station in motion
    earthStationInMotion
    
  end % properties (Access = private)
  
  methods
    
    function this = EarthStationInMotionTest(logFId, testMode)
    % Constructs an EarthStationInMotionTest.
    %
    % Parameters
    %   logFId - Log file identifier
    %   testMode - Test mode, if 'interactive' then beeps and pauses
      
    % Invoke the superclass constructor
      if nargin == 0
        superArgs = {};
        
      else
        superArgs{1} = logFId;
        superArgs{2} = testMode;
        
      end % if
      this@TestUtility(superArgs{:});
      
      % Compute derived properties
      this.receiveAntenna.set_noise_t(this.noise_t);
      this.earthStationInMotion = EarthStationInMotion( ...
          this.stationId, ...
          this.transmitAntenna, ...
          this.receiveAntenna, ...
          this.emission, ...
          this.beam, ...
          this.doMultiplexing);

    end % EarthStationTest()
    
    function test_EarthStationInMotion(this)
    % Tests the EarthStationInMotion constructor.

      t = [];
      t = [t; isequal(this.earthStationInMotion.stationId, this.stationId)];
      t = [t; isequal(this.earthStationInMotion.transmitAntenna, this.transmitAntenna)];
      t = [t; isequal(this.earthStationInMotion.receiveAntenna, this.receiveAntenna)];
      t = [t; isequal(this.earthStationInMotion.emission, this.emission)];
      t = [t; isequal(this.earthStationInMotion.beam, this.beam)];
      t = [t; isequal(this.earthStationInMotion.doMultiplexing, this.doMultiplexing)];

      this.assert_true( ...
          'EarthStationInMotion', ...
          'EarthStationInMotion', ...
          this.IS_EQUAL_DESC, ...
          min(t));

    end % test_EarthStationInMotion()

    function test_set_start_waypoint(this)
    % Tests the set_start_waypoint() function.

      dNm_expected = 737999;
      varphi_expected = +0.732649561783679;
      lambda_expected = -1.534231048201358;
      h_expected = 0.001672588666349;

      this.earthStationInMotion.set_start_waypoint( ...
          this.dNm, this.varphi_start, this.lambda_start, this.h_start);

      t = [];
      t = [t; isequal(this.earthStationInMotion.dNm_s, dNm_expected)];
      t = [t; abs(this.earthStationInMotion.varphi - varphi_expected) < this.HIGH_PRECISION];
      t = [t; abs(this.earthStationInMotion.lambda - lambda_expected) < this.HIGH_PRECISION];
      t = [t; abs(this.earthStationInMotion.h - h_expected) < this.HIGH_PRECISION];

      this.assert_true( ...
          'EarthStationInMotion', ...
          'set_start_waypoint', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));

    end % test_set_start_waypoint()

    function test_add_stop_waypoint(this)
    % Tests the add_stop_waypoint() function.

      % Slight adjustment to 1,388.95 km from:
      % https://www.google.com/maps/dir/
      %   O'Hare+International+Airport,+10000+W+O'Hare+Ave,+Chicago,+IL+60666/
      %   Boston+Logan+International+Airport,+Boston,+MA+02128/
      %   ...
      dNm_expected = this.dNm + 1398.4198 / (450 * 1.852 * 24);
      varphi_expected = +0.739330889397431;
      lambda_expected = -1.239000087363568;
      h_expected = 0.001672588666349;

      this.earthStationInMotion.set_start_waypoint( ...
          this.dNm, this.varphi_start, this.lambda_start, this.h_start);
      this.earthStationInMotion.add_stop_waypoint( ...
          this.speed, this.varphi_stop, this.lambda_stop, this.h_stop);

      t = [];
      t = [t; abs(this.earthStationInMotion.dNm_s(end) - dNm_expected) < this.LOW_PRECISION];
      t = [t; abs(this.earthStationInMotion.varphi(end) - varphi_expected) < this.HIGH_PRECISION];
      t = [t; abs(this.earthStationInMotion.lambda(end) - lambda_expected) < this.MEDIUM_PRECISION];
      t = [t; abs(this.earthStationInMotion.h(end) - h_expected) < this.HIGH_PRECISION];

      this.assert_true( ...
          'EarthStationInMotion', ...
          'add_stop_waypoint', ...
          this.LOW_PRECISION_DESC, ...
          min(t));

    end % test_add_stop_waypoint()

  end % methods

end % classdef
