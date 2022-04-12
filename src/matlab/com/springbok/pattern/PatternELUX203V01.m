classdef PatternELUX203V01 < EarthPattern & ReceivePattern
% Describes the ITU antenna pattern ELUX203V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Diameter of an earth antenna [m]
    Diameter
    
    % Intermediate gain calculation results
    d_over_lambda
    phi_r
    G1
    phi_m
    phi_b
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternELUX203V01(GainMax, Diameter)
    % Constructs a PatternELUX203V01 given an antenna maximum gain
    % and diameter. Note that lambda = 0.02476 is assumed.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %   Diameter - Diameter of an earth antenna [m]
      
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
            'Numeric GainMax and Diameter must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      PatternUtility.validate_input('Diameter', Diameter);
      
      % Assign properties
      this.GainMax = GainMax;
      this.Diameter = Diameter;
      
      % Compute derived properties
      lambda = 0.02476;
      this.d_over_lambda = this.Diameter / lambda;
      this.phi_r = 85 / this.d_over_lambda;
      this.G1 = 29 - 25 * log10(this.phi_r);
      this.phi_m = 1 / this.d_over_lambda * sqrt((this.GainMax - this.G1) / 0.00295);
      this.phi_b = 10 ^ (34 / 25);
      
    end % PatternELUX203V01()
    
    function that = copy(this)
    % Copies a PatternELUX203V01 given an antenna maximum gain
    % and diameter. Note that lambda = 0.02476 is assumed.
    %
    %
    % Parameters:
    %   None
      that = PatternELUX203V01(this.GainMax, this.Diameter);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Receiving earth station antenna pattern submitted by LUX for
    % individual reception for analyses under Appendix 30.
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
      
      G0 = this.GainMax - 2.95e-3 * (this.d_over_lambda .* phi) .^ 2;
      
      G2 = 29 - 25 * log10(phi);
      G3 = -5;
      G4 = 0;
      
      G =        G0 .* (     0     <= phi & phi <  this.phi_m) ...
          + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
          +      G2 .* (this.phi_r <= phi & phi <  this.phi_b) ...
          +      G3 .* (this.phi_b <= phi & phi <       70) ...
          +      G4 .* (     70    <= phi & phi <=      180);
      
      Gx0 = this.GainMax - 22;
      
      phi_0 = 2 / this.d_over_lambda * sqrt(3 / 0.00295);
      Gx1 = this.GainMax - 22 + 5 * ((phi - 0.25 * phi_0) / (0.19 * phi_0));
      Gx2 = this.GainMax - 17;
      Gx3 = this.GainMax - 17 - 40 * (phi / phi_0 - 1);
      Gx4 = this.GainMax - 27;
      Gx5 = G;
      
      phi_1 = 0.25 * phi_0;
      phi_2 = 0.44 * phi_0;
      phi_3 = 1.25 * phi_0;
      phi_x = 10 ^ ((56 - this.GainMax) / 25);
      
      Gx =   Gx0 .* (0     <= phi & phi <  phi_1) ...
             + Gx1 .* (phi_1 <= phi & phi <  phi_2) ...
             + Gx2 .* (phi_2 <= phi & phi <  phi_0) ...
             + Gx3 .* (phi_0 <= phi & phi <  phi_3) ...
             + Gx4 .* (phi_3 <= phi & phi <  phi_x) ...
             + Gx5 .* (phi_x <= phi & phi <= 180);
      
      % Validate low level rules.
      if phi_x < phi_3
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'Phi_x is less than Phi_3.', ...
            -6008, ...
            'STDC_ERR_ANG2_LT_ANG1', ...
            'Phi_x is less than Phi_3.');
        throw(exc)
        
      end % if
      
      if this.GainMax < 22
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'GainMax is less than 22. Cross-polar pattern does not intersect with co-polar pattern.', ...
            -6004, ...
            'STDC_ERR_CXCO_NOTINTERS', ...
            'GainMax is less than 22. Cross-polar pattern does not intersect with co-polar pattern.');
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
            'phi_r is less than Phi_m.');
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
