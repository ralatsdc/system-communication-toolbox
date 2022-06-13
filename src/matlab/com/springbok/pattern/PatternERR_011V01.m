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
classdef PatternERR_011V01 < EarthPattern & TransmitPattern
% Describes the ITU antenna pattern ERR_011V01.
  
  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Diameter of an earth antenna, m
    Diameter
    
    % Intermediate gain calculation results
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternERR_011V01(GainMax, Diameter)
    % Constructs a PatternERR_011V01 given a maximum antenna gain.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %   Diameter - Diameter of an earth antenna, m
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 2 ...
           && isnumeric(GainMax) ...
           && isnumeric(Diameter))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric GainMax, and Diameter must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      PatternUtility.validate_input('Diameter', Diameter);
      
      % Assign properties
      this.GainMax = GainMax;
      this.Diameter = Diameter;
      
      % Compute derived properties
      % None
      
    end % PatternERR_011V01()
    
    function that = copy(this)
    % Copies a PatternERR_011V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternERR_011V01(this.GainMax, this.Diameter);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Appendix 30A (RR-2003) reference transmitting earth station
    % antenna pattern for Region 2.
    %
    % Parameters:
    %   Phi - Angle for which a gain is calculated [degrees]
    %
    % Optional parameters (entered as key/value pairs):
    %   PlotFlag - Flag to indicate plot, true or {false}
    %
    % Returns:
    %   G - Co-polar gain [dB]
    %   Gx - Cross-polar gain [dB]
    %   fH - figure handle
      
    % Check number and class of input arguments.
      if ~(nargin >= 1 ...
           && isnumeric(Phi))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric Phi must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('Phi', Phi);
      
      % Handle optional inputs.
      input = struct();
      if ~isempty(varargin)
        nVarargin = size(varargin, 2);
        
        if rem(nVarargin, 2)
          exc = SException( ...
              'Springbok:InvalidInput', ...
              'Inputs must be key/value pairs.');
          throw(exc)
          
        else
          for iVarargin = 1:2:nVarargin
            key = varargin{iVarargin};
            value = varargin{iVarargin + 1};
            input = PatternUtility.validate_input(key, value, input);
            
          end % for
          
        end % if
        
      end % if
      
      % Assign default values to any optional input parameters that
      % were not included in varargin.
      if ~isfield(input, 'PlotFlag')
        PlotFlag = false;

      else
        PlotFlag = input.PlotFlag;

      end % if
      if ~isfield(input, 'DoValidate')
        DoValidate = true;

      else
        DoValidate = input.DoValidate;

      end % if

      % Implement pattern.
      phi = max(eps, Phi); 
      
      G0 = this.GainMax;
      G1 = 36 - 20 * log10(phi);
      G2 = 51.3 - 53.2 * phi .^ 2;
      G3 = max(29 - 25 * log10(phi), -10);
      
      G = G0 .* (0    <= phi & phi <   0.1) ...
          + G1 .* (0.1  <= phi & phi <  0.32) ...
          + G2 .* (0.32 <= phi & phi <  0.54) ...
          + G3 .* (0.54 <= phi & phi <=  180);
      
      G = min(this.GainMax, G);
      
      Gx0 = this.GainMax - 30;
      Gx1 = max(9 - 20 * log10(phi), -10);
      
      phi_x = 0.6 / this.Diameter;
      
      Gx = Gx0 .* (0     <= phi & phi <  phi_x) ...
           + Gx1 .* (phi_x <= phi & phi <=   180);
      
      Gx = min(this.GainMax - 30, Gx);
      
      % Validate low level rules.
      if G < Gx
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'Co-polar curve is less than cross-polar curve.', ...
            -6013, ...
            'STDC_ERR_CO_LT_CX', ...
            'Co-polar curve is less than cross-polar curve.');
        throw(exc)
        
      end % if
      
      if this.Diameter < 2.5
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'Diameter is less that 2.5.', ...
            -6007, ...
            'STDC_ERR_Diameter', ...
            'Diameter is less that 2.5.');
        throw(exc)
        
      end % if
      
      % Validate output parameters.
      if DoValidate
        PatternUtility.validate_output(G, Gx, this.GainMax);
      
      end % if
      
      % Plot results, if requested.
      if PlotFlag == true
        fH = figure;
        semilogx(phi, G, 'k')
        grid on
        hold on
        semilogx(phi, Gx, 'k')
        v = axis;
        axis([0.01 180 v(3) v(4)])
        title([strrep(mfilename, '_', '\_'), ' Reference Antenna Pattern'])
        xlabel('Phi (degrees)')
        ylabel('Gain (dB)')
        
      else
        fH = [];
        
      end % if
      
    end % gain()
    
  end % methods
  
end % classdef
