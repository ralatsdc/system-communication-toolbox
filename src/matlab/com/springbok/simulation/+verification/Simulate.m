% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

function SIM = Simulate()

  % Assign simulation constants
  epoch_0 = datenum(2014, 10, 20, 19, 5, 0); % Epoch date number
  doRenew = 0; % Create and save, rather than load, specification and systems

  % Get SpaceX system specification
  [orbits, cells, main] = verification.getOrbitsAndCells(epoch_0, doRenew);

  % Construct the wanted and interfering system
  [wantedSystem, interferingSystem] = verification.getSystems(orbits, cells, epoch_0);

  % Assign performance calculation constants
  dNm = epoch_0; % Calculation date number
  ref_bw_up = 40; % Article 22 reference bandwith [kHz]
  ref_bw_dn = 40; % Article 22 reference bandwith [kHz]
  ref_bw_is = 40; % Article 22 reference bandwith [kHz]

  % Compute performance
  wantedSystem.assignBeams([], [], dNm);
  interferingSystem.assignBeams([], [], dNm);

  warning('off');

  % Up link
  upPerformance = wantedSystem.computeUpLinkPerformance( ...
      dNm, interferingSystem, [], [], ref_bw_up);

  % Down link
  dnPerformance = wantedSystem.computeDownLinkPerformance( ...
      dNm, interferingSystem, [], [], ref_bw_dn);

  % Inter-satellite 
  wantedSystem.earthStations.emission.set_freq_mhz(11200);
  isPerformance = wantedSystem.computeUpLinkPerformance( ...
      dNm, interferingSystem, [], [], ref_bw_is, 'DoIS', 1);

  warning('on');

  SIM.up = upPerformance;
  SIM.dn = dnPerformance;
  SIM.is = isPerformance;
  
end % Simulate()
