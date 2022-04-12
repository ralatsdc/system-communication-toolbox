classdef PatternEUSA211V01Test < TestUtility
% Tests methods of PatternEUSA211V01 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    self = struct( ...
        'GainMax', 65, ...
        'phi_m', 0.125010657437172, ...
        'phi_r', 1.000000000000000, ...
        'phi_b', 47.863009232263828, ...
        'd_over_lambda', 763.253461456561580, ...
        'G1', 42.240031738381155);
    
    Phi_input = [0.02; 0.1; 0.5; 3; 8; 15; 30; 150];
    
    G_expected = [ ...
        64.417444153574579
        50.436103839364428
        42.240031738381155
        17.071968632008442
        7.900000000000000
        2.597718523607966
        -4.928031367991565
        -10.000000000000000
                 ];
    Gx_expected = [ ...
        34.417444153574579
        30.436103839364428
        22.240031738381155
        7.071968632008440
        -2.000000000000000
        -2.000000000000000
        -4.928031367991565
        -10.000000000000000
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternEUSA211V01Test(logFId, testMode)
    % Constructs a PatternEUSA211V01Test
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
      
    end % PatternEUSA211V01Test()
    
    function test_PatternEUSA211V01(this)
    % Tests PatternEUSA211V01 method.
      
      p = PatternEUSA211V01();
      
      this.assert_true( ...
          'PatternEUSA211V01', ...
          'PatternEUSA211V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternEUSA211V01()
    
    function test_gain(this)
    % Tests gain method.
      
      p = PatternEUSA211V01();
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternEUSA211V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
    end % test_gain()
    
  end % methods
  
end % classdef
