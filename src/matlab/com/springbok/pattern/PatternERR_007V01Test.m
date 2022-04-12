classdef PatternERR_007V01Test < TestUtility
% Tests methods of PatternERR_007V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    GainMax_input = 35.5;
    Diameter_input = 0.6;
    
    self = struct( ...
        'GainMax', 35.5, ...
        'Diameter', 0.6, ...
        'phi_m', 3.815164260242893, ...
        'phi_r', 3.922904064738292, ...
        'phi_b', 22.908676527677734, ...
        'd_over_lambda', 24.216753311385840, ...
        'G1', 14.159807812082960);
    
    Phi_input = [0.2; 0.8; 2; 3.5; 3.85; 8; 40; 150];
    
    G_expected = [ ...
        35.441354885905547
        34.561678174488776
        29.635488590554829
        17.539933808574165
        14.159807812082960
        6.422750325201413
        -5.000000000000000
        0
                 ];
    Gx_expected = [ ...
        10.500000000000000
        11.747620246928316
        18.500000000000000
        13.256354004382899
        10.384636946146038
        -1.577249674798587
        -5.000000000000000
        0
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_007V01Test(logFId, testMode)
    % Constructs a PatternERR_007V01Test
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
      
    end % PatternERR_007V01Test()
    
    function test_PatternERR_007V01(this)
    % Tests PatternERR_007V01 method.
      
      p = PatternERR_007V01(this.GainMax_input, this.Diameter_input);
      
      this.assert_true( ...
          'PatternERR_007V01', ...
          'PatternERR_007V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternERR_007V01()
    
    function test_gain(this)
    % Tests gain method.
      
      p = PatternERR_007V01(this.GainMax_input, this.Diameter_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_007V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
    end % test_gain()
    
  end % methods
  
end % classdef
