% Copyright (C) 2022 Springbok LLC
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or (at
% your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
% 
classdef PatternELUX202V01Test < TestUtility
% Tests methods of PatternELUX202V01 class.
  
  properties (Constant = true)
    
    self = struct( ...
        'd_over_lambda', 96.942890000000006, ...
        'phi_r', 0.876804889971817, ...
        'G1', 30.427425919432462, ...
        'phi_m', 0.773157572851749, ...
        'phi_b', 22.908676527677734);
    
    Phi_input = [0.1; 0.2; 0.4; 0.7; 0.8; 2; 10; 40; 150];
    
    G_expected = [ ...
        46.722761244314214
        45.891044977256854
        42.564179909027409
        33.415300971396441
        30.427425919432462
        21.474250108400472
        4.000000000000000
        -5.000000000000000
        0
                 ];
    Gx_expected = [ ...
        22.000000000000000
        23.420919257974482
        27.000000000000000
        24.440709547575768
        18.360810911515156
        17.000000000000000
        4.000000000000000
        -5.000000000000000
        0
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternELUX202V01Test(logFId, testMode)
    % Constructs a PatternELUX202V01Test
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
      
    end % PatternELUX202V01Test()
    
    function test_PatternELUX202V01(this)
    % Tests PatternELUX202V01 method.
      
      p = PatternELUX202V01();
      
      this.assert_true( ...
          'PatternELUX202V01', ...
          'PatternELUX202V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternELUX202V01()
    
    function test_gain(this)
    % Tests gain method.
      
      p = PatternELUX202V01();
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternELUX202V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
    end % test_gain()
    
  end % methods
  
end % classdef
