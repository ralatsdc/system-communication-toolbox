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
classdef PatternERR_020V01Test < TestUtility
% Tests methods of PatternERR_020V01 class.
  
  properties (Constant = true)
    
    Diameter_input_1 = 3;
    Frequency_input = 11000;
    
    self_1 = struct( ...
        'Frequency', 11000, ...
        'phi_m', 0.790084081312813, ...
        'phi_r', 0.944089841015923, ...
        'phi_b', 34.100000000000001, ...
        'd_over_lambda', 110.076151415390170, ...
        'G1', 29.624666890405141);
    
    Diameter_input_2 = 1;
    
    self_2 = struct( ...
        'Frequency', 11000, ...
        'phi_m', 2.457097134567086, ...
        'phi_r', 2.589116682727273, ...
        'phi_b', 33.100000000000001, ...
        'd_over_lambda', 36.692050471796726, ...
        'G1', 18.671209423536244);
    
    Diameter_input_3 = 0.6;
    
    self_3 = struct( ...
        'Frequency', 11000, ...
        'phi_m', 4.205450430304155, ...
        'phi_r', 4.315194471212122, ...
        'phi_b', 33.100000000000001, ...
        'd_over_lambda', 22.015230283078033, ...
        'G1', 13.124990683127333);
    
    Phi_input = [0.2; 0.9; 2; 10; 60; 100; 150];
    
    G_expected_1 = [ ...
        47.322188827956808
        29.624666890405141
        21.474250108400472
        4.000000000000000
        -12.000000000000000
        -7.000000000000000
        -12.000000000000000
                   ];
    Gx_expected_1 = [ ...
        47.322188827956808
        29.624666890405141
        21.474250108400472
        4.000000000000000
        -12.000000000000000
        -7.000000000000000
        -12.000000000000000
                    ];
    
    G_expected_2 = [ ...
        38.856808987823463
        36.265168844760574
        25.528373966357172
        4.000000000000000
        -9.000000000000000
        -4.000000000000000
        -9.000000000000000
                   ];
    Gx_expected_2 = [ ...
        38.856808987823463
        36.265168844760574
        25.528373966357172
        4.000000000000000
        -9.000000000000000
        -4.000000000000000
        -9.000000000000000
                    ];
    
    G_expected_3 = [ ...
        34.505997615837138
        33.573007164334498
        29.707761008109269
        4.000000000000000
        -9.000000000000000
        -5.000000000000000
        -5.000000000000000
                   ];
    Gx_expected_3 = [ ...
        34.505997615837138
        33.573007164334498
        29.707761008109269
        4.000000000000000
        -9.000000000000000
        -5.000000000000000
        -5.000000000000000
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_020V01Test(logFId, testMode)
    % Constructs a PatternERR_020V01Test
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
      
    end % PatternERR_020V01Test()
    
    function test_PatternERR_020V01(this)
    % Tests PatternERR_020V01 method.
      
      p_1 = PatternERR_020V01(this.Diameter_input_1, this.Frequency_input);
      
      this.assert_true( ...
          'PatternERR_020V01', ...
          sprintf('PatternERR_020V01:%.1f', this.Diameter_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternERR_020V01(this.Diameter_input_2, this.Frequency_input);
      
      this.assert_true( ...
          'PatternERR_020V01', ...
          sprintf('PatternERR_020V01:%.1f', this.Diameter_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
      p_3 = PatternERR_020V01(this.Diameter_input_3, this.Frequency_input);
      
      this.assert_true( ...
          'PatternERR_020V01', ...
          sprintf('PatternERR_020V01:%.1f', this.Diameter_input_3), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_3, p_3));
      
    end % test_PatternERR_020V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternERR_020V01(this.Diameter_input_1, this.Frequency_input);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_020V01', ...
          sprintf('gain:%.1f', this.Diameter_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternERR_020V01(this.Diameter_input_2, this.Frequency_input);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_020V01', ...
          sprintf('gain:%.1f', this.Diameter_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_3 = PatternERR_020V01(this.Diameter_input_3, this.Frequency_input);
      
      [G_actual, Gx_actual] = p_3.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_3) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_3) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_020V01', ...
          sprintf('gain:%.1f', this.Diameter_input_3), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_3.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
