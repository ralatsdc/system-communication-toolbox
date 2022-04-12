classdef PatternELUX205V01Test < TestUtility
% Tests methods of PatternELUX205V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    GainMax_input_1 = 57;
    Efficiency_input = 0.7;
    
    self_1 = struct( ...
        'phi_m', 0.344672797841786, ...
        'phi_r', 1.000000000000000, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 269.340155983215820, ...
        'G1', 35.454516609481068);
    
    GainMax_input_2 = 34;
    
    self_2 = struct( ...
        'phi_m', 4.168649190696996, ...
        'phi_r', 5.244437241325346, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 19.067822799368372, ...
        'G1', 18.204516609481068);
    
    Phi_input = [0.2; 0.8; 2; 4.5; 6; 8; 20; 150];
    
    G_expected_1 = [ ...
        49.745588037493697
        35.454516609481068
        21.474250108400472
        12.669687155616412
        9.546218740408911
        7.900000000000000
        -0.525749891599531
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        49.745588037493697
        35.454516609481068
        21.474250108400472
        12.669687155616412
        9.546218740408911
        7.900000000000000
        -0.525749891599531
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        33.963641813369186
        33.418269013907022
        30.364181336918875
        18.204516609481068
        9.546218740408911
        7.900000000000000
        -0.525749891599531
        -10.000000000000000
                   ];
    Gx_expected_2 = [ ...
        33.963641813369186
        33.418269013907022
        30.364181336918875
        18.204516609481068
        9.546218740408911
        7.900000000000000
        -0.525749891599531
        -10.000000000000000
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternELUX205V01Test(logFId, testMode)
    % Constructs a PatternELUX205V01Test
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
      
    end % PatternELUX205V01Test()
    
    function test_PatternELUX205V01(this)
    % Tests PatternELUX205V01 method.
      
      p_1 = PatternELUX205V01(this.GainMax_input_1, this.Efficiency_input);
      
      this.assert_true( ...
          'PatternELUX205V01', ...
          sprintf('PatternELUX205V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternELUX205V01(this.GainMax_input_2, this.Efficiency_input);
      
      this.assert_true( ...
          'PatternELUX205V01', ...
          sprintf('PatternELUX205V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternELUX205V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternELUX205V01(this.GainMax_input_1, this.Efficiency_input);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternELUX205V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternELUX205V01(this.GainMax_input_2, this.Efficiency_input);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternELUX205V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
