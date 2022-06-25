function REF = assign_REF

% Usage: REF = assign_REF
%
% Assign values for each field of the reference structure.

% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

% --- Check number and class of input arguments.

if ~(nargin == 0)
  error('Invalid input arguments.');

end % if

% --- Assign physical constants.

REF.R_gso    = 42164.160;                            % [km]
REF.R_e      = 8500;                                 % [km]

% REF.R_oplus  = 6371.005076123;                       % [km]
REF.R_oplus  = 6398.137;                             % [km]

REF.GM_oplus = 398600.4405;                          % [km^3/s^2]
REF.T_oplus  = (360 / 360.9856473) * (24 * 60 * 60); % [s]
% [s] = ([deg/rev] / [deg/day]) * ([h/day] * [m/h] * [s/m])

n_gso = 1.0027 * (2 * pi) * (1 / (24 * 60 * 60));
% [rad/s] = [rev/day] * [rad/rev] * ([h/d] * [m/h] * [s/m])

a_gso = (REF.GM_oplus / n_gso^2)^(1/3); 
% [km] = ([km^3/s^2] / [rad/s]^2)^(1/3);

REF.a_gso = a_gso / REF.R_oplus;
% [er]

REF.boltzmann_k    = 1.381e-23;                   % [J/K]
REF.boltzmann_k_dB = 10 * log10(REF.boltzmann_k); % [dB]
REF.c              = 299792458;                   % [m/s]

% --- Assign iteration parameters.

REF.precision_E     = 1e-6;
REF.precision_eta   = 1e-6;
REF.decimal_delta   = 1e-6;
REF.max_iteration   = 10000;
REF.max_time_offset = 1;

% --- Assign test parameters.

REF.precision_high = 1e-12;
REF.precision_low  = 1e-4;
REF.precision_eng  = 3e-2;

% --- Assign polarization codes and discrimination values.

REF.grp_polar_type = {
  'none'
  'H'
  'V'
  'SR'
  'SL'
  'CR'
  'CL'
  'D'
  'M'
  'L'
  };

REF.pol_disc = [
   0  0  0  0  0  0  0  0  0  0
   0  0 20 10 10  3  3  3  3  0
   0 20  0 10 10  3  3  3  3  0
   0 10 10  0 20  3  3  3  3  0
   0 10 10 20  0  3  3  3  3  0
   0  3  3  3  3  0 20  3  3  3
   0  3  3  3  3 20  0  3  3  3
   0  3  3  3  3  3  3  0  3  3
   0  3  3  3  3  3  3  3  0  3
   0  0  0  0  0  3  3  3  3  0
   ];
