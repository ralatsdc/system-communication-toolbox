classdef PatternERR_006V01Test < TestUtility
% Tests methods of PatternERR_006V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    GainMax_input = 35;
    Phi0_input = 2;
    
    self = struct( ...
        'GainMax', 35, ...
        'Phi0', 2);
    
    Phi_input = [0.2; 0.7; 2; 7; 40; 150];
    
    G_expected = [ ...
        35.000000000000000
        33.530000000000001
        26.000000000000000
        12.898298891243108
        2.000000000000000
        2.000000000000000
                 ];
    Gx_expected = [ ...
        10.000000000000000
        12.483465734285776
        15.000000000000000
        5.000000000000000
        2.000000000000000
        2.000000000000000
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_006V01Test(logFId, testMode)
    % Constructs a PatternERR_006V01Test
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
      
    end % PatternERR_006V01Test()
    
    function test_PatternERR_006V01(this)
    % Tests PatternERR_006V01 method.
      
      p = PatternERR_006V01(this.GainMax_input, this.Phi0_input);
      
      this.assert_true( ...
          'PatternERR_006V01', ...
          'PatternERR_006V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternERR_006V01()
    
    function test_gain(this)
    % Tests gain method.
      
      p = PatternERR_006V01(this.GainMax_input, this.Phi0_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_006V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
    end % test_gain()
    
  end % methods
  
end % classdef
