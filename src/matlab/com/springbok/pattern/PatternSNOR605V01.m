classdef PatternSNOR605V01 < SpacePattern & TransmitPattern & ReceivePattern
% Describes the ITU antenna pattern SNOR605V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Cross-sectional half-power beamwidth, degrees
    Phi0
    
    % Intermediate gain calculation results
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternSNOR605V01(GainMax, Phi0)
    % Constructs a PatternSNOR605V01 given a maximum antenna gain.
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
      
    end % PatternSNOR605V01()
    
    function that = copy(this)
    % Copies a PatternSNOR605V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternSNOR605V01(this.GainMax, this.Phi0);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Space station antenna pattern (transmitting and receiving)
    % submitted by NOR for analyses under Appendix 30B.
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
      
      G0 = this.GainMax - 12 * phi_over_phi0 .^ 2;
      G1 = this.GainMax - 30;
      G2 = this.GainMax - 17.5 - 25 * log10(phi_over_phi0);
      
      G = G0 .* (0    <= phi_over_phi0 & phi_over_phi0 <= 1.58) ...
          + G1 .* (1.58 <  phi_over_phi0 & phi_over_phi0 <= 3.16) ...
          + G2 .* (3.16 <  phi_over_phi0);
      
      G = min(35, G);
      
      Gx = G;
      
      % Apply "flooring".
      G = max(0, G);
      Gx = max(0, Gx);
      
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
