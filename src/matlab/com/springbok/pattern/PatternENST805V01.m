classdef PatternENST805V01 < EarthPattern & TransmitPattern & ReceivePattern
% Describes the ITU antenna pattern ENST805V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Sidelobe reference level, dB
    CoefA
    % Sidelobe roll-off level, dB
    CoefB
    % Angular extent of sidelobe, degrees
    Phi1
    
    % Intermediate gain calculation results
    % None
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternENST805V01(GainMax, CoefA, CoefB, Phi1)
    % Constructs a PatternENST805V01 given a maximum antenna gain.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %   CoefA - Sidelobe reference level, dB
    %   CoefB - Sidelobe roll-off level, dB
    %   Phi1 - Angular extent of sidelobe, degrees
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 4 ...
           && isnumeric(GainMax) ...
           && isnumeric(CoefA) ...
           && isnumeric(CoefB) ...
           && isnumeric(Phi1))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric GainMax, CoefA, CoefB, and Phi1 must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      PatternUtility.validate_input('CoefA', CoefA);
      PatternUtility.validate_input('CoefB', CoefB);
      PatternUtility.validate_input('Phi1', Phi1);
      
      % Assign properties
      this.GainMax = GainMax;
      this.CoefA = CoefA;
      this.CoefB = CoefB;
      this.Phi1 = Phi1;
      
      % Compute derived properties
      % None
      
    end % PatternENST805V01()
    
    function that = copy(this)
    % Copies a PatternENST805V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternENST805V01(this.GainMax, this.CoefA, this.CoefB, ...
                               this.Phi1);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Non-standard generic earth station antenna pattern that is a
    % combination of a non-standard pattern described by 2 main
    % coefficients: A and B, within a certain range and the
    % Appendix 8 (RR- 2001) earth station antenna pattern onwards.
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
      G1 = max(this.CoefA - this.CoefB * log10(phi), -10);
      
      G_AB_Phi1 = this.CoefA - this.CoefB * log10(this.Phi1);
      p = PatternERR_001V01(this.GainMax);
      G_AP8_Phi1 = p.gain(this.Phi1);
      [G_AP8, ~, ~] = p.gain(phi);
      
      if G_AP8_Phi1 > G_AB_Phi1
        G2 = min(G_AB_Phi1, G_AP8);
        
      else
        G2 = G_AP8;
        
      end % if
      
      G = G0 .* (0    <= phi & phi <     1) ...
          + G1 .* (1    <= phi & phi <= this.Phi1) ...
          + G2 .* (this.Phi1 <  phi & phi <=  180);
      
      G = min(this.GainMax, G);
      G = max(-10, G);
      
      Gx = G;
      
      % Validate low level rules.
      if this.Phi1 < 1 || this.Phi1 > 99.9
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'Phi1 is out of limits.', ...
            -6018, ...
            'STDC_ERR_NSTD_PHI1', ...
            'Phi1 is out of limits.');
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
