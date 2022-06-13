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
classdef PatternERR_008V01Test < TestUtility
% Tests methods of PatternERR_008V01 class.
  
  properties (Constant = true)
    
    GainMax_input = 35;
    Phi0_input = 1.7;
    
    self = struct( ...
        'GainMax', 35, ...
        'Phi0', 1.7);
    
    Phi_input = [0.2; 0.5; 1; 3; 6; 40; 90; 150];
    
    G_expected = [ ...
        35.000000000000000
        33.961937716262973
        30.847750865051903
        14.833191666465288
        7.307441774865756
        -8.200000000000003
        -5.200000000000003
        -8.200000000000003
                 ];
    Gx_expected = [ ...
        10.000000000000000
        11.050707013225965
        15.000000000000000
        11.533191666465287
        5.000000000000000
        -8.200000000000003
        -5.200000000000003
        -8.200000000000003
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_008V01Test(logFId, testMode)
    % Constructs a PatternERR_008V01Test
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
      
    end % PatternERR_008V01Test()
    
    function test_PatternERR_008V01(this)
    % Tests PatternERR_008V01 method.
      
      p = PatternERR_008V01(this.GainMax_input, this.Phi0_input);
      
      this.assert_true( ...
          'PatternERR_008V01', ...
          'PatternERR_008V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternERR_008V01()
    
    function test_gain(this)
    % Tests gain method.
      
      p = PatternERR_008V01(this.GainMax_input, this.Phi0_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_008V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
    end % test_gain()
    
  end % methods
  
end % classdef
