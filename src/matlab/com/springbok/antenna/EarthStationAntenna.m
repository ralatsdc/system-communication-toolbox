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
classdef EarthStationAntenna < Antenna
% Describes an Earth station antenna.
  
  properties (SetAccess = private, GetAccess = public)
    
    % Antenna pattern identifier
    pattern_id

    % Antenna pattern
    pattern

    % Gain function options
    options

  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = EarthStationAntenna(name, gain, pattern_id, pattern)
      % Constructs an Earth station antenna.
      %
      % Parameters
      %   name - Antenna name
      %   gain - Antenna gain [dB]
      %   pattern_id - Antenna pattern identifier
      %   pattern - Antenna pattern
      
      % Invoke superclass constructor
      if nargin == 0
        superArgs = {};
        
      else
        superArgs{1} = name;
        superArgs{2} = gain;

      end % if
      this@Antenna(superArgs{:});
      if nargin == 0
        return

      end % if

      % Assign properties
      this.set_pattern_id(pattern_id);
      this.set_pattern(pattern);
      this.set_options({});
      
    end % EarthStationAntenna()

    function that = copy(this)
    % Copies an Earth station antenna.
    %
    % Returns
    %   that - A new EarthStationAntenna instance
      that = EarthStationAntenna(this.name, this.gain, this.pattern_id, this.pattern.copy());
      that.set_feeder_loss(this.feeder_loss);
      that.set_body_loss(this.body_loss);
      that.set_noise_t(this.noise_t);
      that.set_x_ltp(this.x_ltp);
      that.set_z_ltp(this.z_ltp);
      that.set_options(this.options);

    end % copy()

    function set_pattern_id(this, pattern_id)
    % Sets antenna pattern identifier.
    %
    % Parameters
    %   pattern_id - Antenna pattern identifier
      this.pattern_id = TypeUtility.set_numeric(pattern_id);

    end % set_pattern_id()

    function set_pattern(this, pattern)
    % Sets pattern
    %
    % Parameters
    %   pattern - An Earth antenna pattern
      if ~isa(pattern, 'EarthPattern')
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'The Earth station antenna must have an Earth pattern');
        throw(MEx);

      end % if
      this.pattern = pattern;

    end % set_pattern()

    function set_options(this, options)
    % Sets options
    %
    % Parameters
    %   options - Gain function options
      this.options = options;

    end % set_options()

  end % methods
  
end % classdef
