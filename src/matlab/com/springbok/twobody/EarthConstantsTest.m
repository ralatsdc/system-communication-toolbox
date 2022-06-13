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
classdef EarthConstantsTest < TestUtility
% Tests methods of EarthConstants class.
  
  properties (Constant = true)
    
    % Date number at which the angle coincides
    dNm = datenum('01/01/2009 12:00:00');
    
  end % properties (Constant = true)
  
  methods
    
    function this = EarthConstantsTest(logFId, testMode)
    % Constructs a CoordinatesTest.
    %
    % Parameters
    %   logFId -Log file identifier
    %   testMode - Test mode, if 'interactive' then beeps and pauses
      
    % Invoke superclass constructor
      if nargin == 0
        superArgs = {};
        
      else
        superArgs{1} = logFId;
        superArgs{2} = testMode;
        
      end % if
      this@TestUtility(superArgs{:});
      
    end % EarthConstantsTest()
    
    function test_Theta(this)
    % Tests Theta method.
      
      theta_expected = 20720.5710265505076677;
      
      theta_actual = EarthConstants.Theta(this.dNm);
      
      this.assert_true( ...
          'EarthConstants', ...
          'Theta', ...
          this.HIGH_PRECISION_DESC, ...
          abs(theta_actual - theta_expected) < this.HIGH_PRECISION);
      
    end % test_Theta()
    
  end % methods
  
end % classdef
