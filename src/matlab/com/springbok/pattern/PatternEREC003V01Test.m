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
classdef PatternEREC003V01Test < TestUtility
% Tests methods of PatternEREC003V01 class.
  
  properties (Constant = true)
    
    GainMax_input_1 = 54.4;
    Efficiency_input = 0.7;
    
    self_1 = struct( ...
        'GainMax', 54.4, ...
        'Efficiency', 0.7, ...
        'phi_m', 0.474081379137515, ...
        'phi_r', 1.000000000000000, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 199.664616023944350, ...
        'G1', 32.000000000000000);
    
    GainMax_input_2 = 34.4;
    
    self_2 = struct( ...
        'GainMax', 34.4, ...
        'Efficiency', 0.7, ...
        'phi_m', 3.597060161830266, ...
        'phi_r', 5.008398683320418, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 19.966461602394443, ...
        'G1', 21.504516609481065);
    
    Phi_input = [0.2; 0.8; 4; 10; 150];
    
    G_expected_1 = [ ...
        50.413404110801082
        32.000000000000000
        16.948500216800944
        7.000000000000000
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        50.413404110801082
        32.000000000000000
        16.948500216800944
        7.000000000000000
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        34.360134041108012
        33.762144657728172
        21.504516609481065
        13.996988927012623
        -3.003011072987377
                   ];
    Gx_expected_2 = [ ...
        34.360134041108012
        33.762144657728172
        21.504516609481065
        13.996988927012623
        -3.003011072987377
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternEREC003V01Test(logFId, testMode)
    % Constructs a PatternEREC003V01Test
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
      
    end % PatternEREC003V01Test()
    
    function test_PatternEREC003V01(this)
    % Tests PatternEREC003V01 method.
      
      p_1 = PatternEREC003V01(this.GainMax_input_1, this.Efficiency_input);
      
      this.assert_true( ...
          'PatternEREC003V01', ...
          sprintf('PatternEREC003V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternEREC003V01(this.GainMax_input_2, this.Efficiency_input);
      
      this.assert_true( ...
          'PatternEREC003V01', ...
          sprintf('PatternEREC003V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternEREC003V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternEREC003V01(this.GainMax_input_1, this.Efficiency_input);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternEREC003V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternEREC003V01(this.GainMax_input_2, this.Efficiency_input);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternEREC003V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
