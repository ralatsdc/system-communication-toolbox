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
classdef PatternERR_002V01 < EarthPattern & TransmitPattern & ReceivePattern
% Describes the ITU antenna pattern ERR_002V01.
  
  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    
    % Intermediate gain calculation results
    Efficiency
    CoefA
    d_over_lambda
    G1
    phi_m
    phi_r
    phi_b
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternERR_002V01(GainMax, varargin)
    % Constructs a PatternERR_002V01 given a maximum antenna gain.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %
    % Optional Inputs (entered as key/value pairs):
    %   Efficiency = Antenna efficiency, fraction {0.7}
    %   CoefA = Sidelobe reference level, dB 29 or {32}
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin >= 1 ...
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
      
      % TODO: Test constructor optional agruments
      % Assign default values to any optional input parameters that
      % were not included in varargin.
      if ~isfield(input, 'Efficiency')
        this.Efficiency = 0.7;
        
      else
        this.Efficiency = input.Efficiency;
        
      end % if
      if ~isfield(input, 'CoefA')
        this.CoefA = 32;
        
      elseif ~(input.CoefA == 29 || input.CoefA == 32)
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'CoefA must be a either 29 or 32.', ...
            -6019, ...
            'STDC_ERR_COEFA_VAL', ...
            'CoefA must be a either 29 or 32.');
        throw(exc)
        
      else
        this.CoefA = input.CoefA;
        
      end % if
      
      % Compute derived properties
      this.d_over_lambda = sqrt((10 ^ (this.GainMax / 10)) / (this.Efficiency * pi ^ 2));
      this.G1 = 15 * log10(this.d_over_lambda) - 30 + this.CoefA;
      this.phi_m = 20 / this.d_over_lambda * sqrt(this.GainMax - this.G1);
      if this.d_over_lambda >= 100
        this.phi_r = 15.85 * (this.d_over_lambda) ^ (-0.6);
        
      else
        this.phi_r = 100 / this.d_over_lambda;
        
      end % if
      this.phi_b = 10 ^ ((this.CoefA + 10) / 25);
      
    end % PatternERR_002V01()
    
    function that = copy(this)
    % Copies a PatternERR_002V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternERR_002V01(this.GainMax, this.Efficiency, ...
                               this.CoefA);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Appendix 30B (RR-2003) reference Earth station pattern with
    % the improved side-lobe. Appendix 30B (RR-2001) reference
    % Earth station antenna pattern.
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
      
      if this.d_over_lambda >= 100
        G2 = this.CoefA - 25 * log10(phi);
        G3 = -10;
        
      else
        G2 = this.CoefA + 20 - 10 * log10(this.d_over_lambda) - 25 * log10(phi);
        G3 = 10 - 10 * log10(this.d_over_lambda);
        
      end % if
      
      G = G0 .* (0     <= phi & phi <  this.phi_m) ...
          + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
          + G2 .* (this.phi_r <= phi & phi <  this.phi_b) ...
          + G3 .* (this.phi_b <= phi & phi <=   180);
      
      Gx = G;
      
      % Validate low level rules.
      if this.phi_b < this.phi_r
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'phi_b is less than phi_r.', ...
            -6010, ...
            'STDC_ERR_PHIB_LT_PHIR', ...
            'phi_b is less than phi_r.');
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
