% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

warning off

clear all

gso_gso.EpfdTest_C

save('EpfdTest.mat', 'up_Performance', 'dn_Performance')

clear all

gso_gso.epfd_test

up_Performance_expected = [C_up; N_up; I_up; EPFD_up];
dn_Performance_expected = [C_dn; N_dn; I_dn; EPFD_dn];

save('epfd_test.mat', 'up_Performance_expected', 'dn_Performance_expected')

load('EpfdTest.mat', 'up_Performance', 'dn_Performance')

up_Performance_expected

up_Performance

dn_Performance_expected

dn_Performance
