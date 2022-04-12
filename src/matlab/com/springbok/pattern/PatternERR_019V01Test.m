classdef PatternERR_019V01Test < TestUtility
% Tests methods of PatternERR_019V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    Diameter_input_1 = 10;
    Frequency_input = 4000;
    
    self_1 = struct( ...
        'Frequency', 4000, ...
        'phi_m', 0.605666030113178, ...
        'phi_r', 0.841173715238910, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 133.425638079260840, ...
        'G1', 33.878589326000522);
    
    Phi_input = [0.2; 0.7; 1; 1.3; 3.5; 10; 22; 150];
    
    G_expected_1 = [ ...
        48.424545678314914
        33.878589326000522
        29.000000000000000
        26.151416192329080
        15.398298891243108
        4.000000000000000
        -3.500000000000000
        -10.000000000000000
                   ];
    Gx_expected_1 = [ ...
        48.424545678314914
        33.878589326000522
        29.000000000000000
        26.151416192329080
        15.398298891243108
        4.000000000000000
        -3.500000000000000
        -10.000000000000000
                    ];
    
    Diameter_input_2 = 4.5;
    
    self_2 = struct( ...
        'Frequency', 4000, ...
        'phi_m', 1.272446285727245, ...
        'phi_r', 1.665513655555556, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 60.041537135667369, ...
        'G1', 28.676777032630678);
    
    G_expected_2 = [ ...
        42.908537425346204
        38.852927971030766
        34.256570589473270
        28.676777032630678
        15.398298891243108
        4.000000000000000
        -3.500000000000000
        -10.000000000000000
                   ];
    Gx_expected_2 = [ ...
        42.908537425346204
        38.852927971030766
        34.256570589473270
        28.676777032630678
        15.398298891243108
        4.000000000000000
        -3.500000000000000
        -10.000000000000000
                    ];
    
    Diameter_input_3 = 1.8;
    
    self_3 = struct( ...
        'Frequency', 4000, ...
        'phi_m', 2.956293654885015, ...
        'phi_r', 4.163784138888889, ...
        'phi_b', 48.000000000000000, ...
        'd_over_lambda', 24.016614854266951, ...
        'G1', 22.707676902550116);
    
    G_expected_3 = [ ...
        35.252556091161004
        34.603658578470537
        33.868241397421336
        32.873265211295944
        22.707676902550116
        7.000000000000000
        -1.560567020555155
        -10.000000000000000
                   ];
    Gx_expected_3 = [ ...
        35.252556091161004
        34.603658578470537
        33.868241397421336
        32.873265211295944
        22.707676902550116
        7.000000000000000
        -1.560567020555155
        -10.000000000000000
                    ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_019V01Test(logFId, testMode)
    % Constructs a PatternERR_019V01Test
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
      
    end % PatternERR_019V01Test()
    
    function test_PatternERR_019V01(this)
    % Tests PatternERR_019V01 method.
      
      p_1 = PatternERR_019V01(this.Diameter_input_1, this.Frequency_input);
      
      this.assert_true( ...
          'PatternERR_019V01', ...
          sprintf('PatternERR_019V01:%.1f', this.Diameter_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_1, p_1));
      
      p_2 = PatternERR_019V01(this.Diameter_input_2, this.Frequency_input);
      
      this.assert_true( ...
          'PatternERR_019V01', ...
          sprintf('PatternERR_019V01:%.1f', this.Diameter_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_2, p_2));
      
      p_3 = PatternERR_019V01(this.Diameter_input_3, this.Frequency_input);
      
      this.assert_true( ...
          'PatternERR_019V01', ...
          sprintf('PatternERR_019V01:%.1f', this.Diameter_input_3), ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self_3, p_3));
      
    end % test_PatternERR_019V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p_1 = PatternERR_019V01(this.Diameter_input_1, this.Frequency_input);
      
      [G_actual, Gx_actual] = p_1.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_1) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_1) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_019V01', ...
          sprintf('gain:%.1f', this.Diameter_input_1), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_1.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_2 = PatternERR_019V01(this.Diameter_input_2, this.Frequency_input);
      
      [G_actual, Gx_actual] = p_2.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_2) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_2) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_019V01', ...
          sprintf('gain:%.1f', this.Diameter_input_2), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_2.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      p_3 = PatternERR_019V01(this.Diameter_input_3, this.Frequency_input);
      
      [G_actual, Gx_actual] = p_3.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected_3) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected_3) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_019V01', ...
          sprintf('gain:%.1f', this.Diameter_input_3), ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p_3.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
