classdef PatternSF__601V01Test < TestUtility
% Tests methods of PatternSF__601V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    Phi0_input = 2;
    GainMax_input = 57;
    
    self = struct( ...
        'Phi0', 2);
    
    Phi_input = [0.2; 1.5; 5; 150];
    
    G_expected = [ ...
        56.880000000000003
        41.812500000000000
        13.631706539125240
        0
                 ];
    Gx_expected = [ ...
        27.000000000000000
        27.000000000000000
        13.631706539125240
        0
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternSF__601V01Test(logFId, testMode)
    % Constructs a PatternSF__601V01Test
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
      
    end % PatternSF__601V01Test()
    
    function test_PatternSF__601V01(this)
    % Tests PatternSF__601V01 method.
      
      p = PatternSF__601V01(this.Phi0_input);
      
      this.assert_true( ...
          'PatternSF__601V01', ...
          'PatternSF__601V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternSF__601V01()
    
    function test_gain(this)
    % Tests gain method.
      
      p = PatternSF__601V01(this.Phi0_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input, 'GainMax', this.GainMax_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternSF__601V01', ...
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
