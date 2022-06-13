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
classdef Beam < handle
% Describes a space or an Earth station beam.
  
  properties (SetAccess = protected, GetAccess = public)
    
    % Beam name
    name
    % Maximum number of divisions allowed
    multiplicity
    % Duty cycle
    dutyCycle
    
    % Flag indicating if the beam is available, or not
    isAvailable
    % Flag indicating if the beam is multiplexed, or not
    isMultiplexed
    % Number of divisions in use
    divisions
    
  end % properties
  
  methods
    
    function this = Beam(name, multiplicity, dutyCycle)
    % Constructs a Beam.
    %
    % Parameters
    %   name - Beam name
    %   multiplicity - Maximum number of divisions allowed
    %   dutyCycle - Duty cycle [%]
      
      % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Assign properties
      this.set_name(name);
      this.set_multiplicity(multiplicity);
      this.set_dutyCycle(dutyCycle);
      
      % Derive properties
      this.isAvailable = 1;
      this.isMultiplexed = 0;
      this.divisions = 0;
      
    end % Beam()

    function that = copy(this)
    % Copies a Beam.
    %
    % Returns
    %   that - A new Beam instance
      that = Beam(this.name, this.multiplicity, this.dutyCycle);
      that.set_isAvailable(this.isAvailable);
      that.set_isMultiplexed(this.isMultiplexed);
      that.set_divisions(this.divisions);

    end % copy()

    function set_name(this, name)
    % Sets beam name.
    % 
    % Parameters
    %   name - Beam name
      this.name = TypeUtility.set_char(name);

    end % set_name()

    function set_multiplicity(this, multiplicity)
    % Sets maximum number of divisions allowed.
    %
    % Parameters
    %   multiplicity - Maximum number of divisions allowed
      this.multiplicity = round(TypeUtility.set_numeric(multiplicity));

    end % set_multiplicity()

    function set_dutyCycle(this, dutyCycle)
    % Sets duty cycle [%].
    %
    % Parameters
    %   dutyCycle - Duty cycle [%]
      dutyCycle = TypeUtility.set_numeric(dutyCycle);
      if dutyCycle < 0 || dutyCycle > 100
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Duty cycle must be between 0 and 100');
        throw(MEx);

      end % if
      this.dutyCycle = dutyCycle;

    end % set_dutyCycle()

    function set_isAvailable(this, isAvailable)
    % Sets flag indicating if the beam is available, or not.
    %
    % Parameters
    %   isAvailable - Flag indicating if the beam is available, or
    %     not
      if ~ismember(isAvailable, [0, 1])
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be zero or one');
        throw(MEx);

      end % if
      this.isAvailable = isAvailable;

    end % set_isAvailable()

    function set_isMultiplexed(this, isMultiplexed)
    % Sets flag indicating if the beam is multiplexed, or not.
    %
    % Parameters
    %   isMultiplexed - Flag indicating if the beam is multiplexed,
    %     or not
      if ~ismember(isMultiplexed, [0, 1])
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input must be zero or one');
        throw(MEx);

      end % if
      this.isMultiplexed = isMultiplexed;

    end % set_isMultiplexed()

    function set_divisions(this, divisions)
    % Sets number of divisions in use.
    %
    % Parameters
    %   divisions - Number of divisions in use
      divisions = TypeUtility.set_numeric(divisions);
      if divisions < 0
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Divisions must be a non-negative integer');
        throw(MEx);

      end % if
      this.divisions = round(divisions);

    end % set_divisions()

    function isAssigned = assign(this, doMultiplexing)
    % Assign this beam, if available. On construction the beam is
    % available, and not multiplexed.  When the beam is first
    % assigned, the beam becomes unavailable if it is not multiplexed,
    % or, if it becomes multiplexed, the multiplicity is
    % one. Subsequently, when the beam is next assigned, the beam must
    % be multiplexed, and so it becomes unavailable if the divisions
    % equal the multiplicity.
    % 
    % Parameters
    %   doMultiplexing - Flag indicating whether to do
    %     multiplexing, or not
    %
    % Returns
    %   isAssigned - Flag indicating whether the beam was assigned,
    %     or not.

      if ~this.isAvailable

        % Unavailable
        isAssigned = 0;
        
      elseif this.divisions == 0

        % Available, and never assigned
        isAssigned = 1;
        this.divisions = this.divisions + 1;
        if ~doMultiplexing

          % Not multiplexed
          this.isAvailable = 0;
          
        else

          % Multiplexed
          this.isMultiplexed = 1;
          if ~(this.divisions < this.multiplicity)

            % No divisions remaining
            this.isAvailable = 0;

          end % if
          
        end % if
        
      else % Available, assigned before, so must be multiplexed

        if ~(doMultiplexing == this.isMultiplexed)

          % Multiplexing disagrees
          isAssigned = 0;
          
        else
          
          % Multiplexing agrees
          isAssigned = 1;
          this.divisions = this.divisions + 1;
          if ~(this.divisions < this.multiplicity)

            % No divisions remaining
            this.isAvailable = 0;

          end % if

        end % if

      end % if
      
    end % assign()
    
    function reset(this)
    % Reset derived properties to initial values.
      this.isAvailable = 1;
      this.isMultiplexed = 0;
      this.divisions = 0;

    end % reset()
    
  end % methods
  
end % classdef
