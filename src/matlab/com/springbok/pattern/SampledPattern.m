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
classdef SampledPattern < EarthPattern & SpacePattern & TransmitPattern & ReceivePattern
% Describes a pattern sampled in scan angle, and antenna coordinate
% system azimuth and elevation
  
  properties (SetAccess = private, GetAccess = public)
    
    % Name of file containing antenna pattern gain samples
    patternFNm

    % Maximum antenna gain [dB]
    GainMax

    % Sampled scan angle vector [deg]
    phi
    % Sampled antenna coordinate system azimuth matrix [deg]
    azimuth
    % Sampled antenna coordinate system elevation matrix [deg]
    elevation
    % Antenna pattern gain samples [dB]
    samples
    % Antenna pattern interpolant
    interpolant
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = SampledPattern(patternFNm)
    % Constructs a SampledPattern given a directory containing
    % antenna pattern gain sample files.
    %
    % Parameters
    %   patternFNm - Name of file containing antenna pattern gain
    %     samples
      
      % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Check number and class of input arguments.
      if ~(nargin == 1 ...
           && exist(patternFNm, 'file'))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Character name of existing file must be provided.');
        throw(exc)
        
      end % if
      
      % Assign properties
      this.patternFNm = patternFNm;
      
      % Compute derived properties
      this.loadPattern();
      
    end % SampledPattern()
    
    function that = copy(this)
    % Copies a SampledPattern given a directory containing antenna
    % pattern gain sample files.
    %
    % Parameters:
    %   None
      that = SampledPattern(this.patternFNm);

    end % copy()

    function loadPattern(this)
    % Loads file containing antenna pattern gain samples.
    %
    % Parameters:
    %   None

      data = load(this.patternFNm);

      this.phi = data.steered_angles;
      azimuth = data.azs;
      elevation = data.els;

      [this.azimuth, this.elevation] = ndgrid(azimuth, elevation);

      nTh = length(this.phi);
      nAz = length(azimuth);
      nEl = length(elevation);
      
      for iTh = 1:nTh
        this.samples{iTh} = data.Kmat(:, :, iTh)';
        this.interpolant{iTh} = griddedInterpolant(this.azimuth, this.elevation, this.samples{iTh});

      end % for

    end % loadPattern()

    function [G, Gx, fH] = gain(this, phi, azimuth, elevation, varargin)
    % Sampled antenna pattern gain.
    %
    % Parameters:
    %   phi - Scan angle [rad]
    %   azimuth - Antenna coordinate system azimuth [rad]
    %   elevation - Antenna coordinate system elevation [rad]
    %
    % Optional parameters (entered as key/value pairs):
    %   PlotFlag - Flag to indicate plot, true or {false}
    %
    % Returns:
    %   G - Co-polar gain [dB]
    %   Gx - Cross-polar gain [dB]
    %   fH - figure handle
      
      % Check number and class of input arguments.
      if ~(nargin >= 3 ...
           && isnumeric(phi) ...
           && isnumeric(azimuth) ...
           && isnumeric(elevation))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric value of scan angle, and azimuth and elevation, must be provided.');
        throw(exc)
        
      end % if
      
      % Handle optional inputs.
      p = inputParser;
      p.addParamValue('GainMax', 0);
      p.addParamValue('PlotFlag', 0);
      p.parse(varargin{:});
      this.GainMax = p.Results.GainMax;
      PlotFlag = p.Results.PlotFlag;

      % Implement pattern.
      if phi < min(this.phi) || phi > max(this.phi)
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Invalid scan angle');
        throw(exc)

      end % if
      idx_left = max(find(this.phi <= phi));
      idx_right = min(find(this.phi >= phi));
      G_left = this.interpolant{idx_left}(abs(azimuth), elevation);
      % TODO: Test how interpolant handles azimuth = 0 and, or elevation = 0
      if idx_left == idx_right
        G = G_left;

      else
        G_right = this.interpolant{idx_right}(abs(azimuth), elevation);
        % TODO: Hanlde non-uniformly spaced phi?
        G = (G_left + G_right) / 2;

      end % if
      G = this.GainMax + G;
      % TODO: Do something better?
      Gx = G;
      
      % Plot results, if requested.
      if PlotFlag == true
        % TODO: complete

      else
        fH = [];

      end % if

    end % gain()

  end % methods

end % classdef
