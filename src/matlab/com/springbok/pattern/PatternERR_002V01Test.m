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
classdef PatternERR_002V01Test < TestUtility
% Tests methods of PatternERR_002V01 class.
  
  properties (Constant = true)
    
    GainMax_input_1 = 54.4;
    
    self_1 = struct( ...
        'GainMax', 54.4, ...
        'phi_m', 0.423741115329201, ...
        'phi_r', 0.660463166200195, ...
        'phi_b', 47.863009232263828, ...
        'd_over_lambda', 199.664616023944350, ...
        'G1', 36.504516609481058);
    
    GainMax_input_2 = 34.4;
    
    self_2 = struct( ...
        'GainMax', 34.4, ...
        'phi_m', 3.597060161830266, ...
        'phi_r', 5.008398683320418, ...
        'phi_b', 47.863009232263828, ...
        'd_over_lambda', 19.966461602394443, ...
        'G1', 21.504516609481065);
    
    Phi_input = [0.2; 0.5; 3; 10; 150];
    
    G_expected_1 = [ ...
        50.413404110801082
        36.504516609481058
        20.071968632008442
        7.000000000000000
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        50.413404110801082
        36.504516609481058
        20.071968632008442
        7.000000000000000
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        34.360134041108012
        34.150837756925064
        25.430159249302434
        13.996988927012623
        -3.003011072987377
                   ];
    Gx_expected_2 = [ ...
        34.360134041108012
        34.150837756925064
        25.430159249302434
        13.996988927012623
        -3.003011072987377
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_002V01Test(logFId, testMode)
    % Constructs a PatternERR_002V01Test
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
      
    end % PatternERR_002V01Test()
    
    function test_PatternERR_002V01(this)
    % Tests PatternERR_002V01 method.
      
      p_1 = PatternERR_002V01(this.GainMax_input_1);
      
      this.assert_true( ...
          'PatternERR_002V01', ...
          sprintf('PatternERR_002V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternERR_002V01(this.GainMax_input_2);
      
      this.assert_true( ...
          'PatternERR_002V01', ...
          sprintf('PatternERR_002V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternERR_002V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternERR_002V01(this.GainMax_input_1);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_002V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternERR_002V01(this.GainMax_input_2);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_002V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
