classdef PatternERECM2101_0Test < TestUtility
% Tests methods of PatternERECM2101_0 class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)

    % IMT base station and user equipment antenna patterns from
    % R0A0600007A0001MSWE.docx

    bs_n_elements_row = 8;
    bs_n_elements_column = 8;
    bs_gain_element = 5;
    bs_phi_3dB = 65;
    bs_A_m = 30;
    bs_SLAv = 30;
    bs_theta_3dB = 65;
    bs_d_V_lambda = 0.5;
    bs_d_H_lambda = 0.5;

    ue_n_elements_row = 4;
    ue_n_elements_column = 4;
    ue_gain_element = 5;
    ue_phi_3dB = 90;
    ue_A_m = 25;
    ue_SLAv = 30;
    ue_theta_3dB = 90;
    ue_d_V_lambda = 0.5;
    ue_d_H_lambda = 0.5;

    % Angle and gain measured on Figure 2 IMT base station and user
    % equipment antenna patterns from R0A0600007A0001MSWE.docx with
    % 400% (BS) or 200% (UE) zoom on LG Ultrafine 4k display
    
    imt_bs_h_l_e = [ -150,  150,  -30,   30]; % Base station horizontal limits engineering
    imt_bs_h_l_p = [ 1018, 1584,  825,  313]; % Base station horizontal limits pixels

    imt_bs_h_ml_x_p = 1299; imt_bs_h_ml_y_p = 372; % Base station horizontal main lobe x, y pixels
    imt_bs_h_fn_x_p = 1327; imt_bs_h_fn_y_p = 781; % Base station horizontal first null x, y pixels
    imt_bs_h_fs_x_p = 1339; imt_bs_h_fs_y_p = 493; % Base station horizontal first sidelobe x, y pixels

    imt_bs_v_l_e = [   20,  160,  -30,   30]; % Base station vertical limits engineering
    imt_bs_v_l_p = [ 1137, 1665,  825,  313]; % Base station vertical limits pixels

    imt_bs_v_ml_x_p = 1400; imt_bs_v_ml_y_p = 373; % Base station vertical main lobe x, y pixels
    imt_bs_v_fn_x_p = 1454; imt_bs_v_fn_y_p = 698; % Base station vertical first null x, y pixels
    imt_bs_v_fs_x_p = 1478; imt_bs_v_fs_y_p = 492; % Base station vertical first sidelobe x, y pixels

    imt_ue_h_l_e = [ -150,  150,  -40,   20]; % User equipment horizontal limits engineering
    imt_ue_h_l_p = [  323,  607,  909,  653]; % User equipment horizontal limits pixels

    imt_ue_h_ml_x_p = 466; imt_ue_h_ml_y_p = 665; % User equipment horizontal main lobe x, y pixels
    imt_ue_h_fn_x_p = 494; imt_ue_h_fn_y_p = 829; % User equipment horizontal first null x, y pixels
    imt_ue_h_fs_x_p = 508; imt_ue_h_fs_y_p = 726; % User equipment horizontal first sidelobe x, y pixels

    imt_ue_v_l_e = [   20,  160,  -40,   20]; % User equipment vertical limits engineering
    imt_ue_v_l_p = [  742, 1005,  909,  653]; % User equipment vertical limits pixels

    imt_ue_v_ml_x_p = 872; imt_ue_v_ml_y_p = 665; % User equipment vertical main lobe x, y pixels
    imt_ue_v_fn_x_p = 930; imt_ue_v_fn_y_p = 863; % User equipment vertical first null x, y pixels
    imt_ue_v_fs_x_p = 957; imt_ue_v_fs_y_p = 726; % User equipment vertical first sidelobe x, y pixels

  end % properties (Constant = true)
  
  methods
    
    function this = PatternERECM2101_0Test(logFId, testMode)
    % Constructs a PatternERECM2101_0Test
    %
    % Parameters:
    %   logFId - Log file identifier
    %   testMode - Test mode, if 'interactive' then beeps and pauses
      
    % Invoke superclass constructor
      if nargin == 0
        superArgs = {};

      else
        superArgs{1} = logFId;
        superArgs{2} = testMode;

      end % if
      this@TestUtility(superArgs{:});

    end % PatternERECM2101_0Test()
    
    function test_PatternERECM2101_0(this)
    % Tests PatternERECM2101_0 method.

      bs_p = PatternERECM2101_0( ...
          this.bs_n_elements_row, ...
          this.bs_n_elements_column, ...
          this.bs_gain_element, ...
          this.bs_phi_3dB, ...
          this.bs_A_m, ...
          this.bs_SLAv, ...
          this.bs_theta_3dB, ...
          this.bs_d_V_lambda, ...
          this.bs_d_H_lambda);

      t = [];
      t = [t; isequal(bs_p.n_elements_row, this.bs_n_elements_row)];
      t = [t; isequal(bs_p.n_elements_column, this.bs_n_elements_column)];
      t = [t; isequal(bs_p.gain_element, this.bs_gain_element)];
      t = [t; isequal(bs_p.phi_3dB, this.bs_phi_3dB)];
      t = [t; isequal(bs_p.A_m, this.bs_A_m)];
      t = [t; isequal(bs_p.SLAv, this.bs_SLAv)];
      t = [t; isequal(bs_p.theta_3dB, this.bs_theta_3dB)];
      t = [t; isequal(bs_p.d_V_lambda, this.bs_d_V_lambda)];
      t = [t; isequal(bs_p.d_H_lambda, this.bs_d_H_lambda)];

      this.assert_true( ...
          'PatternERECM2101_0', ...
          'PatternERECM2101_0', ...
          this.IS_EQUAL_DESC, ...
          min(t));

    end % test_PatternEREC015V01()
    
    function test_gain(this)
    % Tests gain method.

      phi_off_axis = 0;
      theta_off_axis = 90;
      phi_scan = 0;
      theta_scan = 0;

      bs_p = PatternERECM2101_0( ...
          this.bs_n_elements_row, ...
          this.bs_n_elements_column, ...
          this.bs_gain_element, ...
          this.bs_phi_3dB, ...
          this.bs_A_m, ...
          this.bs_SLAv, ...
          this.bs_theta_3dB, ...
          this.bs_d_V_lambda, ...
          this.bs_d_H_lambda);

      t = [];

      [imt_bs_h_ml_phi, imt_bs_h_ml_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_bs_h_l_p, this.imt_bs_h_l_e, this.imt_bs_h_ml_x_p, this.imt_bs_h_ml_y_p);
      imt_bs_h_ml_gain_actual = bs_p.gain(imt_bs_h_ml_phi, theta_off_axis, phi_scan, theta_scan);
      t = [t; abs(imt_bs_h_ml_gain_actual - imt_bs_h_ml_gain_expected) < 0.5];

      [imt_bs_h_fn_phi, imt_bs_h_fn_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_bs_h_l_p, this.imt_bs_h_l_e, this.imt_bs_h_fn_x_p, this.imt_bs_h_fn_y_p);
      % Adjust phi to find the null
      imt_bs_h_fn_gain_actual = bs_p.gain(imt_bs_h_fn_phi + 0.635, theta_off_axis, phi_scan, theta_scan);
      t = [t; abs(imt_bs_h_fn_gain_actual - imt_bs_h_fn_gain_expected) < 0.5];

      [imt_bs_h_fs_phi, imt_bs_h_fs_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_bs_h_l_p, this.imt_bs_h_l_e, this.imt_bs_h_fs_x_p, this.imt_bs_h_fs_y_p);
      imt_bs_h_fs_gain_actual = bs_p.gain(imt_bs_h_fs_phi, theta_off_axis, phi_scan, theta_scan);
      t = [t; abs(imt_bs_h_fs_gain_actual - imt_bs_h_fs_gain_expected) < 0.5];
      
      [imt_bs_v_ml_theta, imt_bs_v_ml_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_bs_v_l_p, this.imt_bs_v_l_e, this.imt_bs_v_ml_x_p, this.imt_bs_v_ml_y_p);
      imt_bs_v_ml_gain_actual = bs_p.gain(phi_off_axis, imt_bs_v_ml_theta, phi_scan, theta_scan);
      t = [t; abs(imt_bs_v_ml_gain_actual - imt_bs_v_ml_gain_expected) < 0.5];

      [imt_bs_v_fn_theta, imt_bs_v_fn_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_bs_v_l_p, this.imt_bs_v_l_e, this.imt_bs_v_fn_x_p, this.imt_bs_v_fn_y_p);
      % Adjust theta to find the null
      imt_bs_v_fn_gain_actual = bs_p.gain(phi_off_axis, imt_bs_v_fn_theta + 0.240, phi_scan, theta_scan);
      t = [t; abs(imt_bs_v_fn_gain_actual - imt_bs_v_fn_gain_expected) < 0.5];

      [imt_bs_v_fs_theta, imt_bs_v_fs_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_bs_v_l_p, this.imt_bs_v_l_e, this.imt_bs_v_fs_x_p, this.imt_bs_v_fs_y_p);
      imt_bs_v_fs_gain_actual = bs_p.gain(phi_off_axis, imt_bs_v_fs_theta, phi_scan, theta_scan);
      t = [t; abs(imt_bs_v_fs_gain_actual - imt_bs_v_fs_gain_expected) < 0.5];

      ue_p = PatternERECM2101_0( ...
          this.ue_n_elements_row, ...
          this.ue_n_elements_column, ...
          this.ue_gain_element, ...
          this.ue_phi_3dB, ...
          this.ue_A_m, ...
          this.ue_SLAv, ...
          this.ue_theta_3dB, ...
          this.ue_d_V_lambda, ...
          this.ue_d_H_lambda);

      [imt_ue_h_ml_phi, imt_ue_h_ml_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_ue_h_l_p, this.imt_ue_h_l_e, this.imt_ue_h_ml_x_p, this.imt_ue_h_ml_y_p);
      imt_ue_h_ml_gain_actual = ue_p.gain(imt_ue_h_ml_phi, theta_off_axis, phi_scan, theta_scan);
      t = [t; abs(imt_ue_h_ml_gain_actual - imt_ue_h_ml_gain_expected) < 0.5];

      [imt_ue_h_fn_phi, imt_ue_h_fn_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_ue_h_l_p, this.imt_ue_h_l_e, this.imt_ue_h_fn_x_p, this.imt_ue_h_fn_y_p);
      imt_ue_h_fn_gain_actual = ue_p.gain(imt_ue_h_fn_phi, theta_off_axis, phi_scan, theta_scan);
      t = [t; abs(imt_ue_h_fn_gain_actual - imt_ue_h_fn_gain_expected) < 10.0];

      [imt_ue_h_fs_phi, imt_ue_h_fs_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_ue_h_l_p, this.imt_ue_h_l_e, this.imt_ue_h_fs_x_p, this.imt_ue_h_fs_y_p);
      imt_ue_h_fs_gain_actual = ue_p.gain(imt_ue_h_fs_phi, theta_off_axis, phi_scan, theta_scan);
      t = [t; abs(imt_ue_h_fs_gain_actual - imt_ue_h_fs_gain_expected) < 0.5];

      [imt_ue_v_ml_theta, imt_ue_v_ml_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_ue_v_l_p, this.imt_ue_v_l_e, this.imt_ue_v_ml_x_p, this.imt_ue_v_ml_y_p);
      imt_ue_v_ml_gain_actual = ue_p.gain(phi_off_axis, imt_ue_v_ml_theta, phi_scan, theta_scan);
      t = [t; abs(imt_ue_v_ml_gain_actual - imt_ue_v_ml_gain_expected) < 0.5];

      [imt_ue_v_fn_theta, imt_ue_v_fn_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_ue_v_l_p, this.imt_ue_v_l_e, this.imt_ue_v_fn_x_p, this.imt_ue_v_fn_y_p);
      imt_ue_v_fn_gain_actual = ue_p.gain(phi_off_axis, imt_ue_v_fn_theta, phi_scan, theta_scan);
      t = [t; abs(imt_ue_v_fn_gain_actual - imt_ue_v_fn_gain_expected) < 10.0];

      [imt_ue_v_fs_theta, imt_ue_v_fs_gain_expected] = PatternERECM2101_0Test.convert( ...
          this.imt_ue_v_l_p, this.imt_ue_v_l_e, this.imt_ue_v_fs_x_p, this.imt_ue_v_fs_y_p);
      imt_ue_v_fs_gain_actual = ue_p.gain(phi_off_axis, imt_ue_v_fs_theta, phi_scan, theta_scan);
      t = [t; abs(imt_ue_v_fs_gain_actual - imt_ue_v_fs_gain_expected) < 0.5];

      this.assert_true( ...
          'PatternERECM2101_0', ...
          'gain', ...
          this.ENGINEERING_PRECISION_DESC, ...
          min(t));

      phi_off_axis = [-180:180];
      theta_off_axis = ones(size(phi_off_axis)) * 90;
      phi_scan = zeros(size(phi_off_axis));
      theta_scan = zeros(size(phi_off_axis));
      [A_T, A_A, A_E, fH] = bs_p.gain( ...
          phi_off_axis, theta_off_axis, phi_scan, theta_scan, 'PlotFlag', true);
      pause(1); close(fH);

      theta_off_axis = [0:180];
      phi_off_axis = zeros(size(theta_off_axis));
      phi_scan = zeros(size(theta_off_axis));
      theta_scan = zeros(size(theta_off_axis));
      [A_T, A_A, A_E, fH] = bs_p.gain( ...
          phi_off_axis, theta_off_axis, phi_scan, theta_scan, 'PlotFlag', true);
      pause(1); close(fH);

      phi_off_axis = [-180:180];
      theta_off_axis = ones(size(phi_off_axis)) * 90;
      phi_scan = zeros(size(phi_off_axis));
      theta_scan = zeros(size(phi_off_axis));
      [A_T, A_A, A_E, fH] = ue_p.gain( ...
          phi_off_axis, theta_off_axis, phi_scan, theta_scan, 'PlotFlag', true);
      pause(1); close(fH);

      theta_off_axis = [0:180];
      phi_off_axis = zeros(size(theta_off_axis));
      phi_scan = zeros(size(theta_off_axis));
      theta_scan = zeros(size(theta_off_axis));
      [A_T, A_A, A_E, fH] = ue_p.gain( ...
          phi_off_axis, theta_off_axis, phi_scan, theta_scan, 'PlotFlag', true);
      pause(1); close(fH);

    end % test_gain()

  end % methods

  methods (Static = true)

    function [x_e, y_e] = convert(limits_p, limits_e, x_p, y_p)
    % Converts pixel measurements to engineering measurements.
    %
    % Parameters
    %   limits_p - Pixel limits: [x_min, x_max, y_min, y_max]
    %   limits_e - Engineering limits: [x_min, x_max, y_min, y_max]
    %   x_p - Pixel x
    %   y_p - Pixel y
    %
    % Returns
    %   x_e - Engineering x
    %   y_e - Engineering y
      x_e_1 = limits_e(1);
      x_e_2 = limits_e(2);
      y_e_1 = limits_e(3);
      y_e_2 = limits_e(4);

      x_p_1 = limits_p(1);
      x_p_2 = limits_p(2);
      y_p_1 = limits_p(3);
      y_p_2 = limits_p(4);

      x_e = (x_e_2 - x_e_1) / (x_p_2 - x_p_1) * (x_p - x_p_1) + x_e_1;
      y_e = (y_e_2 - y_e_1) / (y_p_2 - y_p_1) * (y_p - y_p_1) + y_e_1;

    end % convert()

  end % methods (Static = true)

end % classdef
