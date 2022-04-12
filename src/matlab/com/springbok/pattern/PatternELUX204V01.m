classdef PatternELUX204V01 < EarthPattern & TransmitPattern & ReceivePattern
% Describes the ITU antenna pattern ELUX204V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Antenna efficiency, fraction
    Efficiency
    
    % Intermediate gain calculation results
    d_over_lambda
    G1
    phi_m
    phi_r
    phi_b
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternELUX204V01(GainMax, Efficiency)
    % Constructs a PatternELUX204V01 given a maximum antenna gain, and efficiency.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %   Efficiency - Antenna efficiency, fraction
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 2 ...
           && isnumeric(GainMax) ...
           && isnumeric(Efficiency))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric GainMax must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      PatternUtility.validate_input('Efficiency', Efficiency);
      
      % Assign properties
      this.GainMax = GainMax;
      this.Efficiency = Efficiency;
      
      % Compute derived properties
      this.d_over_lambda = sqrt((10 ^ (this.GainMax / 10)) / (this.Efficiency * pi ^ 2));
      this.G1 = -1 + 15 * log10(this.d_over_lambda);
      this.phi_m = 20 / this.d_over_lambda * sqrt(this.GainMax - this.G1);
      this.phi_r = 15.85 * (this.d_over_lambda) ^ (-0.6);
      this.phi_b = 48;
      
    end % PatternELUX204V01()
    
    function that = copy(this)
    % Copies a PatternELUX204V01 given a maximum antenna gain.
    %
    % Parameters:
    %   None
      that = PatternELUX204V01(this.GainMax, this.Efficiency);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Earth station antenna pattern submitted by LUX for both
    % uplinks and downlinks for analyses under Appendix 30B.
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
      G3 = 32 - 25 * log10(phi);
      G4 = -10;
      
      G =        G0 .* (     0     <= phi & phi <  this.phi_m) ...
          + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
          +      G2 .* (this.phi_r <= phi & phi <       20) ...
          +      G3 .* (     20    <= phi & phi <  this.phi_b) ...
          +      G4 .* (this.phi_b <= phi & phi <=      180);
      
      Gx = G;
      
      % Validate low level rules.
      
      if this.d_over_lambda < 100
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'D/lambda is less than 100.', ...
            -6002, ...
            'STDC_ERR_DLAMBDA', ...
            'D/lambda is less than 100.');
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
