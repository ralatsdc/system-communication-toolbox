% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function Plot(d_terminal, plotLabel, runLabel, ...
              wantedLink, interferingSystem, ...
              iePerformance, ieResults, titleStr, subtitleStr)
% Plot:
% - Terrestrial link Earth station receive and NGSO system
%   Earth station in motion transmit gain patterns
% - Empirical CDF of I/N
% - Time history of I/N
% - Time history of distance between interfering stations
% - Time history of distance between interfering and wanted stations
% - Time history of transmit offset angles
% - Time history of receive offset and scan angles
% - Time history of transmit and receive gain
%
% Parameters
%   d_terminal - ?
%   plotLabel - Label for naming plot files
%   runLabel - Label for naming run files
%   wantedLink - The wanted link
%   interferingSystem - The interfering LEO system
%   iePerformance - The performance of the wanted link
%   ieResults - The intermediate results from the performance
%     computation
%   titleStr - Title of the plot
%   subtitleStr - Subtitle of the plot

  light_yellow = [254, 209,   0] / 256;  % Define Colors
  dark_yellow  = [215, 169,   0] / 256;
  orange       = [256, 127,  69] / 256;
  brown        = [ 91,  43,  47] / 256;
  green        = [130, 124,  52] / 256;
  blue         = [  0, 115, 207] / 256;

  off = [0.05, 0.05, 0.05, 0.05];  % Set offsets

  % == Plot terrestrial link Earth station receive and NGSO system
  % Earth station in motion transmit gain patterns

  ter_es = wantedLink.receiveStation;
  ngso_esim = interferingSystem.earthStations(1);

  phi_off_axis = [-180 : 0.1 : 180];
  theta_off_axis = ones(size(phi_off_axis)) * 90;
  phi_scan = zeros(size(phi_off_axis));
  theta_scan = zeros(size(phi_off_axis));
  warning('off');
  [A_T, A_A, A_E, fH] = ter_es.receiveAntenna.pattern.gain( ...
  phi_off_axis, theta_off_axis, phi_scan, theta_scan, 'PlotFlag', true);
  warning('on');
  set(get(gca, 'Children'), 'LineWidth', 1.5)
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  set(get(gcf, 'Children'), 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  off = [0.05, 0.05, 0.05, 0.05];
  PlotUtility.trim_plot(off);
  % TODO: Use -h- or -v- correctly
  print(sprintf('simulate-esim-at-terminal-ter-es-rx-pattern-h-%s.pdf', runLabel), '-dpdf');
  pause(1); close(fH);

  theta_off_axis = [0 : 0.1 : 180];
  phi_off_axis = zeros(size(theta_off_axis));
  phi_scan = zeros(size(theta_off_axis));
  theta_scan = zeros(size(theta_off_axis));
  warning('off');
  [A_T, A_A, A_E, fH] = ter_es.receiveAntenna.pattern.gain( ...
  phi_off_axis, theta_off_axis, phi_scan, theta_scan, 'PlotFlag', true);
  warning('on');
  set(get(gca, 'Children'), 'LineWidth', 1.5)
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  set(get(gcf, 'Children'), 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  off = [0.05, 0.05, 0.05, 0.05];
  PlotUtility.trim_plot(off);
  % TODO: Use -h- or -v- correctly
  print(sprintf('simulate-esim-at-terminal-ter-es-rx-pattern-v-%s.pdf', runLabel), '-dpdf');
  pause(1); close(fH);

  phi = [0 : 0.1 : 180];
  warning('off');
  [G, Gx, fH] = ngso_esim.transmitAntenna.pattern.gain(phi, 'PlotFlag', true);
  warning('on');
  set(get(gca, 'Children'), 'LineWidth', 1.5)
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  set(get(gcf, 'Children'), 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  off = [0.05, 0.05, 0.05, 0.05];
  PlotUtility.trim_plot(off);
  print(sprintf('simulate-esim-at-terminal-leo-es-tx-pattern-%s.pdf', runLabel), '-dpdf');
  pause(1); close(fH);

  % == Plot empirical CDF of I/N

  I_to_N = cat(1, iePerformance.I) - cat(1, iePerformance.N);
  [F, X] = ecdf(I_to_N);

  fH = figure(); hold off;

  h = [];
  h = [h, semilogy(X, 100 * (1 - F), '-', 'Color', 'k')]; hold on;
  % axis([-80, 30, 10^(-4), 10^(2)]);
  limits = axis;
  x1 = limits(1); x2 = limits(2); xW = x2 - x1;
  y1 = limits(3); y2 = limits(4); yW = log10(y2) - log10(y1);
  h = [h, semilogy([-6, -6], [y1, y2], 'r')];
  h = [h, semilogy(X, 100 * (1 - F), '-', 'Color', 'k')]; hold on;
  set(h, 'LineWidth', 1.5);
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');

  h = [];
  h = [h, xlabel('I/N [dB]')];
  h = [h, ylabel('Percent')];
  h = [h, title(titleStr)];
  h = [h, subtitle(subtitleStr)];
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');

  PlotUtility.trim_plot(off);
  print_plot(d_terminal, plotLabel, 'cdf', runLabel);
  pause(1); close(fH);
  return

  % == Plot time history of I/N

  fH = figure(); hold off;
  h = [];
  h = [h, plot(I_to_N)];
  set(h, 'LineWidth', 1.5);
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  h = [];
  h = [h, xlabel('Sample')];
  h = [h, ylabel('I/N [dB]')];
  h = [h, title(titleStr)];
  h = [h, subtitle('I/N')];
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');

  PlotUtility.trim_plot(off);
  print_plot(d_terminal, plotLabel, 'i-to-n', runLabel);
  pause(1); close(fH);
  
  % == Plot time history of distance between interfering stations

  d_i_i = cat(1, ieResults.d_i_i);
  fH = figure(); hold off;
  h = [];
  h = [h, plot(d_i_i)]; hold on;
  set(h, 'LineWidth', 1.5);
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  h = [];
  h = [h, xlabel('Sample')];
  h = [h, ylabel('Distance [km]')];
  h = [h, title(titleStr)];
  h = [h, subtitle('Distance Between Interfering Stations')];
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');

  PlotUtility.trim_plot(off);
  print_plot(d_terminal, plotLabel, 'd-i-i', runLabel);
  pause(1); close(fH);

  % == Plot time history of distance between interfering and wanted
  % stations

  d_i_w = cat(1, ieResults.d_i_w);
  fH = figure(); hold off;
  h = [];
  h = [h, plot(d_i_w)]; hold on;
  set(h, 'LineWidth', 1.5);
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  h = [];
  h = [h, xlabel('Sample')];
  h = [h, ylabel('Distance [km]')];
  h = [h, title(titleStr)];
  h = [h, subtitle('Distance Between Interfering and Wanted Stations')];
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');

  PlotUtility.trim_plot(off);
  print_plot(d_terminal, plotLabel, 'd-i-w', runLabel);
  pause(1); close(fH);

  % == Plot time history of transmit offset angles

  theta_t_i = cat(1, ieResults.theta_t_i);
  theta_t_i_f = cat(1, ieResults.theta_t_i_f);
  fH = figure(); hold off;
  h = [];
  h = [h, plot(theta_t_i)]; hold on;
  h = [h, plot(theta_t_i_f)];
  set(h, 'LineWidth', 1.5);
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  h = [];
  h = [h, xlabel('Sample')];
  h = [h, ylabel('Angle [deg]')];
  h = [h, title(titleStr)];
  h = [h, subtitle('Transmit Offset Angles')];
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');

  PlotUtility.trim_plot(off);
  print_plot(d_terminal, plotLabel, 'angles-t', runLabel);
  pause(1); close(fH);

  % == Plot time history of receive offset and scan angles

  phi_r_w_o = cat(1, ieResults.phi_r_w_o);
  theta_r_w_o = cat(1, ieResults.theta_r_w_o);
  phi_r_w_s = cat(1, ieResults.phi_r_w_s);
  psi_r_w_s = cat(1, ieResults.psi_r_w_s);
  fH = figure(); hold off;
  h = [];
  h = [h, plot(phi_r_w_o)]; hold on;
  h = [h, plot(theta_r_w_o)];
  h = [h, plot(phi_r_w_s)];
  h = [h, plot(psi_r_w_s)];
  set(h, 'LineWidth', 1.5);
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  h = [];
  h = [h, xlabel('Sample')];
  h = [h, ylabel('Angle [deg]')];
  h = [h, title(titleStr)];
  h = [h, subtitle('Receive Offset and Scan Angles')];
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');

  PlotUtility.trim_plot(off);
  print_plot(d_terminal, plotLabel, 'angles-r', runLabel);
  pause(1); close(fH);

  % == Plot time history of transmit and receive gain

  G_t_i = cat(1, ieResults.G_t_i);
  G_r_w = cat(1, ieResults.G_r_w);
  fH = figure(); hold off;
  h = [];
  h = [h, plot(G_t_i)]; hold on;
  h = [h, plot(G_r_w)];
  set(h, 'LineWidth', 1.5);
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  h = [];
  h = [h, xlabel('Sample')];
  h = [h, ylabel('Gain [dB]')];
  h = [h, title(titleStr)];
  h = [h, subtitle('Transmit and Receive Gain')];
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');

  PlotUtility.trim_plot(off);
  print_plot(d_terminal, plotLabel, 'gains', runLabel);
  pause(1); close(fH);

end % Plot()

 function print_plot(d_terminal, plotLabel, identifier, runLabel)
  if d_terminal > 0
    print(sprintf('simulate-esim-at-terminal-north-%d-%s-%s-ie-%s.pdf', ...
                  d_terminal * 1000, plotLabel, identifier, runLabel), '-dpdf');

  else
    print(sprintf('simulate-esim-at-terminal-south-%d-%s-%s-ie-%s.pdf', ...
                  -d_terminal * 1000, plotLabel, identifier, runLabel), '-dpdf');

  end % if

end % print_plot()
