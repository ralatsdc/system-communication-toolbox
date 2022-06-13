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
classdef HohmannTransfer < handle
% Describes a Hohmann transfer between two orbits which are circular
% (or elliptical with a common line of apsides) and coplanar.
  
  properties (SetAccess = private, GetAccess = public)
    
    % Initial Keplerian orbit
    kep_orb_1
    % Final Keplerian orbit
    kep_orb_2
    % Transfer Keplerian orbit
    kep_orb_t
    
    % Velocity of object in initial orbit at perigee of the
    % transfer (and initial) orbit [er/s]
    v_1
    % Velocity of object in transfer orbit at perigee of the
    % transfer (and initial) orbit [er/s]
    v_t_p
    % Velocity of object in transfer orbit at apogee of the
    % transfer (and final) orbit [er/s]
    v_t_a
    % Velocity of object in final orbit at apogee of the transfer
    % (and final) orbit [er/s]
    v_2
    
    % Change in velocity required at perigee of the transfer (and
    % initial) orbit [er/s]
    delta_v_p
    % Change in velocity required at apogee of the transfer (and
    % final) orbit [er/s]
    delta_v_a
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = HohmannTransfer(kep_orb_1, kep_orb_2)
    % Constructs a HohmannTransfer given the initial and final
    % Keplerian orbits.
    %
    % Parameters
    %   kep_orb_1 - Initial Keplerian orbit
    %   kep_orb_2 - Final Keplerian orbit
      
      % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Assign properties
      this.init_kep_orb_1(kep_orb_1);
      this.init_kep_orb_2(kep_orb_2);
      
      % Ensure elliptical orbits have a common line of
      % apsides, and all orbits are coplanar
      e_max = 0.001;
      if (kep_orb_1.e > e_max || kep_orb_2.e > e_max) ...
            && kep_orb_1.omega ~= kep_orb_2.omega
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Elliptical orbits must have a common line of apsides');
        throw(MEx);
        
      end % if
      if kep_orb_1.Omega ~= kep_orb_2.Omega || kep_orb_1.i ~= kep_orb_2.i
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Orbits must be coplanar');
        throw(MEx);
        
      end % if
      
      % Compute derived properties
      this.computeTransferOrbit;
      
    end % HohmannTransfer()

    function that = copy(this)
    % Copies a HohmannTransfer given the initial and final
    % Keplerian orbits.
    %
    % Returns
    %   that - A new HohmannTransfer instance
      that = HohmannTransfer(this.kep_orb_1.copy(), this.kep_orb_2.copy());

    end % copy()

    function init_kep_orb_1(this, kep_orb_1)
    % Set kep_orb_1
    %
    % Parameters
    %   kep_orb_1 - The kep_orb_1
      if ~isa(kep_orb_1, 'KeplerianOrbit')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be an instance of class "KeplerianOrbit"');
        throw(MEx);

      end % if
      this.kep_orb_1 = kep_orb_1;

    end % if
        
    function init_kep_orb_2(this, kep_orb_2)
    % Set kep_orb_2
    %
    % Parameters
    %   kep_orb_2 - The kep_orb_2
      if ~isa(kep_orb_2, 'KeplerianOrbit')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be an instance of class "KeplerianOrbit"');
        throw(MEx);

      end % if
      this.kep_orb_2 = kep_orb_2;

    end % if
    
    function [kep_orb_s, sgp4_orb_s, delta_v_t] = simulateTransferOrbit(this, t_cut_off, n_impulse, mode, do_fit)
    % Simulates the two maneuvers of a Hohmann transfer over a
    % period using a series of impulsive maneuvers directed
    % according to the specified steering law.
    %
    % Parameters
    %   t_cut_off - Duration of each maneuver, [s]
    %   n_impulse - Number of impulses used to simulate each
    %       maneuver
    %   mode - steering law, valid values:
    %              'velocity-to-be-gained'
    %              'terminal-state-vector'
    %   do_fit - flag to indicating fit of SGP4 orbits to
    %       Keplerian orbits
    %
    % Returns
    %   kep_orb_s - a vector of Keplerian orbits representing
    %       the states of the object throughout the transfer
    %   sgp4_orb_s - a vector of Sgp4 orbits representing
    %       the states of the object throughout the transfer
      
    % Ensure time between impulses reasonable
      if t_cut_off / (n_impulse - 1) <= 1
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Time between each impulse must be greater than one second');
        throw(MEx);
        
      end % if                
      
      % Simulate perigee maneuver. Note that epoch of the
      % transfer orbit occurs at perigee of the initial orbit.
      do_circ = 0;
      [kep_orb_p, sgp4_orb_p, delta_v_p] = HohmannTransfer.simulateManeuver( ...
          this.kep_orb_1, this.kep_orb_t, this.kep_orb_t.epoch, ...
          t_cut_off, this.delta_v_p, n_impulse, mode, do_circ, do_fit);
      
      % Simulate apogee maneuver. Note that epoch of the final
      % orbit occurs at one half the period of the transfer
      % orbit after the epoch of the transfer orbit.
      do_circ = 0;
      [kep_orb_a, sgp4_orb_a, delta_v_a] = HohmannTransfer.simulateManeuver( ...
          kep_orb_p(end), this.kep_orb_2, this.kep_orb_2.epoch - t_cut_off / 86400, ...
          t_cut_off, this.delta_v_a, n_impulse, mode, do_circ, do_fit);
      
      % Accumulate delta_v
      delta_v_t = delta_v_p + delta_v_a;
      
      % Accumulate Keplerian and Sgp4 orbits
      kep_orb_s = [kep_orb_p(1 : end - 1), kep_orb_a];
      sgp4_orb_s = [sgp4_orb_p(1 : end - 1), sgp4_orb_a];
      
    end % simulateTransferOrbit()
    
    function set_kep_orb_1(this, kep_orb_1)
    % Sets initial Keplerian orbit.
    %
    % Parameters
    %   kep_orb_1 - Initial Keplerian orbit
      this.kep_orb_1 = kep_orb_1;
      this.computeTransferOrbit;
      
    end % set_kep_orb_1()
    
    function set_kep_orb_2(this, kep_orb_2)
    % Sets final Keplerian orbit.
    %
    % Parameters
    %   kep_orb_2 - Final Keplerian orbit
      this.kep_orb_2 = kep_orb_2;
      this.computeTransferOrbit;
      
    end % set_kep_orb_2()
    
  end % methods
  
  methods (Access = private)
    
    function computeTransferOrbit(this)
    % Computes the Hohmann transfer orbit.
      
    % Initial orbit perigee
      r_1 = this.kep_orb_1.a * (1 - this.kep_orb_1.e);
      % Final orbit apogee
      r_2 = this.kep_orb_2.a * (1 + this.kep_orb_2.e);
      
      % Transfer orbit semi-major axis [er]
      a_t = (r_2 + r_1) / 2;
      % Transfer orbit eccentricity [-]
      e_t = (r_2 - r_1) / (r_2 + r_1);
      % Transfer orbit inclination [rad]
      i_t = this.kep_orb_1.i;
      % Transfer orbit right ascension of the ascending node [rad]
      Omega_t = this.kep_orb_1.Omega;
      
      % Transfer orbit epoch date number (at perigee of initial orbit)
      if this.kep_orb_1.M > 0
        epoch_t = this.kep_orb_1.epoch + (2 * pi - this.kep_orb_1.M) / this.kep_orb_1.n / 86400;
        
      else
        epoch_t = this.kep_orb_1.epoch;
        
      end % if
      
      % Transfer orbit argument of perigee [rad]
      omega_t = this.kep_orb_1.omega;
      % Transfer orbit mean anomaly [rad]
      M_t = 0.0; % perigee
                 % Transfer orbit method to solve Kepler's equation: 'newton' or 'halley'
      method_t = this.kep_orb_1.method;
      
      % Transfer Keplerian orbit
      this.kep_orb_t = KeplerianOrbit( ...
          a_t, e_t, i_t, Omega_t, omega_t, M_t, epoch_t, method_t);
      
      % Final orbit semi-major axis [er]
      a_2 = this.kep_orb_2.a;
      % Final orbit eccentricity [-]
      e_2 = this.kep_orb_2.e;
      % Final orbit inclination [rad]
      i_2 = this.kep_orb_2.i;
      % Final orbit right ascension of the ascending node [rad]
      Omega_2 = this.kep_orb_2.Omega;
      
      % Final orbit epoch date number (one half period after epoch of transfer orbit)
      epoch_2 = epoch_t + (1 / 2) * (this.kep_orb_t.T / 86400);
      
      % Final orbit argument of perigee [rad]
      omega_2 = this.kep_orb_2.omega;
      % Final orbit mean anomaly [rad]
      M_2 = pi; % apogee
                % Final orbit method to solve Kepler's equation: 'newton' or 'halley'
      method_2 = this.kep_orb_2.method;
      
      % Final Keplerian orbit
      this.kep_orb_2 = KeplerianOrbit( ...
          a_2, e_2, i_2, Omega_2, omega_2, M_2, epoch_2, method_2);
      
      % Compute velocities of object in the initial and transfer
      % orbit at perigee of the transfer (and initial) orbit,
      % and in the transfer and final orbit at apogee of the
      % transfer (and final) orbit
      v_1 = this.kep_orb_1.v_gei(this.kep_orb_t.epoch);
      this.v_1 = sqrt(v_1' * v_1);
      v_t_p = this.kep_orb_t.v_gei(this.kep_orb_t.epoch);
      this.v_t_p = sqrt(v_t_p' * v_t_p);
      v_t_a = this.kep_orb_t.v_gei(this.kep_orb_2.epoch);
      this.v_t_a = sqrt(v_t_a' * v_t_a);
      v_2 = this.kep_orb_2.v_gei(this.kep_orb_2.epoch);
      this.v_2 = sqrt(v_2' * v_2);
      
      % Compute the change in velocity required to enter and
      % exit the transfer orbit
      this.delta_v_p = this.v_t_p - this.v_1;
      this.delta_v_a = this.v_2 - this.v_t_a;
      
    end % computeTranserOrbit()
    
  end % methods (Access = private)
  
  methods (Static = true)
    
    function [kep_orb_s, sgp4_orb_s, delta_v_t] = simulateManeuver( ...
        kep_orb_i, kep_orb_f, t_0, t_cut_off, delta_v, n_impulse, mode, do_circ, do_fit)
      % Compute the series of KeplerianOrbits and Sgp4Orbits
      % which result from a series of impulses directed in a
      % specified steering direction.
      %
      % Parameters
      %   kep_orb_i - Initial Keplerian orbit
      %   kep_orb_f - Final Keplerian orbit
      %   t_0 - Time of maneuver, [d]
      %   t_cut_off - Duration of each maneuver, [s]
      %   delta_v - Total change of velocity required during
      %       maneuver, [er/s]
      %   n_impulse - Number of impulses used to simulate each
      %       maneuver
      %   mode - steering law, valid values:
      %              'velocity-to-be-gained'
      %              'terminal-state-vector'
      %   do_circ - flag indicating circulation of final orbit,
      %        or not
      %   do_fit - flag indicating fit of SGP4 orbits to
      %       Keplerian orbits, or not
      %
      % Returns
      %   kep_orb_s - a vector of Keplerian orbits representing
      %       the states of the object throughout the transfer
      %   sgp4_orb_s - a vector of Sgp4 orbits representing
      %       the states of the object throughout the transfer
      
      % Simulated and required KeplerianOrbits
      kep_orb_s = [kep_orb_i];
      kep_orb_r = kep_orb_f;
      
      % Impulse times from start of maneuver
      t_impulse = [t_cut_off / n_impulse : t_cut_off / n_impulse : t_cut_off]; % [s]
      
      % Maximum delta velocity during a maneuver
      delta_v_m = delta_v / n_impulse; % [er/s]
      
      % Total delta velocity during a maneuver
      delta_v_t = 0;
      
      % Steering law
      if strcmp(mode, 'velocity-to-be-gained')
        
        % Nothing to do
        
      elseif strcmp(mode, 'terminal-state-vector')
        
        % Final position and velocity
        t_1 = t_0 + t_cut_off / 86400; % [d]
        r_1 = kep_orb_f.r_gei(t_1); % [er]
        v_1 = kep_orb_f.v_gei(t_1); % [er/s]
        
      else
        MEx = MException('Springbok:IllegalArgumentException', ...
                         ['Unknown steering mode: ', mode]);
        throw(MEx);
        
      end % if
      
      % Perform specified number of impulses
      for i_impulse = 1:n_impulse
        
        % Time of impulse
        t_i = t_0 + t_impulse(i_impulse) / 86400; % [d]
        
        % Position and velocity immediately before impulse
        r_b = kep_orb_s(i_impulse).r_gei(t_i);
        v_b = kep_orb_s(i_impulse).v_gei(t_i);
        
        % Steering law giving direction of impulse
        if strcmp(mode, 'velocity-to-be-gained')
          
          % Required position and velocity at time of impulse
          r_r = kep_orb_r.r_gei(t_i);
          v_r = kep_orb_r.v_gei(t_i);
          
          % Position and velocity to be gained
          r_g = r_r - r_b;
          v_g = v_r - v_b;
          r_g_hat = r_g / sqrt(r_g' * r_g);
          v_g_hat = v_g / sqrt(v_g' * v_g);
          
          % Delta velocity
          delta_v_i = delta_v_m * v_g_hat;
          
        elseif strcmp(mode, 'terminal-state-vector')
          
          % Position and velocity immediately before impulse
          r_i = r_b;
          v_i = v_b;
          
          % Delta velocity
          delta_v_i = ...
              4 * (t_1 - t_0) / (t_1 - t_i) * (v_1 - v_i) ...
              + 6 * (t_1 - t_0) / (n_impulse * (t_1 - t_i)^2) * (r_1 - (r_i + v_1 * (t_1 - t_i)));
          
        end % if
        
        % Position and velocity immediately after impulse
        r_a = r_b;
        v_a = v_b + delta_v_i;
        
        % Accumulate delta_v
        delta_v_t = delta_v_t + sqrt((v_a - v_b)' * (v_a - v_b));
        
        % Keplerian orbit equivalent to position and
        % velocity immediately after impulse
        element_set = kep_orb_s(i_impulse).element_set(r_a, v_a);
        a = element_set(1);
        e = element_set(2);
        i = element_set(3);
        Omega = Coordinates.check_wrap(element_set(4));
        omega = Coordinates.check_wrap(element_set(5));
        M = Coordinates.check_wrap(element_set(6));
        method = 'halley';
        kep_orb_s(i_impulse + 1) = KeplerianOrbit(a, e, i, Omega, omega, M, t_i, method);
        
      end % for
      
      % Circularize the final Keplerian orbit
      if do_circ
        
        % Position and velocity immediately before
        % circularizing impulse
        epoch_c = kep_orb_s(i_impulse + 1).epoch + t_cut_off / n_impulse / 86400;
        r_b = kep_orb_s(i_impulse + 1).r_gei(epoch_c);
        v_b = kep_orb_s(i_impulse + 1).v_gei(epoch_c);
        
        % Semi-major axis and eccentricity of circular
        % orbit, and corresponding velocity magnitude
        a_c = sqrt(r_b' * r_b);
        e_c = 0.002; 
        GM_oplus = EarthConstants.GM_oplus / EarthConstants.R_oplus^3;
        % [er^3/s^2] = [km^3/s^2] / [km/er]^3
        % v_c_mag = sqrt(GM_oplus * (1 / a_c));
        v_c_mag = sqrt(GM_oplus * ((1 - e_c) / ((1 + e_c) * a_c)));
        % [er/s] = sqrt([er^3/s^2] * (1 / [er]))
        
        % Position and velocity immediately after
        % circularizing impulse
        r_a = r_b;
        r_b_hat = r_b / sqrt(r_b' * r_b);
        v_b_hat = v_b / sqrt(v_b' * v_b);
        % W_hat = cross(r_b_hat, v_b_hat);
        W = cross(r_b_hat, v_b_hat);
        W_hat = W / sqrt(W' * W);
        v_c_hat = cross(W_hat, r_b_hat);
        v_a = v_c_mag * v_c_hat;
        
        % Accumulate delta_v
        delta_v_t = delta_v_t + sqrt((v_a - v_b)' * (v_a - v_b));
        
        % Keplerian orbit equivalent to position and
        % velocity immediately after circularizing impulse
        element_set = kep_orb_s(i_impulse + 1).element_set(r_a, v_a);
        a = element_set(1);
        e = element_set(2);
        i = element_set(3);
        Omega = Coordinates.check_wrap(element_set(4));
        omega = Coordinates.check_wrap(element_set(5));
        M = Coordinates.check_wrap(element_set(6));
        method = 'halley';
        kep_orb_s(i_impulse + 2) = KeplerianOrbit(a, e, i, Omega, omega, M, epoch_c, method);
        
      end % if
      
      % Convert each Keplerian orbit to an Sgp4 orbit, if requested
      if do_fit
        n_orb = length(kep_orb_s);
        for i_orb = 1:n_orb
          sgp4_orb_s(i_orb) = Sgp4Orbit.fitSgp4OrbitFromKeplerianOrbit(kep_orb_s(i_orb));
          
        end % for            
        
      else
        sgp4_orb_s = [];
        
      end % if
      
    end % simulateManeuver()
    
  end % methods (Static = true)
  
end % classdef
