classdef StationTest < TestUtility
% Tests methods of Station class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    % Identifier for station
    stationId = 'one';
    % Transmit antenna gain, and pattern
    transmitAntenna = EarthStationAntenna( ...
        'transmit', 50, 1, PatternELUX201V01(50))
    % Receive antenna gain, pattern, and noise temperature
    receiveAntenna = EarthStationAntenna( ...
        'receive', 50, 1, PatternELUX202V01())
    noise_t = 290;
    % Signal power, frequency, and requirement
    emission = Emission();
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % A station
    station
    
  end % properties
  
  methods
    
    function this = StationTest(logFId, testMode)
    % Constructs an StationTest.
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
      this.station = Station(this.stationId, ...
                             this.transmitAntenna, ... 
                             this.receiveAntenna, ...
                             this.emission);

    end % StationTest()
    
    function test_Station(this)
    % Tests Station method.
      
      t = [];
      t = [t; isequal(this.station.stationId, this.stationId)];
      t = [t; isequal(this.station.transmitAntenna, this.transmitAntenna)];
      t = [t; isequal(this.station.receiveAntenna, this.receiveAntenna)];
      t = [t; isequal(this.station.emission, this.emission)];

      this.assert_true( ...
          'Station', ...
          'Station', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_Station()

  end % methods

end % classdef
