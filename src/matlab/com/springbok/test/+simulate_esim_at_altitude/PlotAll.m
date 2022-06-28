% Plots all mat files in the simulation directory.
matFls = dir('simulate-esim-at-altitude-*.mat');
nFl = length(matFls);
for iFl = 1:nFl
  matFln = matFls(iFl).name;

  % Load results
  fprintf('Loading variables from %s ...\n', matFln);
  load(matFln, ...
       'h_start', 'fuselage_loss_offset', 'runLabel', ...
       'wantedUserEquipmentLink', 'wantedBaseStationLink', 'interferingSystem', ...
       'uePerformance', 'ueResults', 'bsPerformance', 'bsResults');

  % Define subtitle
  if fuselage_loss_offset ~= 0
    subtitleStr = sprintf('A-ESIM altitude = %d km, Fuselage Loss Offset = %d dB', ...
                          h_start, fuselage_loss_offset);

  else
    subtitleStr = sprintf('A-ESIM altitude = %d km', h_start);

  end % if

  % Plot user equipment link performance
  fprintf('Plotting %s for user equipment ...\n', runLabel);
  simulate_esim_at_altitude.Plot( ...
      h_start, fuselage_loss_offset, 'ue', runLabel, ...
      wantedUserEquipmentLink, interferingSystem, ...
      uePerformance, ueResults, ...
      'CDF of I/N - A-ESIM 3 into System A UE', subtitleStr);
  close('all');

  % Plot base station link performance
  fprintf('Plotting %s for base station ...\n', runLabel);
  simulate_esim_at_altitude.Plot( ...
      h_start, fuselage_loss_offset, 'bs', runLabel, ...
      wantedBaseStationLink, interferingSystem, ...
      bsPerformance, bsResults, ...
      'CDF of I/N - A-ESIM 3 into System A BS', subtitleStr);
  close('all');

  % Clean up
  fprintf('Clearing variables from %s ...\n', matFln);
  clear('h_start', 'fuselage_loss_offset', 'runLabel', ...
        'wantedUserEquipmentLink', 'wantedBaseStationLink', 'interferingSystem', ...
        'uePerformance', 'ueResults', 'bsPerformance', 'bsResults');

end % if
