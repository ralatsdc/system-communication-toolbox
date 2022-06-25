% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function [wantedSystem, interferingSystem, upPerformance, isPerformance, dnPerformance, assignments] = Simulate(doPlot)

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
  [wantedSystem, interferingSystem] = example.getSystems();
  
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
    example.Plot(runLabel, wantedSystem, interferingSystem, upPerformance, isPerformance, dnPerformance);

  end % if

end % Simulate()
