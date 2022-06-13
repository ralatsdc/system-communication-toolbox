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
classdef StationTest < TestUtility
% Tests methods of Station class.
  
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
