% Copyright (C) 2022 Springbok LLC
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or (at
% your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
% 
function [wantedUserEquipmentLink, wantedBaseStationLink, interferingSystem, ...
          assignments, uePerformance, bsPerformance] = Simulate(h_start, fuselage_loss_offset)
% Simulate terrestrial network performance in the presence of an
% interfering LEO system with an ESIM at altitude.
%
% Parameters
%   h_start - Altitude [km]
%   fuselage_loss_offset - Fuselage loss offset [dB]
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
      = simulate_esim_at_altitude.getWntLink(doCheck);
  [interferingSystem, interferingEarthStations, interferingSpaceStations] ...
      = simulate_esim_at_altitude.getIntSystem(h_start, baseStation);

  % Assign simulation constants
  assignmentDNm = interferingSystem.earthStations(1).dNm_s;  % Date numbers for beam assignements
  performanceDNm = assignmentDNm;  % Date numbers for link performance
  numSmpES = 1;  % Ratio of the number of Earth stations to the
                 % number for which asisgnment is attempted
  numSmpBm = 1;  % Ratio of the number of Beams to the number which
                 % is assigned
  ref_bw = 40;  % Article 22 reference bandwith [kHz]

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
        'DoIE', 1, 'PlDs', 0, 'DoRI', 1, 'FuselageLossOffset', fuselage_loss_offset);
    [bsPerformance(iPDN), bsResults(iPDN, 1)] = wantedBaseStationLink.computePerformance( ...
        performanceDNm(iPDN), interferingSystem, numSmpES, numSmpBm, ref_bw, ...
        'DoIE', 1, 'PlDs', 0, 'DoRI', 1, 'FuselageLossOffset', fuselage_loss_offset);

  end % for
  toc

  % Save everything
  savFNm = sprintf('simulate-esim-at-altitude-%d-%d-%s.mat', h_start, fuselage_loss_offset, runLabel);
  fprintf('Saving %s ...\n', savFNm);
  save(savFNm, '-v7.3');

end % Simulate()
