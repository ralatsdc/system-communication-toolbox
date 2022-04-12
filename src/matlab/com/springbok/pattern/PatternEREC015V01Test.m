classdef PatternEREC015V01Test < TestUtility
% Tests methods of PatternEREC015V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    GainMax_input_1 = 54.4;
    Efficiency_input = 0.7;
    
    self_1 = struct( ...
        'GainMax', 54.4, ...
        'Efficiency', 0.7, ...
        'phi_m', 0.457883611484118, ...
        'phi_r', 0.660463166200195, ...
        'phi_b', 47.863009232263828, ...
        'd_over_lambda', 199.664616023944350, ...
        'G1', 33.504516609481058);
    
    GainMax_input_2 = 44;
    
    self_2 = struct( ...
        'GainMax', 44, ...
        'Efficiency', 0.7, ...
        'phi_m', 1.501502525147764, ...
        'phi_r', 1.658436672839821, ...
        'phi_b', 47.863009232263828, ...
        'd_over_lambda', 60.297750066491929, ...
        'G1', 23.507527682468449);
    
    Phi_input = [0.2; 0.7; 5; 22; 150];
    
    G_expected_1 = [ ...
        50.413404110801082
        32.872548999643577
        11.525749891599531
        -3.500000000000000
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        50.413404110801082
        32.872548999643577
        11.525749891599531
        -3.500000000000000
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        43.636418133691890
        39.546122137725618
        11.525749891599531
        -3.500000000000000
        -10.000000000000000
                   ];
    Gx_expected_2 = [ ...
        43.636418133691890
        39.546122137725618
        11.525749891599531
        -3.500000000000000
        -10.000000000000000
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternEREC015V01Test(logFId, testMode)
    % Constructs a PatternEREC015V01Test
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
      
    end % PatternEREC015V01Test()
    
    function test_PatternEREC015V01(this)
    % Tests PatternEREC015V01 method.
      
      p_1 = PatternEREC015V01(this.GainMax_input_1, this.Efficiency_input);
      
      this.assert_true( ...
          'PatternEREC015V01', ...
          sprintf('PatternEREC015V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternEREC015V01(this.GainMax_input_2, this.Efficiency_input);
      
      this.assert_true( ...
          'PatternEREC015V01', ...
          sprintf('PatternEREC015V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternEREC015V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternEREC015V01(this.GainMax_input_1, this.Efficiency_input);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternEREC015V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternEREC015V01(this.GainMax_input_2, this.Efficiency_input);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternEREC015V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
