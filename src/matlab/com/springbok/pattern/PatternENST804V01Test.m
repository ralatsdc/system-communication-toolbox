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
classdef PatternENST804V01Test < TestUtility
% Tests methods of PatternENST804V01 class.
  
  properties (Constant = true)
    
    GainMax_input_1 = 38;
    CoefA_input_1 = 35;
    CoefB_input_1 = 24;
    
    self_1 = struct( ...
        'GainMax', 38, ...
        'CoefA', 35, ...
        'CoefB', 24, ...
        'phi_r', 1, ...
        'phi_b', 74.990000000000000);
    
    GainMax_input_2 = 30;
    CoefA_input_2 = 33;
    CoefB_input_2 = 26;
    
    self_2 = struct( ...
        'GainMax', 30, ...
        'CoefA', 33, ...
        'CoefB', 26, ...
        'phi_r', 1, ...
        'phi_b', 45.066000000000000);
    
    Phi_input = [0.2; 4; 150];
    
    G_expected_1 = [ ...
        38.000000000000000
        20.550560208128907
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        38.000000000000000
        20.550560208128907
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        30.000000000000000
        17.346440225472982
        -10.000000000000000
                   ];
    Gx_expected_2 = [ ...
        30.000000000000000
        17.346440225472982
        -10.000000000000000
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternENST804V01Test(logFId, testMode)
    % Constructs a PatternENST804V01Test
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
      
    end % PatternENST804V01Test()
    
    function test_PatternENST804V01(this)
    % Tests PatternENST804V01 method.
      
      p_1 = PatternENST804V01(this.GainMax_input_1, this.CoefA_input_1, this.CoefB_input_1);
      
      this.assert_true( ...
          'PatternENST804V01', ...
          sprintf('PatternENST804V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternENST804V01(this.GainMax_input_2, this.CoefA_input_2, this.CoefB_input_2);
      
      this.assert_true( ...
          'PatternENST804V01', ...
          sprintf('PatternENST804V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternENST804V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternENST804V01(this.GainMax_input_1, this.CoefA_input_1, this.CoefB_input_1);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternENST804V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternENST804V01(this.GainMax_input_2, this.CoefA_input_2, this.CoefB_input_2);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternENST804V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
