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
classdef PatternERECM2101_0 < EarthPattern & TransmitPattern & ReceivePattern
% Describes the Recommendation ITU-R M.2101-0 IMT Base Station (BS)
% and User Equipment (UE) beamforming antenna pattern.

  properties (SetAccess = private, GetAccess = public)

    %  Number of array elements in a row
    n_elements_row
    %  Number of array elements in a column
    n_elements_column
    %  Element gain
    gain_element
    %  Element horizontal 3 dB beamwidth
    phi_3dB
    %  Element front-to-back ratio
    A_m
    %  Element vertical sidelobe attenuation
    SLAv
    %  Element vertical 3 dB beamwidth
    theta_3dB
    %  Array vertical element spacing
    d_V_lambda
    %  Array horizontal element spacing
    d_H_lambda

  end % properties (SetAccess = private, GetAccess = public)

  methods

    function this = PatternERECM2101_0( ...
        n_elements_row, n_elements_column, ...
        gain_element, phi_3dB, A_m, SLAv, theta_3dB, ...
        d_V_lambda, d_H_lambda)
    % Constructs a PatternERECM2102_0 instance.
    %
    % Parameters
    %   n_elements_row - Number of array elements in a row
    %   n_elements_column - Number of array elements in a column
    %   gain_element - Element gain
    %   phi_3dB - Element horizontal 3 dB beamwidth
    %   A_m - Element front-to-back ratio
    %   SLAv -Element vertical sidelobe attenuation
    %   theta_3dB - Element vertical 3 dB beamwidth
    %   d_V_lambda - Array vertical element spacing
    %   d_H_lambda - Array horizontal element spacing

    % No argument constructor
      if nargin == 0
        return;

      end % if

      % Check number and class of input arguments.
      if ~(nargin == 9 ...
           && isnumeric(n_elements_row) ...
           && isnumeric(n_elements_column) ...
           && isnumeric(gain_element) ...
           && isnumeric(phi_3dB) ...
           && isnumeric(A_m) ...
           && isnumeric(SLAv) ...
           && isnumeric(theta_3dB) ...
           && isnumeric(d_V_lambda) ...
           && isnumeric(d_H_lambda))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Array antenna parameters have not been specified correctly');
        throw(exc)

      end % if

      % Assign properties
      this.n_elements_row = n_elements_row;
      this.n_elements_column = n_elements_column;
      this.gain_element = gain_element;
      this.phi_3dB = phi_3dB;
      this.A_m = A_m;
      this.SLAv = SLAv;
      this.theta_3dB = theta_3dB;
      this.d_V_lambda = d_V_lambda;
      this.d_H_lambda = d_H_lambda;

      % Compute derived properties
      % None required.

    end % PatternERECM2101_0()

    function that = copy(this)
    % Copies a PatternERECM2101_0 instance.
    %
    % Parameters
    %   None
      that = PatternERECM2101_0( ...
          this.n_elements_row, this.n_elements_column, ...
          this.gain_element, this.phi_3dB, this.A_m, this.SLAv, this.theta_3dB, ...
          this.d_V_lambda, this.d_H_lambda);

    end % copy()

    function [A_T, A_A, A_E, fH] = gain( ...
        this, phi_off_axis, theta_off_axis, phi_scan, theta_scan, varargin);
      % Recommendation ITU-R M.2101-0 IMT Base Station (BS) and User
      % Equipment (UE) beamforming antenna pattern gain.
      %
      % Parameters:
      %   phi_off_axis - Off-axis pointing azimuth [deg]
      %   theta_off_axis - Off-axis pointing elevation [deg]
      %   phi_scan - Electrical pointing azimuth [deg]
      %   theta_scan - Electrical pointing elevation [deg]
      %
      % Optional parameters (entered as key/value pairs):
      %   PlotFlag - Flag to indicate plot, true or {false}
      %
      % Returns:
      %   A_T - Total gain
      %   A_A - Array gain
      %   A_E - Element gain

      % Check number and class of input arguments.
      if ~(nargin >= 4 ...
           && isnumeric(phi_off_axis) ...
           && isnumeric(theta_off_axis) ...
           && isnumeric(phi_scan) ...
           && isnumeric(theta_scan))
        exc = SException( ...
            'Springbok:InvalidInput', ...
            'Numeric angles must be provided.');
        throw(exc)

      elseif ~(length(phi_off_axis) == length(theta_off_axis) ...
                && length(phi_scan) == length(theta_scan) ...
                && length(phi_off_axis) == length(phi_scan))
          exc = SException( ...
              'Springbok:InvalidInput', ...
              'Numeric angles must have the same length.');
          throw(exc)

      end % if

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
      nAng = length(phi_off_axis);
      for iAng = 1:nAng
        G_E_max = this.gain_element;
        A_E_H = -min(12 * (phi_off_axis(iAng) / this.phi_3dB) ^ 2, this.A_m);
        A_E_V = -min(12 * ((theta_off_axis(iAng) - 90) / this.theta_3dB) ^ 2, this.SLAv);
        A_E(iAng) = G_E_max - min(-(A_E_H + A_E_V), this.A_m);
        N_H = this.n_elements_column;
        N_V = this.n_elements_row;
        p = NaN(N_V, N_H);
        for m = 1:N_H
          for n = 1:N_V
            v = exp(1i * 2 * pi * ( ...
                (n - 1) * this.d_V_lambda * cosd(theta_off_axis(iAng)) + ...
                (m - 1) * this.d_H_lambda * sind(theta_off_axis(iAng)) * sind(phi_off_axis(iAng))));
            w = 1 / sqrt(N_H * N_V) * exp(1i * 2 * pi * ( ...
                (n - 1) * this.d_V_lambda * sind(theta_scan(iAng)) - ...
                (m - 1) * this.d_H_lambda * cosd(theta_scan(iAng)) * sind(phi_scan(iAng))));
            p(n, m) = v * w;

          end % for n

        end % for m
        A_A(iAng) = 10 * log10(abs(sum(sum(p)))^2);
        A_T(iAng) = A_A(iAng) + A_E(iAng);

      end % for iAng

      % Plot results, if requested.
      if PlotFlag == true
        fH = figure;
        if (unique(diff(phi_scan)) ~= 0 ...
            || unique(diff(theta_scan)) ~= 0)
          exc = SException( ...
              'Springbok:InvalidInput', ...
              'Constant scan phi and theta expected for plotting.');
          throw(exc)
        end % if
        if unique(diff(theta_off_axis)) == 0
          plot(phi_off_axis, A_T, 'k');
          axis([-180, 180, -40, 30]);
          xlabel('Phi (degs)')
          title(sprintf('%s Reference Antenna Pattern Horizontal Cut', ...
                        strrep(mfilename, '_', '\_')));

        elseif unique(diff(phi_off_axis)) == 0
          plot(theta_off_axis, A_T, 'k');
          axis([0, 180, -40, 30]);
          xlabel('Theta (degs)')
          title(sprintf('%s Reference Antenna Pattern Vertical Cut', ...
                        strrep(mfilename, '_', '\_')));

        else
          exc = SException( ...
              'Springbok:InvalidInput', ...
              'Constant off axis phi or theta expected for plotting.');
          throw(exc)

        end % if
        ylabel('Gain (dB)')

      else
        fH = [];

      end % if

    end % gain()

  end % methods

end % classdef
