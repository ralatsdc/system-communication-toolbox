% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function spaceStations = getIntLeoSpaceSegment(epoch_0)
  
  % = Interfering system
  
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
  
  stationId = 'interfering';                     % Identifier for station
  a         = 1 + 1500 / EarthConstants.R_oplus; % Semi-major axis [er]
  e         = 0.001;                             % Eccentricity [-]
  i         = 80.0 * pi / 180;                   % Inclination [rad]
  Omega     = 30.0 * pi / 180;                   % Right ascension of the ascending node [rad]
  omega     = 60.0 * pi / 180;                   % Argument of perigee [rad]
  M         = 130.0 * pi / 180;                  % Mean anomaly [rad]
  epoch     = epoch_0;                           % Epoch date number
  method    = 'halley';                          % Method to solve Kepler's equation: 'newton' or 'halley'
  
  nBeams = 4;
  spaceStations = [];
  d_Omega = 360 / 30;
  d_M = 360 / 30;
  for delta_Omega = [0 : d_Omega : 360 - d_Omega] * (pi / 180)
    for delta_M = [0 : d_M : 360 - d_M] * (pi / 180)

      % === Beam
  
      for iBeam = 1:nBeams
        beams(iBeam) = Beam('IntLeoSpaceSegment', 1, 100);

      end % for

      % == Space stations

      spaceStations = [spaceStations; SpaceStation( ...
          stationId, transmitAntenna, receiveAntenna, emission, beams, ...
          KeplerianOrbit(a, e, i, Omega + delta_Omega, omega, M + delta_M, epoch, method))];
      
    end % for
    
  end % for

end % getLeoSpaceSegment()
