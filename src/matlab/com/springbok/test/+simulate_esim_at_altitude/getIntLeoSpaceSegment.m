% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function spaceStations = getIntLeoSpaceSegment(epoch_0)
% Defines the interfering LEO space segments.
%
% Parameters
%   epoch_0 - The epoch of the space station orbits
%
% Returns
%   spaceStations - The space stations of the interfering LEO system

  % = Interfering system

  % == Space stations

  % === Transmit pattern

  % Maximum antenna gain [dB]
  GainMax = NaN;
  % Cross-sectional half-power beamwidth, degrees
  Phi0 = NaN;
  
  % Transmit space pattern
  pattern = PatternSREC408V01(Phi0);
  
  % === Transmit antenna
  
  % Antenna name
  name = 'NGSO SS Tx';
  % Antenna gain
  gain = GainMax;
  % Antenna pattern identifier
  pattern_id = 1;
  % Antenna feeder loss
  feeder_loss = 0;
  
  % Transmit space station antenna
  transmitAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);
  transmitAntenna.set_feeder_loss(feeder_loss);
  
  % Gain function options
  options = {'GainMax', GainMax, 'DoValidate', false};
  transmitAntenna.set_options(options);
  
  % === Emission
  
  % Emission designator
  design_emi = '---';
  % Maximum power density
  pwr_ds_max = -73;
  % Minimum power density
  pwr_ds_min = NaN;
  % Center frequency
  freq_mhz = 27925;
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
  % Antenna pattern identifier
  pattern_id = 1;
  % Antenna feeder loss
  feeder_loss = 0;
  
  % Receive space station antenna
  receiveAntenna = SpaceStationAntenna(name, gain, pattern_id, pattern);
  receiveAntenna.set_feeder_loss(feeder_loss);
  
  % Gain function options
  options = {'GainMax', GainMax, 'DoValidate', false};
  receiveAntenna.set_options(options);
  
  % == Space stations
  
  spaceStations = [];

  stationId = 'interfering space station';  % Identifier for station

  % Orbit 1
  a         = 1 + 630 / EarthConstants.R_oplus;  % Semi-major axis [er]
  e         = 0.001;  % Eccentricity [-]
  i         = 51.9 * pi / 180;  % Inclination [rad]
  Omega     = 30.0 * pi / 180;  % Right ascension of the ascending node [rad]
  omega     = 60.0 * pi / 180;  % Argument of perigee [rad]
  M         = 130.0 * pi / 180;  % Mean anomaly [rad]
  epoch     = epoch_0;  % Epoch date number
  method    = 'halley';  % Method to solve Kepler's equation: 'newton' or 'halley'
  
  nBeams = 1;
  d_Omega = 360 / 34;
  d_M = 360 / 34;
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

  % Orbit 2
  a         = 1 + 610 / EarthConstants.R_oplus;  % Semi-major axis [er]
  e         = 0.001;  % Eccentricity [-]
  i         = 42.0 * pi / 180;  % Inclination [rad]
  Omega     = 33.0 * pi / 180;  % Right ascension of the ascending node [rad]
  omega     = 60.0 * pi / 180;  % Argument of perigee [rad]
  M         = 130.0 * pi / 180;  % Mean anomaly [rad]
  epoch     = epoch_0;  % Epoch date number
  method    = 'halley';  % Method to solve Kepler's equation: 'newton' or 'halley'
  
  nBeams = 1;
  d_Omega = 360 / 36;
  d_M = 360 / 36;
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

  % Orbit 3
  a         = 1 + 590 / EarthConstants.R_oplus;  % Semi-major axis [er]
  e         = 0.001;  % Eccentricity [-]
  i         = 33.0 * pi / 180;  % Inclination [rad]
  Omega     = 36.0 * pi / 180;  % Right ascension of the ascending node [rad]
  omega     = 60.0 * pi / 180;  % Argument of perigee [rad]
  M         = 130.0 * pi / 180;  % Mean anomaly [rad]
  epoch     = epoch_0;  % Epoch date number
  method    = 'halley';  % Method to solve Kepler's equation: 'newton' or 'halley'
  
  nBeams = 1;
  d_Omega = 360 / 28;
  d_M = 360 / 28;
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
