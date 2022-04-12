classdef PatternSRR_401V01 < SpacePattern & TransmitPattern & ReceivePattern
% Describes the ITU antenna pattern SRR_401V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Cross-sectional half-power beamwidth, degrees
    Phi0
    
    % Intermediate gain calculation results
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternSRR_401V01(Phi0)
    % Constructs a PatternSRR_401V01 given a maximum antenna gain.
    %
    % Parameters
    %   Phi0 - Cross-sectional half-power beamwidth, degrees
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 1 ...
           && isnumeric(Phi0))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric Phi0 must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('Phi0', Phi0);
      
      % Assign properties
      this.Phi0 = Phi0;
      
      % Compute derived properties
      % None
      
    end % PatternSRR_401V01()
    
    function that = copy(this)
    % Copies a PatternSRR_401V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternSRR_401V01(this.Phi0);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Appendix 30 and Appendix 30A (RR-2001) reference space
    % station antenna pattern for Region 2. Appendix 30B (RR-2001)
    % space station antenna co-polar pattern for all Regions.
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
      
      % TODO: Test constructor optional agruments
      % Assign default values to any optional input parameters that
      % were not included in varargin.
      if ~isfield(input, 'GainMax')
        this.GainMax = 0;
        absolute_pattern = false;
        
      else
        this.GainMax = input.GainMax;
        absolute_pattern = true;
        
      end % if
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
      G1 = this.GainMax - 22 - 20 * log10(phi_over_phi0);
      
      G = G0 .* (0    <= phi_over_phi0 & phi_over_phi0 <= 1.45) ...
          + G1 .* (1.45 <  phi_over_phi0);
      
      Gx = min(this.GainMax - 30, G);
      
      % Apply "flooring" for absolute gain pattern.
      if absolute_pattern
        G = max(0, G);
        Gx = max(0, Gx);
        
      end % if
      
      % Validate low level rules.
      if this.GainMax < 30 && absolute_pattern
        warning( ...
            'Springbok:InvalidResult', ...
            'GainMax is less than 30.');
        
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
        
        if absolute_pattern
          ttlStr = [strrep(mfilename, '_', '\_'), ' Absolute Reference Antenna Pattern'];
          
        else
          ttlStr = [strrep(mfilename, '_', '\_'), ' Relative Reference Antenna Pattern'];
          
        end % if
        
        title(ttlStr)
        xlabel('Phi (degrees)')
        ylabel('Gain (dB)')
        
      else
        fH = [];
        
      end % if
      
    end % gain()
    
  end % methods
  
end % classdef
