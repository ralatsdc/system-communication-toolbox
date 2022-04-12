classdef PatternERR_001V01Test < TestUtility
% Tests methods of PatternERR_001V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    GainMax_input_1 = 53.7;
    
    self_1 = struct( ...
        'GainMax', 53.7, ...
        'phi_m', 0.415713587085940, ...
        'phi_r', 0.660737972800482, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 199.526231496887870, ...
        'G1', 36.500000000000000);
    
    GainMax_input_2 = 33.7;
    
    self_2 = struct( ...
        'GainMax', 33.7, ...
        'phi_m', 3.501143496883088, ...
        'phi_r', 5.011872336272720, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 19.952623149688808, ...
        'G1', 21.500000000000004);
    
    Phi_input = [0.2; 0.5; 4.5; 150];
    
    G_expected_1 = [ ...
        49.718928294465030
        36.500000000000000
        15.669687155616412
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        49.718928294465030
        36.500000000000000
        15.669687155616412
        -10.000000000000000
                    ];
    
    G_expected_2 = [ ...
        33.660189282944650
        33.451183018404066
        21.500000000000004
        -3.000000000000004
                   ];
    Gx_expected_2 = [ ...
        33.660189282944650
        33.451183018404066
        21.500000000000004
        -3.000000000000004
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_001V01Test(logFId, testMode)
    % Constructs a PatternERR_001V01Test
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
      
    end % PatternERR_001V01Test()
    
    function test_PatternERR_001V01(this)
    % Tests PatternERR_001V01 method.
      
      p_1 = PatternERR_001V01(this.GainMax_input_1);
      
      this.assert_true( ...
          'PatternERR_001V01', ...
          sprintf('PatternERR_001V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternERR_001V01(this.GainMax_input_2);
      
      this.assert_true( ...
          'PatternERR_001V01', ...
          sprintf('PatternERR_001V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternERR_001V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternERR_001V01(this.GainMax_input_1);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_001V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternERR_001V01(this.GainMax_input_2);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_001V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
