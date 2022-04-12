classdef PatternEUSA211V01 < EarthPattern & TransmitPattern
% Describes the ITU antenna pattern EUSA211V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

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
    
    function this = PatternEUSA211V01()
    % Constructs a PatternEUSA211V01 given a maximum antenna gain.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
      
    % Check number and class of input arguments.
      if ~(nargin >= 0)
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'No input arguments are required.');
        throw(exc)
        
      end % if
      
      % Assign properties
      this.GainMax = 65;
      
      % Compute derived properties
      this.d_over_lambda = sqrt((10 ^ (this.GainMax / 10)) / (0.55 * pi ^ 2));
      this.G1 = -1 + 15 * log10(this.d_over_lambda);
      this.phi_m = 20 / this.d_over_lambda * sqrt(this.GainMax - this.G1);
      this.phi_r = 1;
      this.phi_b = 10 ^ (42 / 25);
      
    end % PatternEUSA211V01()
    
    function that = copy(this)
    % Copies a PatternEUSA211V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternEUSA211V01();

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Earth station transmitting antenna pattern for analyses under
    % Appendix 30A for USABSS-14 and USABSS-15 networks.
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
      G3 = 7.9;
      G4 = max(32 - 25 * log10(phi), -10);
      
      G = G0 .* (0     <= phi & phi <  this.phi_m) ...
          + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
          + G2 .* (this.phi_r <= phi & phi <      7) ...
          + G3 .* (7     <= phi & phi <      9) ...
          + G4 .* (9     <= phi & phi <=   180);
      
      Gx0 = this.GainMax - 2.5e-3 * (this.d_over_lambda .* phi) .^ 2 - 30;
      Gx1 = this.GainMax - 2.5e-3 * (this.d_over_lambda .* phi) .^ 2 - 20;
      Gx2 = this.G1 - 20;
      Gx3 = 19 - 25 * log10(phi);
      Gx4 = min(-2, G);
      
      Gx = Gx0 .* (0         <= phi & phi <  this.phi_m / 2) ...
           + Gx1 .* (this.phi_m / 2 <= phi & phi <      this.phi_m) ...
           + Gx2 .* (this.phi_m     <= phi & phi <      this.phi_r) ...
           + Gx3 .* (this.phi_r     <= phi & phi <       6.92) ...
           + Gx4 .* (6.92      <= phi & phi <=       180);
      
      % Validate low level rules.
      % None.
      
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
