classdef PatternENOR207V01Test < TestUtility
% Tests methods of PatternENOR207V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    Phi_input = [0.2; 4; 150];
    
    self = struct( ...
        'GainMax', 50.7);
    
    G_expected = [ ...
        49.008000000000003
        13.948500216800943
        -10.000000000000000
                 ];
    Gx_expected = [ ...
        49.008000000000003
        13.948500216800943
        -10.000000000000000
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternENOR207V01Test(logFId, testMode)
    % Constructs a PatternENOR207V01Test
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
      
    end % PatternENOR207V01Test()
    
    function test_PatternENOR207V01(this)
    % Tests PatternENOR207V01 method.
      
      p = PatternENOR207V01();
      
      this.assert_true( ...
          'PatternENOR207V01', ...
          'PatternENOR207V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternENOR207V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p = PatternENOR207V01();
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternENOR207V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
