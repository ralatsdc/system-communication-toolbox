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
classdef AntennaTest < TestUtility
% Tests methods of Antenna class.
  
  properties (Constant = true)
    
    % Antenna name
    name = 'RAMBOUILLET';
    % Antenna gain [dB]
    gain = 54.000000000000000;

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
    
    % An antenna
    antenna
    
  end % properties (Access = private)
  
  methods
    
    function this = AntennaTest(logFId, testMode)
    % Constructs an AntennaTest.
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
      this.antenna = Antenna(this.name, ...
                             this.gain);

    end % AntennaTest()
    
    function test_Antenna(this)
    % Tests Antenna method.
      
      t = [];
      t = [t; strcmp(this.antenna.name, this.name)];
      t = [t; isequal(this.antenna.gain, this.gain)];
      t = [t; isequal(this.antenna.feeder_loss, this.feeder_loss)];
      t = [t; isequal(this.antenna.body_loss, this.body_loss)];
      t = [t; isequalwithequalnans(this.antenna.noise_t, this.noise_t)];
      t = [t; isequalwithequalnans(this.antenna.x_ltp, this.x_ltp)];
      t = [t; isequalwithequalnans(this.antenna.z_ltp, this.z_ltp)];

      this.assert_true( ...
          'Antenna', ...
          'Antenna', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_Antenna()
    
  end % methods
  
end % classdef
