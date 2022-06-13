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
% TODO: Add altitude
classdef EarthStation < Station
% Describes an Earth station
  
  properties (SetAccess = private, GetAccess = public)
    
    % A beam
    beam

    % Geodetic latitude [rad]
    varphi
    % Longitude [rad]
    lambda
    % Altitude [er]
    h

    % Flag indicating whether to do multiplexing, or not
    doMultiplexing
    
    % Geocentric equatorial rotating position [er]
    r_ger

    % Date number at which the position vector occurs
    dNm
    % Geocentric equatorial inertial position vector [er]
    r_gei
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = EarthStation(stationId, transmitAntenna, ...
                                 receiveAntenna, emission, beam, ...
                                 varphi, lambda, doMultiplexing)
      % Constructs an EarthStation.
      %
      % Parameters
      %   stationId - Identifier for station
      %   transmitAntenna - Antenna gain, and pattern
      %   receiveAntenna - Antenna gain, pattern, and noise
      %     temperature
      %   emission - Signal power, frequency, and requirement
      %   beam - A beam
      %   varphi - Geodetic latitude [rad]
      %   lambda - Longitude [rad]
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
      this.set_varphi(varphi);
      this.set_lambda(lambda);
      this.set_h(0.0);
      this.set_doMultiplexing(doMultiplexing)
      
    end % EarthStation()
    
    function that = copy(this)
    % Copies an EarthStation.
    %
    % Returns
    %   that - A new EarthStation instance
      that = EarthStation(this.stationId, this.transmitAntenna.copy(), ...
                          this.receiveAntenna.copy(), this.emission.copy(), ...
                          this.beam.copy(), this.varphi, this.lambda, ...
                          this.doMultiplexing);
      that.set_h(this.h);
      that.compute_r_gei(this.dNm);

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
    
    function set_varphi(this, varphi)
    % Sets geodetic latitude [rad].
    % 
    % Parameters
    %   varphi - The geodetic latitude [rad]
      this.varphi = TypeUtility.set_numeric(varphi);
      this.compute_r_ger();
      
    end % set_varphi()
    
    function set_lambda(this, lambda)
    % Sets longitude [rad]
    % 
    % Parameters
    %   lambda - The longitude [rad]
      this.lambda = TypeUtility.set_numeric(lambda);
      this.compute_r_ger();

    end % set_lambda()

    function set_h(this, h)
    % Sets altitude [er].
    % 
    % Parameters
    %   h - The altitude [er]
      this.h = TypeUtility.set_numeric(h);
      this.compute_r_ger();

    end % set_lambda()

    function set_doMultiplexing(this, doMultiplexing)
    % Sets flag indicating whether to do multiplexing, or not.
    %
    % Parameters
    %   doMultiplexing - Flag indicating whether to do
    %     multiplexing, or not.
      this.doMultiplexing = TypeUtility.set_logical(doMultiplexing);

    end % if

    function r_ger = compute_r_ger(this, varargin)
    % Computes the geocentric equatorial rotating position
    % vector [er]. (MG-5.83)
      if isempty(this.varphi) || isempty(this.lambda) || isempty(this.h)
        return

      end % if
      if nargin == 1
        r_glla = [this.varphi; ...
                  this.lambda; ...
                  this.h];
        this.r_ger = Coordinates.glla2ger(r_glla);
      else
        % Anticipate being called with an additional date number
        % argument for consistency with the EarthStationInMotion and
        % SpaceStation classes. If so, the geocentric equatorial
        % rotating position vector will have been computed during
        % construction.
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
      if ~isequal(dNm, this.dNm)
        this.dNm = dNm;
        this.r_gei = Coordinates.ger2gei(this.r_ger, dNm);

      end % if
      r_gei = this.r_gei;

    end % compute_r_gei()

  end % methods
  
end % classdef
