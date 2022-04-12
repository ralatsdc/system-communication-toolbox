classdef PatternERR_010V01 < EarthPattern & TransmitPattern
% Describes the ITU antenna pattern ERR_010V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    
    % Intermediate gain calculation results
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternERR_010V01(GainMax)
    % Constructs a PatternERR_010V01 given a maximum antenna gain.
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
      % None
      
    end % PatternERR_010V01()
    
    function that = copy(this)
    % Copies a PatternERR_010V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternERR_010V01(this.GainMax);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Appendix 30A (RR-2001) reference transmitting earth station
    % antenna pattern for Regions 1 and 3 (WRC-97).
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
      G1 = this.GainMax - 21 - 20 * log10(phi);
      G2 = this.GainMax - 5.7 - 53.2 * phi .^ 2;
      G3 = this.GainMax - 28 - 25 * log10(phi);
      G4 = this.GainMax - 67;
      
      G = G0 .* ( 0    <= phi & phi <=  0.1 ) ...
          + G1 .* ( 0.1  <  phi & phi <=  0.32) ...
          + G2 .* ( 0.32 <  phi & phi <=  0.54) ...
          + G3 .* ( 0.54 <  phi & phi <= 36.31) ...
          + G4 .* (36.31 <  phi & phi <=   180);
      
      Gx = min(this.GainMax - 35, G);
      
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
        axis([0.05 180 v(3) v(4)])
        title([strrep(mfilename, '_', '\_'), ' Reference Antenna Pattern'])
        xlabel('Phi (degrees)')
        ylabel('Gain (dB)')
        
      else
        fH = [];
        
      end % if
      
    end % gain()
    
  end % methods
  
end % classdef
