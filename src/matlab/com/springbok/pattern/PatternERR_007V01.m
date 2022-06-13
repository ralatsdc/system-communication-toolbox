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
classdef PatternERR_007V01 < EarthPattern & ReceivePattern
% Describes the ITU antenna pattern ERR_007V01.
  
  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Diameter of an earth antenna, m
    Diameter
    
    % Intermediate gain calculation results
    lambda
    d_over_lambda
    G1
    phi_m
    phi_r
    phi_b
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternERR_007V01(GainMax, Diameter)
    % Constructs a PatternERR_007V01 given an antenna maximum gain, and diameter.
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
      this.lambda = 299792458 / (12.1 * 1e9);
      this.d_over_lambda = this.Diameter / this.lambda;
      this.phi_r = 95 / this.d_over_lambda;
      this.G1 = 29 - 25 * log10(this.phi_r);
      this.phi_m = 20 / this.d_over_lambda * sqrt(this.GainMax - this.G1);
      this.phi_b = 10 ^ (34 / 25);
      
    end % PatternERR_007V01()
    
    function that = copy(this)
    % Copies a PatternERR_007V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternERR_007V01(this.GainMax, this.Diameter);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Appendix 30 (RR-2003) reference receiving earth station
    % antenna pattern for Regions 1 and 3 (WRC-97).
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
      
      G0 = this.GainMax - 2.5e-3 * (this.d_over_lambda .* phi) .^ 2;
      
      G2 = 29 - 25 * log10(phi);
      G3 = -5;
      G4 = 0;
      
      G = G0 .* (    0 <= phi & phi <  this.phi_m) ...
          + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
          + G2 .* (this.phi_r <= phi & phi <  this.phi_b) ...
          + G3 .* (this.phi_b <= phi & phi <     70) ...
          + G4 .* (   70 <= phi & phi <=   180);
      
      Gx0 = this.GainMax - 25;
      
      phi_0 = 2 / this.d_over_lambda * sqrt(3 / 0.0025);
      Gx1 = this.GainMax - 25 + 8 * (phi - 0.25 * phi_0) / (0.19 * phi_0);
      Gx2 = this.GainMax - 17;
      
      phi_1 = phi_0 / 2 * sqrt(10.1875);
      S = 21 - 25 * log10(phi_1) - (this.GainMax - 17);
      Gx3 = this.GainMax - 17 + S * abs((phi - phi_0) / (phi_1 - phi_0));
      Gx4 = 21 - 25 * log10(phi);
      Gx5 = -5;
      Gx6 = 0;
      
      phi_2 = 10 ^ (26/25);
      
      Gx = Gx0 .* (0            <= phi & phi <  0.25 * phi_0) ...
           + Gx1 .* (0.25 * phi_0 <= phi & phi <  0.44 * phi_0) ...
           + Gx2 .* (0.44 * phi_0 <= phi & phi <         phi_0) ...
           + Gx3 .* (phi_0        <= phi & phi <         phi_1) ...
           + Gx4 .* (phi_1        <= phi & phi <         phi_2) ...
           + Gx5 .* (phi_2        <= phi & phi <            70) ...
           + Gx6 .* (70           <= phi & phi <=          180);
      
      % Validate low level rules.
      if 0 < S
        exc = SException( ...
            'Springbok:InvalidResult', ...
            '0 is less than S.', ...
            -6031, ...
            'STDC_ERR_0_LT_S', ...
            '0 is less than S.');
        throw(exc)
        
      end % if
      
      if this.phi_r < this.phi_m
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'phi_r is less than phi_m.', ...
            -6009, ...
            'STDC_ERR_PHIR_LT_PHIM', ...
            'phi_r is less than phi_m.');
        throw(exc)
        
      end % if
      
      if phi_2 < phi_1
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'Phi_2 is less than Phi_1.', ...
            -6008, ...
            'STDC_ERR_ANG2_LT_ANG1', ...
            'Phi_2 is less than Phi_1.');
        throw(exc)
        
      end % if
      
      if this.GainMax < this.G1
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'GainMax is less than G1.', ...
            -6001, ...
            'STDC_ERR_GNAX_LT_G1', ...
            'GainMax is less than G1.');
        throw(exc)
        
      end % if
      
      if this.phi_r < this.phi_m
        warning( ...
            'Springbok:InvalidResult', ...
            'phi_r is less than phi_m.');
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
        axis([0.1 180 v(3) v(4)])
        title([strrep(mfilename, '_', '\_'), ' Reference Antenna Pattern'])
        xlabel('Phi (degrees)')
        ylabel('Gain (dB)')
        
      else
        fH = [];
        
      end % if
      
    end % gain()
    
  end % methods
  
end % classdef
