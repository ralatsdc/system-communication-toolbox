% Copyright (C) 2022 Springbok LLC
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or (at
% your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
% 
classdef PatternENST899V01 < EarthPattern & TransmitPattern & ReceivePattern
% Describes the ITU antenna pattern ENST899V01.
  
  properties (SetAccess = private, GetAccess = public)
    
    % Maximum antenna gain [dB]
    GainMax
    % Angle values associated with gain, degrees
    AngleTable
    % Gain values, dB
    GainTable
    
    % Intermediate gain calculation results
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = PatternENST899V01(GainMax, AngleTable, GainTable)
    % Constructs a PatternENST899V01 given a maximum antenna gain.
    %
    % Parameters
    %   GainMax - Maximum antenna gain [dB]
    %   AngleTable - Angle values associated with gain, degrees
    %   GainTable - Gain values, dB
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 3 ...
           && isnumeric(GainMax) ...
           && isnumeric(AngleTable) ...
           && isnumeric(GainTable))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric GainMax, AngleTable, and GainTable must be provided.');
        throw(exc)
        
      end % if
      
      % Validate input parameters.
      PatternUtility.validate_input('GainMax', GainMax);
      
      if ~(max(size(AngleTable) == [1, 1]))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'AngleTable must be a vector (or scalar).');
        throw(exc)
        
      end % if
      
      if  ~min(diff(AngleTable) > 0)
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Wrong angles order (must be monotonically increasing).', ...
            -6024, ...
            'STDC_ERR_ANGORDER', ...
            'Wrong angles order (must be monotonically increasing).');
        throw(exc)
        
      end % if
      
      if  max(AngleTable) ~= 180
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'End angle is out of limits [180:180]).', ...
            -6023, ...
            'STDC_ERR_ENDANG', ...
            'End angle is out of limits [180:180].');
        throw(exc)
        
      end % if
      
      if  AngleTable(1) < 0 || AngleTable(1) > AngleTable(length(AngleTable))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Start angle is out of limits [0:End angle].', ...
            -6022, ...
            'STDC_ERR_STARTANG', ...
            'Start angle is out of limits [0:End angle].');
        throw(exc)
        
      end % if
      
      % Note: Error code -6021 (STDC_ERR_NUMPTS) is not
      % implemented here since the number of points is not limited.
      
      if ~(max(size(GainTable) == [1, 1]))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'GainTable must be a vector (or scalar).');
        throw(exc)
        
      end % if
      
      if ~(size(AngleTable) == size(GainTable))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'AngleTable and GainTable must have the same dimensions.');
        throw(exc)
        
      end % if
      
      % Assign properties
      this.GainMax = GainMax;
      this.AngleTable = AngleTable;
      this.GainTable = GainTable;
      
      % Compute derived properties
      % None
      
    end % PatternENST899V01()
    
    function that = copy(this)
    % Copies a PatternENST899V01 given a maximum antenna gain.
    %
    % Parameters
    %   None
      that = PatternENST899V01(this.GainMax, this.AngleTable, ...
                               this.GainTable);

    end % copy()

    function [G, Gx, fH] = gain(this, Phi, varargin)
    % Earth station antenna pattern which is given by a table.
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
      
      if size(this.AngleTable, 2) > 1
        this.AngleTable = this.AngleTable';
        this.GainTable = this.GainTable';
        
      end % if
      
      if min(this.AngleTable) ~= 0
        this.AngleTable = [0; this.AngleTable];
        this.GainTable = [this.GainMax; this.GainTable];
        
      end % if
      
      G = interp1(this.AngleTable, this.GainTable, phi, 'linear');
      Gx = G;
      
      % Validate low level rules.
      if max(this.GainMax < this.GainTable)
        exc = SException( ...
            'Springbok:InvalidResult', ...
            'GainMax is less than GainTable.', ...
            -6025, ...
            'STDC_ERR_GMAX_LT_G', ...
            'GainMax is less than GainTable.');
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
