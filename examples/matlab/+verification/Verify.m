% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function VER = Verify()

  REF.E = referenceEllipsoid('wgs84');
  REF.R_oplus  = REF.E.SemimajorAxis / 1e3; % [km]
  REF.R_gso = 6.61073 * REF.R_oplus; % [km]

  REF.boltzmann_k = 1.38064852e-23; % [J/K]
  REF.boltzmann_k_dB = 10 * log10(REF.boltzmann_k);
  REF.c = 299792458; % [m/s]
  
  f_MHz_up = 13000; % MHz
  f_Hz_up = f_MHz_up * 1e6;
  
  f_MHz_dn = 11200; % MHz
  f_Hz_dn = f_MHz_dn * 1e6;
  
  f_MHz_is = 11200; % MHz
  f_Hz_is = f_MHz_is * 1e6;
  
  % Wanted system.
  
  lat_es_w = 0; % degrees
  lng_es_w = 49.58921; % degrees
  
  phi_es_w = lat_es_w * pi / 180;
  lambda_es_w = lng_es_w * pi / 180;
  h_es_w = 0;
  
  [x, y, z] = geodetic2ecef(phi_es_w, lambda_es_w, h_es_w, REF.E);
  P_es_w = [x; y; z];
  
  lat_ss_w = 0; % degrees
  lng_ss_w = lng_es_w + 5; % degrees
  
  P_ss_w = REF.R_gso * 1e3 * ...
           [cosd(lat_ss_w) * cosd(lng_ss_w); ...
            cosd(lat_ss_w) * sind(lng_ss_w); ...
            sind(lat_ss_w)];
  
  G_max_ss_tx_w = 38; % dBi
  Phi0_ss_tx_w = 4; % degrees
  G_max_ss_rx_w = 40; % dBi
  Phi0_ss_rx_w = 4; % degrees
  T_ss_w = 1000; % K
  pd_ss_w = -58; % dBW/Hz
  
  G_max_es_tx_w = 50; % dBi
  Eff_es_tx_w = 0.7; % fraction
  D_es_rx_w = 1.2; % m
  T_es_w = 150; % K
  pd_es_w = -42; % dBW/Hz
  
  % Interferring system.
  
  lat_es_i = -0.31142; % degrees
  lng_es_i = 44.72744; % degrees
  
  phi_es_i = lat_es_i * pi / 180;
  lambda_es_i = lng_es_i * pi / 180;
  h_es_i = 0;
  
  [x, y, z] = geodetic2ecef(phi_es_i, lambda_es_i, h_es_i, REF.E);
  P_es_i = [x; y; z];
  
  lat_ss_i = 0; % degrees
  lng_ss_i = 0.77823 * 180 / pi; % degrees
  
  r_leo = 1.18030 * REF.R_oplus;
  
  P_ss_i = r_leo * 1e3 * ...
           [cosd(lat_ss_i) * cosd(lng_ss_i); ...
            cosd(lat_ss_i) * sind(lng_ss_i); ...
            sind(lat_ss_i)];
  
  G_max_ss_tx_i = 27; % dBi
  Phi0_ss_tx_i = 6.9; % degrees
  pd_ss_i = -73; % dBW/Hz
  
  G_max_es_tx_i = 54; % dBi
  Eff_es_tx_i = 0.7; % fraction
  pd_es_i = -74; % dBW/Hz
  
  % EPFD requirement.
  
  BW_ref_up = 40e3; % Hz
  BW_ref_dn = 40e3; % Hz
  BW_ref_is = 40e3; % Hz
  
  % Geometry.
  
  % Wanted ES, Wanted SS.
  
  V_es_w_ss_w = P_ss_w - P_es_w;
  d_es_w_ss_w = sqrt(V_es_w_ss_w' * V_es_w_ss_w);
  v_es_w_ss_w = V_es_w_ss_w / d_es_w_ss_w;
  theta_es_w_ss_w = 0;
  
  d_ss_w_es_w = d_es_w_ss_w;
  v_ss_w_es_w = -v_es_w_ss_w;
  theta_ss_w_es_w = 0;
  
  % Interfering ES, Interfering SS.
  
  V_es_i_ss_i = P_ss_i - P_es_i;
  d_es_i_ss_i = sqrt(V_es_i_ss_i' * V_es_i_ss_i);
  v_es_i_ss_i = V_es_i_ss_i / d_es_i_ss_i;
  theta_es_i_ss_i = 0;
  
  d_ss_i_es_i = d_es_i_ss_i;
  v_ss_i_es_i = -v_es_i_ss_i;
  theta_ss_i_es_i = 0;
  
  % Wanted ES, Interfering SS.
  
  V_es_w_ss_i = P_ss_i - P_es_w;
  d_es_w_ss_i = sqrt(V_es_w_ss_i' * V_es_w_ss_i);
  v_es_w_ss_i = V_es_w_ss_i / d_es_w_ss_i;
  theta_es_w_ss_i = acosd(v_es_w_ss_w' * v_es_w_ss_i);
  
  d_ss_i_es_w = d_es_w_ss_i;
  v_ss_i_es_w = -v_es_w_ss_i;
  theta_ss_i_es_w = acosd(v_ss_i_es_i' * v_ss_i_es_w);
  
  % Interfering ES, Wanted SS.
  
  V_es_i_ss_w = P_ss_w - P_es_i;
  d_es_i_ss_w = sqrt(V_es_i_ss_w' * V_es_i_ss_w);
  v_es_i_ss_w = V_es_i_ss_w / d_es_i_ss_w;
  theta_es_i_ss_w = acosd(v_es_i_ss_i' * v_es_i_ss_w);
  
  d_ss_w_es_i = d_es_i_ss_w;
  v_ss_w_es_i = -v_es_i_ss_w;
  theta_ss_w_es_i = acosd(v_ss_w_es_w' * v_ss_w_es_i);
  
  % Wanted SS, Interfering SS.
  
  V_ss_w_ss_i = P_ss_i - P_ss_w;
  d_ss_w_ss_i = sqrt(V_ss_w_ss_i' * V_ss_w_ss_i);
  v_ss_w_ss_i = V_ss_w_ss_i / d_ss_w_ss_i;
  theta_ss_w_ss_i = acosd(v_ss_w_es_w' * v_ss_w_ss_i);
  
  d_ss_i_ss_w = d_ss_w_ss_i;
  v_ss_i_ss_w = -v_ss_w_ss_i;
  theta_ss_i_ss_w = acosd(v_ss_i_es_i' * v_ss_i_ss_w);
  
  warning off
  
  % Uplink.
  
  gain_es_w_ss_w = verification.APEREC013V01(G_max_es_tx_w, Eff_es_tx_w, theta_es_w_ss_w);
  gain_ss_w_es_w = verification.APSREC408V01(theta_ss_w_es_w, Phi0_ss_rx_w, 'GainMax', G_max_ss_rx_w);
  
  lambda_up = REF.c / f_Hz_up;
  pl_es_w_ss_w = 20 * log10(4 * pi * d_es_w_ss_w / lambda_up);
  
  C = pd_es_w + gain_es_w_ss_w - pl_es_w_ss_w + gain_ss_w_es_w;
  N = REF. boltzmann_k_dB + 10*log10(T_ss_w);
  
  gain_es_i_ss_w = verification.APEREC013V01(G_max_es_tx_i, Eff_es_tx_i, theta_es_i_ss_w);
  gain_ss_w_es_i = verification.APSREC408V01(theta_ss_w_es_i, Phi0_ss_rx_w, 'GainMax', G_max_ss_rx_w);
  
  pl_es_i_ss_w = 20 * log10(4 * pi * d_es_i_ss_w / lambda_up);
  
  I = pd_es_i + gain_es_i_ss_w - pl_es_i_ss_w + gain_ss_w_es_i;
  
  sl_es_i_ss_w = 10 * log10(4 * pi * d_es_i_ss_w ^ 2);
  
  EPFD =  pd_es_i + gain_es_i_ss_w - sl_es_i_ss_w + gain_ss_w_es_i - gain_ss_w_es_w + 10 * log10(BW_ref_up);
  
  VER.up.C = C;
  VER.up.N = N;
  VER.up.i = I;
  VER.up.I = I;
  VER.up.epfd = EPFD;
  VER.up.EPFD = EPFD;
  
  % Downlink.
  
  gain_ss_w_es_w = verification.APSREC408V01(theta_ss_w_es_w, Phi0_ss_tx_w, 'GainMax', G_max_ss_tx_w);
  gain_es_w_ss_w = verification.APERR_020V01(D_es_rx_w, f_MHz_dn, theta_es_w_ss_w);
  
  lambda_dn = REF.c / f_Hz_dn;
  pl_ss_w_es_w = 20 * log10(4 * pi * d_ss_w_es_w / lambda_dn);
  
  C = pd_ss_w + gain_ss_w_es_w - pl_ss_w_es_w + gain_es_w_ss_w;
  N = REF. boltzmann_k_dB + 10*log10(T_es_w);
  
  gain_ss_i_es_w = verification.APSREC408V01(theta_ss_i_es_w, Phi0_ss_tx_i, 'GainMax', G_max_ss_tx_i);
  gain_es_w_ss_i = verification.APERR_020V01(D_es_rx_w, f_MHz_dn, theta_es_w_ss_i);
  
  pl_ss_i_es_w = 20 * log10(4 * pi * d_ss_i_es_w / lambda_dn);
  
  I = pd_ss_i + gain_ss_i_es_w - pl_ss_i_es_w + gain_es_w_ss_i;
  
  sl_ss_i_es_w = 10 * log10(4 * pi * d_ss_i_es_w ^ 2);
  
  EPFD =  pd_ss_i + gain_ss_i_es_w - sl_ss_i_es_w + gain_es_w_ss_i - gain_es_w_ss_w + 10 * log10(BW_ref_dn);
  
  VER.dn.C = C;
  VER.dn.N = N;
  VER.dn.i = I;
  VER.dn.I = I;
  VER.dn.epfd = EPFD;
  VER.dn.EPFD = EPFD;
  
  % IS
  
  gain_es_w_ss_w = verification.APEREC013V01(G_max_es_tx_w, Eff_es_tx_w, theta_es_w_ss_w);
  gain_ss_w_es_w = verification.APSREC408V01(theta_ss_w_es_w, Phi0_ss_rx_w, 'GainMax', G_max_ss_rx_w);
  
  lambda_is = REF.c / f_Hz_is;
  pl_es_w_ss_w = 20 * log10(4 * pi * d_es_w_ss_w / lambda_is);
  
  C = pd_es_w + gain_es_w_ss_w - pl_es_w_ss_w + gain_ss_w_es_w;
  N = REF. boltzmann_k_dB + 10*log10(T_ss_w);
  
  gain_ss_i_ss_w = verification.APSREC408V01(theta_ss_i_ss_w, Phi0_ss_tx_i, 'GainMax', G_max_ss_tx_i);
  gain_ss_w_ss_i = verification.APSREC408V01(theta_ss_w_ss_i, Phi0_ss_rx_w, 'GainMax', G_max_ss_rx_w);
  
  pl_ss_i_ss_w = 20 * log10(4 * pi * d_ss_i_ss_w / lambda_is);
  
  I = pd_ss_i + gain_ss_i_ss_w - pl_ss_i_ss_w + gain_ss_w_ss_i;
  
  sl_ss_i_ss_w = 10 * log10(4 * pi * d_ss_i_ss_w ^ 2);
  
  EPFD =  pd_ss_i + gain_ss_i_ss_w - sl_ss_i_ss_w + gain_ss_w_ss_i - gain_ss_w_es_w + 10 * log10(BW_ref_is);
  
  VER.is.C = C;
  VER.is.N = N;
  VER.is.i = I;
  VER.is.I = I;
  VER.is.epfd = EPFD;
  VER.is.EPFD = EPFD;
  
  warning on
  
end % Verify()
