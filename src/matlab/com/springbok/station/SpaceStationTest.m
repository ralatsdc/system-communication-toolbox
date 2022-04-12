classdef SpaceStationTest < TestUtility
% Tests methods of SpaceStation class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    % Identifier for station
    stationId = 'one';
    % Transmit antenna gain, and pattern
    transmitAntenna = SpaceStationAntenna( ...
        'transmit', 50, 1, PatternSRR_405V01(3));
    % Receive antenna gain, pattern, and noise temperature
    receiveAntenna = SpaceStationAntenna( ...
        'transmit', 50, 1, PatternSRR_404V01(3))
    noise_t = 290;
    % Signal power, frequency, and requirement
    emission = Emission();
    % Beam array
    beams = [Beam('one', 1, 100), Beam('two', 2, 100), Beam('three', 3, 100)];

    % Orbit
    orbit = KeplerianOrbit();
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % A space station
    spaceStation
    
  end % properties
  
  methods
    
    function this = SpaceStationTest(logFId, testMode)
    % Constructs a SpaceStationTest.
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
      this.spaceStation = SpaceStation(this.stationId, ...
                                       this.transmitAntenna, ...
                                       this.receiveAntenna, ...
                                       this.emission, ...
                                       this.beams, ...
                                       this.orbit);
      
    end % SpaceStationTest()
    
    function test_SpaceStation(this)
    % Tests the SpaceStation constructor.
      
      t = [];
      t = [t; strcmp(this.spaceStation.stationId, this.stationId)];
      t = [t; isequal(this.spaceStation.transmitAntenna, this.transmitAntenna)];
      t = [t; isequal(this.spaceStation.receiveAntenna, this.receiveAntenna)];
      t = [t; isequal(this.spaceStation.emission, this.emission)];
      t = [t; isequal(this.spaceStation.beams, this.beams)];
      t = [t; this.spaceStation.orbit.isEqual(this.orbit)];
      
      this.assert_true( ...
          'SpaceStation', ...
          'SpaceStation', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_SpaceStation()
    
    function test_assign_without_multiplexing(this)

      doMultiplexing = 0;

      this.spaceStation = SpaceStation(this.stationId, ...
                                       this.transmitAntenna, ...
                                       this.receiveAntenna, ...
                                       this.emission, ...
                                       this.beams, ...
                                       this.orbit);

      beams = [Beam('one', 1, 100), Beam('two', 2, 100), Beam('three', 3, 100)];

      this.spaceStation.set_beams(beams);
      
      t = [];
      t = [t; this.spaceStation.isAvailable == 1];
      
      beam = this.spaceStation.assign(doMultiplexing);

      t = [t; beam == beams(1)];
      t = [t; this.spaceStation.isAvailable == 1];
      
      beam = this.spaceStation.assign(doMultiplexing);
      
      t = [t; beam == beams(2)];
      t = [t; this.spaceStation.isAvailable == 1];
      
      beam = this.spaceStation.assign(doMultiplexing);
      
      t = [t; beam == beams(3)];
      t = [t; this.spaceStation.isAvailable == 0];

      this.assert_true( ...
          'SpaceStation', ...
          'assign', ...
          'test_assign_without_multiplexing', ...
          min(t));

    end % test_assign_without_multiplexing()

    function test_assign_with_multiplexing(this)

      doMultiplexing = 1;

      this.spaceStation = SpaceStation(this.stationId, ...
                                       this.transmitAntenna, ...
                                       this.receiveAntenna, ...
                                       this.emission, ...
                                       this.beams, ...
                                       this.orbit);

      beams = [Beam('one', 1, 100), Beam('two', 2, 100), Beam('three', 3, 100)];

      this.spaceStation.set_beams(beams);

      t = [];
      t = [t; this.spaceStation.isAvailable == 1];
      
      beam = this.spaceStation.assign(doMultiplexing);

      t = [t; beam == beams(1)];
      t = [t; this.spaceStation.isAvailable == 1];
      
      for idx = 1:this.beams(2).multiplicity - 1
        beam = this.spaceStation.assign(doMultiplexing);
      
        t = [t; beam == beams(2)];
        t = [t; this.spaceStation.isAvailable == 1];
      
      end % for
      
      beam = this.spaceStation.assign(doMultiplexing);
      
      t = [t; beam == beams(2)];
      t = [t; this.spaceStation.isAvailable == 1];

      for idx = 1:this.beams(3).multiplicity - 1
        beam = this.spaceStation.assign(doMultiplexing);
      
        t = [t; beam == beams(3)];
        t = [t; this.spaceStation.isAvailable == 1];
      
      end % for
      
      beam = this.spaceStation.assign(doMultiplexing);
      
      t = [t; beam == beams(3)];
      t = [t; this.spaceStation.isAvailable == 0];

      this.assert_true( ...
          'SpaceStation', ...
          'assign', ...
          'test_assign_with_multiplexing', ...
          min(t));

    end % test_assign_with_multiplexing()

    % TODO: Test function r_gei = compute_r_gei(this, dNm)
    % TODO: Test function r_ger = compute_r_ger(this, dNm)

    function test_reset(this)

      doMultiplexing = 0;

      this.spaceStation = SpaceStation(this.stationId, ...
                                       this.transmitAntenna, ...
                                       this.receiveAntenna, ...
                                       this.emission, ...
                                       this.beams, ...
                                       this.orbit);

      beams = [Beam('one', 1, 100), Beam('two', 2, 100), Beam('three', 3, 100)];

      this.spaceStation.set_beams(beams);
      
      t = [];
      t = [t; this.spaceStation.isAvailable == 1];
      
      beam = this.spaceStation.assign(doMultiplexing);

      t = [t; beam == beams(1)];
      t = [t; this.spaceStation.isAvailable == 1];
      
      beam = this.spaceStation.assign(doMultiplexing);
      
      t = [t; beam == beams(2)];
      t = [t; this.spaceStation.isAvailable == 1];
      
      beam = this.spaceStation.assign(doMultiplexing);
      
      t = [t; beam == beams(3)];
      t = [t; this.spaceStation.isAvailable == 0];

      this.spaceStation.reset();
      
      nBm = length(this.spaceStation.beams);
      for iBm = 1:nBm
        t = [t; this.spaceStation.beams(iBm).isAvailable == 1];
        t = [t; this.spaceStation.beams(iBm).isMultiplexed == 0]; 
        t = [t; this.spaceStation.beams(iBm).divisions == 0];

      end % for
      t = [t; this.spaceStation.isAvailable == 1];

      this.assert_true( ...
          'SpaceStation', ...
          'assign', ...
          'test_reset', ...
          min(t));

    end % test_reset()

  end % methods
  
end % classdef
