classdef PatternELUX203V01Test < TestUtility
% Tests methods of PatternELUX203V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    GainMax_input = 35;
    Diameter_input = 0.6;
    
    self = struct( ...
        'GainMax', 35, ...
        'Diameter', 0.6, ...
        'd_over_lambda', 24.232633279483036, ...
        'phi_r', 3.507666666666667, ...
        'G1', 15.374542108031763, ...
        'phi_m', 3.365877307774267, ...
        'phi_b', 22.908676527677734);
    
    Phi_input = [0.2; 0.8; 2; 3.4; 5; 10; 40; 150];
    
    G_expected = [ ...
        34.930707979152366
        33.891327666437867
        28.070797915236675
        15.374542108031763
        11.525749891599531
        4.000000000000000
        -5.000000000000000
        0
                 ];
    
    Gx_expected = [ ...
        13.000000000000000
        14.419899550304727
        18.000000000000000
        8.000000000000000
        8.000000000000000
        4.000000000000000
        -5.000000000000000
        0
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternELUX203V01Test(logFId, testMode)
    % Constructs a PatternELUX203V01Test
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
      
    end % PatternELUX203V01Test()
    
    function test_PatternELUX203V01(this)
    % Tests PatternELUX203V01 method.
      
      p = PatternELUX203V01(this.GainMax_input, this.Diameter_input);
      
      this.assert_true( ...
          'PatternELUX203V01', ...
          'PatternELUX203V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternELUX203V01()
    
    function test_gain(this)
    % Tests gain method.
      
      p = PatternELUX203V01(this.GainMax_input, this.Diameter_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternELUX203V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
    end % test_gain()
    
  end % methods
  
end % classdef
