classdef PatternSREC407V01Test < TestUtility
% Tests methods of PatternSREC407V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    Phi0_input = 1.55;
    GainMax_input = 40;
    
    self = struct( ...
        'Phi0', 1.55);
    
    Phi_input = [0.2; 2; 10; 150];
    
    G_expected = [ ...
        39.800208116545264
        30.000000000000000
        22.232542562657759
        0
                 ];
    Gx_expected = [ ...
        39.800208116545264
        30.000000000000000
        22.232542562657759
        0
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternSREC407V01Test(logFId, testMode)
    % Constructs a PatternSREC407V01Test
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
      
    end % PatternSREC407V01Test()
    
    function test_PatternSREC407V01(this)
    % Tests PatternSREC407V01 method.
      
      p = PatternSREC407V01(this.Phi0_input);
      
      this.assert_true( ...
          'PatternSREC407V01', ...
          'PatternSREC407V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternSREC407V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p = PatternSREC407V01(this.Phi0_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input, 'GainMax', this.GainMax_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternSREC407V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'GainMax', this.GainMax_input, 'PlotFlag', true);
      pause(1); close(fH);
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
