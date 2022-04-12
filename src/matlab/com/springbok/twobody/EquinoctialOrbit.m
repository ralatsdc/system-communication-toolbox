classdef EquinoctialOrbit < Orbit & TwoBodyOrbit
% Describes an orbit using equinoctial elements by solving the generalized
% Kepler's equation and computing position in the orbit plane and
% relative to the Earth center.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Direct or retrograde orbit indicator [-]
    j
    % Semi-major axis [er]
    a
    % Y component of the eccentricity vector [-]
    h
    % X component of the eccentricity  [-]
    k
    % Y component of the nodal vector [-]
    p
    % X component of the nodal vector [-]
    q
    % Mean longitude [rad]
    lambda
    % Epoch date number
    epoch
    
    % Method to solve Kepler's equation: 'newton' or 'halley'
    method = 'halley';
    
    % Mean motion [rad/s]
    n
    % Orbital period [s]
    T
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = EquinoctialOrbit(j, a, h, k, p, q, lambda, epoch, method)
    % Constructs an EquinoctialOribt given equinoctial elements.
    %
    % Parameters
    %   j - Direct or retrograde orbit indicator [-]
    %   a - Semi-major axis [er]
    %   h - Y component of the eccentricity vector [-]
    %   k - X component of the eccentricity vector [-]
    %   p - Y component of the nodal vector [-]
    %   q - X component of the nodal vector [-]
    %   lambda - Mean longitude [rad]
    %   epoch - Epoch date number
    %   method - Method to solve Kepler's equation: 'newton' or 'halley'
      
    % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Assign properties. Set numeric properties directly since
      % setters have side effects.
      this.j      = TypeUtility.set_numeric(j);
      this.a      = TypeUtility.set_numeric(a);
      this.h      = TypeUtility.set_numeric(h);
      this.k      = TypeUtility.set_numeric(k);
      this.p      = TypeUtility.set_numeric(p);
      this.q      = TypeUtility.set_numeric(q);
      this.lambda = TypeUtility.set_numeric(lambda);
      this.epoch  = TypeUtility.set_numeric(epoch);

      this.set_method(method);

      % Compute derived properties
      this.n = meanMotion(this);
      this.T = orbitalPeriod(this);
      
    end % EquinoctialOrbit()
    
    function that = copy(this)
    % Copies an EquinoctialOribt given equinoctial elements.
    %
    % Returns
    %   that - A new EquinoctialOrbit instance
      that = EquinoctialOrbit(this.j, this.a, this.h, this.k, this.p, ...
                              this.q, this.lambda, this.epoch, ...
                              this.method);

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
    
    function lambda = meanPosition(this, dNm)
    % Computes the mean longitude at the given date (LCVF-3-271).
    %
    % Parameters
    %   dNm - Date number at which mean longitude occurs
    %
    % Returns
    %   lambda - Mean longitude [rad]
      lambda = Coordinates.check_wrap(this.lambda ...
                                      + this.n * (dNm - this.epoch) * 86400);
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
    
    function F = keplersEquation(this, lambda)
    % Solve generalized Kepler's equation using Newton's or Halley's
    % method to solve for the eccentric longitude (LCVF-3-230).
    %
    % Parameters
    %   lambda - Mean longitude [rad]
    %
    % Returns
    %   F - Eccentric longitude, radians
      
      F_i = lambda;
      
      f_i   = F_i + this.h * cos(F_i) - this.k * sin(F_i) - lambda;
      f_p_i = 1 - this.h * sin(F_i) - this.k * cos(F_i);
      
      switch this.method
        case 'newton'
          F_iplus1 = F_i - F_i / f_p_i;
          
        case 'halley'
          f_pp_i = - this.h * cos(F_i) + this.k * sin(F_i);
          
          F_iplus1 = F_i - (2 * f_i * f_p_i) / (2 * f_p_i^2 - F_i * f_pp_i);
          
        otherwise
          MEx = MException('Springbok:IllegalArgumentException', 'Invalid method.');
          throw(MEx);
          
      end % switch
      
      nItn = 0;
      while abs(F_iplus1 - F_i) > this.precision_E
        nItn = nItn + 1;
        if nItn > this.max_iteration
          Simlogger.printMsg(Simlogger.INFO, 'Maximum iterations exceeded.');
          break;
          
        end % if
        
        F_i = F_iplus1;
        
        f_i   = F_i + this.h * cos(F_i) - this.k * sin(F_i) - lambda;
        f_p_i = 1 - this.h * sin(F_i) - this.k * cos(F_i);
        
        switch this.method
          case 'newton'
            F_iplus1 = F_i - f_i / f_p_i;
            
          case 'halley'
            f_pp_i = - this.h * cos(F_i) + this.k * sin(F_i);
            
            F_iplus1 = F_i - (2 * f_i * f_p_i) / (2 * f_p_i^2 - f_i * f_pp_i);
            
        end % switch
        
      end % while abs(F_iplus1 - F_i) > this.precision_E
      
      F = F_iplus1;
      
    end % keplersEquation()
    
    function r_goi = r_goi(this, F)
    % Computes orbital plane inertial position vector (LCVF-3-236).
    %
    % Parameters
    %   F - Eccentric longitude [rad]
    %
    % Returns
    %   r_goi - Orbital plane inertial position vector [er]
      
      beta = 1 / (1 + sqrt(1 - this.h^2 - this.k^2));
      
      X_1 = this.a * ((1 - this.h^2 * beta) * cos(F) ...
                      + this.h * this.k * beta * sin(F) - this.k);
      Y_1 = this.a * ((1 - this.k^2 * beta) * sin(F) ...
                      + this.h * this.k * beta * cos(F) - this.h);
      
      r_goi = [X_1; ...
               Y_1; ...
               0];
      
    end % r_goi()
    
    function r_gei = r_gei(this, dNm)
    % Computes geocentric equatorial inertial position vector
    % (LCVF-3-238).
    %
    % Parameters
    %   dNm - Date number at which the position vector occurs
    %
    % Returns
    %   r_gei - Geocentric equatorial inertial position vector [er]
      
      f = [1 - this.p^2 + this.q^2; ...
           2 * this.p * this.q; ...
           - 2 * this.p * this.j] / (1 + this.p^2 + this.q^2);
      
      g = [2 * this.p * this.q * this.j; ...
           (1 + this.p^2 - this.q^2) * this.j; ...
           + 2 * this.q] / (1 + this.p^2 + this.q^2);
      
      r_goi = this.r_goi(this.keplersEquation(this.meanPosition(dNm)));
      r_gei = r_goi(1) * f + r_goi(2) * g; 
      
    end % r_gei()
    
    function set_a(this, a)
    % Sets semi-major axis [er].
    %
    % Parameters
    %   a - Semi-major axis [er]
      this.a = a;
      this.n = meanMotion(this);
      this.T = orbitalPeriod(this);
      
    end % set_a()
    
    function set_h(this, h)
    % Sets y component of the eccentricity vector [-].
    %
    % Parameters
    %   h - Y component of the eccentricity vector [-]
      this.h = h;
      
    end % set_h()
    
    function set_k(this, k)
    % Sets x component of the eccentricity  [-].
    %
    % Parameters
    %   k - X component of the eccentricity  [-]
      this.k = k;
      
    end % set_k()
    
    function set_p(this, p)
    % Sets y component of the nodal vector [-].
    %
    % Parameters
    %   p - Y component of the nodal vector [-]
      this.p = p;
      
    end % set_p()
    
    function set_q(this, q)
    % Sets x component of the nodal vector [-].
    %
    % Parameters
    %   q - X component of the nodal vector [-]
      this.q = q;
      
    end % set_q()
    
    function set_lambda(this, lambda)
    % Sets mean longitude [rad].
    %
    % Parameters
    %   lambda - Mean longitude [rad]
      this.lambda = lambda;
      
    end % set_lambda()
    
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
    %   method - Method for solving Kepler's equation: 'newton' or
    %         'halley'
      if ~isequal(method, 'newton') && ~isequal(method, 'halley')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Method must be either newton or halley.');
        throw(MEx);
        
      end % if
      this.method = method;
      
    end % set_method()
    
    function is = isEmpty(this)
    % Determines if orbit properties are empty, or not.
      is = isempty(this.j) ...
           && isempty(this.a) ...
           && isempty(this.h) ...
           && isempty(this.k) ...
           && isempty(this.p) ...
           && isempty(this.q) ...
           && isempty(this.lambda) ...
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
        t = [t; isequal(this.j, that.j)];
        t = [t; isequal(this.a, that.a)];
        t = [t; isequal(this.h, that.h)];
        t = [t; isequal(this.k, that.k)];
        t = [t; isequal(this.p, that.p)];
        t = [t; isequal(this.q, that.q)];
        t = [t; isequal(this.lambda, that.lambda)];
        t = [t; isequal(this.epoch, that.epoch)];
        t = [t; isequal(this.method, that.method)];
        t = [t; abs(this.n - that.n) < TestUtility.HIGH_PRECISION];
        t = [t; abs(this.T - that.T) < TestUtility.HIGH_PRECISION];

        is = min(t);
      
      end % if
      
    end % isEqual()

  end % methods
  
end % classdef
