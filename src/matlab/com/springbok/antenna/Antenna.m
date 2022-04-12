classdef Antenna < handle
% Describes a space or an Earth station antenna.

% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = protected, GetAccess = public)
    
    % Antenna name
    name
    % Antenna gain [dB]
    gain

    % Feeder loss [dB]
    feeder_loss
    % Body loss [dB]
    body_loss
    % Antenna noise temperature [K]
    noise_t
    % Antenna unit azimuth reference (normal) vector in local tangent coordinates
    x_ltp
    % Antenna unit elevation reference vector in local tangent coordinates
    z_ltp

  end % properties
  
  methods
    
    function this = Antenna(name, gain)
    % Constructs an Antenna.
    %
    % Parameters
    %   name - Antenna name
    %   gain - Antenna gain [dB]

    % No argument constructor
      if nargin == 0
        return;
        
      end % if

      % Assign properties
      this.set_name(name);
      this.set_gain(gain);
      this.set_feeder_loss(0);
      this.set_body_loss(0);
      this.set_noise_t(NaN);
      this.set_x_ltp([]);
      this.set_z_ltp([]);

    end % Antenna()

    function that = copy(this)
    % Copies an Antenna.
    %
    % Returns
    %   that - A new Antenna instance
      that = Antenna(this.name, this.gain)
      that.set_feeder_loss(this.feeder_loss);
      that.set_body_loss(this.body_loss);
      that.set_noise_t(this.noise_t);
      that.set_x_ltp(this.x_ltp);
      that.set_z_ltp(this.z_ltp);

    end % copy()

    function set_name(this, name)
    % Sets antenna name.
    %
    % Parameters
    %   name - Antenna name
      this.name = TypeUtility.set_char(name);

    end % set_name()

    function set_gain(this, gain)
    % Sets antenna gain [dB].
    %
    % Parameters
    %   gain - Antenna gain [dB]
      this.gain = TypeUtility.set_numeric(gain);

    end % set_gain()
      
    function set_feeder_loss(this, feeder_loss)
    % Sets antenna feeder loss [dB].
    %
    % Parameters
    %   feeder_loss - Feeder loss [dB]
      this.feeder_loss = TypeUtility.set_numeric(feeder_loss);

    end % set_feeder_loss()
      
    function set_body_loss(this, body_loss)
    % Sets antenna body loss [dB].
    %
    % Parameters
    %   body_loss - Body loss [dB]
      this.body_loss = TypeUtility.set_numeric(body_loss);

    end % set_body_loss()
      
    function set_noise_t(this, noise_t)
    % Sets antenna noise temperature [K].
    %
    % Parameters
    %   noise_t - Antenna noise temperature [K]
      this.noise_t = TypeUtility.set_numeric(noise_t);

    end % set_noise_t()

    function set_x_ltp(this, x_ltp)
    % Set antenna unit azimuth reference (normal) vector in local
    % tangent coordinates.
      if ~(isempty(x_ltp) ...
           || (isnumeric(x_ltp) ...
               && isequal(size(x_ltp), [3, 1])))
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'x_ltp must be a numeric column vector');
        throw(MEx)

      end % if
      this.x_ltp = x_ltp;

    end % set_x_ltp()

    function set_z_ltp(this, z_ltp)
    % Set antenna unit elevation reference vector in local tangent
    % coordinates.
      if ~(isempty(z_ltp) ...
           || (isnumeric(z_ltp) ...
               && isequal(size(z_ltp), [3, 1])))
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'z_ltp must be a numeric column vector');
        throw(MEx)

      end % if
      this.z_ltp = z_ltp;

    end % set_z_ltp()

    % TODO: Add antenna pattern gain function that accepts optional arguments

  end % methods

end % classdef
