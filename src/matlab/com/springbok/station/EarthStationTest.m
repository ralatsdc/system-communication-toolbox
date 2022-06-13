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
classdef EarthStationTest < TestUtility
% Tests methods of EarthStation class.
  
  properties (Constant = true)
    
    % Identifier for station
    stationId = 'one';
    % Transmit antenna gain, and pattern
    transmitAntenna = EarthStationAntenna( ...
        'transmit', 50, 1, PatternELUX201V01(50))
    % Receive antenna gain, pattern, and noise temperature
    receiveAntenna = EarthStationAntenna( ...
        'transmit', 50, 1, PatternELUX202V01())
    noise_t = 290;
    % Signal power, frequency, and requirement
    emission = Emission();
    % Beam
    beam = Beam('one', 1, 100);

    % Geodetic latitude [rad]
    varphi = -0.388146681233106;
    % Longitude [rad]
    lambda = 1.991134636453675;
    
    % Flag indicating whether to do multiplexing, or not
    doMultiplexing = 1;

    % Geocentric equatorial rotating position [er]
    % TODO: Manually validate this values
    r_ger = [ ...
        -0.377895136637375; ...
        +0.845443871581228; ...
        -0.376120343255564];
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % An Earth station
    earthStation
    
  end % properties (Access = private)
  
  methods
    
    function this = EarthStationTest(logFId, testMode)
    % Constructs an EarthStationTest.
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
      this.earthStation = EarthStation(this.stationId, ...
                                       this.transmitAntenna, ...
                                       this.receiveAntenna, ...
                                       this.emission, ...
                                       this.beam, ... 
                                       this.varphi, ...
                                       this.lambda, ...
                                       this.doMultiplexing);
      
    end % EarthStationTest()
    
    function test_EarthStation(this)
    % Tests the EarthStation constructor. Note that the private
    % method compute_r_ger can only be tested implicitly.
      
      t = [];
      t = [t; isequal(this.earthStation.stationId, this.stationId)];
      t = [t; isequal(this.earthStation.transmitAntenna, this.transmitAntenna)];
      t = [t; isequal(this.earthStation.receiveAntenna, this.receiveAntenna)];
      t = [t; isequal(this.earthStation.emission, this.emission)];
      t = [t; isequal(this.earthStation.beam, this.beam)];
      t = [t; isequal(this.earthStation.varphi, this.varphi)];
      t = [t; isequal(this.earthStation.lambda, this.lambda)];
      t = [t; isequal(this.earthStation.doMultiplexing, this.doMultiplexing)];
      t = [t; max(abs(this.earthStation.r_ger - this.r_ger)) < this.HIGH_PRECISION];

      this.assert_true( ...
          'EarthStation', ...
          'EarthStation', ...
          this.IS_EQUAL_DESC, ...
          min(t));

    end % test_EarthStation()

  end % methods
  
end % classdef
