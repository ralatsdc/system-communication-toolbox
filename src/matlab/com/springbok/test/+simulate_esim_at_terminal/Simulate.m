% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function [wantedUserEquipmentLink, wantedBaseStationLink, interferingSystem, ...
          assignments, uePerformance, bsPerformance] = Simulate(d_terminal)
% Simulate terrestrial network performance in the presences on an
% interfering LEO system with an ESIM at a terminal.
%
% Parameters
%   d_terminal - Distance North from base station to terminal [km]
%
% Returns
%   wantedUserEquipmentLink - The user equipment of the wanted
%     terrestrial network
%   wantedBaseStationLink - The wanted base station of the terrestrial
%     network
%   interferingSystem - The interfering LEO system
%   assignments - Interfering system beam assignments
%   uePerformance - User equipment link performance
%   bsPerformance - Base station link performance

  doCheck = 0;  % Do not test inputs

  % Construct wanted link and interfering system
  [wantedUserEquipmentLink, wantedBaseStationLink, userEquipment, baseStation] ...
      = simulate_esim_at_terminal.getWntLink(doCheck);
  [interferingSystem, interferingEarthStations, interferingSpaceStations] ...
      = simulate_esim_at_terminal.getIntSystem(d_terminal, baseStation);

  % Assign simulation constants
  dNm_s = interferingSystem.earthStations(1).dNm_s;
  assignmentDNm = [dNm_s(1) : 5.000969395041466e-06 : dNm_s(end)];  % Date numbers for beam assignements
  performanceDNm = assignmentDNm;  % Date numbers for link performance
  numSmpES = 1; % Ratio of the number of Earth stations to the
                % number for which asisgnment is attempted
  numSmpBm = 1; % Ratio of the number of Beams to the number which
                % is assigned
  ref_bw = 40; % Article 22 reference bandwith [kHz]

  % Assign a run label
  runLabel = input('Enter a run label [yyyy-mm-dd-HHMMSS]: ');
  if isempty(runLabel)
    runLabel = datestr(now, 'yyyy-mm-dd-HHMMSS');
    
  end % if
  fprintf('run label: %s\n', runLabel);
  reply = input('Continue? Y/N [Y]: ', 's');
  if isempty(reply)
    reply = 'Y';
    
  else
    reply = upper(reply);
    
  end % if
  if ~strcmp(reply, 'Y')
    return;
    
  end % if

  % Assign beams
  disp('Assign beams ...');
  tic
  nADN = length(performanceDNm);
  assignments(nADN, 1) = Assignment();
  parfor iADN = 1:nADN
    assignments(iADN) = interferingSystem.assignBeams( ...
        [], [], assignmentDNm(iADN), 'Method', 'random', 'doCheck', doCheck);

  end % for
  toc

  % Compute performance
  disp('Compute performance ...');
  tic
  nPDN = length(performanceDNm);
  uePerformance(nPDN, 1) = Performance();
  bsPerformance(nPDN, 1) = Performance();
  parfor iPDN = 1:nPDN
    iADN = max(find(performanceDNm(iPDN) >= assignmentDNm));
    interferingSystem.apply(assignments(iADN));
    [uePerformance(iPDN), ueResults(iPDN, 1)] = wantedUserEquipmentLink.computePerformance( ...
        performanceDNm(iPDN), interferingSystem, numSmpES, numSmpBm, ref_bw, ...
        'DoIE', 1, 'PlDs', 0, 'DoRI', 1);
    [bsPerformance(iPDN), bsResults(iPDN, 1)] = wantedBaseStationLink.computePerformance( ...
        performanceDNm(iPDN), interferingSystem, numSmpES, numSmpBm, ref_bw, ...
        'DoIE', 1, 'PlDs', 0, 'DoRI', 1);

  end % for
  toc

  % Save everything
  if d_terminal > 0
    savFNm = sprintf('simulate-esim-at-terminal-north-%d-%s.mat', ...
                     d_terminal * 1000, runLabel);
  else
    savFNm = sprintf('simulate-esim-at-terminal-south-%d-%s.mat', ...
                     -d_terminal * 1000, runLabel);
  end % if
  fprintf('Saving %s ...\n', savFNm);
  save(savFNm, '-v7.3');

end % Simulate()