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
classdef PatternERR_020V01 < EarthPattern & ReceivePattern
% Describes the ITU antenna pattern ERR_020V01.
  
  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Diameter of an earth antenna, m
    Diameter
    % Frequency for which a gain is calculated, MHz
    Frequency
    
    % Intermediate gain calculation results
    lambda
    d_over_lambda
    G1
    phi_m
    phi_r
    phi_b
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternERR_020V01(Diameter, Frequency)
    % Constructs a PatternERR_020V01 given a maximum antenna gain.
    %
    % Parameters
    %   Diameter - Diameter of an earth antenna, m
    %   Frequency - Frequency for which a gain is calculated, MHz
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 2 ...
           && isnumeric(Diameter) ...
           && isnumeric(Frequency))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric Diameter, and Frequency must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('Diameter', Diameter);
      PatternUtility.validate_input('Frequency', Frequency);
      
      % Assign properties
      this.Diameter = Diameter;
      this.Frequency = Frequency;
      
      % Compute derived properties
      this.lambda = 299792458 / (Frequency * 1e6);
      this.d_over_lambda = this.Diameter / this.lambda;
      this.GainMax = 7.7 + 20 * log10(this.d_over_lambda);
      if this.d_over_lambda >= 100
        this.phi_r = 15.85 * (this.d_over_lambda) ^ (-0.6);
        this.phi_b = 34.1;
        
      else % this.d_over_lambda < 100
        this.phi_r = 95 / this.d_over_lambda;
        this.phi_b = 33.1;
        
      end % if
      this.G1 = 29 - 25 * log10(this.phi_r);
      this.phi_m = 20 / this.d_over_lambda * sqrt(this.GainMax - this.G1);
      
    end % PatternERR_020V01()
    
    function that = copy(this)
    % Copies a PatternERR_020V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternERR_020V01(this.Diameter, this.Frequency);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Recommendation ITU-R S.1428-1 reference receiving earth
    % station antenna pattern.
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
      
      if this.d_over_lambda > 100
        G2 = 29 - 25 * log10(phi);
        G3 = 34 - 30 * log10(phi);
        G4 = -12;
        G5 = -7;
        G6 = -12;
        
        G = G0 .* (0     <= phi & phi <  this.phi_m) ...
            + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
            + G2 .* (this.phi_r <= phi & phi <     10) ...
            + G3 .* (10    <= phi & phi <  this.phi_b) ...
            + G4 .* (this.phi_b <= phi & phi <     80) ...
            + G5 .* (80    <= phi & phi <    120) ...
            + G6 .* (120   <= phi & phi <=   180);
        
      elseif 25 < this.d_over_lambda && this.d_over_lambda <= 100
        G2 = 29 - 25 * log10(phi);
        G3 = -9;
        G4 = -4;
        G5 = -9;
        
        G = G0 .* (0     <= phi & phi <  this.phi_m) ...
            + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
            + G2 .* (this.phi_r <= phi & phi <= this.phi_b) ...
            + G3 .* (this.phi_b <  phi & phi <=    80) ...
            + G4 .* (80    <  phi & phi <=   120) ...
            + G5 .* (120   <  phi & phi <=   180);
        
      elseif 20 <= this.d_over_lambda && this.d_over_lambda <= 25
        G2 = 29 - 25 * log10(phi);
        G3 = -9;
        G4 = -5;
        
        G = G0 .* (0     <= phi & phi <  this.phi_m) ...
            + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
            + G2 .* (this.phi_r <= phi & phi <= this.phi_b) ...
            + G3 .* (this.phi_b <  phi & phi <=    80) ...
            + G4 .* (80    <  phi & phi <=   180);
        
      end % if
      
      Gx = G;
      
      % Validate low level rules.
      if this.d_over_lambda < 20
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'D/lambda is less than 20.', ...
            -6002, ...
            'STDC_ERR_DLAMBDA', ...
            'D/lambda is less than 20.');
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
