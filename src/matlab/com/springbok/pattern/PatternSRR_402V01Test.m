classdef PatternSRR_402V01Test < TestUtility
% Tests methods of PatternSRR_402V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    Beamlet_input = 0.6;
    Phi0_input = 2;
    GainMax_input = 57;
    
    self = struct( ...
        'Beamlet', 0.6, ...
        'Phi0', 2);
    
    Phi_input = [0.2; 2; 5; 150];
    
    G_expected = [ ...
        56.880000000000003
        31.770000000000000
        27.041199826559250
        0
                 ];
    Gx_expected = [ ...
        27.000000000000000
        27.000000000000000
        27.000000000000000
        0
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternSRR_402V01Test(logFId, testMode)
    % Constructs a PatternSRR_402V01Test
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
      
    end % PatternSRR_402V01Test()
    
    function test_PatternSRR_402V01(this)
    % Tests PatternSRR_402V01 method.
      
      p = PatternSRR_402V01(this.Beamlet_input, this.Phi0_input);
      
      this.assert_true( ...
          'PatternSRR_402V01', ...
          'PatternSRR_402V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternSRR_402V01()
    
    function test_gain(this)
    % Tests gain method.
      
      p = PatternSRR_402V01(this.Beamlet_input, this.Phi0_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input, 'GainMax', this.GainMax_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternSRR_402V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'GainMax', this.GainMax_input, 'PlotFlag', true);
      pause(1); close(fH);
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
    end % test_gain()
    
  end % methods
  
end % classdef
