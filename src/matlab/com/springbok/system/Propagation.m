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
classdef Propagation < handle
% Models propagation losses.

  properties (Constant = true)

    % Speed of light [m/s]
    c = 299792458
    % The Boltzmann constant [m^2 * kg] / [s^2 K]
    k = 10 * log10(1.38064852e-23)

  end % properties (Constant = true)

  methods (Static = true)

    function free_space_loss = computeFreeSpaceLoss(frequency, distance)
    % Computes free space loss.
    %
    % Parameters
    %   frequency - Frequency [MHz]
    %   distance - Distance [km]
    %
    % Returns
    %   free_space_loss - Free space loss [dB]
      lambda = Propagation.c / (frequency * 10^6);
      free_space_loss = - 20 * log10(lambda / (4 * pi * distance * 10^3));

    end % computeFreeSpaceLoss

    function spreading_loss = computeSpreadingLoss(distance)
    % Computes spreading loss.
    %
    % Parameters
    %   distance - Distance [km]
    %
    % Returns
    %   spreading_loss - Spreading loss [dB/m^2]
      spreading_loss = 10 * log10(4 * pi * (distance * 10^3)^2);

    end % computeSpreadingLoss()

    function fuselage_loss = computeFuselageLoss(angle)
    % Computes fuselage loss based on ITU-R Document 4A/??.
    %
    % Parameters
    %   angle - Angle from local horizontal
    %
    % Returns
    %   fuselage_loss - Fuselage loss [dB]
      if angle < 0 || angle > 90
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Angle from local horizontal must be between 0 and 90 inclusive');
        throw(MEx);

      end % if
      fuselage_loss ...
          = (4 + (6 - 4) / (10 - 0) * (angle - 0)) * (angle < 10) ...
          + (6 + (26 - 6) / (35 - 10) * (angle - 10)) * (angle >= 10 && angle < 35) ...
          + (26 + (35 - 26) / (50 - 35) * (angle - 35)) * (angle >= 35 && angle < 50) ...
          + (35) * (angle >= 50 && angle < 130) ...
          + (35 + (35 - 26) / (130 - 145) * (angle - 130)) * (angle >= 130 && angle < 145) ...
          + (26 + (26 - 6) / (145 - 170) * (angle - 145)) * (angle >= 145 && angle < 170) ...
          + (6 + (6 - 4) / (170 - 180) * (angle - 170)) * (angle >= 170);

    end % computeFuselageLoss()

    % TODO: Complete
    function building_loss = computeBuildingLoss( ...
        building_loss_flag, building_loss_model, building_loss_p, building_loss_p_fixed, traditional_p, ...
        building_loss_mean, building_loss_sigma, building_loss_min, building_loss_max, ...
        building_loss_td_r, building_loss_td_s, building_loss_td_t, building_loss_td_u, building_loss_td_v, ...
        building_loss_td_w, building_loss_td_x, building_loss_td_y, building_loss_td_z, ...
        building_loss_te_r, building_loss_te_s, building_loss_te_t, building_loss_te_u, building_loss_te_v, ...
        building_loss_te_w, building_loss_te_x, building_loss_te_y, building_loss_te_z, ...
        f_ghz, el_angle)
    % Computes building entry loss bassd on a normal distribution or
    % ITU-R Recommendation P.2109-1 Prediction of Building Entry
    % Loss.
    %
    % Parameters
    %   building_loss_flag -
    %   building_loss_model -
    %   building_loss_p -
    %   building_loss_p_fixed -
    %   traditional_p -
    %   building_loss_mean -
    %   building_loss_sigma -
    %   building_loss_min -
    %   building_loss_max -
    %   building_loss_td_r -
    %   building_loss_td_s -
    %   building_loss_td_t -
    %   building_loss_td_u -
    %   building_loss_td_v -
    %   building_loss_td_w -
    %   building_loss_td_x -
    %   building_loss_td_y -
    %   building_loss_td_z -
    %   building_loss_te_r -
    %   building_loss_te_s -
    %   building_loss_te_t -
    %   building_loss_te_u -
    %   building_loss_te_v -
    %   building_loss_te_w -
    %   building_loss_te_x -
    %   building_loss_te_y -
    %   building_loss_te_z -
    %   f_ghz -
    %   el_angle -
      if building_loss_flag == 0
        building_loss = 0;
        return
      end % if

      switch building_loss_p
        case 'Random'
          p_percent = 100 * rand;

        case 'Median'
          p_percent = 50;

        case 'Fixed'
          p_percent = building_loss_p_fixed;

        otherwise
          MEx = MException('Springbok:IllegalArgumentException', ...
                           sprintf('Unexpected building loss ?: %s', building_loss_p));
          throw(MEx);

      end % switch

      switch building_loss_model
        case 'None'
          building_loss = 0;

        case 'Normal'
          building_loss = get_randn( ...
              building_loss_mean, building_loss_sigma, building_loss_min, building_loss_max);

        case 'P.2109'
          if rand <= traditional_p / 100
            r = building_loss_td_r;
            s = building_loss_td_s;
            t = building_loss_td_t;
            u = building_loss_td_u;
            v = building_loss_td_v;
            w = building_loss_td_w;
            x = building_loss_td_x;
            y = building_loss_td_y;
            z = building_loss_td_z;

          else
            r = building_loss_te_r;
            s = building_loss_te_s;
            t = building_loss_te_t;
            u = building_loss_te_u;
            v = building_loss_te_v;
            w = building_loss_te_w;
            x = building_loss_te_x;
            y = building_loss_te_y;
            z = building_loss_te_z;

          end % if

          P = p_percent / 100;
          theta = el_angle;
          L_h = r + s * log10(f_ghz) + t * (log10(f_ghz)) ^ 2;
          L_e = 0.212 * abs(theta);

          mu_1 = L_h + L_e;
          mu_2 = w + x * log10(f_ghz);
          sigma_1 = u + v * log10(f_ghz);
          sigma_2 = y + z * log10(f_ghz);

          F_inv = norminv(P, 0, 1);

          A = F_inv * sigma_1 + mu_1;
          B = F_inv * sigma_2 + mu_2;
          C = -3.0;

          building_loss = 10 * log10(10 ^ (0.1 * A) + 10 ^ (0.1 * B) + 10 ^ (0.1 * C));

        otherwise
          MEx = MException('Springbok:IllegalArgumentException', ...
                           sprintf('Unexpected building loss model: %s', building_loss_model));
          throw(MEx);

      end % switch

    end % computeBuildingLoss()

  end % methods (Static = true)

end % classdef
