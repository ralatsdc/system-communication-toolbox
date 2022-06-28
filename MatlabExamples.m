
pool = gcp;

disp(' ')
disp('Simulating wanted GSO system performance');
disp('in the presence of an interfering LEO system ...');
disp(' ')
doPlot = 1;
[wntSystem, ...
 intSystem, ...
 upPerformance, ...
 isPerformance, ...
 dnPerformance, ...
 assignments] = simulate_gso_leo.Simulate(doPlot);
pause(1);
close all;

disp(' ')
disp('Simulating wanted terrestrial network performance')
disp('in the presence of an interfering LEO system');
disp('with an ESIM at altitude ...');
disp(' ')
disp('This may take a few minutes ...')
disp(' ')
h_start = 1.0;  % Altitude [km]
fuselage_loss_offset = 0.0;  % [dB]
[wntUeLink, ...
 wntBsLink, ...
 intSystem, ...
 assignments, ...
 uePerformance, ...
 bsPerformance] = simulate_esim_at_altitude.Simulate(h_start, fuselage_loss_offset);
simulate_esim_at_altitude.PlotAll;
close all;

disp(' ')
disp('Simulating wanted terrestrial network performance')
disp('in the presence of an interfering LEO system');
disp('with an ESIM at a terminal ...');
disp(' ')
disp('This may take a few minutes ...')
disp(' ')
d_terminal = 0.1;  % Distance North from base station to terminal [km]
[wntUeLink, ...
 wntBsLink, ...
 intSystem, ...
 assignments, ...
 uePerformance, ...
 bsPerformance] = simulate_esim_at_terminal.Simulate(d_terminal);
simulate_esim_at_terminal.PlotAll;
pause();
close all;
