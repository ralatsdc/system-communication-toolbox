classdef PatternERR_017V01 < EarthPattern & ReceivePattern
% Describes the ITU antenna pattern ERR_017V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

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
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternERR_017V01(GainMax, Diameter, Frequency)
    % Constructs a PatternERR_017V01 given a maximum antenna gain.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %   Diameter - Diameter of an earth antenna, m
    %   Frequency - Frequency for which a gain is calculated, MHz
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 3 ...
           && isnumeric(GainMax) ...
           && isnumeric(Diameter) ...
           && isnumeric(Frequency))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric GainMax, Diameter, and Frequency  must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      PatternUtility.validate_input('Diameter', Diameter);
      PatternUtility.validate_input('Frequency', Frequency);
      
      % Assign properties
      this.GainMax = GainMax;
      this.Diameter = Diameter;
      this.Frequency = Frequency;
      
      % Compute derived properties
      this.lambda = 299792458 / (this.Frequency * 1e6);
      this.d_over_lambda = this.Diameter / this.lambda;
      this.phi_r = 95 / this.d_over_lambda;
      this.G1 = 29 - 25 * log10(this.phi_r);
      this.phi_m = 20 / this.d_over_lambda * sqrt(this.GainMax - this.G1);
      
    end % PatternERR_017V01()
    
    function that = copy(this)
    % Copies a PatternERR_017V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternERR_017V01(this.GainMax, this.Diameter, ...
                               this.Frequency);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Appendix 30 (RR-2003) reference receiving earth station
    % antenna pattern for Regions 1, 2 and 3 for digital BSS
    % assignments.
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
      
      G2 = max(29 - 25 * log10(phi), 0);
      
      G = G0 .* (0     <= phi & phi <  this.phi_m) ...
          + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
          + G2 .* (this.phi_r <= phi & phi <=   180);
      
      Gx = G;
      
      % Validate low level rules.
      if this.phi_r < this.phi_m
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'phi_r is less than phi_m.', ...
            -6009, ...
            'STDC_ERR_PHIR_LT_PHIM', ...
            'phi_r is less than phi_m.');
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
