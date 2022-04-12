classdef PatternENST807V01 < EarthPattern & TransmitPattern & ReceivePattern
% Describes the ITU antenna pattern ENST807V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Near sidelobe reference level, dB
    CoefA
    % Near sidelobe roll-off level, dB
    CoefB
    % Far sidelobe reference level, dB
    CoefC
    % Far sidelobe roll-off level, dB
    CoefD
    % Angular extent of near sidelobe, degrees
    Phi1
    
    % Intermediate gain calculation results
    % None
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternENST807V01(GainMax, CoefA, CoefB, CoefC, CoefD, Phi1)
    % Constructs a PatternENST807V01 given a maximum antenna gain.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %   CoefA - Near sidelobe reference level, dB
    %   CoefB - Near sidelobe roll-off level, dB
    %   CoefC - Far sidelobe reference level, dB
    %   CoefD - Far sidelobe roll-off level, dB
    %   Phi1 - Angular extent of near sidelobe, degrees
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 6 ...
           && isnumeric(GainMax) ...
           && isnumeric(CoefA) ...
           && isnumeric(CoefB) ...
           && isnumeric(CoefC) ...
           && isnumeric(CoefD) ...
           && isnumeric(Phi1))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric GainMax, CoefA, CoefB, CoefC, CoefD, and Phi1 must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      PatternUtility.validate_input('CoefA', CoefA);
      PatternUtility.validate_input('CoefB', CoefB);
      PatternUtility.validate_input('CoefC', CoefC);
      PatternUtility.validate_input('CoefD', CoefD);
      PatternUtility.validate_input('Phi1', Phi1);
      
      % Assign properties
      this.GainMax = GainMax;
      this.CoefA = CoefA;
      this.CoefB = CoefB;
      this.CoefC = CoefC;
      this.CoefD = CoefD;
      this.Phi1 = Phi1;
      
      % Compute derived properties
      % None
      
    end % PatternENST807V01()
    
    function that = copy(this)
    % Copies a PatternENST807V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternENST807V01(this.GainMax, this.CoefA, this.CoefB, ...
                               this.CoefC, this.CoefD, this.Phi1);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Non-standard generic earth station antenna pattern described
    % by 4 main coefficients: A, B, C, D and angle phi1. Minimum
    % antenna gain (Gmin) is -10 dB.
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
      
      G0 = this.GainMax;
      G1 = this.CoefA - this.CoefB * log10(phi);
      G_phi1 = this.CoefA - this.CoefB * log10(this.Phi1);
      G2 = max(min(G_phi1, this.CoefC - this.CoefD * log10(phi)), -10);
      
      G = G0 .* (0    <= phi & phi <     1) ...
          + G1 .* (1    <= phi & phi <= this.Phi1) ...
          + G2 .* (this.Phi1 <  phi & phi <=  180);
      
      G = min(this.GainMax, G);
      G = max(-10, G);
      
      Gx = G;
      
      % Validate low level rules.
      if min(G) < -100 || min(G) > this.GainMax
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'Gmin is out of limits.', ...
            -6020, ...
            'STDC_ERR_GMIN', ...
            'Gmin is out of limits.');
        throw(exc)
        
      end % if
      
      if this.Phi1 < 1 || this.Phi1 > 99.9
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'Phi1 is out of limits.', ...
            -6018, ...
            'STDC_ERR_NSTD_PHI1', ...
            'Phi1 is out of limits.');
        throw(exc)
        
      end % if
      
      if this.CoefD < 10 || this.CoefD > 50
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'CoefD is out of limits.', ...
            -6017, ...
            'STDC_ERR_COEFD', ...
            'CoefD is out of limits.');
        throw(exc)
        
      end % if
      
      if this.CoefC < 18 || this.CoefC > 47
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'CoefC is out of limits.', ...
            -6016, ...
            'STDC_ERR_COEFC', ...
            'CoefC is out of limits.');
        throw(exc)
        
      end % if
      
      if this.CoefB < 10 || this.CoefB > 50
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'CoefB is out of limits.', ...
            -6015, ...
            'STDC_ERR_COEFB', ...
            'CoefB is out of limits.');
        throw(exc)
        
      end % if
      
      if this.CoefA < 18 || this.CoefA > 47
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'CoefA is out of limits.', ...
            -6014, ...
            'STDC_ERR_COEFA_LIM', ...
            'CoefA is out of limits.');
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
