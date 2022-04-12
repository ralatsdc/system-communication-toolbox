classdef PatternEREC004V01Test < TestUtility
% Tests methods of PatternEREC004V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    GainMax_input_1 = 54.4;
    Efficiency_input = 0.7;
    
    self_1 = struct( ...
        'GainMax', 54.4, ...
        'Efficiency', 0.7, ...
        'phi_m', 0.457883611484118, ...
        'phi_r', 0.660463166200195, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 199.664616023944350, ...
        'G1', 33.504516609481058);
    
    GainMax_input_2 = 44;
    
    self_2 = struct( ...
        'GainMax', 44, ...
        'Efficiency', 0.7, ...
        'phi_m', 1.297210608788515, ...
        'phi_r', 1.658436672839821, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 60.297750066491929, ...
        'G1', 28.704516609481072);
    
    Phi_input = [0.2; 0.6; 1.5; 10; 22; 40; 150];
    
    G_expected_1 = [ ...
        50.413404110801082
        33.504516609481058
        24.597718523607970
        4.000000000000000
        -3.500000000000000
        -8.051499783199063
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        50.413404110801082
        33.504516609481058
        24.597718523607970
        4.000000000000000
        -3.500000000000000
        -8.051499783199063
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        43.636418133691890
        40.727763203226985
        28.704516609481072
        7.000000000000000
        0.636421906457464
        -5.854510856186444
        -7.803011072987381
                   ];
    Gx_expected_2 = [ ...
        43.636418133691890
        40.727763203226985
        28.704516609481072
        7.000000000000000
        0.636421906457464
        -5.854510856186444
        -7.803011072987381
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternEREC004V01Test(logFId, testMode)
    % Constructs a PatternEREC004V01Test
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
      
    end % PatternEREC004V01Test()
    
    function test_PatternEREC004V01(this)
    % Tests PatternEREC004V01 method.
      
      p_1 = PatternEREC004V01(this.GainMax_input_1, this.Efficiency_input);
      
      this.assert_true( ...
          'PatternEREC004V01', ...
          sprintf('PatternEREC004V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternEREC004V01(this.GainMax_input_2, this.Efficiency_input);
      
      this.assert_true( ...
          'PatternEREC004V01', ...
          sprintf('PatternEREC004V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternEREC004V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternEREC004V01(this.GainMax_input_1, this.Efficiency_input);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternEREC004V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternEREC004V01(this.GainMax_input_2, this.Efficiency_input);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternEREC004V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
