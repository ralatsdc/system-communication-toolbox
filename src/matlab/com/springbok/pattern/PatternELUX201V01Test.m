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
classdef PatternELUX201V01Test < TestUtility
% Tests methods of PatternELUX201V01 class.
  
  properties (Constant = true)
    
    GainMax_input = 57;
    
    self = struct( ...
        'GainMax', 57, ...
        'd_over_lambda', 288.526169332032340, ...
        'G1', 35.902778147007240, ...
        'phi_m', 0.318388535104499, ...
        'phi_r', 0.529563618062320, ...
        'phi_b', 36.307805477010142);
    
    Phi_input = [0.2; 0.4; 10; 150];
    
    G_expected = [ ...
        48.675264961058339
        35.902778147007240
        4.000000000000000
        -10.000000000000000
                 ];
    Gx_expected = [ ...
        27.000000000000000
        27.000000000000000
        4.000000000000000
        -10.000000000000000
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternELUX201V01Test(logFId, testMode)
    % Constructs a PatternELUX201V01Test
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
      
    end % PatternELUX201V01Test()
    
    function test_PatternELUX201V01(this)
    % Tests PatternELUX201V01 method.
      
      p = PatternELUX201V01(this.GainMax_input);
      
      this.assert_true( ...
          'PatternELUX201V01', ...
          'PatternELUX201V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternELUX201V01()
    
    function test_gain(this)
    % Tests gain method.
      
      p = PatternELUX201V01(this.GainMax_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternELUX201V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
    end % test_gain()
    
  end % methods
  
end % classdef
