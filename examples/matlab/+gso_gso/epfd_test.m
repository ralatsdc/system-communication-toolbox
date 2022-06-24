% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

clear all
% addpath('C:\Projects\APT-mnt-1.0-wrkng\src')

% REF.R_oplus  = 6371.005076123;                       % [km]
% REF.R_gso    = 6.618134678113744 * REF.R_oplus;      % [km]
% REF.boltzmann_k    = 1.38064852e-23;                 % [J/K]
% REF.boltzmann_k_dB = 10 * log10(REF.boltzmann_k);    % [dBJ/K]
% REF.c              = 299792458;                      % [m/s]

% format long

% a_gso = 6.618134678113744

% REF = assign_REF;

% REF1.a_gso

% format short

REF.R_oplus = 6378.137;
REF.GM_oplus = 398600.4415;
REF.T_oplus = (360 / 360.9856473) * 86400;
REF.T_gso = REF.T_oplus;
REF.R_gso = (REF.GM_oplus * (REF.T_gso / (2 * pi))^2)^(1/3);
REF.boltzmann_k = 1.38064852e-23;
REF.boltzmann_k_dB = 10 * log10(REF.boltzmann_k);
REF.c = 299792458;





f_MHz_up = 13000;
f_Hz_up = 13000e6;

f_MHz_dn = 11200;
f_Hz_dn = 11200e6;

% Wanted system.

lat = 10;
lng = 0;

P_es_w = REF.R_oplus * 10^3 * ...
    [cosd(lat) * cosd(lng); ...
     cosd(lat) * sind(lng); ...
     sind(lat)];
P_es_w = REF.R_oplus * 10^3 * [ ...
   0.984907164835665; ...
  -0.000000000000000; ...
   0.172503122422012];


P_ss_w = REF.R_gso * 10^3 * ...
    [cosd(0) * cosd(lng); ...
     cosd(0) * sind(lng); ...
     sind(0)];
P_ss_w = REF.R_oplus * 10^3 * [ ...
   6.604123658538473; ...
                   0; ...
                   0];

G_max_ss_tx_w = 38;
G_max_ss_rx_w = 40;
Phi0_ss_w = 4;
T_ss_w = 1000;
pd_ss_w = -58;

G_max_es_tx_w = 50;
Eff_es_tx_w = 0.7;
D_es_rx_w = 1.2;
T_es_w = 150;
pd_es_w = -42;

% Interfering system.

lat = 20;
lng = 5;

P_es_i = REF.R_oplus * 10^3 * ...
    [cosd(lat) * cosd(lng); ...
     cosd(lat) * sind(lng); ...
     sind(lat)];
P_es_i = REF.R_oplus * 10^3 * [ ...
   0.936483555662590; ...
   0.081931694698925; ...
   0.339863629117524];

P_ss_i = REF.R_gso * 10^3 * ...
    [cosd(0) * cosd(lng); ...
     cosd(0) * sind(lng); ...
     sind(0)];
P_ss_i = REF.R_oplus * 10^3 * [ ...
   6.578992974178288; ...
   0.575587302657302; ...
                   0];

G_max_ss_tx_i = 38;
G_max_ss_rx_i = 40;
Phi0_ss_i = 4;
T_ss_i = 1000;
pd_ss_i = -58;

G_max_es_tx_i = 50;
Eff_es_tx_i = 0.7;
D_es_rx_i = 1.2;
T_es_i = 150;
pd_es_i = -42;

% EPFD requirement.

BW_ref_up = 40e3;
BW_ref_dn = 40e3;

% Geometry.

V_es_w_ss_w = P_ss_w - P_es_w;
d_es_w_ss_w = sqrt(V_es_w_ss_w' * V_es_w_ss_w)
v_es_w_ss_w = V_es_w_ss_w / d_es_w_ss_w;
theta_es_w_ss_w = 0

d_ss_w_es_w = d_es_w_ss_w;
v_ss_w_es_w = -v_es_w_ss_w;
theta_ss_w_es_w = 0

V_es_i_ss_i = P_ss_i - P_es_i;
d_es_i_ss_i = sqrt(V_es_i_ss_i' * V_es_i_ss_i)
v_es_i_ss_i = V_es_i_ss_i / d_es_i_ss_i;
theta_es_i_ss_i = 0

d_ss_i_es_i = d_es_i_ss_i;
v_ss_i_es_i = -v_es_i_ss_i;
theta_ss_i_es_i = 0

V_es_w_ss_i = P_ss_i - P_es_w;
d_es_w_ss_i = sqrt(V_es_w_ss_i' * V_es_w_ss_i)
v_es_w_ss_i = V_es_w_ss_i / d_es_w_ss_i;
theta_es_w_ss_i = acosd(v_es_w_ss_w' * v_es_w_ss_i)

d_ss_i_es_w = d_es_w_ss_i
v_ss_i_es_w = -v_es_w_ss_i;
theta_ss_i_es_w = acosd(v_ss_i_es_i' * v_ss_i_es_w)

V_es_i_ss_w = P_ss_w - P_es_i;
d_es_i_ss_w = sqrt(V_es_i_ss_w' * V_es_i_ss_w)
v_es_i_ss_w = V_es_i_ss_w / d_es_i_ss_w;
theta_es_i_ss_w = acosd(v_es_i_ss_i' * v_es_i_ss_w)

d_ss_w_es_i = d_es_i_ss_w
v_ss_w_es_i = -v_es_i_ss_w;
theta_ss_w_es_i = acosd(v_ss_w_es_w' * v_ss_w_es_i)

warning off

% Uplink.

gain_es_w_ss_w = gso_gso.APEREC013V01(G_max_es_tx_w, Eff_es_tx_w, theta_es_w_ss_w)
gain_ss_w_es_w = gso_gso.APSREC408V01(theta_ss_w_es_w, Phi0_ss_w, 'GainMax', G_max_ss_rx_w)

lambda_up = REF.c / f_Hz_up;
pl_es_w_ss_w = 20 * log10(4 * pi * d_es_w_ss_w / lambda_up)

C_up = pd_es_w + gain_es_w_ss_w - pl_es_w_ss_w + gain_ss_w_es_w
N_up = REF.boltzmann_k_dB + 10*log10(T_ss_w)

gain_es_i_ss_w = gso_gso.APEREC013V01(G_max_es_tx_i, Eff_es_tx_i, theta_es_i_ss_w)
gain_ss_w_es_i = gso_gso.APSREC408V01(theta_ss_w_es_i, Phi0_ss_w, 'GainMax', G_max_ss_rx_w)

pl_es_i_ss_w = 20 * log10(4 * pi * d_es_i_ss_w / lambda_up)

I_up = pd_es_i + gain_es_i_ss_w - pl_es_i_ss_w + gain_ss_w_es_i

sl_es_i_ss_w = 10 * log10(4 * pi * d_es_i_ss_w ^ 2)

EPFD_up =  pd_es_i + gain_es_i_ss_w - sl_es_i_ss_w + gain_ss_w_es_i - gain_ss_w_es_w + 10 * log10(BW_ref_up)

% Downlink.

gain_ss_w_es_w = gso_gso.APSREC408V01(theta_ss_w_es_w, Phi0_ss_w, 'GainMax', G_max_ss_tx_w)
gain_es_w_ss_w = gso_gso.APERR_020V01(D_es_rx_w, f_MHz_dn, theta_es_w_ss_w)

lambda_dn = REF.c / f_Hz_dn;
pl_ss_w_es_w = 20 * log10(4 * pi * d_ss_w_es_w / lambda_dn)

C_dn = pd_ss_w + gain_ss_w_es_w - pl_ss_w_es_w + gain_es_w_ss_w
N_dn = REF.boltzmann_k_dB + 10*log10(T_es_w)

gain_ss_i_es_w = gso_gso.APSREC408V01(theta_ss_i_es_w, Phi0_ss_i, 'GainMax', G_max_ss_tx_i)
gain_es_w_ss_i = gso_gso.APERR_020V01(D_es_rx_w, f_MHz_dn, theta_es_w_ss_i)

pl_ss_i_es_w = 20 * log10(4 * pi * d_ss_i_es_w / lambda_dn)

I_dn = pd_ss_i + gain_ss_i_es_w - pl_ss_i_es_w + gain_es_w_ss_i

sl_ss_i_es_w = 10 * log10(4 * pi * d_ss_i_es_w ^ 2)

EPFD_dn =  pd_ss_i + gain_ss_i_es_w - sl_ss_i_es_w + gain_es_w_ss_i - gain_es_w_ss_w + 10 * log10(BW_ref_dn)

warning on

% keyboard
