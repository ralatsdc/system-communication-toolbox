% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function Plot(runLabel, wantedSystem, interferingSystem, upPerformance, isPerformance, dnPerformance)

  % Define Colors
  light_yellow = [254, 209,   0] / 256;
  dark_yellow  = [215, 169,   0] / 256;
  orange       = [256, 127,  69] / 256;
  brown        = [ 91,  43,  47] / 256;
  green        = [130, 124,  52] / 256;
  blue         = [  0, 115, 207] / 256;
  
  % == Plot GSO Earth station receive and NGSO space station transmit gain patterns
  
  phi = [0 : 0.1 : 90];
  
  gso_es = wantedSystem.earthStations(1);
  ngso_ss = interferingSystem.spaceStations(1);
  
  warning('off');
  gain_gso_es_rx = gso_es.receiveAntenna.pattern.gain(phi, gso_es.receiveAntenna.options{:});
  gain_ngso_ss_tx = ngso_ss.transmitAntenna.pattern.gain(phi, ngso_ss.transmitAntenna.options{:});
  warning('on');
  
  figure(1);
  
  hold off;
  
  h = [];
  
  h = [h, plot(phi, gain_gso_es_rx, 'Color', blue)];
  
  hold on;
  
  h = [h, plot(phi, gain_ngso_ss_tx, 'Color', light_yellow)];
  
  set(h, 'LineWidth', 1.5);
  
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  
  warning('off');
  
  h = [];
  
  h = [h, xlabel('Phi (degrees)')];
  h = [h, ylabel('Gain (dB)')];
  
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  
  warning('on');
  
  limits = axis;
  x1 = limits(1); x2 = limits(2); xW = x2 - x1;
  y1 = limits(3); y2 = limits(4); yW = y2 - y1;
  
  h = [];
  
  h = [h, text(x2 - 0.05 * xW, y2 - 0.05 * yW, 'GSO ES Rx', 'Color', blue)];
  h = [h, text(x2 - 0.05 * xW, y2 - 0.10 * yW, 'NGSO SS Tx', 'Color', dark_yellow)];
  
  set(h, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
  
  off = [0.05, 0.05, 0.05, 0.05];
  
  PlotUtility.trim_plot(off);
  
  print(sprintf('doc/simulation-example-pattern-%s.pdf', runLabel), '-dpdf');
  
  % == Plot Article 22 limits and EPFD IS
  
  [freq_is_s, EPFD_is_s] = ecdf(cat(1, isPerformance.EPFD));
  
  freq_art_22 = [   0.0    99.99];
  EPFD_art_22 = [-160.0  -160.0 ];
  
  figure(2);
  
  hold off;
  
  h = [];
  
  h = [h, semilogy(EPFD_art_22, 100 - freq_art_22, '-', 'Color', light_yellow)];
  
  hold on;
  
  h = [h, semilogy(EPFD_is_s, 100 * (1 - freq_is_s), '-', 'Color', blue)];
  
  set(h, 'LineWidth', 1.5);
  
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  
  h = [];
  
  h = [h, xlabel('dBW/m^2 at 40 kHz')];
  h = [h, ylabel('Percent Time EPFD IS Exceeded')];
  
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  
  limits = axis;
  x1 = limits(1); x2 = limits(2); xW = x2 - x1;
  y1 = limits(3); y2 = limits(4); yW = log10(y2) - log10(y1);
  
  h = [];
  
  h = [h, plot(x1 + [0.050, 0.15] * xW, y1 .* 10.^([0.10, 0.10] * yW), '-', 'Color', light_yellow)];
  h = [h, plot(x1 + [0.050, 0.15] * xW, y1 .* 10.^([0.05, 0.05] * yW), '-', 'Color', blue)];
  
  set(h, 'LineWidth', 1.5);
  
  h = [];
  
  h = [h, text(x1 + 0.175 * xW, y1 * 10^(0.10 * yW), 'Article 22 Limit IS', 'Color', dark_yellow)];
  h = [h, text(x1 + 0.175 * xW, y1 * 10^(0.05 * yW), 'EPFD IS', 'Color', blue)];
  
  set(h, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
  
  off = [0.05, 0.05, 0.05, 0.05];
  
  PlotUtility.trim_plot(off);
  
  print(sprintf('doc/simulation-example-epfd-is-%s.pdf', runLabel), '-dpdf');
  
  % == Plot Article 22 limits and EPFD Up
  
  [freq_up_s, EPFD_up_s] = ecdf(cat(1, upPerformance.EPFD));
  
  freq_art_22 = [   0.0    99.99];
  EPFD_art_22 = [-160.0  -160.0 ];
  
  figure(3);
  
  hold off;
  
  h = [];
  
  h = [h, semilogy(EPFD_art_22, 100 - freq_art_22, '-', 'Color', light_yellow)];
  
  hold on;
  
  h = [h, semilogy(EPFD_up_s, 100 * (1 - freq_up_s), '-', 'Color', blue)];
  
  set(h, 'LineWidth', 1.5);
  
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  
  h = [];
  
  h = [h, xlabel('dBW/m^2 at 40 kHz')];
  h = [h, ylabel('Percent Time EPFD Up Exceeded')];
  
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  
  limits = axis;
  x1 = limits(1); x2 = limits(2); xW = x2 - x1;
  y1 = limits(3); y2 = limits(4); yW = log10(y2) - log10(y1);
  
  h = [];
  
  h = [h, plot(x1 + [0.050, 0.15] * xW, y1 .* 10.^([0.10, 0.10] * yW), '-', 'Color', light_yellow)];
  h = [h, plot(x1 + [0.050, 0.15] * xW, y1 .* 10.^([0.05, 0.05] * yW), '-', 'Color', blue)];
  
  set(h, 'LineWidth', 1.5);
  
  h = [];
  
  h = [h, text(x1 + 0.175 * xW, y1 * 10^(0.10 * yW), 'Article 22 Limit Up', 'Color', dark_yellow)];
  h = [h, text(x1 + 0.175 * xW, y1 * 10^(0.05 * yW), 'EPFD Up', 'Color', blue)];
  
  set(h, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
  
  off = [0.05, 0.05, 0.05, 0.05];
  
  PlotUtility.trim_plot(off);
  
  print(sprintf('doc/simulation-example-epfd-up-%s.pdf', runLabel), '-dpdf');
  
  % == Plot Article 22 limits and EPFD Down
  
  [freq_dn_s, EPFD_dn_s] = ecdf(cat(1, dnPerformance.EPFD));
  
  freq_art_22 = [   0.0   99.5   99.74  99.857 99.954 99.984 99.991 99.997 99.997 99.9993];
  EPFD_art_22 = [-181.9 -178.4 -173.4 -173.0 -164.0 -161.6 -161.4 -160.8 -160.5 -160.0   ];
  
  figure(4);
  
  hold off;
  
  h = [];
  
  h = [h, semilogy(EPFD_art_22, 100 - freq_art_22, '-', 'Color', light_yellow)];
  
  hold on;
  
  h = [h, semilogy(EPFD_dn_s, 100 * (1 - freq_dn_s), '-', 'Color', blue)];
  
  set(h, 'LineWidth', 1.5);
  
  set(gca, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  
  h = [];
  
  h = [h, xlabel('dBW/m^2 at 40 kHz')];
  h = [h, ylabel('Percent Time EPFD Down Exceeded')];
  
  set(h, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'demi');
  
  limits = axis;
  x1 = limits(1); x2 = limits(2); xW = x2 - x1;
  y1 = limits(3); y2 = limits(4); yW = log10(y2) - log10(y1);
  
  h = [];
  
  h = [h, plot(x1 + [0.050, 0.15] * xW, y1 .* 10.^([0.10, 0.10] * yW), '-', 'Color', light_yellow)];
  h = [h, plot(x1 + [0.050, 0.15] * xW, y1 .* 10.^([0.05, 0.05] * yW), '-', 'Color', blue)];
  
  set(h, 'LineWidth', 1.5);
  
  h = [];
  
  h = [h, text(x1 + 0.175 * xW, y1 * 10^(0.10 * yW), 'Article 22 Limit Down', 'Color', dark_yellow)];
  h = [h, text(x1 + 0.175 * xW, y1 * 10^(0.05 * yW), 'EPFD Down', 'Color', blue)];
  
  set(h, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
  
  off = [0.05, 0.05, 0.05, 0.05];
  
  PlotUtility.trim_plot(off);
  
  print(sprintf('doc/simulation-example-epfd-dn-%s.pdf', runLabel), '-dpdf');
  
end % Plot()
