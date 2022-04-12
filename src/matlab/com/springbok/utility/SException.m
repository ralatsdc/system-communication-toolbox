classdef SException < MException
% Extends the MATLAB exception class which includes error and
% warning messages.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties
    
    event_code
    symbol
    event_message
    
  end % properties
  
  methods
    
    function this = SException(msg_ident, msg_string, ...
                               event_code, symbol, event_message)
      % Constructs a Springbok exception.
      
      % Call superclass constructor
      if nargin < 2 || nargin > 5
        exc = MException('Springbok:APT:InvalidInput', ...
                         'Invalid number of arguments.');
        throw(exc)
        
      end % if
      this@MException(msg_ident, msg_string)
      
      % Assign instance properties
      this.event_code = 0;
      this.symbol = '';
      this.event_message = '';
      
      if nargin > 2
        this.event_code = TypeUtility.set_numeric(event_code);
        
      end % if
      
      if nargin > 3
        this.symbol = TypeUtility.set_numeric(symbol);
        
      end % if
      
      if nargin > 4
        this.event_message = TypeUtility.set_numeric(event_message);
        
      end % if
      
    end % SException
      
    function that = copy(this)
    % Constructs a Springbok exception.
    %
    % Returns
    %   that - A new SException instance
    that = SException(this.msg_ident, this.msg_string, this.event_code, ...
                      this.symbol, this.event_message);

    end % copy()

  end % methods

end % classdef
