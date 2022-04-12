classdef LinkTest < TestUtility
% Tests methods of Link class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)

    % Current date number
    dNm = datenum(2000, 1, 1, 12, 0, 0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot;
    % Reference bandwidth [kHz]
    ref_bw = 40;
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % A transmit station
    transmitStation
    % A transmit station beam
    transmitStationBeam
    % A receive station
    receiveStation
    % Propagation loss models to apply
    losses

    % An interfering system
    interferingSystem

    % A link
    link
    
  end % properties (Access = private)
  
  methods
    
    function this = LinkTest(logFId, testMode)
    % Constructs a LinkTest.
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
      
      % Set up
      [this.transmitStation, ...
       this.transmitStationBeam, ...
       this.receiveStation, ...
       this.losses, ...
       this.interferingSystem] = this.setUp();
      
      % Compute derived properties
      this.link = Link(this.transmitStation, ...
                       this.transmitStationBeam, ...
                       this.receiveStation, ...
                       this.losses);

    end % LinkTest()
    
    function [transmitStation, transmitStationBeam, receiveStation, losses, interferingSystem] = setUp(this)
      
      % = Wanted system

      wantedSystem = gso_gso.getWntGsoSystem();

      wantedSystem.assignBeams([], [], wantedSystem.dNm);

      earthStationA = wantedSystem.networks(1).earthStation;
      spaceStationA = wantedSystem.networks(1).spaceStation;
      spaceStationBeam = wantedSystem.networks(1).spaceStationBeam;

      earthStationA.set_doMultiplexing(1);
      spaceStationBeam.set_multiplicity(2);

      earthStationB = EarthStation( ...
          earthStationA.stationId, ...
          earthStationA.transmitAntenna, ...
          earthStationA.receiveAntenna, ...
          earthStationA.emission, ...
          earthStationA.beam, ...
          earthStationA.varphi, ...
          earthStationA.lambda, ...
          earthStationA.doMultiplexing);

      wantedSystem.set_earthStations([wantedSystem.earthStations; earthStationB]);

      wantedSystem.reset();
      
      wantedSystem.assignBeams([], [], wantedSystem.dNm);

      % = Interfering system

      interferingSystem = gso_gso.getIntGsoSystem();

      interferingSystem.assignBeams([], [], interferingSystem.dNm);

      earthStationA = interferingSystem.networks(1).earthStation;
      spaceStationA = interferingSystem.networks(1).spaceStation;
      spaceStationBeam = interferingSystem.networks(1).spaceStationBeam;

      earthStationA.set_doMultiplexing(1);
      spaceStationBeam.set_multiplicity(2);

      earthStationB = EarthStation( ...
          earthStationA.stationId, ...
          earthStationA.transmitAntenna, ...
          earthStationA.receiveAntenna, ...
          earthStationA.emission, ...
          earthStationA.beam, ...
          earthStationA.varphi, ...
          earthStationA.lambda, ...
          earthStationA.doMultiplexing);

      interferingSystem.set_earthStations([interferingSystem.earthStations; earthStationB]);

      interferingSystem.reset();
      
      interferingSystem.assignBeams([], [], interferingSystem.dNm);

      % Assign inputs
      
      transmitStation = wantedSystem.spaceStations(1);
      transmitStationBeam = wantedSystem.spaceStations(1).beams(1);
      receiveStation = wantedSystem.earthStations(1);
      losses = {};

    end % setUp()

    function test_Link(this)
    % Tests Link method.
      
      t = [];
      t = [t; isequal(this.link.transmitStation, this.transmitStation)];
      t = [t; isequal(this.link.transmitStationBeam, this.transmitStationBeam)];
      t = [t; isequal(this.link.receiveStation, this.receiveStation)];
      t = [t; isequal(this.link.losses, this.losses)];
      t = [t; isequal(this.link.doCheck, 1)];
      
      this.assert_true( ...
          'Link', ...
          'Link', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_Link()
    
    function test_computePerformance(this)

      performance_expected = Performance(-183.7920554531003 - 10 * log10(2), ...
                                         -206.8382560925405, ...
                                         [-220.4414417558061; -220.4414417558061], ...
                                         -217.4311417991658, ...
                                         [-172.7123681232581; -172.7123681232581], ...
                                         -169.7020681666177);
      
      warning('off');
      performance_actual = this.link.computePerformance( ...
          this.dNm, this.interferingSystem, 1, 1, this.ref_bw);
      warning('on');

      t = [];
      t = [t; abs(performance_actual.C - performance_expected.C) < this.MEDIUM_PRECISION];
      t = [t; abs(performance_actual.N - performance_expected.N) < this.MEDIUM_PRECISION];
      t = [t; abs(performance_actual.i - performance_expected.i) < this.MEDIUM_PRECISION];
      t = [t; abs(performance_actual.I - performance_expected.I) < this.MEDIUM_PRECISION];
      t = [t; abs(performance_actual.epfd - performance_expected.epfd) < this.MEDIUM_PRECISION];
      t = [t; abs(performance_actual.EPFD - performance_expected.EPFD) < this.MEDIUM_PRECISION];
      
      this.assert_true( ...
          'Link', ...
          'computePerformance', ...
          this.MEDIUM_PRECISION_DESC, ...
          min(t));

      FdL_t_i = 1;
      this.interferingSystem.spaceStations(1).transmitAntenna.set_feeder_loss(FdL_t_i);

      this.link.set_losses({'fuselage-loss'});
      FsL_t_i = 35;

      FdL_r_w = 1;
      this.link.receiveStation.receiveAntenna.set_feeder_loss(FdL_r_w);

      PlDs = 1;
      
      performance_expected.set_i(performance_expected.i - FdL_t_i - FsL_t_i - FdL_r_w - PlDs);
      performance_expected.set_I(10 * log10(sum(10.^(performance_expected.i / 10))));

      performance_expected.set_epfd(performance_expected.epfd - FdL_t_i - FsL_t_i - FdL_r_w - PlDs);
      performance_expected.set_EPFD(10 * log10(sum(10.^(performance_expected.epfd / 10))));

      warning('off');
      performance_actual = this.link.computePerformance( ...
          this.dNm, this.interferingSystem, 1, 1, this.ref_bw, ...
          'PlDs', PlDs);
      warning('on');

      t = [t; abs(performance_actual.C - performance_expected.C) < this.MEDIUM_PRECISION];
      t = [t; abs(performance_actual.N - performance_expected.N) < this.MEDIUM_PRECISION];
      t = [t; abs(performance_actual.i - performance_expected.i) < this.MEDIUM_PRECISION];
      t = [t; abs(performance_actual.I - performance_expected.I) < this.MEDIUM_PRECISION];
      t = [t; abs(performance_actual.epfd - performance_expected.epfd) < this.MEDIUM_PRECISION];
      t = [t; abs(performance_actual.EPFD - performance_expected.EPFD) < this.MEDIUM_PRECISION];

      this.assert_true( ...
          'Link', ...
          'computePerformance with feeder and fuselage loss, and polarizatio discrimination', ...
          this.MEDIUM_PRECISION_DESC, ...
          min(t));

    end % test_computePerformance()

    function test_computeDistance(this)
      
      r_one = [1; 1; 1];
      r_two = [2; 2; 2];

      distance_expected = sqrt(3) * EarthConstants.R_oplus;

      distance_actual = Link.computeDistance(r_one, r_two);

      t = [];
      t = [t; abs(distance_actual - distance_expected) < this.HIGH_PRECISION];

      this.assert_true( ...
          'Link', ...
          'computeDistance', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));

    end % test_computeDistance()
      
    function test_computeAngleBetweenVectors(this)
      
      r_ref = [1; 1; 1];
      r_one = [2; 2; 2];
      r_two = [3; 3; 3];

      theta_expected = 0;

      theta_actual = Link.computeAngleBetweenVectors(r_ref, r_one, r_two);

      t = [];
      t = [t; abs(theta_actual - theta_expected) < this.HIGH_PRECISION];

      r_one = [1; 2; 1];
      r_two = [1; 1; 3];

      theta_expected = 90;

      theta_actual = Link.computeAngleBetweenVectors(r_ref, r_one, r_two);

      t = [t; abs(theta_actual - theta_expected) < this.HIGH_PRECISION];

      r_one = [1;  2; 1];
      r_two = [1; -2; 1];

      theta_expected = 180;

      theta_actual = Link.computeAngleBetweenVectors(r_ref, r_one, r_two);

      t = [t; abs(theta_actual - theta_expected) < this.HIGH_PRECISION];

      this.assert_true( ...
          'Link', ...
          'computeAngleBetweenVectors', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));

    end % test_computeAngleBetweenVectors()

    function test_computeAnglesFromZenith(this)
      
      r_ref = [0; 0; 1];
      r_one = [0; 0; 2];
      r_two = [0; 0; 2];

      phi_expected = 0;
      azm_expected = 0;
      elv_expected = 0;

      [phi_actual, ...
       azm_actual, ...
       elv_actual] = Link.computeAnglesFromZenith(EarthStation(), r_ref, r_one, r_two);
      
      t = [];
      t = [t; abs(phi_actual - phi_expected) < this.HIGH_PRECISION];
      t = [t; abs(azm_actual - azm_expected) < this.HIGH_PRECISION];
      t = [t; abs(elv_actual - elv_expected) < this.MEDIUM_PRECISION];

      r_one = [1; 0; 2];
      r_two = [sqrt(3); 0; 2];

      phi_expected = 45;
      azm_expected = 0;
      elv_expected = 15;

      [phi_actual, ...
       azm_actual, ...
       elv_actual] = Link.computeAnglesFromZenith(EarthStation(), r_ref, r_one, r_two);

      t = [t; abs(phi_actual - phi_expected) < this.HIGH_PRECISION];
      t = [t; abs(azm_actual - azm_expected) < this.HIGH_PRECISION];
      t = [t; abs(elv_actual - elv_expected) < this.MEDIUM_PRECISION];

      r_two = [0; sqrt(3); 2];

      phi_expected = 45;
      azm_expected = 90;
      elv_expected = 69.295188945364572;

      [phi_actual, ...
       azm_actual, ...
       elv_actual] = Link.computeAnglesFromZenith(EarthStation(), r_ref, r_one, r_two);

      t = [t; abs(phi_actual - phi_expected) < this.HIGH_PRECISION];
      t = [t; abs(azm_actual - azm_expected) < this.HIGH_PRECISION];
      t = [t; abs(elv_actual - elv_expected) < this.MEDIUM_PRECISION];

      r_two = [0; -sqrt(3); 2];

      phi_expected = 45;
      azm_expected = -90;
      elv_expected = 69.295188945364572;

      [phi_actual, ...
       azm_actual, ...
       elv_actual] = Link.computeAnglesFromZenith(EarthStation(), r_ref, r_one, r_two);

      t = [t; abs(phi_actual - phi_expected) < this.HIGH_PRECISION];
      t = [t; abs(azm_actual - azm_expected) < this.HIGH_PRECISION];
      t = [t; abs(elv_actual - elv_expected) < this.MEDIUM_PRECISION];

      r_ref = [0; 0; 3];
      r_one = [0; 0; 2];
      r_two = [0; 0; 2];

      phi_expected = 0;
      azm_expected = 0;
      elv_expected = 0;

      [phi_actual, ...
       azm_actual, ...
       elv_actual] = Link.computeAnglesFromZenith(SpaceStation(), r_ref, r_one, r_two);
      
      t = [t; abs(phi_actual - phi_expected) < this.HIGH_PRECISION];
      t = [t; abs(azm_actual - azm_expected) < this.HIGH_PRECISION];
      t = [t; abs(elv_actual - elv_expected) < this.MEDIUM_PRECISION];

      r_one = [1; 0; 2];
      r_two = [sqrt(3); 0; 2];

      phi_expected = 45;
      azm_expected = 0;
      elv_expected = 15;

      [phi_actual, ...
       azm_actual, ...
       elv_actual] = Link.computeAnglesFromZenith(SpaceStation(), r_ref, r_one, r_two);

      t = [t; abs(phi_actual - phi_expected) < this.HIGH_PRECISION];
      t = [t; abs(azm_actual - azm_expected) < this.HIGH_PRECISION];
      t = [t; abs(elv_actual - elv_expected) < this.MEDIUM_PRECISION];

      r_two = [0; sqrt(3); 2];

      phi_expected = 45;
      azm_expected = -90;
      elv_expected = 69.295188945364572;
      
      [phi_actual, ...
       azm_actual, ...
       elv_actual] = Link.computeAnglesFromZenith(SpaceStation(), r_ref, r_one, r_two);

      t = [t; abs(phi_actual - phi_expected) < this.HIGH_PRECISION];
      t = [t; abs(azm_actual - azm_expected) < this.HIGH_PRECISION];
      t = [t; abs(elv_actual - elv_expected) < this.MEDIUM_PRECISION];

      r_two = [0; -sqrt(3); 2];

      phi_expected = 45;
      azm_expected = 90;
      elv_expected = 69.295188945364572;

      [phi_actual, ...
       azm_actual, ...
       elv_actual] = Link.computeAnglesFromZenith(SpaceStation(), r_ref, r_one, r_two);

      t = [t; abs(phi_actual - phi_expected) < this.HIGH_PRECISION];
      t = [t; abs(azm_actual - azm_expected) < this.HIGH_PRECISION];
      t = [t; abs(elv_actual - elv_expected) < this.MEDIUM_PRECISION];

      this.assert_true( ...
          'Link', ...
          'computeAnglesFromZenith', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));

    end % test_computeAnglesFromZenith()

    function test_computeAnglesForRecM2101_0(this)

      wantedSystem = gso_gso.getWntGsoSystem();

      wantedSystem.assignBeams([], [], wantedSystem.dNm);

      refStn = wantedSystem.networks(1).earthStation;

      refAnt = refStn.transmitAntenna;
      refAnt.set_x_ltp([0; 1; 0]);
      refAnt.set_z_ltp([0; 0; 1]);

      r_ref = refStn.r_ger;
      r_off = Coordinates.E_t2e(refStn) * [1; 1; 1] + r_ref;

      phi_expected = -45.0;
      theta_expected = acosd(1 / sqrt(3));
      
      [phi_actual, ...
       theta_actual] = Link.computeAnglesForRecM2101_0(this.dNm, refStn, refAnt, r_ref, r_off);

      t = [];
      t = [t; abs(phi_actual - phi_expected) < this.HIGH_PRECISION];
      t = [t; abs(theta_actual - theta_expected) < this.HIGH_PRECISION];

      this.assert_true( ...
          'Link', ...
          'computeAnglesForRecM2101_0', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));

    end % test_computeAnglesForRecM2101_0()

    % TODO: Test function [idxVisES, idxVisSS, r_ger_SS] = findIdxVisEStoSS(earthStations, spaceStations, dNm)
    % TODO: Test function [idxVisSS_A, idxVisSS_B, r_ger_SS_A, r_ger_SS_B] = findIdxVisSStoSS(spaceStationsA, spaceStationsB, dNm)
    % TODO: Test function is = isEmpty(this)

  end % methods
  
end % classdef
