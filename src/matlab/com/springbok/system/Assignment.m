classdef Assignment < handle
% Encapsulates the result of a System beam assignment.

% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = protected, GetAccess = public)

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

    % Flag array indicating if the station is available, or not
    isAvailable_SS

    % Flag array indicating if the beam is available, or not
    isAvailable_SS_Bm
    % Flag array indicating if the beam is multiplexed, or not
    isMultiplexed_SS_Bm
    % Number of divisions in use array
    divisions_SS_Bm

    % Duty cycle array
    dutyCycle_ES_Bm

  end % properties

  methods

    function this = Assignment(dNm, theta_g, theta_z, metrics, ...
                               networks, idxNetES, idxNetSS, ...
                               isAvailable_SS, isAvailable_SS_Bm, ...
                               isMultiplexed_SS_Bm, divisions_SS_Bm, ...
                               dutyCycle_ES_Bm)
    % Constructs an Assignment.
    %
    % Parameters
    %   dNm - Current date number
    %   theta_g -  Angle between space station position vector
    %     relative to the Earth station and GSO arc
    %   theta_z -  Angle between space station position vector
    %     relative to the Earth station and Earth station zenith
    %     direction
    %   metrics - Metric used to select space station for each
    %     Earth station
    %   networks - A network array
    %   idxNetES - Index of each Earth station assigned to a
    %     network
    %   idxNetSS - Index of each space station assigned to a
    %     network
    %   isAvailable_SS - Flag array indicating if the station is
    %     available, or not
    %   isAvailable_SS_Bm - Flag array indicating if the beam is
    %     available, or not
    %   isMultiplexed_SS_Bm - Flag array indicating if the beam
    %     is multiplexed, or not
    %   divisions_SS_Bm - Number of divisions in use array
    %   dutyCycle_ES_Bm - Duty cycle array

      % No argument constructor
      if nargin == 0
        return;

      end % if

      % Assign properties
      this.set_dNm(dNm);
      this.set_theta_g(theta_g);
      this.set_theta_z(theta_z);
      this.set_metrics(metrics);
      this.set_networks(networks);
      this.set_idxNetES(idxNetES);
      this.set_idxNetSS(idxNetSS);
      this.set_isAvailable_SS(isAvailable_SS);
      this.set_isAvailable_SS_Bm(isAvailable_SS_Bm);
      this.set_isMultiplexed_SS_Bm(isMultiplexed_SS_Bm);
      this.set_divisions_SS_Bm(divisions_SS_Bm);
      this.set_dutyCycle_ES_Bm(dutyCycle_ES_Bm);

    end % Assignment()
    
    function that = copy(this)
    % Copies a Assignment.
    %
    % Returns
    %   that - A new Assignment instance
      that = Assignment(this.dNm, this.theta_g, this.theta_z, ...
                        this.metrics, this.networks, this.idxNetES, ...
                        this.idxNetSS, this.isAvailable_SS, ...
                        this.isAvailable_SS_Bm, this.isMultiplexed_SS_Bm, ...
                        this.divisions_SS_Bm, this.dutyCycle_ES_Bm);

    end % copy()

    function set_dNm(this, dNm)
    % Sets current date number.
    %
    % Parameters
    %   dNm - Current date number
      this.dNm = TypeUtility.set_numeric(dNm);

    end % set_dNm()

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

    function set_isAvailable_SS(this, isAvailable_SS)
    % Sets flag array indicating if the station is available, or
    % not.
    %
    % Parameters
    %   isAvailable_SS - Flag array indicating if the station is
    %     available, or not
      if ~isnumeric(isAvailable_SS)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.isAvailable_SS = isAvailable_SS;

    end % set_isAvailable_SS()

    function set_isAvailable_SS_Bm(this, isAvailable_SS_Bm)
    % Sets flag array indicating if the beam is available, or not.
    %
    % Parameters
    %   isAvailable_SS_Bm - Flag array indicating if the beam is
    %     available, or not
      if ~isnumeric(isAvailable_SS_Bm)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.isAvailable_SS_Bm = isAvailable_SS_Bm;

    end % set_isAvailable_SS_Bm()

    function set_isMultiplexed_SS_Bm(this, isMultiplexed_SS_Bm)
    % Sets flag array indicating if the beam is multiplexed, or
    % not.
    %
    % Parameters
    %   isMultiplexed_SS_Bm - Flag array indicating if the beam is
    %     multiplexed, or not
      if ~isnumeric(isMultiplexed_SS_Bm)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.isMultiplexed_SS_Bm = isMultiplexed_SS_Bm;

    end % set_isMultiplexed_SS_Bm()

    function set_divisions_SS_Bm(this, divisions_SS_Bm)
    % Sets number of divisions in use array.
    %
    % Parameters
    %   divisions_SS_Bm - Number of divisions in use array
      if ~isnumeric(divisions_SS_Bm)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.divisions_SS_Bm = divisions_SS_Bm;

    end % set_divisions_SS_Bm()

    function set_dutyCycle_ES_Bm(this, dutyCycle_ES_Bm)
    % Sets duty cycle array.
    %
    % Parameters
    %   dutyCycle_ES_Bm - Duty cycle array
      if ~isnumeric(dutyCycle_ES_Bm)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.dutyCycle_ES_Bm = dutyCycle_ES_Bm;

    end % set_dutyCycle_ES_Bm()

  end % methods

end % classdef
