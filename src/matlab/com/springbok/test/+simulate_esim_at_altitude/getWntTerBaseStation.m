% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function baseStation = getWntTerBaseStation()
% Defines the wanted base station of the terrestrial network.
%
% Returns
%   baseStation - The wanted base station of the terrestrial network

  % = Wanted system

  % == Earth station

  % === Transmit pattern

  %  Number of array elements in a row
  n_elements_row = 16;
  %  Number of array elements in a column
  n_elements_column = 16;
  %  Element gain
  gain_element = 5.0;
  %  Element horizontal 3 dB beamwidth
  phi_3dB = 80.0;
  %  Element front-to-back ratio
  A_m = 30.0;
  %  Element vertical sidelobe attenuation
  SLAv = 30.0;
  %  Element vertical 3 dB beamwidth
  theta_3dB = 65.0;
  %  Array vertical element spacing
  d_V_lambda = 0.5;
  %  Array horizontal element spacing
  d_H_lambda = 0.5;

  % Transmit Earth pattern
  pattern = PatternERECM2101_0( ...
      n_elements_row, n_elements_column, ...
      gain_element, phi_3dB, A_m, SLAv, theta_3dB, ...
      d_V_lambda, d_H_lambda);

  % === Transmit antenna

  % Antenna name
  name = 'Ter BS Tx';
  % Antenna gain
  gain = 10 * log10(n_elements_row * n_elements_column) + gain_element;
  % Antenna pattern identifier
  pattern_id = 1;
  % Antenna feeder loss
  feeder_loss = 0;

  % Transmit Earth station antenna
  transmitAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
  transmitAntenna.set_feeder_loss(feeder_loss);

  % Gain function options
  options = {'DoValidate', false};
  transmitAntenna.set_options(options);

  % Set pointing and orientation
  transmitAntenna.set_x_ltp([0; 1; 0]);  % North
  transmitAntenna.set_z_ltp([0; 0; 1]);  % Zenith
  
  % === Emission

  % Emission designator
  design_emi = '---';
  % Maximum power density
  pwr_ds_max = NaN;
  % Minimum power density
  pwr_ds_min = NaN;
  % Center frequency
  freq_mhz = 27925;
  % Required C/N
  c_to_n = NaN;

  emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);

  % === Beam

  beam = Beam('WntTerBaseStation', 1, 100);

  % === Receive pattern

  %  Number of array elements in a row
  n_elements_row = 16;
  %  Number of array elements in a column
  n_elements_column = 16;
  %  Element gain
  gain_element = 5.0;
  %  Element horizontal 3 dB beamwidth
  phi_3dB = 80.0;
  %  Element front-to-back ratio
  A_m = 30.0;
  %  Element vertical sidelobe attenuation
  SLAv = 30.0;
  %  Element vertical 3 dB beamwidth
  theta_3dB = 65.0;
  %  Array vertical element spacing
  d_V_lambda = 0.5;
  %  Array horizontal element spacing
  d_H_lambda = 0.5;

  % Receive Earth pattern
  pattern = PatternERECM2101_0( ...
      n_elements_row, n_elements_column, ...
      gain_element, phi_3dB, A_m, SLAv, theta_3dB, ...
      d_V_lambda, d_H_lambda);

  % === Receive antenna

  % Antenna name
  name = 'Ter BS Rx';
  % Antenna gain
  gain = 10 * log10(n_elements_row * n_elements_column) + gain_element;
  % Antenna pattern identifier
  pattern_id = 1;
  % Antenna feeder loss
  feeder_loss = 0;
  % Antenna noise temperature
  noise_figure = 6.5;
  receiver_noise_temp = 290 * (10 ^ (noise_figure / 10) - 1);
  antenna_noise_temp = 290;
  noise_t = receiver_noise_temp + antenna_noise_temp;

  % Receive Earth station antenna
  receiveAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
  receiveAntenna.set_feeder_loss(feeder_loss);
  receiveAntenna.set_noise_t(noise_t);

  % Gain function options
  options = {'DoValidate', false};
  receiveAntenna.set_options(options);

  % Set pointing and orientation
  receiveAntenna.set_x_ltp([0; 1; 0]);  % North
  receiveAntenna.set_z_ltp([0; 0; 1]);  % Zenith

  % == Earth station

  stationId = 'wanted base station'; % Identifier for station
  varphi = +20.0 * (pi / 180);  % [rad] = [deg] * [rad/deg]
  lambda = -100.0 * (pi / 180);  % [rad] = [deg] * [rad/deg]
  h = 20 / 1000 / EarthConstants.R_oplus;  % [er] = [m] / [m/km] / [km/er]
  doMultiplexing = 0;  % Flag indicating whether to do multiplexing, or not
  baseStation = EarthStation( ...
      stationId, transmitAntenna, receiveAntenna, emission, beam, ...
      varphi, lambda, doMultiplexing);
  baseStation.set_h(h);

end % getWntTerBaseStation()
