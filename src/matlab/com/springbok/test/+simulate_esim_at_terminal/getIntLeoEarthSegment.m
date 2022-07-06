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
function earthStations = getIntLeoEarthSegment(d_terminal, baseStation)
% Defines the interfering LEO Earth stations in motion.
%
% Parameters
%   d_terminal - Distance North from base station to terminal [km]
%   baseStation - The base station of the wanted terrestrial network
%
% Returns
%   earthStations - The Earth stations of the interfering LEO system

  % = Interfering system

  % == Earth stations

  % === Transmit pattern

  % Maximum antenna gain [dB]
  GainMax = 37.6;

  % Transmit Earth pattern
  pattern = PatternERR_001V01(GainMax);

  % === Transmit antenna

  % Antenna name
  name = 'NGSO ESIM Tx';
  % Antenna gain
  gain = GainMax;
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

  % === Emission

  % Emission designator
  design_emi = '---';
  % Maximum power density
  pwr_ds_max = -70.1;
  % Minimum power density
  pwr_ds_min = -70.1;
  % Center frequency
  freq_mhz = 27925;
  % Required C/N
  c_to_n = NaN;

  emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);

  % === Beam

  beam = Beam('IntLeoEarthSegment', 1, 100);

  % === Receive pattern

  % Maximum antenna gain [dB]
  GainMax = 37.6;

  % Receive Earth pattern
  pattern = PatternERR_001V01(GainMax);

  % === Receive antenna

  % Antenna name
  name = 'NGSO ESIM Rx';
  % Antenna gain
  gain = GainMax;
  % Antenna pattern identifier
  pattern_id = 1;
  % Antenna feeder loss
  feeder_loss = 0;

  % Receive Earth station antenna
  receiveAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
  receiveAntenna.set_feeder_loss(feeder_loss);

  % Gain function options
  options = {'DoValidate', false};
  receiveAntenna.set_options(options);

  % == Earth stations

  earthStations = [];

  stationId = 'interfering earth station';  % Identifier for station
  doMultiplexing = 0;  % Flag indicating whether to do multiplexing, or not

  esim = EarthStationInMotion( ...
      stationId, transmitAntenna, receiveAntenna, emission, beam, doMultiplexing);

  % Delta latitude
  delta_varphi = (d_terminal / EarthConstants.R_oplus);  % [rad]

  % Delta longitude
  delta_lambda = 0.0;  % [rad]

  % ESIM track
  dNm_s = [datenum('27-Jul-2020'), datenum('27-Jul-2020 00:16:12')];
  varphi_start = baseStation.varphi + delta_varphi;  % [rad]
  varphi = [varphi_start, varphi_start];
  lambda_start = baseStation.lambda + delta_lambda;  % [rad]
  lambda = [lambda_start, lambda_start];
  % TODO: Huh?
  h_start = baseStation.h * 1.1;  % [km]
  h = [h_start, h_start];
  esim.set_dNm_s(dNm_s);
  esim.set_varphi(varphi);
  esim.set_lambda(lambda);
  esim.set_h(h);

  earthStations = [earthStations; esim];

end % getIntLeoEarthSegment()
