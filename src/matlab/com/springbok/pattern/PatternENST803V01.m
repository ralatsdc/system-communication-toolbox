classdef PatternENST803V01 < EarthPattern & TransmitPattern & ReceivePattern
% Describes the ITU antenna pattern ENST803V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Antenna efficiency, fraction
    Efficiency
    % Sidelobe reference level, dB
    CoefA
    
    % Intermediate gain calculation results
    d_over_lambda
    G1
    phi_m
    phi_r
    phi_b
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternENST803V01(GainMax, Efficiency, CoefA)
    % Constructs a PatternENST803V01 given a maximum antenna gain.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %   Efficiency - Antenna efficiency, fraction
    %   CoefA - Sidelobe reference level, dB
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 3 ...
           && isnumeric(GainMax) ...
           && isnumeric(Efficiency) ...
           && isnumeric(CoefA))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric GainMax, Efficiency, and CoefA must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      PatternUtility.validate_input('Efficiency', Efficiency);
      PatternUtility.validate_input('CoefA', CoefA);
      
      % Assign properties
      this.GainMax = GainMax;
      this.Efficiency = Efficiency;
      this.CoefA = CoefA;
      
      % Compute derived properties
      this.d_over_lambda = sqrt((10 ^ (this.GainMax / 10)) / (this.Efficiency * pi ^ 2));
      this.G1 = 15 * log10(this.d_over_lambda) - 30 + this.CoefA;
      this.phi_m = 20 / this.d_over_lambda * sqrt(this.GainMax - this.G1);
      if this.d_over_lambda >= 100
        this.phi_r = 15.85 * (this.d_over_lambda) ^ (-0.6);
        
      else % this.d_over_lambda < 100
        this.phi_r = 100 / this.d_over_lambda;
        
      end % if
      this.phi_b = 10 ^ ((this.CoefA + 10) / 25);
      
    end % PatternENST803V01()
    
    function that = copy(this)
    % Copies a PatternENST803V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternENST803V01(this.GainMax, this.Efficiency, ...
                               this.CoefA);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Non-standard generic earth station antenna pattern similar to
    % that in Appendix 30B (RR-2001), where the side-lobe radiation
    % is represented by the expression CoefA - 25 log(phi).
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
        
      else % this.d_over_lambda < 100
        G2 = this.CoefA + 20 - 10 * log10(this.d_over_lambda) - 25 * log10(phi);
        G3 = 10 - 10 * log10(this.d_over_lambda);
        
      end % if
      
      G = G0 .* (0     <= phi & phi <  this.phi_m) ...
          + this.G1 .* (this.phi_m <= phi & phi <  this.phi_r) ...
          + G2 .* (this.phi_r <= phi & phi <  this.phi_b) ...
          + G3 .* (this.phi_b <= phi & phi <=   180);
      
      Gx = G;
      
      % Validate low level rules.
      if this.CoefA < 18 || this.CoefA > 47
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'CoefA is out of limits.', ...
            -6014, ...
            'STDC_ERR_COEFA_LIM', ...
            'CoefA is out of limits.');
        throw(exc)
        
      end % if
      
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
