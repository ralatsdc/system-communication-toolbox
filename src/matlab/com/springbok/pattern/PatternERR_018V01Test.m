classdef PatternERR_018V01Test < TestUtility
% Tests methods of PatternERR_018V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    GainMax_input = 43.2;
    
    self = struct( ...
        'GainMax', 43.2);
    
    Phi_input = [0.2; 1; 10; 150];
    
    G_expected = [ ...
        43.200000000000003
        39.047750865051903
        9.961223034456850
        0
                 ];
    Gx_expected = [ ...
        43.200000000000003
        39.047750865051903
        9.961223034456850
        0
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternERR_018V01Test(logFId, testMode)
    % Constructs a PatternERR_018V01Test
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
      
    end % PatternERR_018V01Test()
    
    function test_PatternERR_018V01(this)
    % Tests PatternERR_018V01 method.
      
      p = PatternERR_018V01(this.GainMax_input);
      
      this.assert_true( ...
          'PatternERR_018V01', ...
          'PatternERR_018V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternERR_018V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p = PatternERR_018V01(this.GainMax_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternERR_018V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
