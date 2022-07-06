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
function [wantedSystem, interferingSystem, upPerformance, isPerformance, dnPerformance, assignments] = Simulate(doPlot)
% Compute the uplink, inter-satellite, and downlink performance of a
% wanted GSO system in the presence of an interfering LEO
% constellation.
%
% Parameters
%   doPlot - Flag to indicate plotting, or not
%
% Returns
%   wantedSystem - Wanted GSO system
%   interferingSystem - Interfering LEO system
%   upPerformance - Wanted system uplink performance
%   isPerformance - Wanted system uplink performance in the presence
%     of interfering system inter-satellite links
%   dnPerformance - Wanted system downlink performance
%   assignments - Interfering system beam assignments
    
  if nargin < 1
    doPlot = 1;

  end % if

  % Assign simulation constants
  epoch_0 = datenum(2014, 10, 20, 19, 5, 0); % Epoch date number
  numSmpES = 1; % Ratio of the number of Earth stations to the
                % number for which asisgnment is attempted
  numSmpBm = 1; % Ratio of the number of Beams to the number which
                % is assigned

  % Assign beam assignment constants
  assignmentDNm = epoch_0 + [0 : 10 : 1000] / 86400; % Date number
  
  % Assign performance calculation constants
  performanceDNm = epoch_0 + [0 : 1 : 1000] / 86400; % Date number
  ref_bw = 40; % Article 22 reference bandwith [kHz]
  
  % Construct systems
  [wantedSystem, interferingSystem] = simulate_gso_leo.getSystems();
  
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
  wantedSystem.assignBeams([], [], epoch_0, 'Method', 'random');
  nADN = length(assignmentDNm);
  assignments(nADN, 1) = Assignment();
  parfor iADN = 1:nADN
    assignments(iADN) = interferingSystem.assignBeams([], [], assignmentDNm(iADN), 'Method', 'random');
    
  end % for
  toc
  
  % Compute performance
  disp('Compute performance ...');
  tic
  nPDN = length(performanceDNm);
  upPerformance(nPDN, 1) = Performance();
  isPerformance(nPDN, 1) = Performance();
  dnPerformance(nPDN, 1) = Performance();
  parfor iPDN = 1:nPDN
    iADN = max(find(performanceDNm(iPDN) >= assignmentDNm));
    
    interferingSystem.apply(assignments(iADN));

    warning('off');
    
    upPerformance(iPDN) = wantedSystem.computeUpLinkPerformance( ...
        performanceDNm(iPDN), interferingSystem, numSmpES, numSmpBm, ref_bw);
    isPerformance(iPDN) = wantedSystem.computeUpLinkPerformance( ...
        performanceDNm(iPDN), interferingSystem, numSmpES, numSmpBm, ref_bw, 'DoIS', 1);
    dnPerformance(iPDN) = wantedSystem.computeDownLinkPerformance( ...
        performanceDNm(iPDN), interferingSystem, numSmpES, numSmpBm, ref_bw);
    
    warning('on');
    
  end % for
  toc
  
  save(sprintf('mat/simulation-example-%s.mat', runLabel));

  if doPlot
    simulate_gso_leo.Plot(runLabel, wantedSystem, interferingSystem, upPerformance, isPerformance, dnPerformance);

  end % if

end % Simulate()
