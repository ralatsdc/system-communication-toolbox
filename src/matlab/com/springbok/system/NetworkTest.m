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
classdef NetworkTest < TestUtility
% Tests methods of Network class.
  
  properties (Constant = true)
    
    % None

  end % properties (Constant = true)
  
  properties (Access = private)
    
    % A network
    network
    
  end % properties (Access = private)
  
  methods
    
    function this = NetworkTest(logFId, testMode)
    % Constructs a NetworkTest.
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
      this.network = Network();
      
    end % NetworkTest()
    
    function test_Network(this)
    % Tests Network method.
      
      t = [];
      t = [t; isempty(this.network.earthStation)];
      t = [t; isempty(this.network.spaceStation)];
      t = [t; isempty(this.network.spaceStationBeam)];
      t = [t; isempty(this.network.losses)];
      t = [t; isequal(this.network.type, 'both')];
      t = [t; isequal(this.network.doCheck, 1)];
      t = [t; isequal(this.network.up_Link, Link())];
      t = [t; isequal(this.network.dn_Link, Link())];

      this.assert_true( ...
          'Network', ...
          'Network', ...
          this.IS_EQUAL_DESC, ...
          min(t));

    end % test_Network()
    
  end % methods
  
end % classdef
