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
classdef SystemTest < TestUtility
% Tests methods of System class.
  
  properties (Constant = true)
    
    % Reference bandwidth [kHz]
    ref_bw = 40;

  end % properties (Constant = true)
  
  properties (Access = private)
    
    % An Earth station array
    earthStations
    % A space station array
    spaceStations
    % Propagation loss models to apply
    losses
    % Current date number
    dNm

    % A network array
    networks

    % An interfering system
    interferingSystem
    
    % A system
    system

  end % properties (Access = private)
  
  methods
    
    function this = SystemTest(logFId, testMode)
    % Constructs a SystemTest.
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
      [this.earthStations, ...
       this.spaceStations, ...
       this.losses, ...
       this.dNm, ...
       this.networks, ...
       this.interferingSystem] = this.setUp();
      
      % Compute derived properties
      this.system = System(this.earthStations, ...
                           this.spaceStations, ...
                           this.losses, ...
                           this.dNm, 'testAngleFromGsoArc', 0);
      this.system.assignBeams([], [], this.dNm);
      
    end % SystemTest()
    
    function [earthStations, spaceStations, losses, dNm, networks, interferingSystem] = setUp(this)

      % = Wanted system

      wantedSystem = gso_gso.getWntGsoSystem();

      wantedSystem.assignBeams([], [], wantedSystem.dNm);

      % = Interfering system

      interferingSystem = gso_gso.getIntGsoSystem();

      interferingSystem.assignBeams([], [], interferingSystem.dNm);

      % Assign inputs
      earthStations = wantedSystem.earthStations;
      spaceStations = wantedSystem.spaceStations;
      spaceStationBeam = wantedSystem.spaceStations.beams;
      losses = wantedSystem.losses;
      dNm = wantedSystem.spaceStations.orbit.epoch;
      networks = Network(earthStations, ...
                         spaceStations, ...
                         spaceStationBeam, ...
                         losses);

    end % setUp()

    function test_System(this)
    % Tests System method.
      
      t = [];
      t = [t; isequal(this.system.testAngleFromGsoArc, 0)];
      t = [t; isequal(this.system.angleFromGsoArc, 10)];
      t = [t; isequal(this.system.testAngleFromZenith, 1)];
      t = [t; isequal(this.system.angleFromZenith, 60)];
      t = [t; isequal(this.system.earthStations, this.earthStations)];
      t = [t; isequal(this.system.spaceStations, this.spaceStations)];
      t = [t; isequal(this.system.losses, this.losses)];
      t = [t; isequal(this.system.dNm, this.dNm)];
      t = [t; isequal(this.system.networks, this.networks)];
      % TODO: Include test of indxNetES and idxNetSS
      
      this.assert_true( ...
          'System', ...
          'System', ...
          this.IS_EQUAL_DESC, ...
          min(t));

    end % test_System()
    
    function test_copy(this)

      wantedSystemOne = gso_gso.getWntGsoSystem();
      
      wantedSystemTwo = wantedSystemOne.copy();
      
      t = isequaln(wantedSystemOne, wantedSystemTwo);
      
      this.assert_true( ...
          'System', ...
          'copy', ...
          this.IS_EQUAL_DESC, ...
          min(t));

    end % test_copy()
    
    % TODO: Test function earthStations = get_assignedEarthStations(this)
    % TODO: Test function spaceStations = get_assignedSpaceStations(this)

    function test_assignBeams_by_maximum_elevation_without_multiplexing(this)

      [wantedSystem, interferingSystem] = gso_leo.getSystems();

      wantedSystem.assignBeams([], [], wantedSystem.dNm);
      interferingSystem.assignBeams([], [], interferingSystem.dNm);

      nSS = length(interferingSystem.spaceStations);
      for iSS = 1:nSS

        r_gei = interferingSystem.spaceStations(iSS).orbit.r_gei(interferingSystem.dNm);

        r_ltp = Coordinates.gei2ltp(r_gei, ...
                                    interferingSystem.networks(1).earthStation, ...
                                    interferingSystem.dNm);

        r_rae = Coordinates.ltp2rae(r_ltp);

        elv(iSS) = r_rae(3);
  
      end % for

      [elv_max, iSS_max] = max(elv);

      t = isequal(interferingSystem.networks(1).spaceStation, ...
                  interferingSystem.spaceStations(iSS_max));

      this.assert_true( ...
          'System', ...
          'assignBeams', ...
          'Assign beams by maximum elevation without multiplexing', ...
          min(t));

      spaceStations = interferingSystem.get_assignedSpaceStations();

      nSS = length(spaceStations);
      
      t = isequal(nSS, length(unique(spaceStations)));
      
      this.assert_true( ...
          'System', ...
          'assignBeams', ...
          'Assign beams by maximum elevation and uniquely without multiplexing', ...
          min(t));

    end % test_assignBeams_by_maximum_elevation_without_multiplexing()

    function test_assignBeams_randomly(this)

      [wantedSystem, interferingSystem] = gso_leo.getSystems();

      wantedSystem.assignBeams([], [], wantedSystem.dNm);
      interferingSystem.assignBeams([], [], interferingSystem.dNm);

      indexes = [];

      warning('off');
      nRnd = 100;
      for iRnd = 1:nRnd

        interferingSystem.reset();

        interferingSystem.assignBeams([], [], interferingSystem.dNm, 'method', 'random');

        indexes = [indexes, ...
                   find(interferingSystem.networks(1).spaceStation == interferingSystem.spaceStations)];

      end % for
      warning('on');
      
      unique_indexes = unique(indexes);

      nUnq = length(unique_indexes);

      samples = [];
      
      nIdx = length(indexes);
      for iIdx = 1:nIdx
        samples = [samples, ...
                   find(indexes(iIdx) == unique_indexes)];

      end % for

      t = kstest2(randi(nUnq, 1, nRnd), samples) == 0;

      this.assert_true( ...
          'System', ...
          'assignBeams', ...
          'Assign beams randomly', ...
          min(t));

      spaceStations = interferingSystem.get_assignedSpaceStations();

      nSS = length(spaceStations);
      
      t = isequal(nSS, length(unique(spaceStations)));
      
      this.assert_true( ...
          'System', ...
          'assignBeams', ...
          'Assign beams randomly and uniquely', ...
          min(t));

    end % test_assignBeams_randomly(this)

    function test_assignBeams_by_maximum_separation(this)

      [wantedSystem, interferingSystem] = gso_leo.getSystems();

      wantedSystem.assignBeams([], [], wantedSystem.dNm);
      interferingSystem.assignBeams([], [], interferingSystem.dNm, 'method', 'maxsep');

      r_gei_es = interferingSystem.networks(1).earthStation.compute_r_gei(interferingSystem.dNm);

      nSS = length(interferingSystem.spaceStations);
      for iSS = 1:nSS

        r_gei_ss = interferingSystem.spaceStations(iSS).orbit.r_gei(interferingSystem.dNm);
        
        theta_g(iSS) = System.computeAngleFromGsoArc(r_gei_ss, r_gei_es);

      end % for

      [theta_g_max, iSS_max] = max(theta_g);

      t = isequal(interferingSystem.networks(1).spaceStation, ...
                  interferingSystem.spaceStations(iSS_max));

      this.assert_true( ...
          'System', ...
          'assignBeams', ...
          'Assign beams by maximum separation', ...
          min(t));

      spaceStations = interferingSystem.get_assignedSpaceStations();

      nSS = length(spaceStations);
      
      t = isequal(nSS, length(unique(spaceStations)));
      
      this.assert_true( ...
          'System', ...
          'assignBeams', ...
          'Assign beams by maximum separation and uniquely', ...
          min(t));

    end % test_assignBeams_by_maximum_separation(this)

    function test_assignBeams_by_minimum_separation(this)

      [wantedSystem, interferingSystem] = gso_leo.getSystems();

      wantedSystem.assignBeams([], [], wantedSystem.dNm);
      interferingSystem.assignBeams([], [], interferingSystem.dNm, 'method', 'minsep');

      r_gei_es = interferingSystem.networks(1).earthStation.compute_r_gei(interferingSystem.dNm);

      nSS = length(interferingSystem.spaceStations);
      for iSS = 1:nSS

        r_gei_ss = interferingSystem.spaceStations(iSS).orbit.r_gei(interferingSystem.dNm);
        
        theta_g(iSS) = System.computeAngleFromGsoArc(r_gei_ss, r_gei_es);
        if theta_g(iSS) < interferingSystem.angleFromGsoArc
          theta_g(iSS) = Inf;

        end % if          

      end % for

      [theta_g_min, iSS_min] = min(theta_g);

      t = isequal(interferingSystem.networks(1).spaceStation, ...
                  interferingSystem.spaceStations(iSS_min));

      this.assert_true( ...
          'System', ...
          'assignBeams', ...
          'Assign beams by minimum separation', ...
          min(t));

      spaceStations = interferingSystem.get_assignedSpaceStations();

      nSS = length(spaceStations);
      
      t = isequal(nSS, length(unique(spaceStations)));
      
      this.assert_true( ...
          'System', ...
          'assignBeams', ...
          'Assign beams by minimum separation and uniquely', ...
          min(t));

    end % test_assignBeams_by_minimum_separation(this)

    function test_assignBeams_by_maximum_elevation_with_multiplexing(this)

      [wantedSystem, interferingSystem] = gso_leo.getSystems();

      wantedSystem.assignBeams([], [], wantedSystem.dNm);
      interferingSystem.assignBeams([], [], interferingSystem.dNm);

      earthStationA = interferingSystem.networks(1).earthStation;
      spaceStationA = interferingSystem.networks(1).spaceStation;
      spaceStationBeam = interferingSystem.networks(1).spaceStationBeam;

      earthStationA.set_doMultiplexing(1)
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
      
      spaceStations = interferingSystem.get_assignedSpaceStations();

      net_idx = find(spaceStations == spaceStationA);

      t = [];
      t = [t; length(net_idx) == 2];

      earthStations = interferingSystem.get_assignedEarthStations();

      t = [t; earthStations(net_idx(1)) == earthStationA];
      t = [t; earthStations(net_idx(2)) == earthStationB];

      this.assert_true( ...
          'System', ...
          'assignBeams', ...
          'Assign beams by maximum elevation with multiplexing', ...
          min(t));

    end % test_assignBeams_by_maximum_elevation_with_multiplexing()

    function test_computeUpLinkPerformance_without_multiplexing(this)

      performance_expected = Performance(-157.8181333616310, ...
                                         -198.5991686830974, ...
                                         -197.6363768430820, ...
                                         -197.6363768430820, ...
                                         -147.8812253020032, ...
                                         -147.8812253020032);

      warning('off');
      performance_actual = this.system.computeUpLinkPerformance( ...
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
          'System', ...
          'computeUpLinkPerformance without multiplexing', ...
          this.MEDIUM_PRECISION_DESC, ...
          min(t));

    end % test_computeUpLinkPerformance_without_multiplexing()

    function test_computeUpLinkPerformance_with_multiplexing(this)

      C_expected =  -157.8181333616310 - 10 * log10(2);

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

      warning('off');
      performance_actual = wantedSystem.computeUpLinkPerformance( ...
          this.dNm, [], 1, 1, this.ref_bw);
      warning('on');

      C_actual = performance_actual(1).C;

      t = [];
      t = [t; abs(C_actual - C_expected) < TestUtility.MEDIUM_PRECISION];

      I_expected = -197.6363768430820;

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

      warning('off');
      performance_actual = wantedSystem.computeUpLinkPerformance( ...
          this.dNm, interferingSystem, 1, 1, this.ref_bw);
      warning('on');

      I_actual = performance_actual(1).I;

      t = [t; abs(I_actual - I_expected) < TestUtility.MEDIUM_PRECISION];

      this.assert_true( ...
          'System', ...
          'computeUpLinkPerformance with multiplexing', ...
          this.MEDIUM_PRECISION_DESC, ...
          min(t));

    end % test_computeUpLinkPerformance_with_multiplexing()

    function test_computeDownLinkPerformance_without_multiplexing(this)

      performance_expected = Performance(-183.7920554531003, ...
                                         -206.8382560925405, ...
                                         -217.4311417991658, ...
                                         -217.4311417991658, ...
                                         -169.7020681666177, ...
                                         -169.7020681666177);

      warning('off');
      performance_actual = this.system.computeDownLinkPerformance( ...
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
          'System', ...
          'computeDownLinkPerformance without multiplexing', ...
          this.MEDIUM_PRECISION_DESC, ...
          min(t));

    end % test_computeDownLinkPerformance_without_multiplexing()

    function test_computeDownLinkPerformance_with_multiplexing(this)

      C_expected = -183.7920554531003 - 10 * log10(2);

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

      warning('off');
      performance_actual = wantedSystem.computeDownLinkPerformance( ...
          this.dNm, [], 1, 1, this.ref_bw);
      
      warning('on');

      C_actual = performance_actual(1).C;

      t = [];
      t = [t; abs(C_actual - C_expected) < TestUtility.MEDIUM_PRECISION];

      I_expected = -217.4311417991658;

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

      warning('off');
      performance_actual = wantedSystem.computeDownLinkPerformance( ...
          this.dNm, interferingSystem, 1, 1, this.ref_bw);
      warning('on');

      I_actual = performance_actual(1).I;

      t = [t; abs(I_actual - I_expected) < TestUtility.MEDIUM_PRECISION];

      this.assert_true( ...
          'System', ...
          'computeDownLinkPerformance with multiplexing', ...
          this.MEDIUM_PRECISION_DESC, ...
          min(t));

    end % test_computeDownLinkPerformance_with_multiplexing()

    function test_apply(this)

      [wantedSystemOne, interferingSystemOne] = gso_leo.getSystems();

      wantedAssignment = wantedSystemOne.assignBeams([], [], wantedSystemOne.dNm);
      
      wantedSystemTwo = wantedSystemOne.copy();

      wantedSystemOne.reset();

      wantedSystemOne.apply(wantedAssignment);

      interferingAssignment = interferingSystemOne.assignBeams([], [], interferingSystemOne.dNm);
      
      interferingSystemTwo = interferingSystemOne.copy();

      interferingSystemOne.reset();

      interferingSystemOne.apply(interferingAssignment);

      t = [];
      t = [t; isequaln(wantedSystemOne, wantedSystemTwo)];
      t = [t; isequaln(interferingSystemOne, interferingSystemTwo)];
      
      this.assert_true( ...
          'System', ...
          'apply', ...
          this.IS_EQUAL_DESC, ...
          min(t));

    end % test_apply()

    function test_reset(this)

      wantedSystemOne = gso_gso.getWntGsoSystem();
      
      wantedSystemTwo = wantedSystemOne.copy();
      
      wantedSystemOne.assignBeams([], [], wantedSystemOne.dNm);
      
      wantedSystemOne.reset();

      t = isequaln(wantedSystemOne, wantedSystemTwo);
      
      this.assert_true( ...
          'System', ...
          'reset', ...
          this.IS_EQUAL_DESC, ...
          min(t));

    end % test_reset()
    
    function test_computeAngleFromGsoArc(this)

      r_gei_es = [1; 0; 1];
      r_gei_ss = [2; 0; 2];

      theta_expected = 135 - atan2d(EarthConstants.a_gso - 1, 1);
 
      theta_actual = System.computeAngleFromGsoArc(r_gei_ss, r_gei_es);

      this.assert_true( ...
          'System', ...
          'computeAngleFromGsoArc', ...
          this.HIGH_PRECISION_DESC, ...
          abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);

      r_gei_ss = [2; 0; 0];

      theta_expected = atan2d(EarthConstants.a_gso - 1, 1) - 45;
 
      theta_actual = System.computeAngleFromGsoArc(r_gei_ss, r_gei_es);

      this.assert_true( ...
          'System', ...
          'computeAngleFromGsoArc', ...
          this.HIGH_PRECISION_DESC, ...
          abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);

      r_gei_es = [1; 0; 0];

      theta_expected = 0;
 
      theta_actual = System.computeAngleFromGsoArc(r_gei_ss, r_gei_es);

      this.assert_true( ...
          'System', ...
          'computeAngleFromGsoArc', ...
          this.HIGH_PRECISION_DESC, ...
          abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);

    end % test_computeAngleFromGsoArc()

    function test_computeAngleFromZenith(this)

      r_gei_ss = [1; 1; sqrt(2)] * 2;
      r_gei_es = [1; 1; sqrt(2)];

      theta = System.computeAngleFromZenith(r_gei_ss, r_gei_es);

      this.assert_true( ...
          'System', ...
          'computeAngleFromZenith', ...
          this.IS_EQUAL_DESC, ...
          theta == 0);

      r_gei_ss = [1; 1; -sqrt(2)];

      theta = System.computeAngleFromZenith(r_gei_ss, r_gei_es);

      this.assert_true( ...
          'System', ...
          'computeAngleFromZenith', ...
          this.MEDIUM_PRECISION_DESC, ...
          abs(theta - 135) < TestUtility.MEDIUM_PRECISION);

      r_gei_ss = [-1; -1; -sqrt(2)];

      theta = System.computeAngleFromZenith(r_gei_ss, r_gei_es);

      this.assert_true( ...
          'System', ...
          'computeAngleFromZenith', ...
          this.IS_EQUAL_DESC, ...
          theta == 180);

    end % test_computeAngleFromZenith()

    function test_computeAngleFromNadir(this)

      r_gei_ss = [1; 1; sqrt(2)] * 2;
      r_gei_es = [1; 1; sqrt(2)];

      theta = System.computeAngleFromNadir(r_gei_ss, r_gei_es);

      this.assert_true( ...
          'System', ...
          'computeAngleFromNadir', ...
          this.IS_EQUAL_DESC, ...
          theta == 180);

      r_gei_ss = [1; 1; -sqrt(2)];

      theta = System.computeAngleFromNadir(r_gei_ss, r_gei_es);

      this.assert_true( ...
          'System', ...
          'computeAngleFromNadir', ...
          this.MEDIUM_PRECISION_DESC, ...
          abs(theta - 45) < TestUtility.MEDIUM_PRECISION);

      r_gei_ss = [-1; -1; -sqrt(2)];

      theta = System.computeAngleFromNadir(r_gei_ss, r_gei_es);

      this.assert_true( ...
          'System', ...
          'computeAngleFromNadir', ...
          this.IS_EQUAL_DESC, ...
          theta == 0);

    end % test_computeAngleFromNadir()

  end % methods
  
end % classdef
