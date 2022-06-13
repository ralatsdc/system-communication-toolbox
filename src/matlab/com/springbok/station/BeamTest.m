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
classdef BeamTest < TestUtility
% Tests methods of Beam class.
  
  properties (Constant = true)
    
    % Beam name
    name = 'RAMBOUILLET';

  end % properties (Constant = true)
  
  properties (Access = private)
    
    % None
    
  end % properties (Access = private)
  
  methods
    
    function this = BeamTest(logFId, testMode)
    % Constructs a BeamTest.
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
      
    end % BeamTest()
    
    function test_Beam(this)
    % Tests Beam method.
      
      multiplicity = 1;
      dutyCycle = 100;
      
      beam = Beam(this.name, multiplicity, dutyCycle);
      
      t = [];
      t = [t; strcmp(beam.name, this.name)];
      t = [t; isequal(beam.multiplicity, multiplicity)];
      t = [t; isequal(beam.dutyCycle, dutyCycle)];
      
      this.assert_true( ...
          'Beam', ...
          'Beam', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_Beam()
    
    function test_assign_with_multiplicity_one_and_without_multiplexing(this)

      multiplicity = 1;
      doMultiplexing = 0;
      dutyCycle = 100;
      
      beam = Beam(this.name, multiplicity, dutyCycle);

      t = [];
      t = [t; beam.isAvailable == 1];
      t = [t; beam.isMultiplexed == 0];
      t = [t; beam.divisions == 0];

      isAssigned = beam.assign(doMultiplexing);

      t = [t; isAssigned == 1];
      t = [t; beam.isAvailable == 0];
      t = [t; beam.isMultiplexed == doMultiplexing];
      t = [t; beam.divisions == 1];

      isAssigned = beam.assign(doMultiplexing);

      t = [t; isAssigned == 0];
      t = [t; beam.isAvailable == 0];
      t = [t; beam.isMultiplexed == doMultiplexing];
      t = [t; beam.divisions == 1];

      this.assert_true( ...
          'Beam', ...
          'assign', ...
          'test_assign_with_multiplicity_one_and_without_multiplexing', ...
          min(t));

    end % test_assign_with_multiplicity_one_and_without_multiplexing()

    function test_assign_with_multiplicity_one_and_with_multiplexing(this)

      multiplicity = 1;
      doMultiplexing = 1;
      dutyCycle = 100;

      beam = Beam(this.name, multiplicity, dutyCycle);

      t = [];
      t = [t; beam.isAvailable == 1];
      t = [t; beam.isMultiplexed == 0];
      t = [t; beam.divisions == 0];

      isAssigned = beam.assign(doMultiplexing);

      t = [t; isAssigned == 1];
      t = [t; beam.isAvailable == 0];
      t = [t; beam.isMultiplexed == doMultiplexing];
      t = [t; beam.divisions == 1];

      isAssigned = beam.assign(doMultiplexing);

      t = [t; isAssigned == 0];
      t = [t; beam.isAvailable == 0];
      t = [t; beam.isMultiplexed == doMultiplexing];
      t = [t; beam.divisions == 1];

      this.assert_true( ...
          'Beam', ...
          'assign', ...
          'test_assign_with_multiplicity_one_and_with_multiplexing', ...
          min(t));

    end % test_assign_with_multiplicity_one_and_with_multiplexing()

    function test_assign_with_multiplicity_three_and_without_multiplexing(this)

      multiplicity = 3;
      doMultiplexing = 0;
      dutyCycle = 100;

      beam = Beam(this.name, multiplicity, dutyCycle);

      t = [];
      t = [t; beam.isAvailable == 1];
      t = [t; beam.isMultiplexed == 0];
      t = [t; beam.divisions == 0];

      isAssigned = beam.assign(doMultiplexing);

      t = [t; isAssigned == 1];
      t = [t; beam.isAvailable == 0];
      t = [t; beam.isMultiplexed == doMultiplexing];
      t = [t; beam.divisions == 1];

      isAssigned = beam.assign(doMultiplexing);

      t = [t; isAssigned == 0];
      t = [t; beam.isAvailable == 0];
      t = [t; beam.isMultiplexed == doMultiplexing];
      t = [t; beam.divisions == 1];

      this.assert_true( ...
          'Beam', ...
          'assign', ...
          'test_assign_with_multiplicity_three_and_without_multiplexing', ...
          min(t));

    end % test_assign_with_multiplicity_three_and_without_multiplexing()

    function test_assign_with_multiplicity_three_and_with_multiplexing(this)

      multiplicity = 3;
      doMultiplexing = 1;
      dutyCycle = 100;

      beam = Beam(this.name, multiplicity, dutyCycle);

      t = [];
      t = [t; beam.isAvailable == 1];
      t = [t; beam.isMultiplexed == 0];
      t = [t; beam.divisions == 0];

      for idx = 1:multiplicity - 1
        isAssigned = beam.assign(doMultiplexing);

        t = [t; isAssigned == 1];
        t = [t; beam.isAvailable == 1];
        t = [t; beam.isMultiplexed == doMultiplexing];
        t = [t; beam.divisions == idx];

      end % for
      
      isAssigned = beam.assign(doMultiplexing);

      t = [t; isAssigned == 1];
      t = [t; beam.isAvailable == 0];
      t = [t; beam.isMultiplexed == doMultiplexing];
      t = [t; beam.divisions == multiplicity];

      isAssigned = beam.assign(doMultiplexing);

      t = [t; isAssigned == 0];
      t = [t; beam.isAvailable == 0];
      t = [t; beam.isMultiplexed == doMultiplexing];
      t = [t; beam.divisions == multiplicity];

      this.assert_true( ...
          'Beam', ...
          'assign', ...
          'test_assign_with_multiplicity_three_and_with_multiplexing', ...
          min(t));

    end % test_assign_with_multiplicity_three_and_with_multiplexing()

    function test_reset(this)

      multiplicity = 1;
      doMultiplexing = 1;
      dutyCycle = 100;

      beam = Beam(this.name, multiplicity, dutyCycle);

      t = [];
      t = [t; beam.isAvailable == 1];
      t = [t; beam.isMultiplexed == 0];
      t = [t; beam.divisions == 0];

      isAssigned = beam.assign(doMultiplexing);

      t = [t; isAssigned == 1];
      t = [t; beam.isAvailable == 0];
      t = [t; beam.isMultiplexed == doMultiplexing];
      t = [t; beam.divisions == 1];

      beam.reset();
      
      t = [t; beam.isAvailable == 1];
      t = [t; beam.isMultiplexed == 0];
      t = [t; beam.divisions == 0];

      this.assert_true( ...
          'Beam', ...
          'assign', ...
          'test_reset', ...
          min(t));
      
    end % test_reset()

  end % methods
  
end % classdef
