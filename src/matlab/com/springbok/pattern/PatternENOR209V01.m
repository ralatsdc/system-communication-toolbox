classdef PatternENOR209V01 < EarthPattern & TransmitPattern
% Describes the ITU antenna pattern ENOR209V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    
    % Intermediate gain calculation results
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternENOR209V01()
    % Constructs a PatternENOR209V01 given a maximum antenna gain.
      
    % Check number and class of input arguments.
      if ~(nargin == 0)
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'No arguments required.');
        throw(exc)
        
      end % if
      
      % Assign properties
      this.GainMax = 50.7;
      
      % Compute derived properties
      % None
      
    end % PatternENOR209V01()
    
    function that = copy(this)
    % Copies a PatternENOR209V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternENOR209V01();

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Earth station transmitting antenna pattern for analyses under
    % Appendix 30B for the BIFROST terminal type I transmitting
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
      
      G0 = 50.7 - 42.3 * phi .^ 2;
      G1 = 30.7;
      G2 = 29 - 25 * log10(phi);
      G3 = -10;
      
      G = G0 .* (0     <= phi & phi <  0.634) ...
          + G1 .* (0.634 <= phi & phi <  0.854) ...
          + G2 .* (0.854 <= phi & phi <     48) ...
          + G3 .* (48    <= phi & phi <=   180);
      
      Gx = G;
      
      % Validate low level rules.
      % None
      
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
