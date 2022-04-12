% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

while 1

  % Earth station (on unit sphere)

  r = 1.0;
  alpha = 2 * pi * rand - pi;
  phi = 2 * pi * rand - pi;

  R_e = r * [cos(alpha) * sin(phi); sin(alpha) * sin(phi); cos(phi)];

  % Non-GSO station (within 30 degrees of Earth station right
  % ascension and declination)

  r = 1.2;
  alpha = alpha + (2 * pi * rand - pi) / 6;
  phi = phi + (2 * pi * rand - pi) / 6;

  R_n = r * [cos(alpha) * sin(phi); sin(alpha) * sin(phi); cos(phi)];

  % Position relative to the Earth station
    
  r_n = R_n - R_e;

  % Unit vector

  e_n = r_n / sqrt(r_n' * r_n);

  % Evaluate the antenna pattern angle offset over the entire GSO arc

  alpha = [-pi : pi / 1800 : pi];

  theta = [];

  nAlpha = length(alpha);
  for iAlpha = 1 : nAlpha

    r = 6.0;
    % alpha = 2 * pi * rand - pi;
    phi = pi / 2;

    R_g = r * [cos(alpha(iAlpha)) * sin(phi); sin(alpha(iAlpha)) * sin(phi); cos(phi)];
    
    % Position relative to the Earth station
    
    r_g = R_g - R_e;
    
    % Unit vector

    e_g = r_g / sqrt(r_g' * r_g);

    % Angle offset
    
    theta = [theta; acos(e_n' * e_g)];

  end % for

  % Find the minimum angle offset and corresponding right ascension
  % of the GSO station

  [theta_min, index_min] = min(theta);
  alpha_min = alpha(index_min);

  % Compute the minimum right ascension of the GSO station and the
  % corresponding angle offset

  r = 6.0;
  r_n(1)
  alpha_opt = atan2(r_n(2), r_n(1));
  phi = pi / 2;

  R_g = r * [cos(alpha_opt) * sin(phi); sin(alpha_opt) * sin(phi); cos(phi)];
    
  % Position relative to the Earth station

  r_g = R_g - R_e;
    
  % Unit vector

  e_g = r_g / sqrt(r_g' * r_g);

  % Angle offset

  e_n' * e_g
  theta_opt = acos(e_n' * e_g);

  figure(1); hold off;
  plot(alpha * 180 / pi, theta * 180 / pi); hold on;
  plot(alpha_min * 180 / pi, theta_min * 180 / pi, 's');
  plot(alpha_opt * 180 / pi, theta_opt * 180 / pi, '+');

  pause;

  clear all; close all;
  
end % while
