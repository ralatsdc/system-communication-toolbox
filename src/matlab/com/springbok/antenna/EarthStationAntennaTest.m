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
classdef EarthStationAntennaTest < TestUtility
% Tests methods of EarthStationAntenna class.
  
  properties (Constant = true)
    
    % Antenna name
    name = 'RAMBOUILLET';
    % Antenna emission direction
    gain = 54.000000000000000;
    % Antenna pattern identifier
    pattern_id = 94;
    % Antenna pattern
    pattern = PatternELUX201V01();

    % Antenna feeder loss [db]
    feeder_loss = 0;
    % Antenna body loss [db]
    body_loss = 0;
    % Antenna noise temperature [K]
    noise_t = NaN;
    % Antenna unit azimuth reference (normal) vector in local tangent coordinates
    x_ltp = [];
    % Antenna unit elevation reference vector in local tangent coordinates
    z_ltp = [];
    
  end % properties (Constant = true)
  
  properties (Access = private)
    
    % An Earth station antenna
    earthStationAntenna
    
  end % properties (Access = private)
  
  methods

    function this = EarthStationAntennaTest(logFId, testMode)
    % Constructs an EarthStationAntennaTest.
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
      this.earthStationAntenna = EarthStationAntenna(this.name, ...
                                                     this.gain, ...
                                                     this.pattern_id, ...
                                                     this.pattern);
      
    end % EarthStationAntennaTest()
    
    function test_EarthStationAntenna(this)
    % Test the EarthStationAntenna constructor.
      
      t = [];
      t = [t; strcmp(this.earthStationAntenna.name, this.name)];
      t = [t; isequal(this.earthStationAntenna.gain, this.gain)];
      t = [t; isequal(this.earthStationAntenna.pattern_id, this.pattern_id)];
      t = [t; isequal(this.earthStationAntenna.pattern, this.pattern)];
      t = [t; isequal(this.earthStationAntenna.feeder_loss, this.feeder_loss)];
      t = [t; isequal(this.earthStationAntenna.body_loss, this.body_loss)];
      t = [t; isequalwithequalnans(this.earthStationAntenna.noise_t, this.noise_t)];
      t = [t; isequalwithequalnans(this.earthStationAntenna.x_ltp, this.x_ltp)];
      t = [t; isequalwithequalnans(this.earthStationAntenna.z_ltp, this.z_ltp)];
      
      this.assert_true( ...
          'EarthStationAntenna', ...
          'EarthStationAntenna', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_EarthStationAntenna()
    
  end % methods
  
end % classdef
