classdef Station < handle
% Describes a space or Earth station.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)
    
    % Identifier for station
    stationId
    % Transmit antenna gain, and pattern
    transmitAntenna
    % Receive antenna gain, pattern, and noise temperature
    receiveAntenna
    % Signal power, frequency, and requirement
    emission
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = Station(stationId, transmitAntenna, receiveAntenna, emission)
    % Constructs a Station.
    %
    % Parameters
    %   stationId - Identifier for station
    %   transmitAntenna - Transmit antenna gain, and pattern
    %   receiveAntenna - Receive antenna gain, pattern, and noise temperature
    %   emission - Signal power, frequency, and requirement
      
      % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Assign properties
      this.set_stationId(stationId);
      this.set_transmitAntenna(transmitAntenna);
      this.set_receiveAntenna(receiveAntenna);
      this.set_emission(emission);
      
    end % Station()
    
    function that = copy(this)
    % Copies a Station.
    %
    % Returns
    %   that - A new Station instance
      that = Station(this.stationId, this.transmitAntenna.copy(), ...
                     this.receiveAntenna.copy(), ...
                     this.emission.copy());

    end % copy()

    function set_stationId(this, stationId)
    % Sets the identifier station.
    %
    % Parameters
    %   stationId - Identifier for station.
      this.stationId = TypeUtility.set_char(stationId);
      
    end % set_stationId()
    
    function set_transmitAntenna(this, transmitAntenna)
    % Sets the transmit antenna.
    %
    % Parameters
    %   transmitAntenna - Transmit antenna
      if ~isa(transmitAntenna.pattern, 'TransmitPattern')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'The transmit antenna must have an transmit pattern');
        throw(MEx);

      end % if
      this.transmitAntenna = transmitAntenna;
      
    end % set_transmitAntenna()
    
    function set_receiveAntenna(this, receiveAntenna)
    % Sets the receive antenna.
    %
    % Parameters
    %   receiveAntenna - Receive antenna
      if ~isa(receiveAntenna.pattern, 'ReceivePattern')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'The receive antenna must have an receive pattern');
        throw(MEx);

      end % if
      this.receiveAntenna = receiveAntenna;
      
    end % set_receiveAntenna()
    
    function set_emission(this, emission)
    % Sets the emission.
    %
    % Parameters
    %   emission - Signal power, frequency, and requirement
      if ~isa(emission, 'Emission')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be class "Emission"');
        throw(MEx);

      end % if
      this.emission = emission;

    end % set_emission()
    
  end % methods
  
end % classdef
