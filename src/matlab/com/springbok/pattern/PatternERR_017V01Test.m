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
classdef PatternERR_017V01Test < TestUtility
% Tests methods of PatternERR_017V01 class.
  
  properties (Constant = true)
    
    GainMax_input_1 = 35.5;
    Diameter_input_1 = 0.6;
    Frequency_input_1 = 11700;
    
    self_1 = struct( ...
        'GainMax', 35.5, ...
        'Diameter', 0.6, ...
        'Frequency', 11700, ...
        'phi_m', 3.979195541957924, ...
        'phi_r', 4.057020443019943, ...
        'd_over_lambda', 23.416199482910272, ...
        'G1', 13.794820097825752);
    
    GainMax_input_2 = 33.3;
    Diameter_input_2 = 0.45;
    Frequency_input_2 = 12200;
    
    self_2 = struct( ...
        'GainMax', 33.3, ...
        'Diameter', 0.45, ...
        'Frequency', 12200, ...
        'phi_m', 5.142843453175333, ...
        'phi_r', 5.187665484517304, ...
        'd_over_lambda', 18.312668826378548, ...
        'G1', 11.125700905832915);
    
    Phi_input = [0.2; 4.5; 10; 150];
    
    G_expected_1 = [ ...
        35.445168160177658
        12.669687155616412
        4.000000000000000
        0
                   ];
    Gx_expected_1 = [ ...
        35.445168160177658
        12.669687155616412
        4.000000000000000
        0
                    ];
    
    G_expected_2 = [ ...
        33.266464616045532
        16.322711873053777
        4.000000000000000
        0
                   ];
    Gx_expected_2 = [ ...
        33.266464616045532
        16.322711873053777
        4.000000000000000
        0
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_017V01Test(logFId, testMode)
    % Constructs a PatternERR_017V01Test
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
      
    end % PatternERR_017V01Test()
    
    function test_PatternERR_017V01(this)
    % Tests PatternERR_017V01 method.
      
      p_1 = PatternERR_017V01(this.GainMax_input_1, this.Diameter_input_1, this.Frequency_input_1);
      
      this.assert_true( ...
          'PatternERR_017V01', ...
          sprintf('PatternERR_017V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternERR_017V01(this.GainMax_input_2, this.Diameter_input_2, this.Frequency_input_2);
      
      this.assert_true( ...
          'PatternERR_017V01', ...
          sprintf('PatternERR_017V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternERR_017V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternERR_017V01(this.GainMax_input_1, this.Diameter_input_1, this.Frequency_input_1);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_017V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternERR_017V01(this.GainMax_input_2, this.Diameter_input_2, this.Frequency_input_2);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_017V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
