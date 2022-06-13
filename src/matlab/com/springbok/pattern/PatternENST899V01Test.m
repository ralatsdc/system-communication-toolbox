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
classdef PatternENST899V01Test < TestUtility
% Tests methods of PatternENST899V01 class.
  
  properties (Constant = true)
    
    GainMax_input_1 = 57;
    AngleTable_input = [1; 40; 180];
    GainTable_input = [32; -10; -10];
    
    self_1 = struct( ...
        'GainMax', 57, ...
        'AngleTable', [1; 40; 180], ...
        'GainTable', [32; -10; -10]);
    
    GainMax_input_2 = 35;
    
    self_2 = struct( ...
        'GainMax', 35, ...
        'AngleTable', [1; 40; 180], ...
        'GainTable', [32; -10; -10]);
    
    Phi_input = [0.2; 4; 150];
    
    G_expected_1 = [ ...
        52.000000000000000
        28.769230769230770
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        52.000000000000000
        28.769230769230770
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        34.399999999999999
        28.769230769230770
        -10.000000000000000
                   ];
    Gx_expected_2 = [ ...
        34.399999999999999
        28.769230769230770
        -10.000000000000000
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternENST899V01Test(logFId, testMode)
    % Constructs a PatternENST899V01Test
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
      
    end % PatternENST899V01Test()
    
    function test_PatternENST899V01(this)
    % Tests PatternENST899V01 method.
      
      p_1 = PatternENST899V01(this.GainMax_input_1, this.AngleTable_input, this.GainTable_input);
      
      this.assert_true( ...
          'PatternENST899V01', ...
          sprintf('PatternENST899V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternENST899V01(this.GainMax_input_2, this.AngleTable_input, this.GainTable_input);
      
      this.assert_true( ...
          'PatternENST899V01', ...
          sprintf('PatternENST899V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternENST899V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternENST899V01(this.GainMax_input_1, this.AngleTable_input, this.GainTable_input);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternENST899V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternENST899V01(this.GainMax_input_2, this.AngleTable_input, this.GainTable_input);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternENST899V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
