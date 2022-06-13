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
classdef PatternEND_099V01Test < TestUtility
% Tests methods of PatternEND_099V01 class.
  
  properties (Constant = true)
    
    GainMax_input = 35.5;
    
    self = struct( ...
        'GainMax', 35.5);
    
    Phi_input = [0.2; 2; 10; 150];
    
    G_expected = [ ...
        35.5
        35.5
        35.5
        35.5
                 ];
    Gx_expected = [ ...
        35.5
        35.5
        35.5
        35.5
                  ];
  end % properties (Constant = true)
  
  methods
    
    function this = PatternEND_099V01Test(logFId, testMode)
    % Constructs a PatternEND_099V01Test
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
      
    end % PatternEND_099V01Test()
    
    function test_PatternEND_099V01(this)
    % Tests PatternEND_099V01 method.
      
      p = PatternEND_099V01(this.GainMax_input);
      
      this.assert_true( ...
          'PatternEND_099V01', ...
          'PatternEND_099V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternEND_099V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p = PatternEND_099V01(this.GainMax_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternEND_099V01', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
      [G, Gx, fH] = p.gain([0:.001:180], 'PlotFlag', true);
      pause(1); close(fH);
      
      warning('on');
      
    end % test_gain()
    
  end % methods
  
end % classdef
