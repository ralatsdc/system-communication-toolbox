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
classdef PatternENST803V01Test < TestUtility
% Tests methods of PatternENST803V01 class.
  
  properties (Constant = true)
    
    GainMax_input_1 = 54.4;
    Efficiency_input= 0.7;
    CoefA_input = 28;
    
    self_1 = struct( ...
        'GainMax', 54.4, ...
        'Efficiency', 0.7, ...
        'CoefA', 28, ...
        'phi_m', 0.468712091388917, ...
        'phi_r', 0.660463166200195, ...
        'phi_b', 33.113112148259113, ...
        'd_over_lambda', 199.664616023944350, ...
        'G1', 32.504516609481058);
    
    GainMax_input_2 = 34.4;
    
    self_2 = struct( ...
        'GainMax', 34.4, ...
        'Efficiency', 0.7, ...
        'CoefA', 28, ...
        'phi_m', 4.117315993119801, ...
        'phi_r', 5.008398683320418, ...
        'phi_b', 33.113112148259113, ...
        'd_over_lambda', 19.966461602394443, ...
        'G1', 17.504516609481065);
    
    Phi_input = [0.2; 0.6; 4.5; 10; 150];
    
    G_expected_1 = [ ...
        50.413404110801082
        32.504516609481058
        11.669687155616412
        3.000000000000000
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        50.413404110801082
        32.504516609481058
        11.669687155616412
        3.000000000000000
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        34.360134041108012
        34.041206369972095
        17.504516609481065
        9.996988927012623
        -3.003011072987377
                   ];
    Gx_expected_2 = [ ...
        34.360134041108012
        34.041206369972095
        17.504516609481065
        9.996988927012623
        -3.003011072987377
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternENST803V01Test(logFId, testMode)
    % Constructs a PatternENST803V01Test
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
      
    end % PatternENST803V01Test()
    
    function test_PatternENST803V01(this)
    % Tests PatternENST803V01 method.
      
      p_1 = PatternENST803V01(this.GainMax_input_1, this.Efficiency_input, this.CoefA_input);
      
      this.assert_true( ...
          'PatternENST803V01', ...
          sprintf('PatternENST803V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternENST803V01(this.GainMax_input_2, this.Efficiency_input, this.CoefA_input);
      
      this.assert_true( ...
          'PatternENST803V01', ...
          sprintf('PatternENST803V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternENST803V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternENST803V01(this.GainMax_input_1, this.Efficiency_input, this.CoefA_input);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternENST803V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternENST803V01(this.GainMax_input_2, this.Efficiency_input, this.CoefA_input);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternENST803V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
