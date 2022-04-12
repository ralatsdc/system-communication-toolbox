classdef PatternUtility < handle
% Defines methods for validating pattern input and output, and for
% comparing patterns.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  methods (Static = true)
    
    function input = validate_input(key, value, varargin)
    % Validate input parameters.
    %
    % Parameters
    %   key - Parameter name
    %   value - Parameter value
    %
    % Returns
    %   input - Structure containing (key, value) pairs
      
    % Check number and class of input arguments
      if nargin ~= 2 && nargin ~= 3
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Input must be a key-value pair');
        throw(exc)
        
      end % if
      
      if ~(ischar(key))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Input parameter name must be a string');
        throw(exc)
        
      end % if
      
      if ~(isnumeric(value) || islogical(value))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Input parameter value must be either numeric or logical');
        throw(exc)
        
      end % if
      
      if nargin == 3
        input = varargin{1};
        if ~isstruct(input)
          exc = SException( ...
              'Springbok:InvalidInput', ...
              'Input input must be a structure');
          throw(exc)

        end % if

      end % if

      % Check size and value of input parameter
      switch key
        
        % Required input parameters
        case 'GainMax'
          if ~(isnumeric(value) ...
               && min(size(value) == [1, 1]))
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'GainMax must be a numeric scalar.');
            throw(exc)
            
          end % if
          
          if value < 0.00e+0 || value > 7.00e+2
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'GainMax is out of limits [0:700].', ...
                -5200, ...
                'APC_ERR_VAL_GAINMAX', ...
                'GainMax is out of limits [0:700].');
            throw(exc)
            
          end % if
          
          if value < 0.00e+0 || value > 1.00e+2
            warning( ...
                'Springbok:InvalidInput', ...
                'GainMax is out of limits [0:100].');
          end % if
          input.(key) = value;
          
        case 'Beamlet'
          if ~(isnumeric(value) ...
               && min(size(value) == [1, 1]))
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Beamlet must be a numeric scalar.');
            throw(exc)
            
          end % if
          
          if value < 1.00e-5 || value > 1.80e+2
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Beamlet is out of limits [1e-5:180].', ...
                -5201, ...
                'APC_ERR_VAL_BEAMLET', ...
                'Beamlet is out of limits [1e-5:180].');
            throw(exc)
            
          end % if
          
          if value < 1.00e-3 || value > 1.80e+1
            warning( ...
                'Springbok:InvalidInput', ...
                'Beamlet is out of limits [1e-3:18].');
          end % if
          input.(key) = value;
          
        case 'Diameter'
          if ~(isnumeric(value) ...
               && min(size(value) == [1, 1]))
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Diameter must be a numeric scalar.');
            throw(exc)
            
          end % if
          
          if value < 1.00e-5 || value > 1.00e+5
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Diameter is out of limits [1e-5:1e+5].', ...
                -5202, ...
                'APC_ERR_VAL_DIAMETER', ...
                'Diameter is out of limits [1e-5:1e+5].');
            throw(exc)
            
          end % if
          
          if value < 1.00e-2 || value > 1.00e+2
            warning( ...
                'Springbok:InvalidInput', ...
                'Diameter is out of limits [0.01:100].');
          end % if
          input.(key) = value;
          
        case 'Frequency'
          if ~(isnumeric(value) ...
               && min(size(value) == [1, 1]))
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Frequency must be a numeric scalar.');
            throw(exc)
            
          end % if
          
          if value < 1.00e-3 || value > 1.00e+10
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Frequency is out of limits [1e-3:1e+10].', ...
                -5203, ...
                'APC_ERR_VAL_FREQUENCY', ...
                'Frequency is out of limits [1e-3:1e+10].');
            throw(exc)
            
          end % if
          
          if value < 1.00e+0 || value > 1.00e+6
            warning( ...
                'Springbok:InvalidInput', ...
                'Frequency is out of limits [1:1e+6].');
          end % if
          input.(key) = value;
          
        case 'Efficiency'
          if ~(isnumeric(value) ...
               && min(size(value) == [1, 1]))
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Efficiency must be a numeric scalar.');
            throw(exc)
            
          end % if
          
          if value < 1.00e-5 || value > 1.00e+0
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Efficiency is out of limits [1e-5:100].', ...
                -5204, ...
                'APC_ERR_VAL_EFFICIENCY', ...
                'Efficiency is out of limits [1e-5:100].');
            throw(exc)
            
          end % if
          
          if value < 1.00e-1 || value > 1.00e+0
            warning( ...
                'Springbok:InvalidInput', ...
                'Efficiency is out of limits [0.1:100].');
          end % if
          input.(key) = value;
          
        case 'Phi'
          if ~(isnumeric(value) ...
               && max(size(value) == [1, 1]))
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Phi must be a numeric vector (or scalar).');
            throw(exc)
            
          end % if
          
          if max(value < 0.00e+0) || max(value > 1.80e+2)
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Phi is out of limits [0:180].', ...
                -5206, ...
                'APC_ERR_VAL_PHI', ...
                'Phi is out of limits [0:180].');
            throw(exc)
            
          end % if
          input.(key) = value;
          
        case 'Phi0'
          if ~(isnumeric(value) ...
               && min(size(value) == [1, 1]))
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Phi0 must be a numeric scalar.');
            throw(exc)
            
          end % if
          
          if value < 1.00e-5 || value > 1.80e+2
            exc = SException( ...
                'Springbok:InvalidInput', ...
                'Phi0 is out of limits [1e-5:180].', ...
                -5207, ...
                'APC_ERR_VAL_PHI0', ...
                'Phi0 is out of limits [1e-5:180].');
            throw(exc)
            
          end % if
          
          if value < 1.00e-3 || value > 1.80e+2
            warning( ...
                'Springbok:InvalidInput', ...
                'Phi0 is out of limits [1e-3:180].');
          end % if
          input.(key) = value;
          
        % Optional input parameters
        case {'CoefA', 'CoefB', 'CoefC', 'CoefD', 'Phi1', 'Gmin'}
          if ~(isnumeric(value) ...
               && min(size(value) == [1, 1]))
            exc = SException( ...
                'Springbok:InvalidInput', ...
                [key, ' must be a numeric scalar.']);
            throw(exc)
            
          end % if
          input.(key) = value;
          
        case 'PlotFlag'
          if ~(min(size(value) == [1, 1]) ...
               && islogical(value))
            warning( ...
                'Springbok:InvalidInput', ...
                'PlotFlag must be a logical scalar.');
          end % if
          input.(key) = value;
          
        case 'DoValidate'
          if ~(min(size(value) == [1, 1]) ...
               && islogical(value))
            warning( ...
                'Springbok:InvalidInput', ...
                'DoValidate must be a logical scalar.');
          end % if
          input.(key) = value;
          
        otherwise
          warning( ...
              'Springbok:UnknownParameterName', ...
              'Input parameter name not recognized (and ignored): %s.', key);
          
      end % switch
      
    end % validate_input()
    
    function validate_output(G, Gx, GainMax)
    % Validate output parameters.
    %
    % Parameters
    %   G - Co-pol gain, dB
    %   Gx - Cross-pol gain, dB
    %   GainMax - Maximum antenna gain, dB
      
    % Check number and class of input arguments
      if ~(nargin == 3 ...
           && isnumeric(G) ...
           && isnumeric(Gx) ...
           && isnumeric(GainMax))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'G, and Gx, and GainMax must be numeric.');
        throw(exc)
        
      end % if
      
      % Check values of output parameters
      if G > GainMax
        exc = SException( ...
            'Springbok:InvalidOutput', ...
            'G is greater than GainMax.', ...
            -5501, ...
            'APC_ERR_G_GT_GMAX', ...
            'G is greater than GainMax.');
        throw(exc)
        
      end % if
      
      if Gx > GainMax
        exc = SException( ...
            'Springbok:InvalidOutput', ...
            'Gx is greater than GainMax.', ...
            -5502, ...
            'APC_ERR_GX_GT_GMAX', ...
            'Gx is greater than GainMax.');
        throw(exc)
        
      end % if
      
      if Gx > G
        warning( ...
            'Springbok:InvalidOutput', ...
            'Gx is greater than G.');
        
      end % if
      
      if Gx == G
        warning( ...
            'Springbok:InvalidOutput', ...
            'Cross-polar gain is not calculated.  Value is set to co-polar gain.');
        
      end % if
      
    end % validate_output()
    
    function isSame = compare_pattern(pattern_a, pattern_b)
    % Compare pattern properties for equality to high precision.
    %
    % Parameters
    %   pattern_a - A pattern, used for fieldnames
    %   pattern_b - B pattern
    %
    % Returns
    %   isSame - True if pattern properties are equal within high
    %       precision
      
    % Check number and class of input arguments
      if ~(nargin == 2 ...
           && (isstruct(pattern_a) || isa(pattern_a, 'Pattern')) ...
           && (isstruct(pattern_b) || isa(pattern_b, 'Pattern')))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Inputs must be structures.');
        throw(exc)
        
      end % if
      
      fldNms = fieldnames(pattern_a);
      
      nFldNms = length(fldNms);
      if nFldNms == 0
        isSame = true;
        
      else
        t = zeros(nFldNms, 1);
        for iFldNms = 1:nFldNms
          curFld = fldNms{iFldNms};
          t(iFldNms) = max(abs(pattern_a.(curFld) - pattern_b.(curFld))) < 1e-14;
          
        end % for iFldNms
        
        if min(t) == 1
          isSame = true;
          
        else
          isSame = false;
          
        end % if
        
      end % if
      
    end % compare_specific()
    
  end % methods (Static = true)
  
end % classdef
