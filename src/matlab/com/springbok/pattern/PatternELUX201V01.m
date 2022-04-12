classdef PatternELUX201V01 < EarthPattern & TransmitPattern
% Describes the ITU antenna pattern ELUX201V01.
  
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
    
    function this = PatternELUX201V01(GainMax)
    % Constructs a PatternELUX201V01 given a maximum antenna gain.
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
      this.d_over_lambda = sqrt((10 ^ (this.GainMax / 10)) / (0.61 * pi ^ 2));
      this.G1 = -1 + 15 * log10(this.d_over_lambda);
      this.phi_m = 20 / this.d_over_lambda * sqrt(this.GainMax - this.G1);
      this.phi_r = 15.85 * (this.d_over_lambda) ^ (-0.6);
      this.phi_b = 10 ^ (39 / 25);
      
    end % PatternELUX201V01()
    
    function that = copy(this)
    % Copies a PatternELUX201V01 given a maximum antenna gain.
    %
    % Parameters:
    %   None
      that = PatternELUX201V01(this.GainMax);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Transmitting earth station antenna pattern submitted by LUX
    % for analyses under Appendix 30A.
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
      G3 = -10;
      
      G =        G0 .* (     0     <= phi & phi <  this.phi_m) ...
          + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
          +      G2 .* (this.phi_r <= phi & phi <  this.phi_b) ...
          +      G3 .* (this.phi_b <= phi & phi <=      180);
      
      Gx0 = this.GainMax - 30;
      Gx1 = 29 - 25 * log10(phi);
      Gx2 = -10;
      
      phi_x = 10 ^ ((59 - this.GainMax) / 25);
      
      Gx =   Gx0 .* (     0     <= phi & phi <       phi_x) ...
             + Gx1 .* (     phi_x <= phi & phi <  this.phi_b) ...
             + Gx2 .* (this.phi_b <= phi & phi <=      180);
      
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
      
      if this.phi_b < phi_x
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'Phi_b is less than Phi_x.', ...
            -6008, ...
            'STDC_ERR_ANG2_LT_ANG1', ...
            'Phi_b is less than Phi_x.');
        throw(exc)
        
      end % if
      
      if this.phi_r < this.phi_m
        warning( ...
            'Springbok:InvalidResult', ...
            'Phi_r is less than Phi_m.');
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
