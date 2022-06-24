% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function spaceStation = getLeoSpaceSegment(orbits)

  % == Space stations
    
  % === Transmit pattern
    
  % Maximum antenna gain [dB]
  GainMax = 27;
  % Cross-sectional half-power beamwidth, degrees
  Phi0 = 6.9;
    
  % Transmit space pattern
  pattern = PatternSREC408V01(Phi0);
    
  % === Transmit antenna
    
  % Antenna name
  name = 'NGSO SS Tx';
  % Antenna gain
  gain = GainMax;
  % Antenna pattern identifier
  pattern_id = 1;
    
  % Transmit space station antenna
  transmitAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);
    
  % Gain function options
  options = {'GainMax', GainMax, 'DoValidate', false};
  transmitAntenna.set_options(options);
    
  % === Emission
    
  % Emission designator
  design_emi = '1K20G1D--';
  % Maximum power density
  pwr_ds_max = -73;
  % Minimum power density
  pwr_ds_min = NaN;
  % Center frequency
  freq_mhz = 11200;
  % Required C/N
  c_to_n = NaN;
    
  emission = Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n);
    
  % === Beams
  
  beams = Beam('NGSO SS', 1, 100);
  
  % === Receive pattern
    
  % Maximum antenna gain [dB]
  GainMax = 30;
  % Cross-sectional half-power beamwidth, degrees
  Phi0 = 5.3;
    
  % Receive space pattern
  pattern = PatternSREC408V01(Phi0);
    
  % === Receive antenna
    
  % Antenna name
  name = 'NGSO SS Rx';
  % Antenna gain
  gain = GainMax;
  % Antenna feeder loss
  feeder_loss = 0;
  % Antenna noise temperature
  noise_t = 600;
  % Antenna pattern identifier
  pattern_id = 1;
    
  % Receive space station antenna
  receiveAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);
  receiveAntenna.set_feeder_loss(feeder_loss);
  receiveAntenna.set_noise_t(noise_t);
    
  % Gain function options
  options = {'GainMax', GainMax, 'DoValidate', false};
  receiveAntenna.set_options(options);
    
  % == Space stations
    
  stationId = 'NGSO SS'; % Identifier for station

  iPln = 1;
  iSat = 1;

  spaceStation = SpaceStation( ...
      stationId, transmitAntenna, receiveAntenna, emission, beams, ...
      orbits(iPln, iSat));

end % getLeoSpaceSegment()
