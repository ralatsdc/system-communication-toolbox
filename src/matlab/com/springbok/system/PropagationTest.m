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
classdef PropagationTest < TestUtility
% Tests methods of Propagation class.
  
  properties (Constant = true)
    
    % None
    
  end % properties (Constant = true)
  
  methods
    
    function this = PropagationTest(logFId, testMode)
    % Constructs a PropagationTest.
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
      
    end % PropagationTest()
    
    function test_computeFreeSpaceLoss(this)

      FSL_expected = 32.447783221883370;
      
      FSL_actual = Propagation.computeFreeSpaceLoss(1, 1);

      t = [];
      t = [t; abs(FSL_actual - FSL_expected) < this.HIGH_PRECISION];

      this.assert_true( ...
          'Propagaton', ...
          'computeFreeSpaceLoss', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));

    end % test_computeFreeSpaceLoss()

    function test_computeSpreadingLoss(this)

      SL_expected = 70.992098640220973;
      
      SL_actual = Propagation.computeSpreadingLoss(1);

      t = [];
      t = [t; abs(SL_actual - SL_expected) < this.HIGH_PRECISION];

      this.assert_true( ...
          'Propagaton', ...
          'computeSpreadingLoss', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));

    end % test_computeSpreadingLoss()

    function test_computeFuselageLoss(this)

      FL_005_expected =  5.0;
      FL_010_expected =  6.0;
      FL_025_expected = 18.0;
      FL_035_expected = 26.0;
      FL_045_expected = 32.0;
      FL_050_expected = 35.0;
      FL_090_expected = 35.0;
      % FL_130_expected = 35.0;
      % FL_140_expected = 29.0;
      % FL_145_expected = 26.0;
      % FL_165_expected = 10.0;
      % FL_175_expected =  5.0;

      FL_005_actual = Propagation.computeFuselageLoss(5);
      FL_010_actual = Propagation.computeFuselageLoss(10);
      FL_025_actual = Propagation.computeFuselageLoss(25);
      FL_035_actual = Propagation.computeFuselageLoss(35);
      FL_045_actual = Propagation.computeFuselageLoss(45);
      FL_050_actual = Propagation.computeFuselageLoss(50);
      FL_090_actual = Propagation.computeFuselageLoss(90);
      % FL_130_actual = Propagation.computeFuselageLoss(130);
      % FL_140_actual = Propagation.computeFuselageLoss(140);
      % FL_145_actual = Propagation.computeFuselageLoss(145);
      % FL_165_actual = Propagation.computeFuselageLoss(165);
      % FL_175_actual = Propagation.computeFuselageLoss(175);

      t = [];
      t = [t; isequal(FL_005_actual, FL_005_expected)];
      t = [t; isequal(FL_010_actual, FL_010_expected)];
      t = [t; isequal(FL_025_actual, FL_025_expected)];
      t = [t; isequal(FL_035_actual, FL_035_expected)];
      t = [t; isequal(FL_045_actual, FL_045_expected)];
      t = [t; isequal(FL_050_actual, FL_050_expected)];
      t = [t; isequal(FL_090_actual, FL_090_expected)];
      % t = [t; isequal(FL_130_actual, FL_130_expected)];
      % t = [t; isequal(FL_140_actual, FL_140_expected)];
      % t = [t; isequal(FL_145_actual, FL_145_expected)];
      % t = [t; isequal(FL_165_actual, FL_165_expected)];
      % t = [t; isequal(FL_175_actual, FL_175_expected)];

      this.assert_true( ...
          'Propagaton', ...
          'computeFuselageLoss', ...
          this.IS_EQUAL_DESC, ...
          min(t));

    end % test_computeFuselageLoss()

    % TODO: Test function building_loss = computeBuildingLoss( ...

  end % methods

end % classdef
