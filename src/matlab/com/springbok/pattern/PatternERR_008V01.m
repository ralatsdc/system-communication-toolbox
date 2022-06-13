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
classdef PatternERR_008V01 < EarthPattern & ReceivePattern
% Describes the ITU antenna pattern ERR_008V01.
  
  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Cross-sectional half-power beamwidth, degrees
    Phi0
    
    % Intermediate gain calculation results
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternERR_008V01(GainMax, Phi0)
    % Constructs a PatternERR_008V01 given an antenna maximum gain, and
    % cross-sectional half-power beamwidth.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %   Phi0 - Cross-sectional half-power beamwidth, degrees
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 2 ...
           && isnumeric(GainMax) ...
           && isnumeric(Phi0))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric GainMax, and Phi0 must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      PatternUtility.validate_input('Phi0', Phi0);
      
      % Assign properties
      this.GainMax = GainMax;
      this.Phi0 = Phi0;
      
      % Compute derived properties
      % None
      
    end % PatternERR_008V01()
    
    function that = copy(this)
    % Copies a PatternERR_008V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternERR_008V01(this.GainMax, this.Phi0);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Appendix 30 (RR-2001) reference receiving earth station
    % antenna pattern for Region 2 for individual reception.
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
      phi_over_phi0 = phi ./ this.Phi0;
      
      G0 = this.GainMax;
      G1 = this.GainMax - 12 * phi_over_phi0 .^ 2;
      G2 = this.GainMax - 14 - 25 * log10(phi_over_phi0);
      G3 = this.GainMax - 43.2;
      G4 = this.GainMax - 85.2 + 27.2 * log10(phi_over_phi0);
      G5 = this.GainMax - 40.2;
      G6 = this.GainMax + 55.2 - 51.7 * log10(phi_over_phi0);
      G7 = this.GainMax - 43.2;
      
      G = G0 .* (0    <= phi_over_phi0 & phi_over_phi0 <= 0.25) ...
          + G1 .* (0.25 <  phi_over_phi0 & phi_over_phi0 <= 1.13) ...
          + G2 .* (1.13 <  phi_over_phi0 & phi_over_phi0 <= 14.7) ...
          + G3 .* (14.7 <  phi_over_phi0 & phi_over_phi0 <=   35) ...
          + G4 .* (35   <  phi_over_phi0 & phi_over_phi0 <= 45.1) ...
          + G5 .* (45.1 <  phi_over_phi0 & phi_over_phi0 <=   70) ...
          + G6 .* (70   <  phi_over_phi0 & phi_over_phi0 <=   80) ...
          + G7 .* (80   <  phi_over_phi0);
      
      Gx0 = this.GainMax - 25;
      
      phix = max(eps, abs(phi_over_phi0 - 1));
      
      Gx1 = this.GainMax - 30 - 40 * log10(phix);
      Gx2 = this.GainMax - 20;
      Gx3 = this.GainMax - 17.3 - 25 * log10(abs(phi_over_phi0));
      Gx4 = this.GainMax - 30;
      
      Gx = Gx0 .* (0    <= phi_over_phi0 & phi_over_phi0 <= 0.25) ...
           + Gx1 .* (0.25 <  phi_over_phi0 & phi_over_phi0 <= 0.44) ...
           + Gx2 .* (0.44 <  phi_over_phi0 & phi_over_phi0 <= 1.28) ...
           + Gx3 .* (1.28 <  phi_over_phi0 & phi_over_phi0 <= 3.22) ...
           + Gx4 .* (3.22 <  phi_over_phi0);
      
      Gx = min(Gx, G);
      
      % Validate low level rules.
      if this.Phi0 < 0.1 || this.Phi0 > 5.0
        warning( ...
            'Springbok:InvalidResult', ...
            'Phi0 is out of limits.');
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
