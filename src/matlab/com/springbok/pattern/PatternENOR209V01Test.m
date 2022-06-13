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
classdef PatternENOR209V01Test < TestUtility
% Tests methods of PatternENOR209V01 class.
  
  properties (Constant = true)
    
    Phi_input = [0.2; 0.7; 10; 150];
    
    self = struct( ...
        'GainMax', 50.7);
    
    G_expected = [ ...
        49.008000000000003
        30.699999999999999
        4.000000000000000
        -10.000000000000000
                 ];
    Gx_expected = [ ...
        49.008000000000003
        30.699999999999999
        4.000000000000000
        -10.000000000000000
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternENOR209V01Test(logFId, testMode)
    % Constructs a PatternENOR209V01Test
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
      
    end % PatternENOR209V01Test()
    
    function test_PatternENOR209V01(this)
    % Tests PatternENOR209V01 method.
      
      p = PatternENOR209V01();
      
      this.assert_true( ...
          'PatternENOR209V01', ...
          'PatternENOR209V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternENOR209V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p = PatternENOR209V01();
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternENOR209V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
