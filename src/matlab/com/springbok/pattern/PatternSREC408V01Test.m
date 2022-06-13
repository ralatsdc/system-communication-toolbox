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
classdef PatternSREC408V01Test < TestUtility
% Tests methods of PatternSREC408V01 class.
  
  properties (Constant = true)
    
    Phi0_input = 4.0;
    GainMax_input = 40;
    
    self = struct( ...
        'Phi0', 4.0);
    
    Phi_input = [0.2; 2; 10; 150];
    
    G_expected = [ ...
        39.969999999999999
        37.000000000000000
        20.000000000000000
        0
                 ];
    Gx_expected = [ ...
        39.969999999999999
        37.000000000000000
        20.000000000000000
        0
                  ];
    
  end % properties (Constant = true)
  
  methods
    
    function this = PatternSREC408V01Test(logFId, testMode)
    % Constructs a PatternSREC408V01Test
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
      
    end % PatternSREC408V01Test()
    
    function test_PatternSREC408V01(this)
    % Tests PatternSREC408V01 method.
      
      p = PatternSREC408V01(this.Phi0_input);
      
      this.assert_true( ...
          'PatternSREC408V01', ...
          'PatternSREC408V01', ...
          this.HIGH_PRECISION_DESC, ...
          PatternUtility.compare_pattern(this.self, p));
      
    end % test_PatternSREC408V01()
    
    function test_gain(this)
    % Tests gain method.
      
      warning('off');
      
      p = PatternSREC408V01(this.Phi0_input);
      
      [G_actual, Gx_actual] = p.gain(this.Phi_input, 'GainMax', this.GainMax_input);
      
      t(1) = max(abs(G_actual - this.G_expected) < this.HIGH_PRECISION);
      t(2) = max(abs(Gx_actual - this.Gx_expected) < this.HIGH_PRECISION);
      
      this.assert_true( ...
          'PatternSREC408V01', ...
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
