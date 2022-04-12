classdef PatternENOR208V01 < EarthPattern & TransmitPattern
% Describes the ITU antenna pattern ENOR208V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Cross-sectional half-power beamwidth, degrees
    Phi0
    
    % Intermediate gain calculation results
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternENOR208V01(GainMax, Phi0)
    % Constructs a PatternENOR208V01 given a maximum antenna gain.
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
            'Numeric GainMax and Phi0 must be provided.');
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
      
    end % PatternENOR208V01()
    
    function that = copy(this)
    % Copies a PatternENOR208V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternENOR208V01(this.GainMax, this.Phi0);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Earth station transmitting antenna pattern for analyses under
    % Appendix 30B for the BIFROST terminal type II transmitting
    % antenna.
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
      G2 = this.GainMax - 12.5 - 25 * log10(phi_over_phi0);
      
      G = G0 .* (0      <= phi_over_phi0 & phi_over_phi0 <=   0.25) ...
          + G1 .* (0.25   <  phi_over_phi0 & phi_over_phi0 <= 1.0363) ...
          + G2 .* (1.0363 <  phi_over_phi0);
      
      G = max(this.GainMax - 42, G);
      
      Gx = G;
      
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
