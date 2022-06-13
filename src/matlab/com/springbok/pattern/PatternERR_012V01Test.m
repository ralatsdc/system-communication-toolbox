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
classdef PatternERR_012V01Test < TestUtility
% Tests methods of PatternERR_012V01 class.
  
  properties (Constant = true)
    
    GainMax_input_1 = 53.7;
    
    self_1 = struct( ...
        'GainMax', 53.7, ...
        'phi_m', 0.450511291385659, ...
        'phi_r', 0.660737972800482, ...
        'phi_b', 36.000000000000000, ...
        'd_over_lambda', 199.526231496887870, ...
        'G1', 33.500000000000000);
    
    GainMax_input_2 = 39.7;
    
    self_2 = struct( ...
        'GainMax', 39.7, ...
        'phi_m', 2.285678632768832, ...
        'phi_r', 2.511886431509580, ...
        'phi_b', 36.000000000000000, ...
        'd_over_lambda', 39.810717055349734, ...
        'G1', 19.000000000000000);
    
    Phi_input = [0.2; 0.6; 2.3; 10; 150];
    
    G_expected_1 = [ ...
        49.718928294465030
        33.500000000000000
        19.956804099560181
        4.000000000000000
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        49.718928294465030
        33.500000000000000
        19.956804099560181
        4.000000000000000
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        39.541510680753895
        38.273596126785002
        19.000000000000000
        4.000000000000000
        -10.000000000000000
                   ];
    Gx_expected_2 = [ ...
        39.541510680753895
        38.273596126785002
        19.000000000000000
        4.000000000000000
        -10.000000000000000
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_012V01Test(logFId, testMode)
    % Constructs a PatternERR_012V01Test
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
      
    end % PatternERR_012V01Test()
    
    function test_PatternERR_012V01(this)
    % Tests PatternERR_012V01 method.
      
      p_1 = PatternERR_012V01(this.GainMax_input_1);
      
      this.assert_true( ...
          'PatternERR_012V01', ...
          sprintf('PatternERR_012V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternERR_012V01(this.GainMax_input_2);
      
      this.assert_true( ...
          'PatternERR_012V01', ...
          sprintf('PatternERR_012V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternERR_012V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternERR_012V01(this.GainMax_input_1);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_012V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternERR_012V01(this.GainMax_input_2);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_012V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
