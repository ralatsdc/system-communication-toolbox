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
classdef Link < handle
% Describes a link between two stations.

  properties (SetAccess = protected, GetAccess = public)

    % A transmit station
    transmitStation
    % A transmit station beam
    transmitStationBeam
    % A receive station
    receiveStation
    % Propagation loss models to apply
    losses

    % Flag to check input arguments, or not
    doCheck

  end % properties

  methods

    function this = Link(transmitStation, transmitStationBeam, receiveStation, losses, varargin)
    % Constructs a Link.
    %
    % Parameters
    %   transmitStation - A transmit station
    %   transmitStationBeam - A transmit station beam
    %   receiveStation - A receive station
    %   losses - Propagation loss models to apply
    % 
    % Options
    %   DoCheck - Flag for checking input values (default is 1)

    % No argument constructor
      if nargin == 0
        this.doCheck = 1;
        return;

      end % if

      % Parse variable input arguments
      p = inputParser;
      p.addParamValue('DoCheck', 1);
      p.parse(varargin{:});
      this.set_doCheck(p.Results.DoCheck);

      % Assign properties
      this.set_transmitStation(transmitStation);
      this.set_transmitStationBeam(transmitStationBeam);
      this.set_receiveStation(receiveStation);
      this.set_losses(losses);

    end % Link()

    function that = copy(this)
    % Copies a Link.
    %
    % Returns
    %   that - A new Link instance
      that = Link(this.transmitStation.copy(), ...
                  this.transmitStationBeam.copy(), ...
                  this.receiveStation.copy(), this.losses);

    end % copy()

    function set_transmitStation(this, transmitStation)
    % Sets the transmit station.
    %
    % Parameters
    %   transmitStation - A transmit station
      if this.doCheck
        if ~isa(transmitStation, 'Station')
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Input argument must be a "Station"');
          throw(MEx);

        end % if
      end % if
      this.transmitStation = transmitStation;

    end % set_transmitStation()

    function set_transmitStationBeam(this, transmitStationBeam)
    % Sets the transmit station beam.
    %
    % Parameters
    %   transmitStationBeam - A transmit station beam
      if this.doCheck
        if ~isa(transmitStationBeam, 'Beam')
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Input must be of class "Beam"');
          throw(MEx);

        elseif length(transmitStationBeam) > 1
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'A Link must have a single transmit station beam');
          throw(MEx);

        elseif isa(this.transmitStation, 'EarthStation') ...
              || isa(this.transmitStation, 'EarthStationInMotion')
          if ~isequal(transmitStationBeam, this.transmitStation.beam)
            MEx = MException('Springbok:IllegalArgumentException', ...
                             'Invalid transmit station beam');
            throw(MEx);

          end % if
          
        elseif isa(this.transmitStation, 'SpaceStation')
          if ~TypeUtility.is_member(transmitStationBeam, this.transmitStation.beams)
            MEx = MException('Springbok:IllegalArgumentException', ...
                             'Invalid transmit station beam');
            throw(MEx);

          end % if
          
        end % if

      end % if
      this.transmitStationBeam = transmitStationBeam;

    end % set_transmitStationBeam()

    function set_receiveStation(this, receiveStation)
    % Sets the receive station.
    %
    % Parameters
    %   receiveStation - A receive station
      if this.doCheck
        if ~isa(receiveStation, 'Station')
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Input argument must be a "Station"');
          throw(MEx);

        end % if
      end % if
      this.receiveStation = receiveStation;

    end % set_receiveStation()

    function set_losses(this, losses)
    % Sets propagation loss models to apply
    %
    % Parameters
    %   losses - Propagation loss models to apply
      if this.doCheck
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
      end % if
      this.losses = losses;

    end % if

    function set_doCheck(this, doCheck)
    % Sets flag to check input arguments, or not.
    %
    % Parameters
    %   doCheck - Flag to check input arguments, or not
      this.doCheck = TypeUtility.set_logical(doCheck);

    end % if

    function [performance, results] = computePerformance( ...
        this, dNm, interferingSystem, numSmpES, numSmpBm, ref_bw, varargin)
    % Computes performance of the link in the presence of an
    % interfering system.
    %
    % Parameters
    %   dNm - Current date number
    %   interferingSystem - Interfering system
    %   numSmpES - Factor of Earth stations to which a space station
    %     was assigned
    %   numSmpBm - Factor of Space station beams assigned
    %   ref_bw - Reference bandwidth [kHz]
    %
    % Options
    %   PlDs - Polarization discrimination [dB]
    %     (optional, default is 0)
    %   FuselageLossOffset - Fuselage loss offset [dB]
    %     (optional, default is 0)
    %   DoIS - Flag for computing up link performance in the presence
    %     of inter-satellite interference (optional, default is 0)
    %   DoIE - Flag for computing link performance in the presence of
    %     inter-earth station interference (optional, default is 0)
    %   DoRI - Flag for returning intermediate results
    %     (optional, default is 0)
    %
    % Returns
    %   performance - Link performance
    %   results - Intermediate results

      if this.isEmpty()
        performance = Performance();
        return

      end % if

      if isempty(numSmpES)
        numSmpES = 1;

      end % if

      if isempty(numSmpBm)
        numSmpBm = 1;

      end % if

      % Parse variable input arguments
      p = inputParser;
      p.addParamValue('PlDs', 0);
      p.addParamValue('DoIS', 0);
      p.addParamValue('DoIE', 0);
      p.addParamValue('DoRI', 0);
      p.addParamValue('DoScan', 1);
      p.addParamValue('FuselageLossOffset', 0);
      p.parse(varargin{:});
      PlDs = TypeUtility.set_numeric(p.Results.PlDs);
      doIS = TypeUtility.set_numeric(p.Results.DoIS);
      doIE = TypeUtility.set_numeric(p.Results.DoIE);
      doRI = TypeUtility.set_numeric(p.Results.DoRI);
      doScan = TypeUtility.set_numeric(p.Results.DoScan);
      FsL_offset = TypeUtility.set_numeric(p.Results.FuselageLossOffset);
      if doIS && doIE
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Only one of IS and IE case can be specified');
            throw(MEx);

      end % if

      % Assign wanted transmit and receive station, for clarity
      s = struct();
      trnStn_w = this.transmitStation;
      trnStnBm_w = this.transmitStationBeam;
      rcvStn_w = this.receiveStation;
      if (isa(trnStn_w, 'EarthStation') ...
          || isa(trnStn_w, 'EarthStationInMotion')) ...
            && isa(rcvStn_w, 'SpaceStation')
        isUpLink = 1;
        % doIS may equal 0 or 1
        % doIE must equal 0
        if doIE
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'IE case only applicable for terestrial links');
          throw(MEx);

        end % if

      elseif isa(trnStn_w, 'SpaceStation') ...
            && (isa(rcvStn_w, 'EarthStation') ...
                || isa(rcvStn_w, 'EarthStationInMotion'))
        isUpLink = 0;
        % doIS must equal 0
        if doIS
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'IS case only applicable for an uplink');
          throw(MEx);

        end % if
        % doIE must equal 0
        if doIE
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'IE case only applicable for terestrial links');
          throw(MEx);

        end % if

      elseif (isa(trnStn_w, 'EarthStation') ...
              || isa(trnStn_w, 'EarthStationInMotion')) ...
            && isa(rcvStn_w, 'EarthStation')
        % doIS must equal 0
        if doIS
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'IS case only applicable for an uplink');
          throw(MEx);

        end % if
        % doIE must equal 1
        if ~doIE
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'IE case expected for terestrial links');
          throw(MEx);

        end % if

      elseif isa(trnStn_w, 'SpaceStation') && isa(rcvStn_w, 'SpaceStation')
        % doIS may equal 0 or 1
        % doIE may equal 0 or 1
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Link between space stations unexpected');
        throw(MEx);

      end % if

      % Assign positions for the wanted stations
      trnStn_w_r_ger = trnStn_w.compute_r_ger(dNm);
      rcvStn_w_r_ger = rcvStn_w.compute_r_ger(dNm);

      % Assign visible interfering transmit and receive stations ...
      if ~isempty(interferingSystem)
        if doIS

          % ... for the IS case
          trnStns_i = interferingSystem.get_assignedSpaceStations();
          trnStnsBms_i = interferingSystem.get_assignedSpaceStationBeams();
          rcvStns_i = interferingSystem.get_assignedEarthStations();

          % This is an up link for the IS case, so assign interfering
          % system space stations visible to this link space station
          [idxVisRx, idxVisTx] = Link.findIdxVisSStoSS(rcvStn_w, trnStns_i, dNm);

        elseif doIE

          % ... for the IE case
          trnStns_i = interferingSystem.get_assignedEarthStations();
          trnStnsBms_i = interferingSystem.get_assignedEarthStationBeams();
          rcvStns_i = interferingSystem.get_assignedSpaceStations();

          % This is a terrestrial link for the IE case, so assign
          % interfering system earth stations visible to this link
          % receive station
          [idxVisRx, idxVisTx] = Link.findIdxVisEStoS(rcvStn_w, trnStns_i, dNm);

        else

          % ... for consistency with wanted transmit station class
          if isUpLink
            trnStns_i = interferingSystem.get_assignedEarthStations();
            trnStnsBms_i = interferingSystem.get_assignedEarthStationBeams();
            rcvStns_i = interferingSystem.get_assignedSpaceStations();

            % This is an up link, so assign interfering system Earth
            % stations visible to this link space station
            [idxVisTx, idxVisRx] = Link.findIdxVisEStoS(trnStns_i, rcvStn_w, dNm);

          else % isDnLink
            trnStns_i = interferingSystem.get_assignedSpaceStations();
            trnStnsBms_i = interferingSystem.get_assignedSpaceStationBeams();
            rcvStns_i = interferingSystem.get_assignedEarthStations();

            % This is a down link, so assign interfering system space
            % stations visible to this link Earth station
            [idxVisRx, idxVisTx] = Link.findIdxVisEStoS(rcvStn_w, trnStns_i, dNm);

          end % if

        end % if

        % Select visible interfering transmit and receive stations
        trnStns_i = trnStns_i(idxVisTx);
        trnStnsBms_i = trnStnsBms_i(idxVisTx);
        rcvStns_i = rcvStns_i(idxVisTx);
        nNet = length(trnStns_i);

      end % if

      % Assign positions for the interfering stations
      if ~isempty(interferingSystem)
        for iNet = 1:nNet
          trnStns_i_r_ger{iNet} = trnStns_i(iNet).compute_r_ger(dNm);
          rcvStns_i_r_ger{iNet} = rcvStns_i(iNet).compute_r_ger(dNm);

        end % for

      end % if

      % Assign frequency and propagation path length
      f_w = trnStn_w.emission.freq_mhz;
      d_w = Link.computeDistance(trnStn_w_r_ger, rcvStn_w_r_ger);
      
      % Assign power density, transmit and receive gain, and
      % propagation path loss
      if isa(trnStn_w.transmitAntenna.pattern, 'SampledPattern')
        phi_t_w = Link.computeAnglesFromZenith( ...
            trnStn_w, trnStn_w_r_ger, rcvStn_w_r_ger);
        G_t_w_0 = trnStn_w.transmitAntenna.pattern.gain( ...
            phi_t_w, 0, phi_t_w, trnStn_w.transmitAntenna.options{:});

      elseif isa(trnStn_w.transmitAntenna.pattern, 'PatternERECM2101_0')
        [phi_t_w, theta_t_w, psi_t_w] = Link.computeAnglesForRecM2101_0( ...
            dNm, trnStn_w, trnStn_w.transmitAntenna, trnStn_w_r_ger, rcvStn_w_r_ger);
        if doScan
          G_t_w_0 = trnStn_w.transmitAntenna.pattern.gain( ...
              phi_t_w, theta_t_w, phi_t_w, psi_t_w);

        else
          G_t_w_0 = trnStn_w.transmitAntenna.pattern.gain( ...
              phi_t_w, theta_t_w, 0, 0);

        end % if

      else
        G_t_w_0 = trnStn_w.transmitAntenna.pattern.gain( ...
            0, trnStn_w.transmitAntenna.options{:});

      end % if
      if isa(rcvStn_w.receiveAntenna.pattern, 'SampledPattern')
        phi_r_w = Link.computeAnglesFromZenith( ...
            rcvStn_w, rcvStn_w_r_ger, trnStn_w_r_ger);
        G_r_w_0 = rcvStn_w.receiveAntenna.pattern.gain( ...
            phi_r_w, 0, phi_r_w, rcvStn_w.receiveAntenna.options{:});

      elseif isa(rcvStn_w.receiveAntenna.pattern, 'PatternERECM2101_0')
        [phi_r_w, theta_r_w, psi_r_w] = Link.computeAnglesForRecM2101_0( ...
            dNm, rcvStn_w, rcvStn_w.receiveAntenna, rcvStn_w_r_ger, trnStn_w_r_ger);
        if doScan
          G_r_w_0 = rcvStn_w.transmitAntenna.pattern.gain( ...
              phi_r_w, theta_r_w, phi_r_w, psi_r_w);

          else
            G_r_w_0 = rcvStn_w.transmitAntenna.pattern.gain( ...
                phi_r_w, theta_r_w, 0, 0);

        end % if

      else
        G_r_w_0 = rcvStn_w.receiveAntenna.pattern.gain( ...
            0, rcvStn_w.receiveAntenna.options{:});

      end % if
      if ~isempty(trnStn_w.emission.pwr_flx_ds)
        SL_w = Propagation.computeSpreadingLoss(d_w);
        PwDn_w = trnStn_w.emission.pwr_flx_ds - G_t_w_0 + SL_w;

      else
        PwDn_w = trnStn_w.emission.pwr_ds_max;

      end % if
      ML_w = 10 * log10(trnStnBm_w.divisions);
      DCL_w = 10 * log10(100 / trnStnBm_w.dutyCycle);
      PL_w = Propagation.computeFreeSpaceLoss(f_w, d_w);

      % Compute carrier power density
      C = PwDn_w - ML_w - DCL_w + G_t_w_0 - PL_w + G_r_w_0;

      % Assign receiver noise temperature
      T_w = rcvStn_w.receiveAntenna.noise_t;

      % Compute noise power density
      N = Propagation.k + 10 * log10(T_w);

      % Initialize intemediate results
      if doRI
        d_i_i = NaN;
        d_i_w = NaN;
        theta_t_i = NaN;
        theta_t_i_f = NaN;
        phi_r_w_o = NaN;
        theta_r_w_o = NaN;
        phi_r_w_s = NaN;
        psi_r_w_s = NaN;
        G_t_i = NaN;
        FsL_t_i = NaN;
        GA_t_i = NaN;
        PL_i = NaN;
        G_r_w = NaN;

      end % if

      % Consider each interfering network
      i = -Inf;
      I = -Inf;
      epfd = -Inf;
      EPFD = -Inf;
      if ~isempty(interferingSystem)
        i = -Inf(nNet, 1);
        epfd = -Inf(nNet, 1);
        for iNet = 1:nNet

          % Assign frequency and propagation path length
          f_i(iNet) = trnStns_i(iNet).emission.freq_mhz;
          d_i_i(iNet) = Link.computeDistance(trnStns_i_r_ger{iNet}, rcvStns_i_r_ger{iNet});
          d_i_w(iNet) = Link.computeDistance(trnStns_i_r_ger{iNet}, rcvStn_w_r_ger);

          % Assign power density, transmit and receive gain, and
          % propagation path and spreading loss
          if isa(trnStns_i(iNet).transmitAntenna.pattern, 'SampledPattern')
            [phi_t_i(iNet), azm_r_w(iNet), elv_r_w(iNet)] = Link.computeAnglesFromZenith( ...
                trnStns_i(iNet), trnStns_i_r_ger{iNet}, rcvStns_i_r_ger{iNet}, rcvStn_w_r_ger);
            G_t_i(iNet) = trnStns_i(iNet).transmitAntenna.pattern.gain( ...
                phi_t_i(iNet), azm_r_w(iNet), elv_r_w(iNet), trnStns_i(iNet).transmitAntenna.options{:});

          elseif isa(trnStns_i(iNet).transmitAntenna.pattern, 'PatternERECM2101_0')
            [phi_t_i_o(iNet), theta_t_i_o(iNet), psi_t_i_o] = Link.computeAnglesForRecM2101_0( ...
                dNm, trnStns_i(iNet), trnStns_i(iNet).transmitAntenna, trnStns_i_r_ger{iNet}, rcvStn_w_r_ger);
            [phi_t_i_s(iNet), theta_t_i_s, psi_t_i_s(iNet)] = Link.computeAnglesForRecM2101_0( ...
                dNm, trnStns_i(iNet), trnStns_i(iNet).transmitAntenna, trnStns_i_r_ger{iNet}, rcvStns_i_r_ger{iNet});
            if doScan
              G_t_i(iNet) = trnStns_i(iNet).transmitAntenna.pattern.gain( ...
                  phi_t_i_o(iNet), theta_t_i_o(iNet), phi_t_i_s(iNet), psi_t_i_s(iNet));

            else
              G_t_i(iNet) = trnStns_i(iNet).transmitAntenna.pattern.gain( ...
                  phi_t_i_o(iNet), theta_t_i_o(iNet), 0, 0);

            end % if

          else
            theta_t_i(iNet) = Link.computeAngleBetweenVectors( ...
                trnStns_i_r_ger{iNet}, rcvStns_i_r_ger{iNet}, rcvStn_w_r_ger);
            G_t_i(iNet) = trnStns_i(iNet).transmitAntenna.pattern.gain( ...
                theta_t_i(iNet), trnStns_i(iNet).transmitAntenna.options{:});

          end % if
          FdL_t_i(iNet) = trnStns_i(iNet).transmitAntenna.feeder_loss;
          BdL_t_i(iNet) = trnStns_i(iNet).transmitAntenna.body_loss;
          if ismember('fuselage-loss', this.losses)
            theta_t_i_f(iNet) = System.computeAngleFromNadir(rcvStn_w_r_ger, trnStns_i_r_ger{iNet});
            FsL_t_i(iNet) = max( ...
                0, Propagation.computeFuselageLoss(theta_t_i_f(iNet)) + FsL_offset);

          end % if
          if ismember('gaseous-attenuation', this.losses)
            GA_t_i(iNet) = Propagation.computeGaseousAttenuation(d_i_w(iNet), f_i(iNet));

          end % if
          SL_i_w(iNet) = Propagation.computeSpreadingLoss(d_i_w(iNet));
          if isa(rcvStn_w.receiveAntenna.pattern, 'SampledPattern')
            [phi_r_w(iNet), azm_t_i(iNet), elv_t_i(iNet)] = Link.computeAnglesFromZenith( ...
                rcvStn_w, rcvStn_w_r_ger, trnStn_w_r_ger, trnStns_i_r_ger{iNet});
            G_r_w(iNet) = rcvStn_w.receiveAntenna.pattern.gain( ...
                phi_r_w(iNet), azm_t_i(iNet), elv_t_i(iNet), rcvStn_w.receiveAntenna.options{:});

          elseif isa(rcvStn_w.receiveAntenna.pattern, 'PatternERECM2101_0')
            [phi_r_w_o(iNet), theta_r_w_o(iNet), psi_r_w_o] = Link.computeAnglesForRecM2101_0( ...
                dNm, rcvStn_w, rcvStn_w.receiveAntenna, rcvStn_w_r_ger, trnStns_i_r_ger{iNet});
            [phi_r_w_s(iNet), theta_r_w_s, psi_r_w_s(iNet)] = Link.computeAnglesForRecM2101_0( ...
                dNm, rcvStn_w, rcvStn_w.receiveAntenna, rcvStn_w_r_ger, trnStn_w_r_ger);
            if doScan
              G_r_w(iNet) = rcvStn_w.transmitAntenna.pattern.gain( ...
                  phi_r_w_o(iNet), theta_r_w_o(iNet), phi_r_w_s(iNet), psi_r_w_s(iNet));

            else
              G_r_w(iNet) = rcvStn_w.transmitAntenna.pattern.gain( ...
                  phi_r_w_o(iNet), theta_r_w_o(iNet), 0, 0);

            end % if

          else
            theta_r_w(iNet) = Link.computeAngleBetweenVectors( ...
                rcvStn_w_r_ger, trnStn_w_r_ger, trnStns_i_r_ger{iNet});
            G_r_w(iNet) = rcvStn_w.receiveAntenna.pattern.gain( ...
                theta_r_w(iNet), rcvStn_w.receiveAntenna.options{:});

          end % if
          FdL_r_w(iNet) = rcvStn_w.receiveAntenna.feeder_loss;
          BdL_r_w(iNet) = rcvStn_w.receiveAntenna.body_loss;
          if ~isempty(trnStns_i(iNet).emission.pwr_flx_ds)
            if isa(trnStns_i(iNet).transmitAntenna.pattern, 'SampledPattern')
              G_t_i_0(iNet) = trnStns_i(iNet).transmitAntenna.pattern.gain( ...
                  phi_t_i(iNet), 0, phi_t_i(iNet), trnStns_i(iNet).transmitAntenna.options{:});

            elseif isa(trnStns_i(iNet).transmitAntenna.pattern, 'PatternERECM2101_0')
              if doScan
                G_t_i_0(iNet) = trnStn_w.transmitAntenna.pattern.gain( ...
                    phi_t_i_o(iNet), theta_t_i_o(iNet), phi_t_i_s(iNet), theta_t_i_s);

              else
                G_t_i_0(iNet) = trnStn_w.transmitAntenna.pattern.gain( ...
                    phi_t_i_o(iNet), theta_t_i_o(iNet), 0, 0);

              end % if

            else
              G_t_i_0(iNet) = trnStns_i(iNet).transmitAntenna.pattern.gain( ...
                  0, trnStns_i(iNet).transmitAntenna.options{:});

            end % if
            SL_i_i(iNet) = Propagation.computeSpreadingLoss(d_i_i(iNet));
            PwDn_i(iNet) = trnStns_i(iNet).emission.pwr_flx_ds - G_t_i_0(iNet) + SL_i_i(iNet);

          else
            PwDn_i(iNet) = trnStns_i(iNet).emission.pwr_ds_max;

          end % if
          ML_i(iNet) = 10 * log10(trnStnsBms_i(iNet).divisions);
          DCL_i(iNet) = 10 * log10(100 / trnStnsBms_i(iNet).dutyCycle);
          PL_i(iNet) = Propagation.computeFreeSpaceLoss(f_i(iNet), d_i_w(iNet));

          % Compute interference power density
          i(iNet) = PwDn_i(iNet) + G_t_i(iNet) - FdL_t_i(iNet) - BdL_t_i(iNet);
          if ismember('fuselage-loss', this.losses)
            i(iNet) = i(iNet) - FsL_t_i(iNet);

          end % if
          if ismember('gaseous-attenuation', this.losses)
            i(iNet) = i(iNet) - GA_t_i(iNet);

          end % if
          i(iNet) = i(iNet) - PL_i(iNet) + G_r_w(iNet) - FdL_r_w(iNet) - BdL_r_w(iNet) - PlDs;
          i(iNet) = i(iNet) - ML_i(iNet) - DCL_i(iNet);  % Due to multiplexing and dutycycle
          i(iNet) = i(iNet) + 10 * log10(numSmpES * numSmpBm);  % Due to sampling
          I = 10 * log10(10^(I / 10) + 10^(i(iNet) / 10));

          % Compute equivalent power flux density
          epfd(iNet) = PwDn_i(iNet) + G_t_i(iNet) - FdL_t_i(iNet);
          if ismember('fuselage-loss', this.losses)
            epfd(iNet) = epfd(iNet) - FsL_t_i(iNet);

          end % if
          if ismember('gaseous-attenuation', this.losses)
            epfd(iNet) = epfd(iNet) - GA_t_i(iNet);

          end % if
          epfd(iNet) = epfd(iNet) - SL_i_w(iNet) + G_r_w(iNet) - FdL_r_w(iNet) - PlDs - G_r_w_0 + 10 * log10(ref_bw * 1000);
          epfd(iNet) = epfd(iNet) - ML_i(iNet) - DCL_i(iNet);  % Due to multiplexing and dutycycle
          epfd(iNet) = epfd(iNet) + 10 * log10(numSmpES * numSmpBm);  % Due to sampling
          EPFD = 10 * log10(10^(EPFD / 10) + 10^(epfd(iNet) / 10));

        end % for

      end % if

      % Assign carrier, noise, and interference power density
      performance = Performance(C, N, i, I, epfd, EPFD);

      % Assign intermediate results: distances, angles, gains, and losses
      results = struct();
      if doRI
        results.d_i_i = d_i_i;
        results.d_i_w = d_i_w;
        results.theta_t_i = theta_t_i;
        results.theta_t_i_f = theta_t_i_f;
        results.phi_r_w_o = phi_r_w_o;
        results.theta_r_w_o = theta_r_w_o;
        results.phi_r_w_s = phi_r_w_s;
        results.psi_r_w_s = psi_r_w_s;
        results.G_t_i = G_t_i;
        results.FsL_t_i = FsL_t_i;
        results.GA_t_i = GA_t_i;
        results.PL_i = PL_i;
        results.G_r_w = G_r_w;

      end % if

    end % computePerformance()

    function is = isEmpty(this)
    % Determines if Link properties are empty, or not.
      is = isempty(this.transmitStation) && ...
           isempty(this.receiveStation) && ...
           isempty(this.losses);

    end % isEmpty()

  end % methods

  methods (Static = true)

    function distance = computeDistance(r_one, r_two)
    % Computes distance between two stations.
    %
    % Parameters
    %   r_one - First station position [er]
    %   r_two - Second station position [er]
    %
    % Returns
    %   distance - Distance [km]
      if ~isequal(size(r_one), [3, 1]) ...
            || ~isequal(size(r_two), [3, 1])
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Positions must be column vectors');
        throw(MEx);

      end % if

      % Compute relative position vector
      r_two_one = r_two - r_one;

      % Compute distance
      distance = sqrt(r_two_one' * r_two_one) * EarthConstants.R_oplus;
      % [km] = [er] * [km/er]

    end % computeDistance()

    function theta = computeAngleBetweenVectors(r_ref, r_one, r_two)
    % Computes the angle between two unit vectors pointing from a
    % reference station to two other stations
    %
    % Parameters
    %   r_ref - Reference station position [er]
    %   r_one - First station position [er]
    %   r_two - Second station position [er]
    %
    % Returns
    %   theta - Angle between unit vectors [deg]
      if ~isequal(size(r_ref), [3, 1]) ...
            || ~isequal(size(r_one), [3, 1]) ...
            || ~isequal(size(r_two), [3, 1])
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Positions must be column vectors');
        throw(MEx);

      end % if

      % Compute relative position vectors
      r_one_ref = r_one - r_ref;
      r_two_ref = r_two - r_ref;

      % Compute unit vectors
      u_one_ref = r_one_ref / sqrt(r_one_ref' * r_one_ref);
      u_two_ref = r_two_ref / sqrt(r_two_ref' * r_two_ref);

      % Compute angle between
      theta = real(acosd(u_one_ref' * u_two_ref));

    end % computeAngleBetweenVectors()

    function [phi, azm, elv] = computeAnglesFromZenith(refStn, r_ref, r_one, r_two)
    % Computes the angles from zenith, defined by the reference
    % position, and the first and second position relative to the
    % reference position. As a result, the first angle from zenith is
    % the scan angle, and the second angle from zenith is the
    % elevation. Defines a local coordinate system with z axis aligned
    % with zenith, x axis such that the x-z axis contains the first
    % relative position vector, and y axis giving a right handed
    % system. Computes the azimuth (from the x axis) corresponding to
    % the second position. Positions must be in the geocentric
    % equatorial rotating coordinate system.
    %
    % Parameters
    %   refStn - Reference station
    %   r_ref - Reference station position [er]
    %   r_one - First station position [er]
    %   r_two - Second station position [er]
    %
    % Returns
    %   phi - Scan angle (corresponds to first position) [deg]
    %   azm - Azimuth (corresponds to second position) [deg]
    %   elv - Elevation (corresponds to second position) [deg]
      if nargin < 3 || nargin > 4
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Two or threes position vectors are required');
        throw(MEx);

      else
        isValid = isequal(size(r_ref), [3, 1]) && isequal(size(r_one), [3, 1]);
        if nargin == 4
          isValid = isValid && isequal(size(r_two), [3, 1]);

        end % if
        if ~isValid
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Positions must be column vectors');
          throw(MEx);

        end % if

      end % if

      % Compute first relative position vector
      r_one_ref = r_one - r_ref;

      % Compute unit vectors
      u_ref = r_ref / sqrt(r_ref' * r_ref);
      if isa(refStn, 'SpaceStation')
        % Space station antennas point toward the center of the
        % Earth
        u_ref = -u_ref;

      end % if
      u_one_ref = r_one_ref / sqrt(r_one_ref' * r_one_ref);

      % Compute scan angle (angle between boresight and first
      % position directions)
      phi = real(acosd(u_ref' * u_one_ref));

      azm = [];
      elv = [];
      if nargin == 4

        % Compute second relative position vector
        r_two_ref = r_two - r_ref;

        % Compute unit vector
        u_two_ref = r_two_ref / sqrt(r_two_ref' * r_two_ref);

        % Compute elevation (angle between scan and second position
        % directions)
        elv = real(acosd(u_one_ref' * u_two_ref));

        % Compute local coordinate system unit vectors
        z_hat = u_ref;
        if (u_one_ref - z_hat)' * (u_one_ref - z_hat) == 0
          % Reference and first relative position vectors are aligned
          y_hat = [0; z_hat(3); -z_hat(2)];

        else
          y_hat = cross(z_hat, u_one_ref);

        end % if
        y_hat = y_hat / sqrt(y_hat' * y_hat);
        x_hat = cross(y_hat, z_hat);

        % Compute azimuth (angle in the array plane between the
        % plane containing scan and boresight directions and plane
        % containing second position and boresight directions)
        x_two_ref = u_two_ref' * x_hat;
        y_two_ref = u_two_ref' * y_hat;
        azm = atan2(y_two_ref, x_two_ref) * (180 / pi);

      end % if

    end % computeAnglesFromZenith()

    function [phi, theta, psi] = computeAnglesForRecM2101_0(dNm, refStn, refAnt, r_ref, r_off)
    % Computes the azimuth and elevation folloiwng the coordinate
    % convention shown in Figure 10 in Section 5 Implementation of IMT
    % Base Station (BS) and User Equipment (UE) Beamforming Antenna
    % Pattern of Recommendation ITU-R M.2101-0. Positions must be in
    % the geocentric equatorial rotating coordinate system.
    %
    % Parameters
    %   dNm - Current date number
    %   refStn - Reference station
    %   refAnt - Reference station antenna, transmit or recieve
    %   r_ref - Position of the reference station [er]
    %   r_off - Position off axis [er]
    %
    % Returns
    %   phi - Azimuth off-axis relative to x-axis and positive around
    %     z-axis [deg]
    %   theta - Elevation off-axis relative to z-axis and positive
    %     around y-axis [deg]
    %   psi - Elevation scan relative to x-axis and positive around
    %     y-axis [deg]

    % Compute off axis relative position vector in local tangent
    % coordinates
      r_ltp = Coordinates.E_e2t(refStn) * (r_off - r_ref);
      u_ltp = r_ltp / sqrt(r_ltp' * r_ltp);  
      
      % Compute unit vectors in local tangent coordinates
      x_ltp = refAnt.x_ltp;
      z_ltp = refAnt.z_ltp;
      y_ltp = cross(z_ltp, x_ltp);

      % Compute components of off axis relative position vector in
      % antenna coordinates
      x_off = u_ltp' * x_ltp;
      y_off = u_ltp' * y_ltp;
      z_off = u_ltp' * z_ltp;

      % Compute azimuth and elevation
      phi = atan2(y_off, x_off) * (180 / pi);
      theta = real(acosd(z_off));
      psi = theta - 90;

    end % computeAnglesForRecM2101_0()

    function [idxVisES, idxVisS, r_ger_S] = findIdxVisEStoS(earthStations, stations, dNm)
    % Finds index of each Earth station which is visible to at least
    % one station, and conversely.
    %
    % Parameters
    %   earthStations - Earth stations with which visibility is
    %     determined
    %   stations - stations with which visibility is determined
    %   dNm - Date number at which the position vectors occur

      if ~(isa(earthStations, 'EarthStation') ...
           || isa(earthStations, 'EarthStationInMotion'))
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be an array of class "EarthStation" or "EarthStationInMotion" instances');
        throw(MEx);

      end % if

      nS = length(stations);
      nES = length(earthStations);

      idxVisES = zeros(nS, nES);
      idxVisS = zeros(nS, nES);

      r_ger_S = cell(nS, 1);

      for iS = 1:nS
        r_ger_S{iS} = stations(iS).compute_r_ger(dNm);

        tmpVisES = zeros(nES, 1);
        tmpVisS = zeros(nES, 1);

        for iES = 1:nES
          r_ger_ES = earthStations(iES).compute_r_ger(dNm);

          alpha = acosd(1 / (1 + earthStations(iES).h));
          beta = Link.computeAngleBetweenVectors([0; 0; 0], r_ger_S{iS}, r_ger_ES);
          theta = System.computeAngleFromZenith(r_ger_S{iS}, r_ger_ES);

          if beta < alpha ...  % Visible on the ground and up
                || theta < 90 + alpha  % Visible if above the tangent line
            tmpVisES(iES) = iES;
            tmpVisS(iES) = iS;

          end % if

        end % for

        idxVisES(iS, :) = tmpVisES;
        idxVisS(iS, :) = tmpVisS;

      end % if

      idxVisES = unique(idxVisES(find(idxVisES > 0)));
      idxVisS = unique(idxVisS(find(idxVisS > 0)));

      idxVisES = reshape(idxVisES, 1, length(idxVisES));
      idxVisS = reshape(idxVisS, 1, length(idxVisS));

    end % find_indexVisibleEStoSS()

    function [idxVisSS_A, idxVisSS_B, r_ger_SS_A, r_ger_SS_B] = findIdxVisSStoSS(spaceStationsA, spaceStationsB, dNm)
    % Finds index of each space station in the first array of space
    % stations which is visible to at least one space station in the
    % second array of space stations, and conversely.
    %
    % Parameters
    %   spaceStationsA - First array space stations with which
    %     visibility is determined
    %   spaceStationsB - Second array of space stations with which
    %     visibility is determined
    %   dNm - Date number at which the position vectors occur

      if ~isa(spaceStationsA, 'SpaceStation')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be an array of class "SpaceStation" instances');
        throw(MEx);

      end % if

      if ~isa(spaceStationsB, 'SpaceStation')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be an array of class "SpaceStation" instances');
        throw(MEx);

      end % if

      nSS_A = length(spaceStationsA);
      r_ger_SS_A = cell(nSS_A, 1);
      d_ger_SS_A = zeros(nSS_A, 1);
      alpha = zeros(nSS_A, 1);
      for iSS_A = 1:nSS_A
        r_ger_SS_A{iSS_A} = spaceStationsA(iSS_A).compute_r_ger(dNm);
        d_ger_SS_A(iSS_A) = sqrt(r_ger_SS_A{iSS_A}' * r_ger_SS_A{iSS_A});
        % Angle at which space station A rises or sets
        alpha(iSS_A) = real(acosd(1 / d_ger_SS_A(iSS_A)));

      end % for

      nSS_B = length(spaceStationsB);
      r_ger_SS_B = cell(nSS_B, 1);
      d_ger_SS_B = zeros(nSS_B, 1);
      beta = zeros(nSS_B, 1);
      for iSS_B = 1:nSS_B
        r_ger_SS_B{iSS_B} = spaceStationsB(iSS_B).compute_r_ger(dNm);
        d_ger_SS_B(iSS_B) = sqrt(r_ger_SS_B{iSS_B}' * r_ger_SS_B{iSS_B});
        % Angle at which space station B rises or sets
        beta(iSS_B) = real(acosd(1 / d_ger_SS_B(iSS_B)));

      end % for

      idxVisSS_A = zeros(nSS_A, nSS_B);
      idxVisSS_B = zeros(nSS_A, nSS_B);

      for iSS_A = 1:nSS_A

        tmpVisSS_A = zeros(nSS_B, 1);
        tmpVisSS_B = zeros(nSS_B, 1);

        for iSS_B = 1:nSS_B

          theta = real(acosd((r_ger_SS_A{iSS_A} / d_ger_SS_A(iSS_A))' ...
                             * (r_ger_SS_B{iSS_B} / d_ger_SS_B(iSS_B))));
          % Compare to sum since rise or set of A could touch set or rise of B
          if theta < alpha(iSS_A) + beta(iSS_B)
            tmpVisSS_A(iSS_B) = iSS_A;
            tmpVisSS_B(iSS_B) = iSS_B;

          end % if

        end % for

        idxVisSS_A(iSS_A, :) = tmpVisSS_A;
        idxVisSS_B(iSS_A, :) = tmpVisSS_B;

      end % if

      idxVisSS_A = unique(idxVisSS_A(find(idxVisSS_A > 0)));
      idxVisSS_B = unique(idxVisSS_B(find(idxVisSS_B > 0)));

      idxVisSS_A = reshape(idxVisSS_A, 1, length(idxVisSS_A));
      idxVisSS_B = reshape(idxVisSS_B, 1, length(idxVisSS_B));

    end % find_indexVisibleSStoSS()

  end % methods (Static = true)

end % classdef
