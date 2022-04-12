classdef System < handle
% Manages a set of networks.

% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant)

    valid_losses = {'fuselage-loss'}

  end % properties (Constant)
    
  properties (SetAccess = protected, GetAccess = public)

    % An Earth station array
    earthStations
    % A space station array
    spaceStations
    % Propagation loss models to apply
    losses

    % Flag for avoiding GSO arc
    testAngleFromGsoArc
    % Angle for avoiding GSO arc
    angleFromGsoArc
    % Flag for avoiding low passes
    testAngleFromZenith
    % Angle for avoiding low passes
    angleFromZenith

    % Current date number
    dNm

    % Angle between space station position vector relative to the
    % Earth station and GSO arc
    theta_g
    % Angle between space station position vector relative to the
    % Earth station and Earth station zenith direction
    theta_z
    % Metric used to select space station for each Earth station
    metrics

    % A network array
    networks
    % Index of each Earth station assigned to a network
    idxNetES
    % Index of each space station assigned to a network
    idxNetSS

  end % properties

  methods

    function this = System(earthStations, spaceStations, losses, dNm, varargin)
    % Constructs a System.
    %
    % Parameters
    %   earthStations - An Earth station array
    %   spaceStations - A space station array
    %   losses - Propagation loss models to apply
    %   dNm - Current date number
    %
    % Options
    %   TestAngleFromGsoArc - Flag for avoiding GSO arc (default is
    %     1)
    %   AngleFromGsoArc - Angle for avoiding GSO arc [deg] (default
    %     is 10)
    %   TestAngleFromZenith - Flag for avoiding low passes (default
    %     is 1)
    %   AngleFromZenith - Angle for avoiding low passes [deg]
    %     (default is 60)

      % No argument constructor
      if nargin == 0
        return;

      end % if

      % Assign properties
      this.set_earthStations(earthStations);
      this.set_spaceStations(spaceStations);
      this.set_losses(losses);
      this.dNm = TypeUtility.set_numeric(dNm); % Set on construction,
                                               % or assignment only
      
      % Parse variable input arguments
      p = inputParser;
      p.addParamValue('TestAngleFromGsoArc', 1);
      p.addParamValue('AngleFromGsoArc', 10);
      p.addParamValue('TestAngleFromZenith', 1);
      p.addParamValue('AngleFromZenith', 60);
      p.parse(varargin{:});
      this.testAngleFromGsoArc = TypeUtility.set_numeric(p.Results.TestAngleFromGsoArc);
      this.angleFromGsoArc = TypeUtility.set_numeric(p.Results.AngleFromGsoArc);
      this.testAngleFromZenith = TypeUtility.set_numeric(p.Results.TestAngleFromZenith);
      this.angleFromZenith = TypeUtility.set_numeric(p.Results.AngleFromZenith);
      
      % Derive properties
      this.networks = Network();
      
    end % System()
    
    function that = copy(this)
    % Copies a System.
    %
    % Returns
    %   that - A new System instance
      nES = length(this.earthStations);
      for iES = 1:nES
        earthStations(iES, 1) = this.earthStations(iES).copy();
        
      end % for
      nSS = length(this.spaceStations);
      for iSS = 1:nSS
        spaceStations(iSS, 1) = this.spaceStations(iSS).copy();
        
      end % for
      that = System(earthStations, spaceStations, this.losses, this.dNm, ...
                    'testAngleFromGsoArc', this.testAngleFromGsoArc, ...
                    'testAngleFromZenith', this.testAngleFromZenith);

      that.set_theta_g(this.theta_g);
      that.set_theta_z(this.theta_z);
      that.set_metrics(this.metrics);
      nNet = length(this.networks);
      for iNet = 1:nNet
        networks(iNet, 1) = this.networks(iNet).copy();
      end % for iNet
      that.set_networks(networks);
      that.set_idxNetES(this.idxNetES);
      that.set_idxNetSS(this.idxNetSS);

    end % copy()

    function set_earthStations(this, earthStations)
    % Set the Earth stations.
    %
    % Parameters
    %   earthStations - The Earth stations
      if ~(isa(earthStations, 'EarthStation') ...
           || isa(earthStations, 'EarthStationInMotion'))
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be an instance of class "EarthStation" or "EarthStationInMotion"');
        throw(MEx);

      end % if
      this.earthStations = earthStations;

    end % if

    function set_spaceStations(this, spaceStations)
    % Set the space stations.
    %
    % Parameters
    %   spaceStations - The space stations
      if ~isa(spaceStations, 'SpaceStation')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be an instance of class "SpaceStation"');
        throw(MEx);

      end % if
      this.spaceStations = spaceStations;

    end % if

    function set_losses(this, losses)
    % Sets propagation loss models to apply
    %
    % Parameters
    %   losses - Propagation loss models to apply
      if ~iscell(losses)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be a cell array');
        throw(MEx);

      end % if
      if ~isempty(setdiff(losses, System.valid_losses))
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Unexpected loss model');
        throw(MEx);

      end % if
      this.losses = losses;

    end % if

    function set_theta_g(this, theta_g)
    % Sets Angle between space station position vector relative to
    % the Earth station and GSO arc.
    %
    % Parameters
    %   theta_g - Angle between space station position vector
    %     relative to the Earth station and GSO arc
      if ~isnumeric(theta_g)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.theta_g = theta_g;

    end % set_theta_g()

    function set_theta_z(this, theta_z)
    % Sets Angle between space station position vector relative to
    % the Earth station and Earth station zenith direction.
    %
    % Parameters
    %   theta_z - Angle between space station position vector
    %     relative to the Earth station and Earth station zenith
    %     direction
      if ~isnumeric(theta_z)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.theta_z = theta_z;

    end % set_theta_z()

    function set_metrics(this, metrics)
    % Sets metric used to select space station for each Earth
    % station.
    %
    % Parameters
    %   metrics - Metric used to select space station for each
    %     Earth station
      if ~isnumeric(metrics)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.metrics = metrics;

    end % set_metrics()

    function set_networks(this, networks)
    % Sets a network array.
    %
    % Parameters
    %   networks - A network array
      if ~isa(networks, 'Network')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'An array of "Network" instances is expected');
        throw(MEx);

      end % if
      this.networks = networks;

    end % set_networks()

    function set_idxNetES(this, idxNetES)
    % Sets index of each Earth station assigned to a network.
    %
    % Parameters
    %   idxNetES - Index of each Earth station assigned to a
    %     network
      if ~isnumeric(idxNetES)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.idxNetES = idxNetES;

    end % set_idxNetES()

    function set_idxNetSS(this, idxNetSS)
    % Sets index of each space station assigned to a network.
    %
    % Parameters
    %   idxNetSS - Index of each space station assigned to a
    %     network
      if ~isnumeric(idxNetSS)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.idxNetSS = idxNetSS;

    end % set_idxNetSS()

    function earthStations = get_assignedEarthStations(this)
    % Gets assigned Earth stations as a column vector.
    %
    % Returns
    %   earthStations - An array of Earth stations
      earthStations = cat(1, this.networks.earthStation);

    end % get_assignedEarthStations()

    function earthStationBeams = get_assignedEarthStationBeams(this)
    % Gets assigned Earth station beamss as a column vector.
    %
    % Returns
    %   earthStationBeams - An array of Earth station beams
      earthStationBeams = cat(1, this.networks.earthStationBeam);

    end % get_assignedEarthStationBeams()

    function spaceStations = get_assignedSpaceStations(this)
    % Gets assigned space stations as a column vector.
    %
    % Returns
    %   spaceStations - An array of space stations
      spaceStations = cat(1, this.networks.spaceStation);

    end % get_assignedSpaceStations()
      
    function spaceStationBeams = get_assignedSpaceStationBeams(this)
    % Gets assigned space station beams as a column vector.
    %
    % Returns
    %   spaceStationBeams - An array of space station beams
      spaceStationBeams = cat(1, this.networks.spaceStationBeam);

    end % get_assignedSpaceStationBeams()
      
    function assignment = assignBeams(this, idxSelES, numSmpSS, dNm, varargin)
    % Establish a one-to-one correspondence between each Earth
    % station and a space station and beam.
    %
    % Parameters
    %   idxSelES - Index of Earth stations selected for assignment
    %   numSmpSS - Number of samples of selected space stations
    %   dNm - Date number of assignment
    %
    % Options
    %   Method - Method for assigning space to Earth stations:
    %     'MaxElv', 'MaxSep', 'MinSep', 'Random' (default is
    %     'MaxElv')
    %   DoCheck - Flag for checking input values (default is 1)
    %
    % Returns
    %   assignment - Beam assignment instance
      
      % Assign index of selected Earth stations
      nES = length(this.earthStations);
      if isempty(idxSelES)
         idxSelES = [1:nES];
        
      else
        [nRow, nCol] = size(idxSelES);
        if (nRow ~= 1 && nCol ~= 1) || ~isempty(setdiff(idxSelES, [1:nES]))
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Index of selected Earth stations invalid');
          throw(MEx);

        end % if
        if nCol == 1
          idxSelES = idxSelES';

        end % if

      end % if
        
      % Assign index, and number of samples, of selected space
      % stations. The space station indexes are randomized for
      % sampling.
      nSS = length(this.spaceStations);
      idxSelSS = randperm(nSS);
      if isempty(numSmpSS)
        numSmpSS = nSS;

      elseif numSmpSS > nSS / 10
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Number of selected Space stations invalid');
        throw(MEx);

      end % if

      % Assign date number of assignement
      this.dNm = dNm;
      
      % Parse variable input arguments
      p = inputParser;
      p.addParamValue('Method', 'MaxElv');
      p.addParamValue('DoCheck', 1);
      p.parse(varargin{:});
      method = lower(TypeUtility.set_char(p.Results.Method));
      doCheck = TypeUtility.set_logical(p.Results.DoCheck);
      method_is_maxsep_or_minsep = 0;
      method_is_maxelv_or_random = 0;
      if ismember(method, {'maxsep', 'minsep'})
        method_is_maxsep_or_minsep = 1;
        
      elseif ismember(method, {'maxelv', 'random'})
        method_is_maxelv_or_random = 1;

      else
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Unexpected value for parameter "method"');
        throw(MEx);

      end % if

      % Reset so that stations and beams can be assigned
      this.reset();

      % Initialize angles, metrics, networks, and their station
      % indexes. No networks are assured.
      this.theta_g = NaN(nES, nSS);
      this.theta_z = NaN(nES, nSS);
      this.metrics = NaN(nES, nSS);
      this.networks(nES, 1) = Network();
      this.idxNetES = zeros(nES, 1);
      this.idxNetSS = zeros(nES, 1);

      % Assign space stations, and their position, for elimination
      % of each space station after assignment
      nSS = length(idxSelSS);
      r_ger_SS = cell(nSS, 1);
      for iSS = 1:nSS
        r_ger_SS{iSS} = this.spaceStations(idxSelSS(iSS)).compute_r_ger(dNm);

      end % for

      % Consider each selected Earth station in order to assign a
      % space station and beam
      for iES = idxSelES
        r_ger_ES = this.earthStations(iES).compute_r_ger(dNm);

        % Initialize local metrics, and indexes of assignable space
        % stations
        nSS = length(idxSelSS);
        theta_g = NaN(1, nSS);
        theta_z = NaN(1, nSS);
        metrics = NaN(1, nSS);

        % Consider a sample from the remaining space stations in
        % order to find the space station by the specified method
        for iSS = 1 : max(1, floor(nSS / numSmpSS)) : nSS

          % Compute angle between space station position vector
          % relative to the Earth station and GSO arc
          if method_is_maxsep_or_minsep || this.testAngleFromGsoArc
            theta_g(iSS) = System.computeAngleFromGsoArc(r_ger_SS{iSS}, r_ger_ES);
            this.theta_g(iES, idxSelSS(iSS)) = theta_g(iSS);

            % Skip the current space station if the current space
            % and Earth station require the current  Earth station
            % to broadcast too directly toward the GSO arc
            if this.testAngleFromGsoArc
              if theta_g(iSS) < this.angleFromGsoArc
                continue

              end % if

            end % if

            % Assign metric for selection
            if method_is_maxsep_or_minsep
              metrics(iSS) = theta_g(iSS);
              
            end % if

          end % if
          
          % Compute angle between space station position vector
          % relative to the Earth station and Earth station zenith
          % direction
          if method_is_maxelv_or_random || this.testAngleFromZenith
            theta_z(iSS) = System.computeAngleFromZenith(r_ger_SS{iSS}, r_ger_ES);
            this.theta_z(iES, idxSelSS(iSS)) = theta_z(iSS);

            % Skip the current space station if it is too near the
            % current Earth station horizon
            if this.testAngleFromZenith
              if theta_z(iSS) > this.angleFromZenith
                continue

              end % if

            end % if

            % Assign metric for selection
            if method_is_maxelv_or_random
              metrics(iSS) = theta_z(iSS);

            end % if

          end % if

          % Assign metric used to select the space station for the
          % current Earth station
          this.metrics(iES, idxSelSS(iSS)) = metrics(iSS);

        end % for iSS

        % Select a space station to assign to the current Earth
        % station
        mmetrics = metrics;
        nans = isnan( mmetrics );
        switch method

          case 'maxelv'

            % TODO: Rewrite Java friendly, or use Java utility

            % Find the minimum angle between space station position
            % vector relative to the Earth station and Earth
            % station zenith direction
            mmetrics(nans) = inf;
            [metric_sel, iSS_sel] = min(mmetrics);

          case 'maxsep'

            % TODO: Rewrite Java friendly, or use Java utility

            % Find the maximum angle between space station position
            % vector relative to the Earth station and GSO arc
            mmetrics(nans) = -inf;
            [metric_sel, iSS_sel] = max(mmetrics);

          case 'minsep'

            % TODO: Rewrite Java friendly, or use Java utility

            % Find the minimum angle between space station position
            % vector relative to the Earth station and GSO arc
            mmetrics(nans) = inf;
            [metric_sel, iSS_sel] = min(mmetrics);

          case 'random'

            % TODO: Rewrite Java friendly, or use Java utility

            % Find valid indexes of assigned space stations then
            % select one at random
            iSS_vld = find(~isnan(metrics));
            if ~isempty(iSS_vld)
              iSS_sel = iSS_vld(randi([1, length(iSS_vld)], 1, 1));

            else
              iSS_sel = [];

            end % if
              
          otherwise
            MEx = MException('Springbok:IllegalArgumentException', ...
                             ['The method for assigning beams must be ' ...
                              '"maxelv", "maxsep, "minsep", or "random"']);
            throw(MEx);

        end % switch

        % Assign a space station to the current Earth station
        if ~isempty(iSS_sel)
          beam = this.spaceStations(idxSelSS(iSS_sel)).assign( ...
              this.earthStations(iES).doMultiplexing);
          this.networks(iES) = Network( ...
              this.earthStations(iES), ...
              this.spaceStations(idxSelSS(iSS_sel)), beam, this.losses, ...
              'doCheck', doCheck);
          this.idxNetES(iES) = iES;
          this.idxNetSS(iES) = idxSelSS(iSS_sel);

          % Eliminate the space station index and position from
          % further assignment, if unavailable. Note that the space
          % station array is not used in the Earth station loop.
          if ~this.spaceStations(idxSelSS(iSS_sel)).isAvailable
            idxSelSS(iSS_sel) = [];
            r_ger_SS(iSS_sel) = [];

          end % if

        end % if

      end % for iES

      % Eliminate empty networks
      idxEmpty = find(this.idxNetES == 0);
      this.networks(idxEmpty) = [];
      this.idxNetES(idxEmpty) = [];
      this.idxNetSS(idxEmpty) = [];

      % Consider each network
      nNet = length(this.networks);
      isAvailable_SS = zeros(nNet, 1);
      isAvailable_SS_Bm = zeros(nNet, 1);
      isMultiplexed_SS_Bm = zeros(nNet, 1);
      divisions_SS_Bm = zeros(nNet, 1);
      dutyCycle_ES_Bm = zeros(nNet, 1);
      for iNet = 1:nNet

        % Compute duty cycle for the Earth station of each
        this.networks(iNet).earthStation.beam.set_dutyCycle( ...
            100 / this.networks(iNet).spaceStationBeam.divisions);

        % Collect assignement properties
        isAvailable_SS(iNet) = this.networks(iNet).spaceStation.isAvailable;
        isAvailable_SS_Bm(iNet) = this.networks(iNet).spaceStationBeam.isAvailable;
        isMultiplexed_SS_Bm(iNet) = this.networks(iNet).spaceStationBeam.isMultiplexed;
        divisions_SS_Bm(iNet) = this.networks(iNet).spaceStationBeam.divisions;
        dutyCycle_ES_Bm(iNet) = this.networks(iNet).earthStationBeam.dutyCycle;

      end % for

      % Check the number of networks
      if nNet ~= length(idxSelES)
        warning('Springbok:UnassignedStations', ...
                'The number of networks and selected Earth stations are not equal');

      end % if
      
      % Create assignment, and set properties, for return
      assignment = Assignment();
      assignment.set_dNm(this.dNm);
      assignment.set_theta_g(this.theta_g);
      assignment.set_theta_z(this.theta_z);
      assignment.set_metrics(this.metrics);
      assignment.set_networks(this.networks);
      assignment.set_idxNetES(this.idxNetES);
      assignment.set_idxNetSS(this.idxNetSS);
      assignment.set_isAvailable_SS(isAvailable_SS);
      assignment.set_isAvailable_SS_Bm(isAvailable_SS_Bm);
      assignment.set_isMultiplexed_SS_Bm(isMultiplexed_SS_Bm);
      assignment.set_divisions_SS_Bm(divisions_SS_Bm);
      assignment.set_dutyCycle_ES_Bm(dutyCycle_ES_Bm);

    end % assignBeams()

    function assignBeamsFromHigh(this, dNm, cellsHigh, systemHigh, numSmpBm, varargin)
    % Establish a one-to-one correspondence between each Earth
    % station and a space station and beam from the networks
    % assigned in the system high. This must be system low.
    %
    % Parameters
    %   dNm - Date number of assignment
    %   cellsHigh - Structure relating system low to high cells
    %   systemHigh - System high with Earth stations based on
    %     cells high
    %   numSmpBm - Number of samples of space station beams to
    %     assign
    %
    % Options
    %   DoCheck - Flag for checking input values (default is 1)

      % Assign current date number
      this.dNm = dNm;
      
      % Parse variable input arguments
      p = inputParser;
      p.addParamValue('DoCheck', 1);
      p.parse(varargin{:});
      doCheck = TypeUtility.set_logical(p.Results.DoCheck);

      % TODO: Check input

      % Reset so that stations and beams can be assigned
      this.reset();

      % Initialize angles, metrics, networks, and their station
      % indexes
      nES = length(this.earthStations);
      nSS = length(this.spaceStations);
      this.theta_g = NaN(nES, nSS);
      this.theta_z = NaN(nES, nSS);
      this.metrics = NaN(nES, nSS);
      this.networks(nES, 1) = Network();
      this.idxNetES = zeros(nES, 1);
      this.idxNetSS = zeros(nES, 1);

      % Consider each system high network
      nNet = length(systemHigh.networks);
      for iNet = 1:nNet

        % System high Earth stations correspond to cells high
        iCell = systemHigh.idxNetES(iNet);

        % Each cell corresponds to a latitude and longitude bin
        iLatBin = cellsHigh.iLatBin(iCell);
        iLonBin = cellsHigh.iLonBin(iCell);

        % Each bin contains a set of system low Earth station
        % indexes
        idxBinES = cellsHigh.lonValIdx{iLatBin}{iLonBin};

        % System high and low space station indexes agree by design
        iSS = systemHigh.idxNetSS(iNet);

        % Assign the space station to each Earth station in the
        % bin. Bins contain no more Earth stations than can be
        % assigned to one space station.
        for iES = idxBinES(1 : numSmpBm : end)
          beam = this.spaceStations(iSS).assign(this.earthStations(iES).doMultiplexing);
          this.networks(iES) = Network( ...
              this.earthStations(iES), this.spaceStations(iSS), beam, this.losses, ...
              'doCheck', doCheck);
          this.idxNetES(iES) = iES;
          this.idxNetSS(iES) = iSS;

          % Collect assignement properties
          this.theta_g(iES, iSS) = systemHigh.theta_g(iCell, iSS);
          this.theta_z(iES, iSS) = systemHigh.theta_z(iCell, iSS);
          this.metrics(iES, iSS) = systemHigh.metrics(iCell, iSS);

        end % for

      end % for

      % Eliminate empty networks
      idxEmpty = find(this.idxNetES == 0);
      this.networks(idxEmpty) = [];
      this.idxNetES(idxEmpty) = [];
      this.idxNetSS(idxEmpty) = [];

      % Compute duty cycle for the Earth station of each network
      nNet = length(this.networks);
      isAvailable_SS = zeros(nNet, 1);
      isAvailable_SS_Bm = zeros(nNet, 1);
      isMultiplexed_SS_Bm = zeros(nNet, 1);
      divisions_SS_Bm = zeros(nNet, 1);
      dutyCycle_ES_Bm = zeros(nNet, 1);
      for iNet = 1:nNet
        this.networks(iNet).earthStation.beam.set_dutyCycle( ...
            100 / this.networks(iNet).spaceStationBeam.divisions);

        % Collect assignement properties
        isAvailable_SS(iNet) = this.networks(iNet).spaceStation.isAvailable;
        isAvailable_SS_Bm(iNet) = this.networks(iNet).spaceStationBeam.isAvailable;
        isMultiplexed_SS_Bm(iNet) = this.networks(iNet).spaceStationBeam.isMultiplexed;
        divisions_SS_Bm(iNet) = this.networks(iNet).spaceStationBeam.divisions;
        dutyCycle_ES_Bm(iNet) = this.networks(iNet).earthStationBeam.dutyCycle;

      end % for

      % Create assignment, and set properties, for return
      assignment = Assignment();
      assignment.set_dNm(this.dNm);
      assignment.set_theta_g(this.theta_g);
      assignment.set_theta_z(this.theta_z);
      assignment.set_metrics(this.metrics);
      assignment.set_networks(this.networks);
      assignment.set_idxNetES(this.idxNetES);
      assignment.set_idxNetSS(this.idxNetSS);
      assignment.set_isAvailable_SS(isAvailable_SS);
      assignment.set_isAvailable_SS_Bm(isAvailable_SS_Bm);
      assignment.set_isMultiplexed_SS_Bm(isMultiplexed_SS_Bm);
      assignment.set_divisions_SS_Bm(divisions_SS_Bm);
      assignment.set_dutyCycle_ES_Bm(dutyCycle_ES_Bm);

    end % assignBeamsFromHigh()

    function Performance = computeUpLinkPerformance(this, dNm, interferingSystem, numSmpES, numSmpBm, ref_bw, varargin)
    % Compute performance measures for the up link of each wanted
    % network.
    %
    % Parameters
    %   dNm - Current date number
    %   interferingSystem - Interfering system
    %   numSmpES - Ratio of the number of Earth stations to the
    %     number for which asisgnment is attempted
    %   numSmpBm - Ratio of the number of Beams to the number which
    %     is assigned
    %   ref_bw - Reference bandwidth [kHz]
    %
    % Options
    %   DoIS - Flag for computing up link performance in the
    %     presence of inter-satellite interference (default is 0)
    %
    % Returns
    %   Performance - Up link performance

      % Compute up link performance
      nNet = length(this.networks);
      for iNet = 1:nNet
        Performance(iNet) ...
            = this.networks(iNet).up_Link.computePerformance( ...
                dNm, interferingSystem, numSmpES, numSmpBm, ref_bw, varargin{:});

      end % for

    end % computeUpLinkPerformance()

    function Performance = computeDownLinkPerformance(this, dNm, interferingSystem, numSmpES, numSmpBm, ref_bw)
    % Compute performance measures for the down link of each wanted
    % network.
    %
    % Parameters
    %   dNm - Current date number
    %   interferingSystem - Interfering system
    %   numSmpES - Ratio of the number of Earth stations to the
    %     number for which asisgnment is attempted
    %   numSmpBm - Ratio of the number of Beams to the number which
    %     is assigned
    %   ref_bw - Reference bandwidth [kHz]
    %
    % Returns
    %   dn_Performance - Down link performance

      nNet = length(this.networks);
      for iNet = 1:nNet
        Performance(iNet) ...
            = this.networks(iNet).dn_Link.computePerformance( ...
                dNm, interferingSystem, numSmpES, numSmpBm, ref_bw);

      end % for

    end % computeDownLinkPerformance()

    function apply(this, assignment)
    % Set derived properties of associated stations to values from
    % specified assignment.

      % TODO: Assignment needs a reference to system, which needs
      % to be tested here

      % Set derived properties of this System instance
      this.dNm = assignment.dNm;
      this.theta_g = assignment.theta_g;
      this.theta_z = assignment.theta_z;
      this.metrics = assignment.metrics;
      this.networks = assignment.networks;
      this.idxNetES = assignment.idxNetES;
      this.idxNetSS = assignment.idxNetSS;

      % Consider each network
      nNet = length(assignment.networks);
      for iNet = 1:nNet

        % Set derived properties of the associated space station,
        % space station beam, and Earth station beam instances.
        this.networks(iNet).spaceStation.set_isAvailable(assignment.isAvailable_SS(iNet));
        this.networks(iNet).spaceStationBeam.set_isAvailable(assignment.isAvailable_SS_Bm(iNet));
        this.networks(iNet).spaceStationBeam.set_isMultiplexed(assignment.isMultiplexed_SS_Bm(iNet));
        this.networks(iNet).spaceStationBeam.set_divisions(assignment.divisions_SS_Bm(iNet));
        this.networks(iNet).earthStationBeam.set_dutyCycle(assignment.dutyCycle_ES_Bm(iNet));

      end % for
      
      % Consider each space station, assigned, or not, in order to
      % compute positions at the date number specified
      nSS = length(this.spaceStations);
      for iSS = 1:nSS
        this.spaceStations(iSS).compute_r_ger(this.dNm);

      end % for

    end % apply()

    function reset(this)
    % Reset derived properties of associated stations to initial
    % values.
      nSS = length(this.spaceStations);
      for iSS = 1:nSS
        this.spaceStations(iSS).reset();
        
      end % for

      % dNm
      this.theta_g = [];
      this.theta_z = [];
      this.metrics = [];
      this.networks = Network();
      this.idxNetES = [];
      this.idxNetSS = [];

    end % reset()

  end % methods

  methods (Static = true)

    function theta = computeAngleFromGsoArc(r_SS, r_ES)
    % Compute the (approximate) minimum angle between the line from
    % the current Earth station to the current space station, and a
    % line from the current Earth station to a point on the GSO
    % arc.
      r_SS_ES = r_SS - r_ES;
      alpha = atan2(r_SS_ES(2), r_SS_ES(1));
      r_gso_ES = EarthConstants.a_gso * [cos(alpha); sin(alpha); 0] - r_ES;
      e_SS_ES = r_SS_ES / sqrt(r_SS_ES' * r_SS_ES);
      e_gso_ES = r_gso_ES / sqrt(r_gso_ES' * r_gso_ES);
      theta = real(acosd(e_SS_ES' * e_gso_ES));

    end % computeAngleFromGsoArc()

    function theta = computeAngleFromZenith(r_S, r_ES)
    % Determine the angle between the current Earth station zenith
    % and a line from the current Earth station to the current
    % station.
      u_ES = r_ES / sqrt(r_ES' * r_ES);
      r_S_ES = r_S - r_ES;
      u_S_ES = r_S_ES / sqrt(r_S_ES' * r_S_ES);
      theta = real(acosd(u_ES' * u_S_ES));
      
    end % computeAngleFromZenith()

    function theta = computeAngleFromNadir(r_S, r_ES)
    % Determine the angle between the current Earth station nadir
    % and a line from the current Earth station to the current
    % station.
      u_ES = -r_ES / sqrt(r_ES' * r_ES);
      r_S_ES = r_S - r_ES;
      u_S_ES = r_S_ES / sqrt(r_S_ES' * r_S_ES);
      theta = real(acosd(u_ES' * u_S_ES));

    end % computeAngleFromNadir()

  end % methods (Static = true)

end % classdef
