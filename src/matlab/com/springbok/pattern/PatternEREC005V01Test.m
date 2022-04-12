classdef PatternEREC005V01Test < TestUtility
% Tests methods of PatternEREC005V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    GainMax_input_1 = 24.6;
    
    self_1 = struct( ...
        'GainMax', 24.6, ...
        'phi_m', 9.003165910021892, ...
        'phi_r', 14.288939585111025, ...
        'phi_b', 55.103761540424230, ...
        'd_over_lambda', 6.998419960022736, ...
        'G1', 14.674999999999999);
    
    GainMax_input_2 = 19.7;
    
    self_2 = struct( ...
        'GainMax', 19.7, ...
        'phi_m', 14.818001075688557, ...
        'phi_r', 25.118864315095802, ...
        'phi_b', 69.052792480458834, ...
        'd_over_lambda', 3.981071705534972, ...
        'G1', 11.000000000000000);
    
    Phi_input = [0.2; 10; 20; 40; 150];
    
    G_expected_1 = [ ...
        24.595102211806317
        14.674999999999999
        11.024250108400466
        3.498500216800935
        0
                   ];
    Gx_expected_1 = [ ...
        24.595102211806317
        14.674999999999999
        11.024250108400466
        3.498500216800935
        0
                    ];
    
    G_expected_2 = [ ...
        19.698415106807538
        15.737767018847217
        11.000000000000000
        5.948500216800937
        0
                   ];
    Gx_expected_2 = [ ...
        19.698415106807538
        15.737767018847217
        11.000000000000000
        5.948500216800937
        0
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternEREC005V01Test(logFId, testMode)
    % Constructs a PatternEREC005V01Test
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
      
    end % PatternEREC005V01Test()
    
    function test_PatternEREC005V01(this)
    % Tests PatternEREC005V01 method.
      
      p_1 = PatternEREC005V01(this.GainMax_input_1);
      
      this.assert_true( ...
          'PatternEREC005V01', ...
          sprintf('PatternEREC005V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternEREC005V01(this.GainMax_input_2);
      
      this.assert_true( ...
          'PatternEREC005V01', ...
          sprintf('PatternEREC005V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternEREC005V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternEREC005V01(this.GainMax_input_1);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternEREC005V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternEREC005V01(this.GainMax_input_2);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternEREC005V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
