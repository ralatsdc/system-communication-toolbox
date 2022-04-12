classdef KeplerianOrbit < Orbit & TwoBodyOrbit
% Describes an orbit using Keplerian elements by solving Kepler's
% equation and computing position in the orbit plane and relative to the
% Earth center.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

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
    
    % Flag for including first order secular perturbations
    includeJ2

    % Mean motion [rad/s]
    n
    % Orbital period [s]
    T
    
    % Right ascension of the ascending node time rate of change [rad/s]
    Omega_dot
    % Argument of perigee time rate of change [rad/s]
    omega_dot
    % Initial mean anomaly time rate of change [rad/s]
    M_0_dot

  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method, varargin)
    % Constructs an KeplerianOrbit given Keplerian elements.
    %
    % Parameters
    %   a - Semi-major axis [er]
    %   e - Eccentricity [-]
    %   i - Inclination [rad]
    %   Omega - Right ascension of the ascending node [rad]
    %   omega - Argument of perigee [rad]
    %   M - Mean anomaly [rad]
    %   epoch - Epoch date number
    %   method - Method to solve Kepler's equation: 'newton' or 'halley'
    %
    % Options
    %   IncludeJ2 - Flag for including first order secular
    %     perturbations (optional, default is 0)
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Parse variable input arguments
      p = inputParser;
      p.addParamValue('IncludeJ2', 0);
      p.parse(varargin{:});
      this.includeJ2 = TypeUtility.set_numeric(p.Results.IncludeJ2);

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
      if this.includeJ2
        [this.Omega_dot, ...
         this.omega_dot, ...
         this.M_0_dot] = this.secularPerturbations();
        
      else
        this.Omega_dot = 0;
        this.omega_dot = 0;
        this.M_0_dot = 0;
        
      end % if

    end % KeplerianOrbit()
    
    function that = copy(this)
    % Constructs an KeplerianOrbit given Keplerian elements.
    %
    % Returns
    %   that - A new KeplerianOrbit instance
      that = KeplerianOrbit(this.a, this.e, this.i, this.Omega, ...
                            this.omega, this.M, this.epoch, this.method, ...
                            'includeJ2', this.includeJ2);

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
    % Computes the mean anomaly at the given date (MG-2.37).
    %
    % Parameters
    %   dNm - Date number at which mean anomaly occurs
    %
    % Returns
    %   M - Mean anomaly [rad]
      M = Coordinates.check_wrap( ...
          this.M + (this.n + this.M_0_dot) * (dNm - this.epoch) * (24 * 60 * 60));
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
    
    function v = visVivaLaw(this, E)
    % Compute orbital velocity using the vis-viva law (MG-2.22).
    %
    % Parameters
    %   E - Eccentric anomaly [rad]
    %
    % Returns
    %   v - Orbital velocity [er/s]
      GM_oplus = EarthConstants.GM_oplus / EarthConstants.R_oplus^3;
      % [er^3/s^2] = [km^3/s^2] / [km/er]^3
      r = sqrt(this.r_goi(E)' * this.r_goi(E));
      % [er]
      v = sqrt(GM_oplus * (2 / r - 1 / this.a));
      % [er/s] = sqrt([er^3/s^2] * (1 / [er]))
      
    end % visVivaLaw()
    
    function [Omega_dot, omega_dot, M_0_dot] = secularPerturbations(this);
    % Compute first-order secular perturbations (E-10.29-32) or
    % (V-9-38-41).
    %
    % Returns
    %   Omega_dot - Right ascension of the ascending node
    %       time rate of change [rad/s]
    %   omega_dot - Argument of perigee time rate of change
    %       [rad/s]
    %   M_0_dot - Initial mean anomaly time rate of change
    %       [rad/s]
      
      p = this.a * (1 - this.e^2);
      % [er]
      Omega_dot = - ((3 / 2) * (EarthConstants.J_2 / p^2) ...
                     * cos(this.i)) * this.n;
      % [rad/s]
      omega_dot = + ((3 / 2) * (EarthConstants.J_2 / p^2) ...
                     * (2 - (5 / 2) * sin(this.i)^2)) * this.n;
      % [rad/s]
      M_0_dot     = + ((3 / 2) * (EarthConstants.J_2 / p^2) ...
                       * sqrt(1 - this.e^2) * (1 - (3 / 2) * sin(this.i)^2)) * this.n;
      % [rad/s]
      
    end % secularPerturbations()
    
    function E = keplersEquation(this, M)
    % Solve conventional Kepler's equation using Newton's or Halley's
    % method to solve for the eccentric anomaly (MG-2.42).
    %
    % Parameters
    %   M - Mean anomaly [rad]
    %
    % Returns
    %   E - Eccentric anomaly [rad]
      
      if this.e < 0.8
        E_i = M;
        
      else
        E_i = pi;
        
      end % if
      
      f_i   = E_i - this.e * sin(E_i) - M;
      f_p_i = 1 - this.e * cos(E_i);
      
      switch this.method
        case 'newton'
          E_iplus1 = E_i - f_i / f_p_i;
          
        case 'halley'
          f_pp_i = this.e * sin(E_i);
          
          E_iplus1 = E_i - (2 * f_i * f_p_i) ...
              / (2 * f_p_i^2 - f_i * f_pp_i);
          
        otherwise
          MEx = MException('Springbok:IllegalArgumentException', 'Invalid method.');
          throw(MEx);
          
      end % switch
      
      nItn = 0;
      while abs(E_iplus1 - E_i) > this.precision_E
        nItn = nItn + 1;
        if nItn > this.max_iteration
          Simlogger.printMsg(Simlogger.INFO, 'Maximum iterations exceeded.');
          break;
          
        end % if
        
        E_i = E_iplus1;
        
        f_i   = E_i - this.e * sin(E_i) - M;
        f_p_i = 1 - this.e * cos(E_i);
        
        switch this.method
          case 'newton'
            E_iplus1 = E_i - f_i / f_p_i;
            
          case 'halley'
            f_pp_i = this.e * sin(E_i);
            
            E_iplus1 = E_i - (2 * f_i * f_p_i) ...
                / (2 * f_p_i^2 - f_i * f_pp_i);
            
        end % switch
        
      end % while abs(E_iplus1 - E_i) > this.precision_E
      
      E = E_iplus1;
      
    end % keplersEquation()
    
    function r_goi = r_goi(this, E)
    % Computes orbital plane inertial position vector (MG-2.30 or MG-2.43).
    %
    % Parameters
    %   E - Eccentric anomaly [rad]
    %
    % Returns
    %   r_goi - Orbital plane inertial position vector [er]
      r_goi = this.a * [+(cos(E) - this.e); ...
                        +sqrt(1 - this.e^2) * sin(E); ...
                        +0.0];
      
    end % r_goi()
    
    function v_goi = v_goi(this, E)
    % Computes orbital plane inertial velocity vector (MG-2.44).
    %
    % Parameters
    %   E - Eccentric anomaly [rad]
    %
    % Returns
    %   v_goi - Orbital plane inertial velocity vector [er/s]
      GM_oplus = EarthConstants.GM_oplus / EarthConstants.R_oplus^3;
      % [er^3/s^2] = [km^3/s^2] / [km/er]^3
      r = this.a * (1 - this.e * cos(E));
      % [er] = [er] * [-] (MG-2.31)
      v_goi = sqrt(GM_oplus * this.a) / r ...
              * [-sin(E); ...
                 +sqrt(1 - this.e^2) * cos(E); ...
                 0];
      % [er/s] = sqrt([er^3/s^2] * [er]) / [er] * [-]
      
    end % v_goi()
    
    function r_gei = r_gei(this, dNm)
    % Computes geocentric equatorial inertial position vector
    % (MG-2.50).
    %
    % Parameters
    %   dNm - Date number at which the position vector occurs
    %
    % Returns
    %   r_gei - Geocentric equatorial inertial position vector [er]
      r_gei = + Coordinates.R_z(-this.Omega - this.Omega_dot * (dNm - this.epoch)) ...
              * Coordinates.R_x(-this.i) ...
              * Coordinates.R_z(-this.omega - this.omega_dot * (dNm - this.epoch)) ...
              * this.r_goi(this.keplersEquation(this.meanPosition(dNm)));
      
    end % r_gei()
    
    function v_gei = v_gei(this, dNm)
    % Computes geocentric equatorial inertial velocity vector (MG-2.50).
    %
    % Parameters
    %   dNm - Date number at which the velocity vector occurs
    %
    % Returns
    %   v_gei - Geocentric equatorial inertial velocity vector [er/s]
      v_gei = + Coordinates.R_z(-this.Omega - this.Omega_dot * (dNm - this.epoch)) ...
              * Coordinates.R_x(-this.i) ...
              * Coordinates.R_z(-this.omega - this.omega_dot * (dNm - this.epoch)) ...
              * this.v_goi(this.keplersEquation(this.meanPosition(dNm)));
      
    end % v_gei()
    
    function element_set = element_set(this, r_gei, v_gei)
    % Computes the element set corresponding to the geocentric
    % equatorial inertial position and velocity vectors.
    %
    % Parameters
    %   r_gei - Geocentric equatorial inertial position vector [er]
    %   v_gei - Geocentric equatorial inertial velocity vector [er/s]
      
    % Alert the user is numerical precision issues might occur
      if this.e < 0.001
        warning('Springbok:NumericalPrecisionWarning', ...
                'Method works poorly for eccentricity less than 0.001');
        
      end % if                
      
      % Compute the areal velocity vector
      h = cross(r_gei, v_gei);
      % [er^2/s] = [er] * [er/s]
      W = h / sqrt(h' * h);
      % [-]
      
      % Compute the inclination, and right ascension of the ascending node
      i = atan2(sqrt(W(1)^2 + W(2)^2), W(3));
      % [rad]
      Omega = atan2(W(1), -W(2));
      % [rad]
      
      % Compute the semi-latus rectum, semi-major axis, and eccentricity
      GM_oplus = EarthConstants.GM_oplus / EarthConstants.R_oplus^3;
      % [er^3/s^2] = [km^3/s^2] / [km/er]^3
      p = (h' * h) / GM_oplus;
      % [er] = ([er^2/s] * [er^2/s]) / [er^3/s^2]
      a = 1 / (2 / sqrt(r_gei' * r_gei) - v_gei' * v_gei / GM_oplus);
      % [er] = 1 / (1 / [er] - [er/s]^2 / [er^3/s^2])
      e = max(0.001, sqrt(1 - p / a));
      % [-]
      
      % Compute the mean motion, eccentric anomaly, and mean anomaly
      n = sqrt(GM_oplus / a^3);
      % [rad/s] = sqrt([er^3/s^2] / [er]^3)
      E = atan2(((r_gei' * v_gei) / (a^2 * n)), (1 - sqrt(r_gei' * r_gei) / a));
      % [rad] = atan2(([er] * [er/s]) / ([er]^2 * [rad/s]), [rad] - [er] / [er])
      M = E - e * sin(E);
      % [rad]
      
      % Compute the argument of latitude, true anomaly, and argument of perigee
      u = atan2(r_gei(3), -r_gei(1) * W(2) + r_gei(2) * W(1));
      % [rad] = atan2([er], [er] * [-])
      nu = atan2(sqrt(1 - e^2) * sin(E), cos(E) - e);
      % [rad] = atan2([rad], [rad])
      omega = u - nu;
      % [rad]
      
      % Collect the elements of the set
      element_set = [a, e, i, Omega, omega, M];
      
    end % element_set()
    
    function set_a(this, a)
    % Sets semi-major axis [er].
    %
    % Parameters
    %   a - Semi-major axis [er]
      this.a = a;
      this.n = meanMotion(this);
      this.T = orbitalPeriod(this);
      [this.Omega_dot, ...
       this.omega_dot, ...
       this.M_0_dot] = this.secularPerturbations();
      
    end % set_a()
    
    function set_e(this, e)
    % Sets eccentricity [-].
    %
    % Parameters
    %   e - Eccentricity [-]
      this.e = e;
      [this.Omega_dot, ...
       this.omega_dot, ...
       this.M_0_dot] = this.secularPerturbations();
      
    end % set_e()
    
    function set_i(this, i)
    % Sets inclination [rad].
    %
    % Parameters
    %   i - Inclination [rad]
      this.i = i;
      [this.Omega_dot, ...
       this.omega_dot, ...
       this.M_0_dot] = this.secularPerturbations();
      
    end % set_i()
    
    function set_Omega(this, Omega)
    % Sets right ascension of the ascending node [rad].
    %
    % Parameters
    %   Omega - Right ascension of the ascending node [rad]
      this.Omega = Omega;
      
    end % set_Omega()
    
    function set_omega(this, omega)
    % Sets argument of perigee [rad].
    %
    % Parameters
    %   omega - Argument of perigee [rad]
      this.omega = omega;
      
    end % set_omega()
    
    function set_M(this, M)
    % Sets mean anomaly [rad].
    %
    % Parameters
    %   M - Mean anomaly [rad]
      this.M = M;
      
    end % set_M()
    
    function set_epoch(this, epoch)
    % Sets epoch date number.
    % Parameters
    %   epoch - Date number
    %
      this.epoch = epoch;
      
    end % set_epoch()
    
    function set_method(this, method)
    % Sets method for solving Kepler's equation.
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
           && isempty(this.T);
      % && isempty(this.method) ...
      
    end % isEmpty()
    
    function is = isEqual(this, that)
    % Determines if two orbits are equal, or not.

      if this.isEmpty() || that.isEmpty()
        is = this.isEmpty() && that.isEmpty();

      else
        t = [];
        t = [t; isequal(this.a, that.a)];
        t = [t; isequal(this.e, that.e)];
        t = [t; isequal(this.i, that.i)];
        t = [t; isequal(this.Omega, that.Omega)];
        t = [t; isequal(this.omega, that.omega)];
        t = [t; isequal(this.M, that.M)];
        t = [t; isequal(this.epoch, that.epoch)];
        t = [t; isequal(this.method, that.method)];
        t = [t; abs(this.n - that.n) < TestUtility.HIGH_PRECISION];
        t = [t; abs(this.T - that.T) < TestUtility.HIGH_PRECISION];

        is = min(t);

      end % if
      
    end % isEqual()

  end % methods
  
end % classdef
