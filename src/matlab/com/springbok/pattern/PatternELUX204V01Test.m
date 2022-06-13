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
classdef PatternELUX204V01Test < TestUtility
% Tests methods of PatternELUX204V01 class.
  
  properties (Constant = true)
    
    GainMax_input_1 = 59;
    Efficiency_input = 0.7;
    
    self_1 = struct( ...
        'phi_m', 0.276941921655738, ...
        'phi_r', 0.480671754000950, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 339.079166783875280, ...
        'G1', 36.954516609481075);
    
    GainMax_input_2 = 49;
    
    self_2 = struct( ...
        'phi_m', 0.824616643786384, ...
        'phi_r', 0.959066236628087, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 107.226247414915680, ...
        'G1', 29.454516609481065);
    
    Phi_input = [0.2; 0.4; 0.9; 10; 30; 150];
    
    G_expected_1 = [ ...
        47.502531865315291
        36.954516609481075
        30.143937264016877
        4.000000000000000
        -4.928031367991565
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        47.502531865315291
        36.954516609481075
        30.143937264016877
        4.000000000000000
        -4.928031367991565
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        47.850253186531532
        44.401012746126113
        29.454516609481065
        4.000000000000000
        -4.928031367991565
        -10.000000000000000
                   ];
    Gx_expected_2 = [ ...
        47.850253186531532
        44.401012746126113
        29.454516609481065
        4.000000000000000
        -4.928031367991565
        -10.000000000000000
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternELUX204V01Test(logFId, testMode)
    % Constructs a PatternELUX204V01Test
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
      
    end % PatternELUX204V01Test()
    
    function test_PatternELUX204V01(this)
    % Tests PatternELUX204V01 method.
      
      p_1 = PatternELUX204V01(this.GainMax_input_1, this.Efficiency_input);
      
      this.assert_true( ...
          'PatternELUX204V01', ...
          sprintf('PatternELUX204V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternELUX204V01(this.GainMax_input_2, this.Efficiency_input);
      
      this.assert_true( ...
          'PatternELUX204V01', ...
          sprintf('PatternELUX204V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternELUX204V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternELUX204V01(this.GainMax_input_1, this.Efficiency_input);
      
      [G_actual_1, Gx_actual_1] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual_1 - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual_1 - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternELUX204V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternELUX204V01(this.GainMax_input_2, this.Efficiency_input);
      
      [G_actual_2, Gx_actual_2] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual_2 - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual_2 - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternELUX204V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
