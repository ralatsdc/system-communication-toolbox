classdef EarthStationInMotion < Station
% Describes an Earth station in motion
  
% Copyright (C) 2021 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % A beam
    beam

    % Flag indicating whether to do multiplexing, or not
    doMultiplexing

    % Date numbers at which the position vector are specified
    dNm_s
    % Geodetic latitudes [rad]
    varphi
    % Longitudes [rad]
    lambda
    % Altitudes [er]
    h

    % Date number at which the rotating position vector occurs
    dNm_r
    % Geocentric equatorial rotating position [er]
    r_ger

    % Date number at which the inertial position vector occurs
    dNm_i
    % Geocentric equatorial inertial position vector [er]
    r_gei
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = EarthStationInMotion(stationId, transmitAntenna, ...
                                         receiveAntenna, emission, beam, ...
                                         doMultiplexing)
      % Constructs an EarthStationInMotion.
      %
      % Parameters
      %   stationId - Identifier for station
      %   transmitAntenna - Antenna gain, and pattern
      %   receiveAntenna - Antenna gain, pattern, and noise
      %     temperature
      %   emission - Signal power, frequency, and requirement
      %   beam - A beam
      %   doMultiplexing - Flag indicating whether to do multiplexing,
      %     or not
      
      % Invoke the superclass constructor
      if nargin == 0
        superArgs = {};
        
      else
        superArgs{1} = stationId;
        superArgs{2} = transmitAntenna;
        superArgs{3} = receiveAntenna;
        superArgs{4} = emission;
        
      end % if
      this@Station(superArgs{:});
      if nargin == 0
        return

      end % if
      
      % Assign properties
      this.set_transmitAntenna(transmitAntenna);
      this.set_receiveAntenna(receiveAntenna);
      this.set_beam(beam);
      this.set_doMultiplexing(doMultiplexing);

    end % EarthStationInMotion()
    
    function that = copy(this)
    % Copies an EarthStationInMotion
    %
    % Returns
    %   that - A new EarthStationInMotion instance
      that = EarthStationInMotion(this.stationId, this.transmitAntenna.copy(), ...
                                  this.receiveAntenna.copy(), this.emission.copy(), ...
                                  this.beam.copy(), this.doMultiplexing);
      that.compute_r_gei(this.dNm_r);

    end % copy()

    function set_transmitAntenna(this, transmitAntenna)
    % Sets the transmit antenna.
    %
    % Parameters
    %   transmitAntenna - Transmit antenna
      if ~isa(transmitAntenna.pattern, 'EarthPattern')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'The transmit antenna must have an Earth pattern');
        throw(MEx);

      end % if
      set_transmitAntenna@Station(this, transmitAntenna);
      
    end % set_transmitAntenna()
    
    function set_receiveAntenna(this, receiveAntenna)
    % Sets the receive antenna.
    %
    % Parameters
    %   receiveAntenna - Receive antenna
      if ~isa(receiveAntenna.pattern, 'EarthPattern')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'The receive antenna must have an Earth pattern');
        throw(MEx);

      end % if
      set_receiveAntenna@Station(this, receiveAntenna);

    end % set_receiveAntenna()

    function set_beam(this, beam)
    % Sets beam.
    %
    % Parameters
    %   beam - A beam
      if ~isa(beam, 'Beam')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be of class "Beam"');
        throw(MEx);

      elseif length(beam) > 1
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'An Earth station must have a single beam');
        throw(MEx);

      elseif beam.multiplicity ~= 1
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'An Earth station beam must have multiplicity one');
        throw(MEx);

      end % if
      this.beam = beam;
      this.beam.assign(this.doMultiplexing);
      
    end % set_beam()
    
    function set_start_waypoint(this, dNm, varphi, lambda, h)
    % Set the way point at the start of the track. Note that standard
    % units for waypoints are used for input, then converted to
    % standard internal units.
    %
    % Parameters
    %   dNm - Date number at which station occupies waypoint
    %   varphi - Geodetic latitude of waypoint [deg]
    %   Lambda - Longitude of waypoint [deg]
    %   h - Altitude of station [ft]
      if ~isnumeric(dNm) || ~isnumeric(varphi) || ~isnumeric(lambda) ...
            || ~isnumeric(h)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Waypoint components must be numeric');
        throw(MEx);

      elseif length(dNm) ~= length(varphi) || length(dNm) ~= length(lambda) ...
            || length(dNm) ~= length(h)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Waypoint components must have the same length');
        throw(MEx);

      elseif length(dNm) ~= 1
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Waypoint components must have length one');
        throw(MEx);

      end % if
      
      % Convert to standard internal units
      this.dNm_s = dNm;
      this.varphi = varphi * pi / 180;  % [rad] = [deg] * [rad/deg]
      this.lambda = lambda * pi / 180;  % [rad] = [deg] * [rad/deg]
      this.h = h / 3280.84 / EarthConstants.R_oplus;  % [er] = [ft] / [ft/km] / [km/er]

    end % set_start_point()

    function add_stop_waypoint(this, speed, varphi, lambda, h, varargin);
    % Adds a waypoint at the end of the track. Note that standard
    % units for waypoints are used, then converted to standard
    % internal units.
    %
    % Parameters
    %   speed - Speed of station [nm/hr]
    %   varphi - Geodetic latitude of waypoint [deg]
    %   lambda - Longitude of waypoint [deg]
    %   h - Altitude of station [ft]
    %   resolution - Resolution of the track [km]
      if isempty(this.dNm_s)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Must set start waypoint before adding a waypoint');
        throw(MEx);

      elseif ~isnumeric(speed) || ~isnumeric(varphi) || ~isnumeric(lambda) ...
            || ~isnumeric(h)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Waypoint components must be numeric');
        throw(MEx);

      elseif length(speed) ~= length(varphi) || length(speed) ~= length(lambda) ...
            || length(speed) ~= length(h)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Waypoint components must have the same length');
        throw(MEx);

      elseif length(speed) ~= 1
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Waypoint components must have length one');
        throw(MEx);

      end % if
      if nargin == 6
        resolution = varargin{1};
        if ~isnumeric(resolution)
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Resolution must be numeric');
          throw(MEx);

        end % if
      else
        resolution = 1;

      end % if
      
      % Convert to standard internal units
      speed = speed * 1.852 / 3600;  % [km/s] = [nm/hr] * [km/nm] / [s/hr]
      varphi = varphi * pi / 180;  % [rad] = [deg] * [rad/deg]
      lambda = lambda * pi / 180;  % [rad] = [deg] * [rad/deg]
      h = h / 3280.84 / EarthConstants.R_oplus;  % [er] = [ft] / [ft/km] / [km/er]

      % Define a WGS84 oblate spheroid at altitude
      ellipsoid = oblateSpheroid;
      ellipsoid.InverseFlattening = 1 / EarthConstants.f;
      ellipsoid.SemimajorAxis = (1 + (this.h(end) + h) / 2) * EarthConstants.R_oplus;

      % Compute arc length of geodesic in units used to define
      % ellipsoid [km]
      units = 'radians';
      [arclen, azm] = distance( ...
          this.varphi(end), this.lambda(end), varphi, lambda, ellipsoid, units);

      % Compute date number at which station occupies new ending
      % waypoint
      dNm = this.dNm_s(end) + arclen / speed / 86400;  % [day] = [day] + [km] / [km/s] / [s/day]

      % Compute date number and waypoint components every kilometer
      nPts = ceil(arclen / resolution);
      dNm = interp1([1, nPts], [this.dNm_s(end), dNm], [1:nPts]');
      [varphi, lambda] = track2( ...
          this.varphi(end), this.lambda(end), varphi, lambda, ellipsoid, units, nPts);
      h = interp1([1, nPts], [this.h(end), h], [1:nPts]');

      % Append waypoint components, removing the old ending waypoint,
      % since it is included with the new values
      this.dNm_s(end) = [];
      this.varphi(end) = [];
      this.lambda(end) = [];
      this.h(end) = [];
      this.dNm_s = [this.dNm_s, dNm];
      this.varphi = [this.varphi, varphi];
      this.lambda = [this.lambda, lambda];
      this.h = [this.h, h];

    end % add_stop_point()

    function set_dNm_s(this, dNm_s)
    % Set date numbers at which the position vector are specified.
    %
    % Parameters
    %   dNm_s - Date numbers at which the position vector are specified
      this.dNm_s = dNm_s;

    end % set_dNm_s()

    function set_varphi(this, varphi)
    % Sets geodetic latitudes.
    %
    % Parameters
    %   varphi - Geodetic latitudes [rad]
      this.varphi = varphi;

    end % set_varphi()

    function set_lambda(this, lambda)
    % Sets longitudes.
    %
    % Parameters
    %   lambda - Longitudes [rad]
      this.lambda = lambda;
      
    end % set_lambda()
    
    function set_h(this, h)
    % Set altitudes.
    %
    % Parameters
    %   h - Altitudes [er]
      this.h = h;

    end % set_h()

    function set_doMultiplexing(this, doMultiplexing)
    % Sets flag indicating whether to do multiplexing, or not.
    %
    % Parameters
    %   doMultiplexing - Flag indicating whether to do
    %     multiplexing, or not.
      this.doMultiplexing = TypeUtility.set_logical(doMultiplexing);

    end % if

    function r_ger = compute_r_ger(this, dNm)
    % Computes geocentric equatorial rotating position vector
    % [er]. (MG-5.83)
    %
    % Parameters
    %   dNm - Date number at which the position vector occurs
    %
    % Returns
    %   r_ger - Geocentric equatorial rotating position vector [er]
      if isempty(this.dNm_s) || isempty(this.lambda) || isempty(this.varphi) ...
            || isempty(this.h)
        r_ger = [];
        return
        
      end % if
      if ~isequal(dNm, this.dNm_r)
        this.dNm_r = dNm;

        % Linearly interpolate specified position
        varphi = interp1(this.dNm_s, this.varphi, dNm);
        lambda = interp1(this.dNm_s, this.lambda, dNm);
        h = interp1(this.dNm_s, this.h, dNm);
        r_glla = [varphi; ...
                  lambda; ...
                  h];

        % Compute corresponding rotating position vector
        this.r_ger = Coordinates.glla2ger(r_glla);

      end % if
      r_ger = this.r_ger;
      
    end % compute_r_ger()

    function r_gei = compute_r_gei(this, dNm)
    % Computes geocentric equatorial inertial position vector.
    %
    % Parameters
    %   dNm - Date number at which the position vector occurs
    %
    % Returns
    %   r_gei - Geocentric equatorial inertial position vector [er]
      if ~isequal(dNm, this.dNm_i)
        this.dNm_i = dNm;
        this.r_gei = Coordinates.ger2gei(this.compute_r_ger(dNm), dNm);

      end % if
      r_gei = this.r_gei;

    end % compute_r_gei()

  end % methods

end % classdef
