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
classdef PatternEREC005V01 < EarthPattern & TransmitPattern & ReceivePattern
% Describes the ITU antenna pattern EREC005V01.
  
  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    
    % Intermediate gain calculation results
    d_over_lambda
    G1
    phi_m
    phi_r
    phi_b
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternEREC005V01(GainMax)
    % Constructs a PatternEREC005V01 given a maximum antenna gain.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 1 ...
           && isnumeric(GainMax))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric GainMax must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      
      % Assign properties
      this.GainMax = GainMax;
      
      % Compute derived properties
      this.d_over_lambda = 10 ^ ((this.GainMax - 7.7) / 20);
      this.G1 = 2 + 15 * log10(this.d_over_lambda);
      this.phi_m = 20 / this.d_over_lambda * sqrt(this.GainMax - this.G1);
      this.phi_r = 100 / this.d_over_lambda;
      this.phi_b = 120 * (1 / this.d_over_lambda) ^ 0.4;
      
    end % PatternEREC005V01()
    
    function that = copy(this)
    % Copies a PatternEREC005V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternEREC005V01(this.GainMax);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Recommendation ITU-R M.694-0 reference Earth station antenna
    % pattern.
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
      
      G2 = 52 - 10 * log10(this.d_over_lambda) - 25 * log10(phi);
      G3 = 0;
      
      G = G0 .* (0     <= phi & phi <  this.phi_m) ...
          + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
          + G2 .* (this.phi_r <= phi & phi <  this.phi_b) ...
          + G3 .* (this.phi_b <= phi & phi <=   180);
      
      Gx = G;
      
      % Validate low level rules.
      if this.GainMax < 19.7 || this.GainMax > 24.8
        warning( ...
            'Springbok:InvalidResult', ...
            'GainMax is out of limits.');
        
      end % if
      
      if this.phi_r < this.phi_m
        warning( ...
            'Springbok:InvalidResult', ...
            'phi_r is less than phi_m.');
        
      end % if
      
      if this.phi_b < this.phi_r
        warning( ...
            'Springbok:InvalidResult', ...
            'phi_b is less than phi_r.');
        
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
