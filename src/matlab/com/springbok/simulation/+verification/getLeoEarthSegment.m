% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function earthStation = getLeoEarthSegment(cells, epoch_0)

  % == Earth station
    
  % === Transmit pattern
    
  % Maximum antenna gain [dB]
  GainMax = 54;
  % Antenna efficiency, fraction
  Efficiency = 0.7;
    
  % Transmit Earth pattern
  pattern = PatternEREC013V01(GainMax, Efficiency);
    
  % === Transmit antenna
    
  % Antenna name
  name = 'NGSO ES Tx';
  % Antenna gain
  gain = GainMax;
  % Antenna pattern identifier
  pattern_id = 1;
    
  % Transmit Earth station antenna
  transmitAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
    
  % Gain function options
  options = {'DoValidate', false};
  transmitAntenna.set_options(options);

  % === Emission
    
  % Emission designator
  design_emi = '1K20G1D--';
  % Maximum power density
  pwr_ds_max = -74;
  % Minimum power density
  pwr_ds_min = NaN;
  % Center frequency
  freq_mhz = 13000;
  % Required C/N
  c_to_n = NaN;
    
  emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);
    
  % === Beam
      
  beam = Beam('NGSO ES', 1, 100);
      
  % === Receive pattern
    
  % Maximum antenna gain [dB]
  GainMax = 27;
  % Antenna efficiency, fraction
  Efficiency = 0.7;
    
  % Receive Earth pattern
  pattern = PatternEREC013V01(GainMax, Efficiency);
    
  % === Receive antenna
    
  % Antenna name
  name = 'NGSO ES Rx';
  % Antenna gain
  gain = GainMax;
  % Antenna feeder loss
  feeder_loss = 0;
  % Antenna noise temperature
  noise_t = 440;
  % Antenna pattern identifier
  pattern_id = 1;
    
  % Receive Earth station antenna
  receiveAntenna = EarthStationAntenna(name, gain, pattern_id, pattern);
  receiveAntenna.set_feeder_loss(feeder_loss);
  receiveAntenna.set_noise_t(noise_t);
    
  % Gain function options
  options = {'DoValidate', false};
  receiveAntenna.set_options(options);

  % == Earth station

  lambda = 2 * pi - Coordinates.check_wrap(EarthConstants.Theta(epoch_0));
  [delta_min, cell_idx] = min(cells.varphi.^2 + (cells.lambda - lambda).^2);

  stationId = 'NGSO ES'; % Identifier for station
  varphi = cells.varphi(cell_idx); % Geodetic latitude [rad]
  lambda = cells.lambda(cell_idx); % Longitude [rad]
  doMultiplexing = 0; % Flag indicating whether to do multiplexing, or not

  earthStation = EarthStation( ...
      stationId, transmitAntenna, receiveAntenna, emission, beam, ...
      varphi, lambda, doMultiplexing);

end % getLeoEarthSegment()
