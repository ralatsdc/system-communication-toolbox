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
classdef Sgp4Orbit < Orbit
% Describes an orbit using S1S2 elements by computing position
% relative to the Earth center using the SGP4 propagator.
  
  properties (SetAccess = private, GetAccess = public)
    
    % Semi-major axis [er]
    a
    % Eccentricity [-]
    e
    % Inclination [rad]
    i
    % Right ascension of the ascending node [rad]
    Omega
    % Argument of perigee [rad]
    omega
    % Mean anomaly [rad]
    M
    % Epoch date number
    epoch
    
    % Method to solve Kepler's equation: 'newton' or 'halley'
    method = 'halley';
    
    % Mean motion [rad/s]
    n
    % Orbital period [s]
    T
    % SGP4 element set record        
    satrec
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = Sgp4Orbit(a, e, i, Omega, omega, M, epoch, method)
    % Constructs an Sgp4Orbit given Keplerian elements.
    %
    % Parameters
    %   a - Semi-major axis [er]
    %   e - Eccentricity [-]
    %   i - Inclination [rad]
    %   Omega - Right ascension of the ascending node [rad]
    %   omega - Argument of perigee [rad]
    %   M - Mean anomaly [rad]
    %   epoch - Epoch date number
    %   method - Not used. Included for compatibility to
    %     KeplerianOrbit class

    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Assign properties. Set numeric properties directly since
      % setters have side effects.
      this.a = TypeUtility.set_numeric(a);
      this.e = TypeUtility.set_numeric(e);
      this.i = TypeUtility.set_numeric(i);
      this.Omega = TypeUtility.set_numeric(Omega);
      this.omega = TypeUtility.set_numeric(omega);
      this.M = TypeUtility.set_numeric(M);
      this.epoch = TypeUtility.set_numeric(epoch);
      
      this.set_method(method);
      
      % Compute derived properties
      this.n = meanMotion(this);
      this.T = orbitalPeriod(this);
      this.satrec = satelliteRecord(this);
      
    end % Sgp4Orbit()
    
    function that = copy(this)
    % Copies an Sgp4Orbit given Keplerian elements.
    %
    % Returns
    %   that - A new Sgp4Orbit instance
      that = Sgp4Orbit(this.a, this.e, this.i, this.Omega, this.omega, ...
                       this.M, this.epoch, this.method);

    end % copy()

    function n = meanMotion(this)
    % Computes mean motion (MG-2.35).
    %
    % Returns
    %   n - Mean motion [rad/s]
      n = sqrt(EarthConstants.GM_oplus ...
               ./ (EarthConstants.R_oplus * this.a).^3);
      % [rad/s] = [ [km^3/s^2] / [ [km/er] * [er] ]^3 ]^(1/2)
      
    end % meanMotion()
    
    function M = meanPosition(this, dNm)
    % Computes the mean anomaly at the given date.
    %
    % Parameters
    %   dNm - Date number at which mean anomaly occurs
    %
    % Returns
    %   M - Mean anomaly [rad]
      M = Coordinates.check_wrap(this.M + this.n * (dNm - this.epoch) * (24 * 60 * 60));
      % [rad] = [rad] + [rad/s] * [decimal day] * [s/day]
      
    end % meanPosition()
    
    function T = orbitalPeriod(this)
    % Computes orbital period.
    %
    % Returns
    %   T - Orbital period [s]
      T = (2 * pi) * sqrt((EarthConstants.R_oplus * this.a).^3 ...
                          / EarthConstants.GM_oplus);
      % [s/rev] = [rad/rev] * sqrt(([km] * [-])^3 / [km^3/s^2])
      
    end % orbitalPeriod()
    
    function satrec = satelliteRecord(this)
    % Initializes the SGP4 element set record.
    %
    % Returns
    %   satrec - SGP4 element set record        
      whichconst = 84;           % WGS-84
      satrec = struct();
      satrec.satnum = 0;         % Object number
      satrec.bstar = 0;          % SGP4 type drag coefficient [kg/m2er]
      satrec.no = this.n * 60;   % Mean motion [rad/min] = [rad/s] * [s/min]
      satrec.ecco = this.e;      % Eccentricity
      satrec.inclo = this.i;     % Inclination [rad]
      satrec.nodeo = this.Omega; % Right ascension of ascending node [rad]
      satrec.argpo = this.omega; % Argument of perigee [rad]
      satrec.mo = this.M;        % Mean anomaly [rad]
      sgp4epoch = this.epoch - datenum(1950, 1, 1, 0, 0, 0); % Epoch time in days from Jan 0, 1950, 0 hr
      satrec = sgp4init( ...
          whichconst, satrec, satrec.bstar, satrec.ecco, sgp4epoch, ...
          satrec.argpo, satrec.inclo, satrec.mo, satrec.no, satrec.nodeo);
      
    end % satelliteRecord()
    
    function [r_gei, v_gei] = r_gei(this, dNm)
    % Computes geocentric equatorial inertial position and
    % velocity vectors using the SGP4 propagator.
    %
    % Parameters
    %   dNm - Date number at which the position vector occurs
    %
    % Returns
    %   r_gei - Geocentric equatorial inertial position vector [er]
    %   v_gei - Geocentric equatorial inertial velocity vector [er/s]
      
      tsince = (dNm - this.epoch) * 1440; % Time eince epoch [min] = [day] * [min/day]
      [this.satrec, r_gei, v_gei] = sgp4(this.satrec, tsince);
      r_gei = r_gei' / EarthConstants.R_oplus; % [er] = [km] / [km/er]
      v_gei = v_gei' / EarthConstants.R_oplus; % [er/s] = [km/s] / [km/er]
      
    end % r_gei()
    
    function [v_gei, r_gei] = v_gei(this, dNm)
    % Computes geocentric equatorial inertial velocity and
    % position vectors using the SGP4 propagator. Included for
    % compatibility with the KeplerianOrbit and HohmannTransfer
    % classes.
    %
    % Parameters
    %   dNm - Date number at which the position vector occurs
    %
    % Returns
    %   v_gei - Geocentric equatorial inertial velocity vector [er/s]
    %   r_gei - Geocentric equatorial inertial position vector [er]
      
      tsince = (dNm - this.epoch) * 1440; % Time eince epoch [min] = [day] * [min/day]
      [this.satrec, r_gei, v_gei] = sgp4(this.satrec, tsince);
      r_gei = r_gei' / EarthConstants.R_oplus; % [er] = [km] / [km/er]
      v_gei = v_gei' / EarthConstants.R_oplus; % [er/s] = [km/s] / [km/er]
      
    end % v_gei()
    
    function set_a(this, a)
    % Sets semi-major axis [er].
    %
    % Parameters
    %   a - Semi-major axis [er]
      this.a = a;
      this.n = meanMotion(this);
      this.T = orbitalPeriod(this);
      this.satrec = satelliteRecord(this);
      
    end % set_a()
    
    function set_e(this, e)
    % Sets eccentricity [-].
    %
    % Parameters
    %   e - Eccentricity [-]
      this.e = e;
      this.satrec = satelliteRecord(this);
      
    end % set_e()
    
    function set_i(this, i)
    % Sets inclination [rad].
    %
    % Parameters
    %   i - Inclination [rad]
      this.i = i;
      this.satrec = satelliteRecord(this);
      
    end % set_i()
    
    function set_Omega(this, Omega)
    % Sets right ascension of the ascending node [rad].
    %
    % Parameters
    %   Omega - Right ascension of the ascending node [rad]
      this.Omega = Omega;
      this.satrec = satelliteRecord(this);
      
    end % set_Omega()
    
    function set_omega(this, omega)
    % Sets argument of perigee [rad].
    %
    % Parameters
    %   omega - Argument of perigee [rad]
      this.omega = omega;
      this.satrec = satelliteRecord(this);
      
    end % set_omega()
    
    function set_M(this, M)
    % Sets mean anomaly [rad].
    %
    % Parameters
    %   M - Mean anomaly [rad]
      this.M = M;
      this.satrec = satelliteRecord(this);
      
    end % set_M()
    
    function set_epoch(this, epoch)
    % Sets epoch date number.
    % Parameters
    %   epoch - Date number
    %
      this.epoch = epoch;
      this.satrec = satelliteRecord(this);
      
    end % set_epoch()
    
    % TODO: Test set methods for side effects

    function set_method(this, method)
    % Sets method for solving Kepler's equation. Not
    % used. Included for compatibility with KeplerianOrbit
    % class.
    %
    % Parameters
    %   method - Method for solving Kepler's equation: 'newton' or 'halley'
      if ~isequal(method, 'newton') && ~isequal(method, 'halley')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Method must be either newton or halley.');
        throw(MEx);
        
      end % if
      this.method = method;
      
    end % set_method()
    
    function is = isEmpty(this)
    % Determines if orbit properties are empty, or not.
      is = isempty(this.a) ...
           && isempty(this.e) ...
           && isempty(this.i) ...
           && isempty(this.Omega) ...
           && isempty(this.omega) ...
           && isempty(this.M) ...
           && isempty(this.epoch) ...
           && isempty(this.n) ...
           && isempty(this.T) ...
           && isempty(this.satrec);
      % && isempty(this.method) ...
      
    end % isEmpty()
    
  end % methods
  
  methods (Static = true)
    
    function sgp4Orb = getSgp4OrbitFromKeplerianOrbit(kepOrb)
    % Constructs an Sgp4Orbit given a KeplerianOrbit by using
    % the elements directly.
    %
    % Parameters
    %   kepOrb - The KeplerianOrbit
    %
    % Returns
    %   sgp4Orbit - The Sgp4Orbit
      
    % Construct an Sgp4 orbit using the Keplerian elements
      sgp4Orb = Sgp4Orbit( ...
          kepOrb.a, kepOrb.e, kepOrb.i, kepOrb.Omega, kepOrb.omega, kepOrb.M, kepOrb.epoch, kepOrb.method);
      
    end % getSgp4OrbitFromKeplerianOrbit()
    
    function sgp4Orb = fitSgp4OrbitFromKeplerianOrbit(kepOrb)
    % Constructs an Sgp4Orbit given a KeplerianOrbit by fitting
    % an Sgp4 orbit the positions corresponding to the
    % Keplerian orbit.
    %
    % Parameters
    %   kepOrb - The KeplerianOrbit
    %
    % Returns
    %   sgp4Orbit - The Sgp4Orbit
      
    % Compute geocentric equatorial inertial position
    % throughout one period of the Keplerian orbit
      obs_dNm = [];
      obs_gei = [];
      T = kepOrb.T / 86400;
      % [d] = [s] / [s/d]
      for dNm = kepOrb.epoch : T / 100 : kepOrb.epoch + T
        obs_dNm = [obs_dNm, dNm];
        obs_gei = [obs_gei, kepOrb.r_gei(dNm)];
        
      end % for
      
      % Construct a preliminary Sgp4 orbit using the
      % Keplerian elements
      sgp4OrbP = Sgp4Orbit( ...
          kepOrb.a, kepOrb.e, kepOrb.i, kepOrb.Omega, kepOrb.omega, kepOrb.M, kepOrb.epoch, kepOrb.method);
      
      % Differentially correct the preliminary orbit
      [sgp4Orb, status] = OrbitDetermination.docLSqNonlin(sgp4OrbP, obs_dNm, obs_gei);
      
    end % fitSgp4OrbitFromKeplerianOrbit()
    
  end % methods (Static = true)
  
end % classdef
