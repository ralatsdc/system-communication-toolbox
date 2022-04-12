classdef PatternENOR208V01Test < TestUtility
% Tests methods of PatternENOR208V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    GainMax_input_1 = 57;
    Phi0_input = 2;
    
    self_1 = struct( ...
        'GainMax', 57, ...
        'Phi0', 2);
    
    Phi_input = [0.2; 1; 10; 150];
    
    G_expected_1 = [ ...
        57.000000000000000
        54.000000000000000
        27.025749891599531
        15.000000000000000
                   ];
    Gx_expected_1 = [ ...
        57.000000000000000
        54.000000000000000
        27.025749891599531
        15.000000000000000
                    ];
    
    GainMax_input_2 = 47;
    
    self_2 = struct( ...
        'GainMax', 47, ...
        'Phi0', 2);
    
    G_expected_2 = [ ...
        47.000000000000000
        44.000000000000000
        17.025749891599531
        5.000000000000000
                   ];
    Gx_expected_2 = [ ...
        47.000000000000000
        44.000000000000000
        17.025749891599531
        5.000000000000000
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternENOR208V01Test(logFId, testMode)
    % Constructs a PatternENOR208V01Test
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
      
    end % PatternENOR208V01Test()
    
    function test_PatternENOR208V01(this)
    % Tests PatternENOR208V01 method.
      
      p_1 = PatternENOR208V01(this.GainMax_input_1, this.Phi0_input);
      
      this.assert_true( ...
          'PatternENOR208V01', ...
          sprintf('PatternENOR208V01:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternENOR208V01(this.GainMax_input_2, this.Phi0_input);
      
      this.assert_true( ...
          'PatternENOR208V01', ...
          sprintf('PatternENOR208V01:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
    end % test_PatternENOR208V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternENOR208V01(this.GainMax_input_1, this.Phi0_input);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternENOR208V01', ...
          sprintf('gain:%.1f', this.GainMax_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternENOR208V01(this.GainMax_input_2, this.Phi0_input);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternENOR208V01', ...
          sprintf('gain:%.1f', this.GainMax_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
