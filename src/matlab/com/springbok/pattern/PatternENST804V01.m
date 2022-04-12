classdef PatternENST804V01 < EarthPattern & TransmitPattern & ReceivePattern
% Describes the ITU antenna pattern ENST804V01.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Sidelobe reference level, dB
    CoefA
    % Sidelobe roll-off level, dB
    CoefB
    
    % Intermediate gain calculation results
    phi_r
    phi_b
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternENST804V01(GainMax, CoefA, CoefB)
    % Constructs a PatternENST804V01 given a maximum antenna gain.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %   CoefA - Sidelobe reference level, dB
    %   CoefB - Sidelobe roll-off level, dB
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 3 ...
           && isnumeric(GainMax) ...
           && isnumeric(CoefA) ...
           && isnumeric(CoefB))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric GainMax, CoefA, and CoefB must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      PatternUtility.validate_input('CoefA', CoefA);
      PatternUtility.validate_input('CoefB', CoefB);
      
      % Assign properties
      this.GainMax = GainMax;
      this.CoefA = CoefA;
      this.CoefB = CoefB;
      
      % Compute derived properties
      this.phi_r = 1;
      this.phi_b = [0 : 0.001 : 180 ];
      g1 = this.CoefA - this.CoefB * log10(this.phi_b);
      this.phi_b = this.phi_b(find(g1 <= -10, 1, 'first'));
      
    end % PatternENST804V01()
    
    function that = copy(this)
    % Copies a PatternENST804V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternENST804V01(this.GainMax, this.CoefA, ...
                               this.CoefB);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Non-standard generic earth station antenna pattern described
    % by 2 main coefficients: A and B.
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
      
      G = G0 .* (0     <= phi & phi <= this.phi_r) ...
          + G1 .* (this.phi_r <  phi & phi <=   180);
      
      G = min(this.GainMax, G);
      
      Gx = G;
      
      % Validate low level rules.
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
