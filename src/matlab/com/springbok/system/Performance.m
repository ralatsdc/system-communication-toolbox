classdef Performance < handle
% Describes a space station
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (SetAccess = private, GetAccess = public)

    % Carrier power density [dBW/Hz]
    C
    % Noise power density [dBW/Hz]
    N
    % Interference power density for each network [dBW/Hz]
    i
    % Interference power density total [dBW/Hz]
    I
    % Equivalent power flux density for each network [dBW/m^2 in reference bandwidth]
    epfd
    % Equivalent power flux density total [dBW/m^2 in reference bandwidth]
    EPFD

  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = Performance(C, N, i, I, epfd, EPFD)
    % Constructs a Performance.
    %
    % Parameters
    %   C - Carrier power density [dBW/Hz]
    %   N - Noise power density [dBW/Hz]
    %   i - Interference power density for each network [dBW/Hz]
    %   I - Interference power density total [dBW/Hz]
    %   epfd - Equivalent power flux density for each network
    %     [dBW/m^2 in reference bandwidth]
    %   EPFD - Equivalent power flux density total [dBW/m^2 in
    %     reference bandwidth]
      
      % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Assign properties
      this.set_C(C);
      this.set_N(N);
      this.set_i(i);
      this.set_I(I);
      this.set_EPFD(EPFD);
      this.set_epfd(epfd);

    end % Performance()
    
    function that = copy(this)
    % Copies a Performance.
    %
    % Returns
    %   that - A new Performance instance
      that = Performance( ...
          this.C, this.N, this.i, this.I, this.epfd, this.EPFD);

    end % copy()

    function set_C(this, C)
    % Sets carrier power density [dBW/Hz].
    %
    % Parameters
    %   C - Carrier power density [dBW/Hz]
      this.C = TypeUtility.set_numeric(C);

    end % set_C()
    
    function set_N(this, N)
    % Sets noise power density [dBW/Hz].
    %
    % Parameters
    %   N - Noise power density [dBW/Hz]
      this.N = TypeUtility.set_numeric(N);

    end % set_N()
    
    function set_i(this, i)
    % Sets interference power density for each network [dBW/Hz].
    %
    % Parameters
    %   i - Interference power density for each network [dBW/Hz]
      if ~isnumeric(i)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.i = i;

    end % set_I()
    
    function set_I(this, I)
    % Sets interference power density total [dBW/Hz].
    %
    % Parameters
    %   I - Interference power density total [dBW/Hz]
      this.I = TypeUtility.set_numeric(I);

    end % set_I()
    
    function set_epfd(this, epfd)
    % Sets equivalent power flux density for each network [dBW/m^2
    % in reference bandwidth].
    %
    % Parameters
    %   EPFD - Equivalent power flux density for each network
    %     [dBW/m^2 in reference bandwidth]
      if ~isnumeric(epfd)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'A numeric array is expected');
        throw(MEx);

      end % if
      this.epfd = epfd;

    end % set_EPFD()
    
    function set_EPFD(this, EPFD)
    % Sets equivalent power flux density total [dBW/m^2 in
    % reference bandwidth].
    %
    % Parameters
    %   EPFD - Equivalent power flux density total [dBW/m^2 in
    %     reference bandwidth]
      this.EPFD = TypeUtility.set_numeric(EPFD);

    end % set_EPFD()
    
  end % methods
  
end % classdef
