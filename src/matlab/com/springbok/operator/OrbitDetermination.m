classdef OrbitDetermination < handle
% Provides orbit determination functions.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods (Static = true)
    
    function kepOrbP = podGauss(dNm_a, r_a, dNm_b, r_b)
    % Determine an element set in Earth radii and radians at a date
    % number given two position vectors in Earth radii at two date
    % numbers. Note that position vectors are inertial geocentric.
    %
    % Parameters
    %   dNm_a - First date number
    %   r_a - First inertial geocentric position vector
    %   dNm_b - Second date number
    %   r_b - Second inertial geocentric position vector
    %
    % Returns
    %   kepOrbP - The preliminary (Keplerian) orbit
      
      if ~isequal(size(dNm_a), [1, 1]) || ~isequal(size(r_a), [3, 1]) ...
            || ~isequal(size(dNm_b), [1, 1]) || ~isequal(size(r_b), [3, 1])
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Date number or position not of legal size.');
        throw(MEx);
        
      end % if
      Logger.printMsg('FINE', '== in ==');
      
      % Compute a normalized measure of time between the two position
      % vectors. (2.99)
      tau = sqrt(EarthConstants.GM_oplus / EarthConstants.R_oplus^3) ...
            * (dNm_b - dNm_a) * (24 * 60 * 60);
      % [-] = sqrt([km^3/s^2] / [km^3]) * [decimal day] * [s/day]
      
      % Iteratively estimate the ratio of the areas of the sector and
      % triangle defined by the two position vectors. (2.101, 2.108,
      % 2.107, 2.105)
      m = tau^2 ...
          / sqrt(2 * (sqrt(r_a' * r_a) * sqrt(r_b' * r_b) + r_a' * r_b))^3;
      % [-]
      l = (sqrt(r_a' * r_a) + sqrt(r_b' * r_b)) ...
          / (2 * sqrt(2 * (sqrt(r_a' * r_a) * sqrt(r_b' * r_b) + r_a' * r_b))) ...
          - (1 / 2);
      % [-]
      
      eta_0   = (12 / 22) + (10 / 22) * sqrt(1 + (44 / 9) * (m / (l + 5 / 6)));
      eta_im1 = eta_0 + 0.1;
      eta_i   = eta_0;
      eta_ip1 = eta_i - OrbitDetermination.f_(eta_i, m, l) ...
                * ((eta_i - eta_im1) ...
                   / (OrbitDetermination.f_(eta_i, m, l) - OrbitDetermination.f_(eta_im1, m, l)));
      % [-]
      
      nItn = 0;
      while abs(eta_ip1 - eta_i) > SimulationConstants.precision_eta
        nItn = nItn + 1;
        if nItn > SimulationConstants.max_iteration
          logMsg = 'Maximum iterations exceeded.';
          Logger.printMsg('INFO', logMsg);
          break;
          
        end % if
        
        eta_im1 = eta_i;
        eta_i   = eta_ip1;
        
        eta_ip1 = eta_i - OrbitDetermination.f_(eta_i, m, l) ...
                  * ((eta_i - eta_im1) ...
                     / (OrbitDetermination.f_(eta_i, m, l) - OrbitDetermination.f_(eta_im1, m, l)));
        
      end % while
      
      % Construct orthogonal unit vectors which lie in the orbital
      % plane. (2.109, 2.100)
      e_a = r_a / sqrt(r_a' * r_a);
      % [-]
      r_0 = r_b - (r_b' * e_a) * e_a;
      % [-]
      e_0 = r_0 / sqrt(r_0' * r_0);
      % [-]
      
      % Construct the Gaussian vector which is a unit vector normal to
      % the orbital plane.
      W = [+ e_a(2) * e_0(3) - e_a(3) * e_0(2); ...
           - e_a(1) * e_0(3) + e_a(3) * e_0(1); ...
           + e_a(1) * e_0(2) - e_a(2) * e_0(1)];
      % [-]
      
      % Compute the inclination and right ascension of the ascending
      % node. (2.58)
      o.i = atan2(sqrt(W(1)^2 + W(2)^2), W(3));
      % [rad]
      o.Omega = atan2(W(1), -W(2));
      % [rad]
      
      % Compute the argument of latitude. (2.111)
      u_a = atan2(r_a(3), -r_a(1) * W(2) + r_a(2) * W(1));
      % [rad]
      
      % Compute the area of the triangle defined by the two position
      % vectors. (2.113)
      Delta = (1 / 2) * sqrt(r_a' * r_a) * sqrt(r_0' * r_0);
      % [-]
      
      % Compute the semi-latus rectum. (2.112)
      p = (2 * Delta * eta_ip1 / tau)^2;
      % [er]
      
      % Compute the eccentricity and true anomaly corresponding to the
      % first position vector. (2.116)
      e_c = p / sqrt(r_a' * r_a) - 1;
      % [-]
      e_s = ((p / sqrt(r_a' * r_a) - 1) * (r_b' * e_a / sqrt(r_b' * r_b)) ...
             - (p / sqrt(r_b' * r_b) - 1)) * (sqrt(r_b' * r_b) / sqrt(r_0' * r_0));
      % [-]
      
      o.e = sqrt(e_c^2 + e_s^2);
      % [-]
      nu_a  = atan2(e_s, e_c);
      % [rad]
      
      % Compute the argument of perigee. (2.117)
      o.omega = u_a - nu_a;
      % [rad]
      
      % Compute the semi-major axis. (2.118)
      o.a = p / (1 - o.e^2);
      % [er]
      
      % Compute the eccentric and mean anomaly corresponding to the first
      % position vector. (2.121, 2.119)
      E_a = atan2(sqrt(1 - o.e^2) * sin(nu_a), cos(nu_a) + o.e);
      % [er]
      o.M = E_a - o.e * sin(E_a);
      % [rad]
      
      % Construct an orbit.
      o.Omega = Coordinates.check_wrap(o.Omega);
      o.omega = Coordinates.check_wrap(o.omega);
      o.M     = Coordinates.check_wrap(o.M);
      o.dNm   = dNm_a;
      
      if (o.a * EarthConstants.R_oplus > 250 ...
          && o.e > 0 && o.e < 1 ...
          && o.i > - pi / 2 && o.i < + pi / 2)
        kepOrbP = KeplerianOrbit( ...
            o.a, o.e, o.i, o.Omega, o.omega, o.M, o.dNm, 'halley');
        
      else      
        kepOrbP = KeplerianOrbit;
        
      end % if
      
    end % podGauss()
    
    function [satOrbC, status] = docLSqNonlin(satOrbP, obs_dNm, obs_gei)
    % Perform differential correction of a preliminary orbit.
    %
    % Parameters
    %   satOrbP - The preliminary (Keplerian or Sgp4) orbit
    %   obs_dNm - Date numbers of measured position
    %   obs_gei - Measured geocentric equatorial inertial position
    %
    % Returns
    %   satOrbC - The corrected (Keplerian or Sgp4) orbit
    %   status - A status message
      
      if isa(satOrbP, 'KeplerianOrbit')
        orb_type = 'keplerian';
        
      elseif isa(satOrbP, 'Sgp4Orbit')
        orb_type = 'sgp4';
        
      else
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Preliminary orbits must be Keplerian or Sgp4.');
        throw(MEx);
        
      end % if
      Logger.printMsg('FINE', '== in ==');
      
      if satOrbP.isEmpty
        satOrbC = satOrbP;
        status = 'preliminary orbit empty';
        return;
        
      end % if
      
      % Use properties of the initial orbit to assign elements of the
      % initial element set matrix.
      els0 = [satOrbP.a, ...
              satOrbP.e, ...
              satOrbP.i, ...
              satOrbP.Omega, ...
              satOrbP.omega, ...
              satOrbP.M];
      
      % Solve the non-linear least-squares problem to minimize the
      % difference between the modeled and measured observations.
      options = optimset('Display', 'off');
      [els1, res_norm, residual, exit_flag] = lsqnonlin( ...
          @(els1) OrbitDetermination.funLSqNonlin(els1, satOrbP.epoch, obs_dNm, obs_gei, orb_type), els0, ...
          [], [], options);
      
      if exit_flag > 0
        status = 'differential correction successful';
        % 1  LSQNONLIN converged to a solution X.
        % 2  Change in X smaller than the specified tolerance.
        % 3  Change in the residual smaller than the specified tolerance.
        % 4  Magnitude search direction smaller than the specified
        %      tolerance.
        
      elseif exit_flag == 0
        status = 'maximum iterations exceeded';
        % 0  Maximum number of function evaluations or of iterations
        %      reached.
        
      else
        status = 'differential correction diverged';
        % -1  Algorithm terminated by the output function.
        % -2  Bounds are inconsistent.
        % -4  Line search cannot sufficiently decrease the residual along
        %       the current search direction.
        
      end % if
      
      % Use elements of the final element set matrix to construct the
      % final orbit.
      o.a     = els1(1);
      o.e     = els1(2);
      o.i     = els1(3);
      o.Omega = Coordinates.check_wrap(els1(4));
      o.omega = Coordinates.check_wrap(els1(5));
      o.M     = Coordinates.check_wrap(els1(6));
      o.epoch = satOrbP.epoch;
      
      if strcmp(orb_type, 'keplerian')
        satOrbC = KeplerianOrbit( ...
            o.a, o.e, o.i, o.Omega, o.omega, o.M, o.epoch, 'halley');
        
      else % strcmp(orb_type, 'sgp4')
        satOrbC = Sgp4Orbit( ...
            o.a, o.e, o.i, o.Omega, o.omega, o.M, o.epoch, 'halley');
        
      end % if
      
    end % docLSqNonlin()
    
    function [satOrbC, status] = docNumerical(satOrbP, obs_dNm, obs_gei, option);
    % Perform differential correction of a preliminary orbit using
    % the Gauss-Newton or Levenberg-Marquardt method.
    %
    % Parameters
    %   satOrbP - The preliminary (Keplerian or Sgp4) orbit
    %   obs_dNm - Date numbers of measured position
    %   obs_gei - Measured geocentric equatorial inertial position
    %   option - The numerical technique used: 'Levenberg-Marquardt' or
    %            'Guass-Newton'
    %
    % Returns
    %   satOrbC - The corrected (Keplerian or Sgp4) orbit
    %   status - A status message
      
      if isa(satOrbP, 'KeplerianOrbit')
        orb_type = 'keplerian';
        
      elseif isa(satOrbP, 'Sgp4Orbit')
        orb_type = 'sgp4';
        
      else
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Preliminary orbits must be Keplerian or Sgp4.');
        throw(MEx);
        
      end % if
      Logger.printMsg('FINE', '== in ==');
      
      if satOrbP.isEmpty
        satOrbC = satOrbP;
        status = 'preliminary orbit empty';
        return;
        
      end % if
      
      % Initialize the algorithm for computing the differential
      % correction.
      OrbitDetermination.computeCorrection(option);
      
      % Apply first optimal differential correction.
      nItn = 1;
      
      satOrb_i = satOrbP;
      [satOrb_ip1, cur_sSq] = OrbitDetermination.searchLine(satOrb_i, obs_dNm, obs_gei, option);
      
      cur_time_offset = (satOrb_ip1.M - satOrb_i.M) / satOrb_i.meanMotion;
      
      logMsg = sprintf('Time offset ip1-i: %f (s) - nItn: %d', ...
                       cur_time_offset, nItn);
      Logger.printMsg('FINE', logMsg);
      
      % Continue to apply differential corrections until the mean anomaly
      % is determined to the given precision or the maximum number of
      % iterations is exceeded.
      status = 'differential correction successful';
      
      min_sSq = +inf;
      
      while abs(cur_time_offset) > SimulationConstants.max_time_diff
        nItn = nItn + 1;
        if nItn > SimulationConstants.max_iteration
          Logger.printMsg('INFO', 'Maximum iterations exceeded.');
          status = 'maximum iterations exceeded';
          break;
          
        end % if
        
        if cur_sSq < min_sSq
          min_sSq = cur_sSq;
          
        else
          logMsg = sprintf('Differential correction diverging (%d).', ...
                           nItn);
          Logger.printMsg('INFO', logMsg);
          satOrbC = satOrb_i;
          status = 'differential correction diverged';
          return;
          
        end % if
        
        % Apply the current optimal differential correction.
        satOrb_i = satOrb_ip1;
        [satOrb_ip1, cur_sSq] = OrbitDetermination.searchLine(satOrb_i, obs_dNm, obs_gei, option);
        
        cur_time_offset = (satOrb_ip1.M - satOrb_i.M) / satOrb_i.meanMotion;
        
        logMsg = sprintf('Time offset ip1-i: %f (s) - nItn: %d', ...
                         cur_time_offset, nItn);
        Logger.printMsg('FINE', logMsg);
        
      end % while
      
      satOrbC = satOrb_ip1;
      
    end % docNumerical()
    
  end % methods (Static = true)
  
  methods (Static = true, Access = private)
    
    function value = f_(x, m, l)
    % Evaluates equation (2.106).
      value = 1 - x + (m / x^2) * OrbitDetermination.W_(m / x^2 - l);
      
    end % f_()
    
    function value = W_(w)
    % Evaluates equation (2.103).
      g = 2 * asin(sqrt(w));
      value = (2 * g - sin(2 * g)) / sin(g)^3;
      
    end % W_()
    
    function res_gei = funLSqNonlin(els1, dNm1, obs_dNm, obs_gei, orb_type)
    % Computes the difference between the modeled and measured
    % observations.
    %
    % Parameters
    %   els1 - Element set matrix
    %   dNm1 - Date number of element set matrix
    %   obs_dNm - Date numbers of measured position
    %   obs_gei - Measured geocentric equatorial inertial position
    %   orb_type - orbit type: 'keplerian' or 'sgp4'
    %
    % Returns
    %   res_gei - Position residuals
      
    % Use elements of the element set matrix to construct an orbit.
      o.a     = els1(1);
      o.e     = els1(2);
      o.i     = els1(3);
      o.Omega = els1(4);
      o.omega = els1(5);
      o.M     = els1(6);
      o.epoch = dNm1;
      
      if strcmp(orb_type, 'keplerian')
        satOrb1 = KeplerianOrbit( ...
            o.a, o.e, o.i, o.Omega, o.omega, o.M, o.epoch, 'halley');
        
      else % strcmp(orb_type, 'sgp4')
        satOrb1 = Sgp4Orbit( ...
            o.a, o.e, o.i, o.Omega, o.omega, o.M, o.epoch, 'halley');
        
      end % if                
      
      % Compute the difference between the modeled and measured
      % observations.
      nDNm = length(obs_dNm);
      for iDNm = 1:nDNm;
        mdl_gei(:, iDNm) = satOrb1.r_gei(obs_dNm(iDNm));
        res_gei(:, iDNm) = obs_gei(:, iDNm) - mdl_gei(:, iDNm);
        
      end % for
      
    end % funLSqNonlin()
    
    function [satOrb_ip1, sSq] = searchLine(satOrb_i, obs_dNm, obs_gei, option)
    % Perform a line search to find the optimum fraction of the
    % differential correction to apply.
    %
    % Parameters
    %   satOrb_i - The orbit (Keplerian or Sgp4) at step i
    %   obs_dNm - Date numbers of measured position
    %   obs_gei - Measured geocentric equatorial inertial position
    %   option - The numerical technique used: 'Levenberg-Marquardt' or
    %            'Guass-Newton'
    %
    % Returns
    %   satOrb_ip1 - The orbit (Keplerian or Sgp4) at step i+1
    %   sSq - The sum of squared residuals
      
    % Compute the differential correction.
      dx = OrbitDetermination.computeCorrection(option, satOrb_i, obs_dNm, obs_gei);
      
      % Use bisection to find the optimum fraction between zero and one
      % of the differential correction to apply.
      alpha_l = 0.0;
      [satOrb_ip1, sSq_l] ...
          = OrbitDetermination.applyCorrection(satOrb_i, dx, alpha_l, obs_dNm, obs_gei);
      
      alpha_r = 1.0;
      [satOrb_ip1, sSq_r] ...
          = OrbitDetermination.applyCorrection(satOrb_i, dx, alpha_r, obs_dNm, obs_gei);
      
      while alpha_r - alpha_l > 0.001
        alpha_m = (alpha_l + alpha_r) / 2;
        if sSq_l < sSq_r
          sSq = sSq_r;
          alpha_r = alpha_m;
          [satOrb_ip1, sSq_r] ...
              = OrbitDetermination.applyCorrection(satOrb_i, dx, alpha_m, obs_dNm, obs_gei);
          
        else
          sSq = sSq_l;
          alpha_l = alpha_m;
          [satOrb_ip1, sSq_l] ...
              = OrbitDetermination.applyCorrection(satOrb_i, dx, alpha_m, obs_dNm, obs_gei);
          
        end % if
        
      end % while
      
    end % searchLine()
    
    function [dx, dz, H] = computeCorrection(option, satOrb_i, obs_dNm, obs_gei)
    % Compute the difference between the modeled and measured
    % observations, the corresponding elements of the Jacobian, and the
    % resulting differential correction.
    %
    % Parameters
    %   option - The numerical technique used: 'Levenberg-Marquardt' or
    %            'Guass-Newton'
    %   satOrb_i - The orbit (Keplerian or Sgp4) at step i
    %   obs_dNm - Date numbers of measured position
    %   obs_gei - Measured geocentric equatorial inertial position
    %
    % Returns
    %   dx - The differential corrections
    %   dz - The position residuals
    %   H - The Jacobian
      
    % Initialize the algorithm, if required.
      persistent nu lambda
      if nargin == 1
        switch option
          case 'Levenberg-Marquardt'
            
            % Initialize the damping parameters.
            nu     = 2.0;
            lambda = 0.1;
            
          otherwise % 'Guass-Newton'
            
            % No initialization required.
            
        end % switch
        dx = [];
        dz = [];
        H  = [];
        return;
        
      end % if
      
      % Compute the difference between the modeled and measured
      % observations, the corresponding elements of the Jacobian.
      dz = [];
      H  = [];
      
      nDNm = length(obs_dNm);
      for iDNm = 1:nDNm;
        mdl_gei(:, iDNm) = satOrb_i.r_gei(obs_dNm(iDNm));
        dz = [dz; obs_gei(:, iDNm) - mdl_gei(:, iDNm)];
        H  = [H; OrbitDetermination.jacobianNumerical(satOrb_i, obs_dNm(iDNm))];
        
      end % for
      
      % Compute the resulting differential correction.
      switch option
        case 'Levenberg-Marquardt'
          
          % Apply the full differential correction.
          alpha = 1;
          
          % Compute the sum of the squared differences (between the modeled
          % and measured observations) without differential correction.
          dx_0 = zeros(6, 1);
          [satOrb_ip1, sSq_0] ...
              = OrbitDetermination.applyCorrection(satOrb_i, dx_0, alpha, obs_dNm, obs_gei);
          
          % Compute the sum of the squared differences with differential
          % correction computed using the _lesser_ damping factor.
          dx_l = (H' * H + (lambda / nu) * diag(diag(H' * H))) \ (H' * dz);
          [satOrb_ip1, sSq_l] ...
              = OrbitDetermination.applyCorrection(satOrb_i, dx_l, alpha, obs_dNm, obs_gei);
          
          % Compute the sum of the squared differences with differential
          % correction computed using the _greater_ damping factor.
          dx_g = (H' * H + lambda * diag(diag(H' * H))) \ (H' * dz);
          [satOrb_ip1, sSq_g] ...
              = OrbitDetermination.applyCorrection(satOrb_i, dx_g, alpha, obs_dNm, obs_gei);
          
          % Increase the damping factor until a reduction in the sum of the
          % squared differences results.
          while sSq_l > sSq_0 & sSq_g > sSq_0 & 0 & lamda < 9
            lambda = nu * lambda;
            
            dx_l = (H' * H + (lambda / nu) * diag(diag(H' * H))) \ (H' * dz);
            [satOrb_ip1, sSq_l] ...
                = OrbitDetermination.applyCorrection(satOrb_i, dx_l, alpha, obs_dNm, obs_gei);
            
            dx_g = (H' * H + lambda * diag(diag(H' * H))) \ (H' * dz);
            [satOrb_ip1, sSq_g] ...
                = OrbitDetermination.apply_correction(satOrb_i, dx_g, alpha, obs_dNm, obs_gei);
            
          end % while
          
          % Retain the least damping factor that gives a reduction in the
          % sum of the squared differences, and assign the corresponding
          % differential correction.
          if sSq_l < sSq_0
            lambda = lambda / nu;
            dx = dx_l;
            
          else
            % lambda is unchanged.
            dx = dx_g;
            
          end % if
          
        otherwise % 'Guass-Newton'
          
          % Compute the differential correction.
          dx = (H' * H) \ (H' * dz);
          
      end % switch
      
    end % computeCorrection()
    
    function [satOrb_ip1, sSq] = applyCorrection(satOrb_i, dx, alpha, obs_dNm, obs_gei)
    % Deferentially correct the given element set. Measure the fit by
    % computing the sum of the squared differences between the modeled
    % and measured observations.
    %
    % Parameters
    %   satOrb_i - The orbit (Keplerian or Sgp4) at step i
    %   dx - The differential corrections
    %   alpha - The differential correction fraction applied
    %   obs_dNm - Date numbers of measured position
    %   obs_gei - Measured geocentric equatorial inertial position
    %
    % Returns
    %   satOrb_ip1 - The orbit (Keplerian or Sgp4) at step i+1
    %   sSq - The sum of squared residuals
      
    % Deferentially correct the given element set.
    % satOrb_ip1.id = satOrb_i.id;
      o.a     = alpha * dx(1) + satOrb_i.a;
      o.e     = alpha * dx(2) + satOrb_i.e;
      o.i     = alpha * dx(3) + satOrb_i.i;
      o.Omega = Coordinates.check_wrap(alpha * dx(4) + satOrb_i.Omega);
      o.omega = Coordinates.check_wrap(alpha * dx(5) + satOrb_i.omega);
      o.M     = Coordinates.check_wrap(alpha * dx(6) + satOrb_i.M);
      o.epoch = satOrb_i.epoch;
      
      if isa(satOrb_i, 'KeplerianOrbit')
        satOrb_ip1 = KeplerianOrbit( ...
            o.a, o.e, o.i, o.Omega, o.omega, o.M, o.epoch, 'halley');
        
      else % isa(satOrb_i, 'Sgp4Orbit')
        satOrb_ip1 = Sgp4Orbit( ...
            o.a, o.e, o.i, o.Omega, o.omega, o.M, o.epoch, 'halley');
        
      end % if
      
      % Enforce sensible physical limits.
      % satOrb_ip1.set_a(max([1, satOrb_ip1.a]));
      satOrb_ip1.set_e(max([0.0001, min([0.9999, satOrb_ip1.e])]));
      % satOrb_ip1.set_i(Coordinates.check_wrap(satOrb_ip1.i));
      % satOrb_ip1.set_Omega(Coordinates.check_wrap(satOrb_ip1.Omega));
      % satOrb_ip1.set_omega(Coordinates.check_wrap(satOrb_ip1.omega));
      % satOrb_ip1.set_M(Coordinates.check_wrap(satOrb_ip1.M));
      
      % Measure the fit by computing the sum of the squared differences
      % between the modeled and measured observations.
      nDNm = length(obs_dNm);
      for iDNm = 1:nDNm;
        mdl_gei(:, iDNm) = satOrb_ip1.r_gei(obs_dNm(iDNm));
        obs_res = obs_gei(:, iDNm) - mdl_gei(:, iDNm);
        sSq = sum(sum(obs_res.^2));
        
      end % for
      
    end % applyCorrection()
    
    function H = jacobianNumerical(satOrbU, dNm)
    % Compute the Jacobian for differential orbit correction using a
    % centered difference. (7.108)
    %
    % Parameters
    %   satOrbU - The orbit (Keplerian or Sgp4)
    %   dNm - The date number
    %
    % Returns
    %   H - The Jacobian
      
    % Compute geocentric equatorial inertial position corresponding to
    % the unmodified orbit.
      r_gei_1 = satOrbU.r_gei(dNm);
      
      % Deferentially modify each property of the orbit, and compute the
      % geocentric equatorial inertial position of the modified orbit and
      % elements of the Jacobian matrix.
      H = [];
      
      if isa(satOrbU, 'KeplerianOrbit')
        satOrbM = KeplerianOrbit(satOrbU.a, ...
                                 satOrbU.e, ...
                                 satOrbU.i, ...
                                 satOrbU.Omega, ...
                                 satOrbU.omega, ...
                                 satOrbU.M, ...
                                 satOrbU.epoch, ...
                                 'halley');
        
      else % isa(satOrbU, 'Sgp4Orbit')
        satOrbM = Sgp4Orbit(satOrbU.a, ...
                            satOrbU.e, ...
                            satOrbU.i, ...
                            satOrbU.Omega, ...
                            satOrbU.omega, ...
                            satOrbU.M, ...
                            satOrbU.epoch, ...
                            'halley');
        
      end % if            
      
      orb_props = {'a', 'e', 'i', 'Omega', 'omega', 'M'};
      
      nPrp = length(orb_props);
      for iPrp = 1:nPrp
        switch orb_props{iPrp}
          case 'a'
            dx = satOrbU.a * SimulationConstants.decimal_delta;
            
            satOrbM.set_a(satOrbU.a + dx / 2);
            dhp = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.a - dx / 2);
            dhm = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.a)
            
          case 'e'
            dx = satOrbU.e * SimulationConstants.decimal_delta;
            
            satOrbM.set_a(satOrbU.e + dx / 2);
            dhp = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.e - dx / 2);
            dhm = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.e)
            
          case 'i'
            dx = satOrbU.i * SimulationConstants.decimal_delta;
            
            satOrbM.set_a(satOrbU.i + dx / 2);
            dhp = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.i - dx / 2);
            dhm = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.i)
            
          case 'Omega'
            dx = satOrbU.Omega * SimulationConstants.decimal_delta;
            
            satOrbM.set_a(satOrbU.Omega + dx / 2);
            dhp = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.Omega - dx / 2);
            dhm = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.Omega)
            
          case 'omega'
            dx = satOrbU.omega * SimulationConstants.decimal_delta;
            
            satOrbM.set_a(satOrbU.omega + dx / 2);
            dhp = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.omega - dx / 2);
            dhm = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.omega)
            
          case 'M'
            dx = satOrbU.M * SimulationConstants.decimal_delta;
            
            satOrbM.set_a(satOrbU.M + dx / 2);
            dhp = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.M - dx / 2);
            dhm = satOrbM.r_gei(dNm) - r_gei_1;
            
            satOrbM.set_a(satOrbU.M)
            
          otherwise
            MEx = MException('Springbok:IllegalArgumentException', ...
                             'Unexpected orbit property.');
            throw(MEx);
            
        end % switch
        
        H = [H, (dhp - dhm) / dx];
        
      end % for iPrp
      
    end % jacobianNumerical()
    
  end % methods (Static = true, Access = private)
  
end % classdef
