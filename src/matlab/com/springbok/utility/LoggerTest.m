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
classdef LoggerTest < TestUtility
% Tests methods of Logger class.
  
  properties (Constant = true)
    
    input_logDir = '.';
    input_logFNm = 'Logger.log';
    input_opnTyp = 'w';
    
  end % properties (Constant = true)
  
  methods
    
    function this = LoggerTest(logFId, testMode)
    % Constructs a LoggerTest.
    %
    % Parameters
    %   logFId - Log file identifier
    %   testMode - Test mode, if 'interactive' then beeps and pauses
      
      % Invoke the superclass constructor
      if nargin == 0
        superArgs = {};
        
      else
        superArgs{1} = logFId;
        superArgs{2} = testMode;
        
      end % if
      this@TestUtility(superArgs{:});
      
    end % LoggerTest()
    
    % TODO: Test function open(logDir, logFNm, opnTyp)
    % TODO: Test function printMsg(level, message)
    % TODO: Test function printVal(level, label, format, value)
    % TODO: Test function printMEx(MEx)
    % TODO: Test function close()
    % TODO: Test function doLog = isLoggable(level);
    % TODO: Test function set_level(value)
    % TODO: Test function value = get_level
    % TODO: Test function set_echo(state)
    % TODO: Test function state = get_echo
    % TODO: Test function varargout = mapio(key, value)

  end % methods
  
end % classdef
