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
classdef SpaceStation < Station
% Describes a space station
  
  properties (SetAccess = private, GetAccess = public)

    % Beam array
    beams

    % A satellite orbit
    orbit

    % Date number at which the inertial position vector occurs
    dNm_i
    % Geocentric equatorial inertial position vector [er]
    r_gei

    % Date number at which the rotating position vector occurs
    dNm_r
    % Geocentric equatorial rotating position vector [er]
    r_ger

     % Flag indicating if the station is available, or not
    isAvailable

 end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = SpaceStation(stationId, transmitAntenna, ...
                                 receiveAntenna, emission, beams, ...
                                 orbit)
    % Constructs a SpaceStation.
    %
    % Parameters
    %   stationId - Identifier for station
    %   transmitAntenna - Transmit antenna gain, and pattern
    %   receiveAntenna - Receive antenna gain, pattern, and noise temperature
    %   emission - Signal power, frequency, and requirement
    %   beams - Beam array
    %   orbit - A satellite orbit
      
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
      this.set_beams(beams);
      this.set_orbit(orbit);

      % Derive properties
      this.isAvailable = 1;
      
    end % SpaceStation()
    
    function that = copy(this)
    % Constructs a SpaceStation.
    %
    % Returns
    %   that - A new SpaceStation instance
      nBm = length(this.beams);
      for iBm = 1:nBm
        beams(iBm) = this.beams(iBm).copy();
        
      end % for
      that = SpaceStation(this.stationId, this.transmitAntenna.copy(), ...
                          this.receiveAntenna.copy(), this.emission.copy(), ...
                          beams, this.orbit.copy());
      that.set_isAvailable(this.isAvailable);
      that.compute_r_ger(this.dNm_r);

    end % copy()

    function set_transmitAntenna(this, transmitAntenna)
    % Sets the transmit antenna.
    %
    % Parameters
    %   transmitAntenna - Transmit antenna
      if ~isa(transmitAntenna.pattern, 'SpacePattern')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'The transmit antenna must have an Space pattern');
        throw(MEx);

      end % if
      set_transmitAntenna@Station(this, transmitAntenna);
      
    end % set_transmitAntenna()
    
    function set_receiveAntenna(this, receiveAntenna)
    % Sets the receive antenna.
    %
    % Parameters
    %   receiveAntenna - Receive antenna
      if ~isa(receiveAntenna.pattern, 'SpacePattern')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'The receive antenna must have an Space pattern');
        throw(MEx);

      end % if
      set_receiveAntenna@Station(this, receiveAntenna);
      
    end % set_receiveAntenna()

    function set_beams(this, beams)
    % Sets beam array.
    %
    % Parameters
    %   beams - Beam array
      if ~isa(beams, 'Beam')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be of class "Beam"');
        throw(MEx);

      end % if
      this.beams = beams;

    end % set_beams()

    function set_orbit(this, orbit)
    % Set the satellite orbit
    %
    % Parameters
    %   orbit - The satellite orbit
      if ~isa(orbit, 'Orbit')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be an instance of class "Orbit"');
        throw(MEx);

      end % if
      this.orbit = orbit;

    end % if

    function set_isAvailable(this, isAvailable)
    % Sets flag indicating if the station is available, or not.
    %
    % Parameters
    %   isAvailable - Flag indicating if the station is available,
    %     or not
      if ~ismember(isAvailable, [0, 1])
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be zero or one');
        throw(MEx);

      end % if
      this.isAvailable = isAvailable;

    end % set_isAvailable()

    function beam = assign(this, doMultiplexing)
    % Assign this station by assigning the first available beam.
    %
    % Parameters
    %   doMultiplexing - Flag indicating whether to do
    %     multiplexing, or not
    %
    % Returns
    %   beam - The assigned beam, or an empty array, if no beam
    %     assigned

      beam = [];
      if ~this.isAvailable

        % Unavailable
        
      else

        % Consider each beam
        nBm = length(this.beams);
        for iBm = 1:nBm

          % Assign the first available beam
          isAsigned = this.beams(iBm).assign(doMultiplexing);
          if isAsigned
            beam = this.beams(iBm);

            % This station remains available as long as it's last
            % beam remains available
            this.isAvailable = this.beams(nBm).isAvailable;
            break

          end % if
          
        end % for

      end % if
      
    end % assign()

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
        this.r_gei = this.orbit.r_gei(dNm);
        
      end % if
      r_gei = this.r_gei;

    end % compute_r_gei()

    function r_ger = compute_r_ger(this, dNm)
    % Computes the geocentric equatorial rotating position vector.
    %
    % Parameters
    %   dNm - Date number at which the position vector occurs
    %
    % Returns
    %   r_ger - Geocentric equatorial rotating position vector [er]
      if ~isequal(dNm, this.dNm_r)
        this.dNm_r = dNm;
        this.r_ger = Coordinates.gei2ger(this.compute_r_gei(dNm), dNm);
        
      end % if
      r_ger = this.r_ger;

    end % compute_r_ger()

    function reset(this)
    % Reset derived properties of associated beams and this to
    % initial values.
      nBm = length(this.beams);
      for iBm = 1:nBm
        this.beams(iBm).reset();

      end % for

      this.dNm_i = [];
      this.r_gei = [];
      this.dNm_r = [];
      this.r_ger = [];
      this.isAvailable = 1;

    end % reset()

  end % methods
  
end % classdef
