classdef EarthConstantsTest < TestUtility
% Tests methods of EarthConstants class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

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
