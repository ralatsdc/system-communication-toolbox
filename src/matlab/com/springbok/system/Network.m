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
classdef Network < handle
% Describes a network of two stations, typically a space and an
% Earth station.
  
  properties (SetAccess = protected, GetAccess = public)
    
    % An Earth station
    earthStation
    % A space station
    spaceStation
    % A space station beam
    spaceStationBeam
    % Propagation loss models to apply
    losses

    % Link direction: 'up', 'down', or 'both' (the default)
    type
    % Flag to check input arguments, or not (check by default)
    doCheck
    
    % An Earth station beam
    earthStationBeam

    % An up link
    up_Link
    % A down link
    dn_Link
    
  end % properties
  
  methods
    
    function this = Network(earthStation, spaceStation, spaceStationBeam, losses, varargin)
    % Constructs a Network.
    %
    % Parameters
    %   earthStation - An Earth station
    %   spaceStation - A space station
    %   spaceStationBeam - A space station beam
    %   losses - Propagation loss models to apply
    %
    % Options
    %   Type - Link direction: 'up', 'down', or 'both' (the
    %   default)
    %   DoCheck - Flag for checking input values (default is 1)
     
      % No argument constructor
      if nargin == 0
        this.type = 'both';
        this.doCheck = 1;
        this.up_Link = Link();
        this.dn_Link = Link();
        return;
        
      end % if
      
      % Parse variable input arguments
      p = inputParser;
      p.addParamValue('Type', 'both');
      p.addParamValue('DoCheck', 1);
      p.parse(varargin{:});
      this.set_type(p.Results.Type);
      this.set_doCheck(p.Results.DoCheck);

      % Assign properties
      this.set_earthStation(earthStation);
      this.set_spaceStation(spaceStation);
      this.set_spaceStationBeam(spaceStationBeam);
      this.set_losses(losses);
      
      % Derive properties
      this.up_Link = Link();
      this.up_Link.set_doCheck(this.doCheck);
      this.dn_Link = Link();
      this.dn_Link.set_doCheck(this.doCheck);
      this.set_links();
      
    end % Network()
    
    function that = copy(this)
    % Copies a Network.
    %
    % Returns
    %   that - A new Network instance
      if ~this.isEmpty
        that = Network(this.earthStation.copy(), this.spaceStation.copy(), ...
                       this.spaceStationBeam.copy(), this.losses, ...
                       'type', this.type, 'doCheck', this.doCheck);
      else
        that = Network();

      end % if
      
    end % copy()

    function set_earthStation(this, earthStation)
    % Set the Earth station.
    %
    % Parameters
    %   earthStation - The Earth station
      if ~(isa(earthStation, 'EarthStation') ...
           || isa(earthStation, 'EarthStationInMotion'))
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be an instance of class "EarthStation" or "EarthStationInMotion"');
        throw(MEx);

      end % if
      this.earthStation = earthStation;

    end % if

    function set_spaceStation(this, spaceStation)
    % Set the space station.
    %
    % Parameters
    %   spaceStation - The space station
      if ~isa(spaceStation, 'SpaceStation')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be an instance of class "SpaceStation"');
        throw(MEx);

      end % if
      this.spaceStation = spaceStation;

    end % if

    function set_spaceStationBeam(this, spaceStationBeam)
    % Sets space station beam.
    %
    % Parameters
    %   spaceStationBeam - A space station beam
      if this.doCheck
        if ~isa(spaceStationBeam, 'Beam')
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Input must be of class "Beam"');
          throw(MEx);

        elseif length(spaceStationBeam) > 1
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'A Network must have a single space station beam');
          throw(MEx);

        elseif ~TypeUtility.is_member(spaceStationBeam, this.spaceStation.beams)
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'The Beam must be a member of the space station beam array');
          throw(MEx);

        end % if

      end % if
      this.spaceStationBeam = spaceStationBeam;
      
    end % set_spaceStationBeam()

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

    function set_type(this, type)
    % Sets link direction: 'up', 'down', or 'both' (the default).
    %
    % Parameters
    %   type - Link direction: 'up', 'down', or 'both' (the
    %     default)
      if this.doCheck
        type = lower(TypeUtility.set_char(type));
        if ~ismember(type, {'up', 'down', 'both'})
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Input must be "up", "down", or "both" (the default)');
          throw(MEx);
          
        end % if
      end % if
      this.type = type;
      
    end % set_type()

    function set_doCheck(this, doCheck)
    % Sets flag to check input arguments, or not.
    %
    % Parameters
    %   doCheck - Flag to check input arguments, or not
      this.doCheck = TypeUtility.set_logical(doCheck);

    end % if

    function set_links(this)
    % Constructs links
      this.earthStationBeam = this.earthStation.beam;
      switch lower(this.type)
        case {'up'}
          this.up_Link.set_transmitStation(this.earthStation)
          this.up_Link.set_transmitStationBeam(this.earthStationBeam)
          this.up_Link.set_receiveStation(this.spaceStation)
          this.up_Link.set_losses(this.losses)
          
        case {'down'}
          this.dn_Link.set_transmitStation(this.spaceStation);
          this.dn_Link.set_transmitStationBeam(this.spaceStationBeam);
          this.dn_Link.set_receiveStation(this.earthStation);
          this.dn_Link.set_losses(this.losses);
          
        case {'both'}
          this.up_Link.set_transmitStation(this.earthStation)
          this.up_Link.set_transmitStationBeam(this.earthStationBeam)
          this.up_Link.set_receiveStation(this.spaceStation)
          this.up_Link.set_losses(this.losses)
                    
          this.dn_Link.set_transmitStation(this.spaceStation);
          this.dn_Link.set_transmitStationBeam(this.spaceStationBeam);
          this.dn_Link.set_receiveStation(this.earthStation);
          this.dn_Link.set_losses(this.losses);
          
        otherwise
          exc = SException('Springbok:InvalidInput', ...
                           sprintf('Link type "%s" invalid', type));
          throw(exc)
          
      end % switch
      
    end % set_links()

    function is = isEmpty(this)
    % Determines if Network properties are empty, or not.
      is = isempty(this.earthStation) && ...
           isempty(this.spaceStation) && ...
           isempty(this.spaceStationBeam) && ...
           isempty(this.losses) && ...
           isempty(this.earthStationBeam) && ...
           this.up_Link.isEmpty() && ...
           this.dn_Link.isEmpty();

    end % isEmpty()

  end % methods
  
end % classdef
