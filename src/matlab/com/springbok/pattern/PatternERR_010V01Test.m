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
classdef PatternERR_010V01Test < TestUtility
% Tests methods of PatternERR_010V01 class.
  
  properties (Constant = true)
    
    GainMax_input = 57;
    
    self = struct( ...
        'GainMax', 57);
    
    Phi_input = [0.08; 0.2; 0.4; 10; 150];
    
    G_expected = [ ...
        57.000000000000000
        49.979400086720375
        42.787999999999997
        4.000000000000000
        -10.000000000000000
                 ];
    Gx_expected = [ ...
        22.000000000000000
        22.000000000000000
        22.000000000000000
        4.000000000000000
        -10.000000000000000
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_010V01Test(logFId, testMode)
    % Constructs a PatternERR_010V01Test
    %
    % Parameters:
    %   logFId - Log file identifier
    %   testMode - Test mode, if 'interactive' then beeps and pauses
      
    % Invoke superclass constructor
      if nargin == 0
        superArgs = {};
        
      else
        superArgs{1} = logFId;
        superArgs{2} = testMode;
        
      end % if
      this@TestUtility(superArgs{:});
      
    end % PatternERR_010V01Test()
    
    function test_PatternERR_010V01(this)
    % Tests PatternERR_010V01 method.
      
      p = PatternERR_010V01(this.GainMax_input);
      
      this.assert_true( ...
          'PatternERR_010V01', ...
          'PatternERR_010V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternERR_010V01()
    
    function test_gain(this)
    % Tests gain method.
      
      p = PatternERR_010V01(this.GainMax_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_010V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
    end % test_gain()
    
  end % methods
  
end % classdef
