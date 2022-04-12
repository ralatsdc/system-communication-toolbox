classdef (Sealed = true) Logger
% Provides for logging of messages to a file.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  methods (Static = true)
    
    function open(logDir, logFNm, opnTyp)
    % Opens the log file.
    %
    % Parameters
    %   logDir - Log file directory
    %   logFNm - Log file name
    %   opnTyp - File open type: 'w' - write, or, 'a' - append
      
      if strcmp(Logger.mapio('level'), 'NONE')
        return;
        
      end % if
      
      if Logger.mapio('FID') ~= 0
        MEx = MException('Springbok:IOException', 'Log file already open.');
        throw(MEx);
        
      end % if
      
      if ~ismember(opnTyp, {'w', 'a'})
        MEx = MException('Springbok:InvalidInputExcpetion', 'Invalid log type.');
        throw(MEx);
        
      end % if
      
      Logger.mapio('logDir', logDir);
      Logger.mapio('logFNm', logFNm);
      
      Logger.mapio('FID', fopen([logDir, '/', logFNm], opnTyp));
      
    end % open()
    
    function printMsg(level, message)
    % Prints time stamp, class.function name, level and message if
    % input level is less than class level.
    %
    % Parameters
    %   level - Level for this message: 'NONE', 'INFO', 'FINE', 'FINER', 'FINEST'
    %   message - message to print
      
      if strcmp(Logger.mapio('level'), 'NONE')
        return;
        
      end % if
      
      if ~ismember({level}, {'NONE', 'INFO', 'FINE', 'FINER', 'FINEST'})
        MEx = MException('Springbok:IllegalArgumentException', 'Invalid level.');
        throw(MEx);
        
      end % if
      
      if ~Logger.isLoggable(level)
        return;
        
      end % if
      
      tstamp = datestr(now);
      logStk = dbstack;
      cfname = logStk(2).name;
      
      logMsg = sprintf('%s %s\n%s: %s\n', tstamp, cfname, level, message);
      
      fprintf(Logger.mapio('FID'), '%s', logMsg);
      
      if Logger.mapio(Logger.mapio('echo'))
        fprintf('%s', logMsg);
        
      end % if
      
    end % printMsg()
    
    function printVal(level, label, format, value)
    % Prints time stamp, class.function name, level, label and matrix
    % of formatted values if input level is less than class level.
    % 
    % Parameters
    %   level - Level for this message: 'NONE', 'INFO', 'FINE', 'FINER', 'FINEST'
    %   label - Label for the matrix of values
    %   format - Format for the matrix of values
    %   value - Matrix of values
      
      if strcmp(Logger.mapio('level'), 'NONE')
        return;
        
      end % if
      
      if ~ismember({level}, {'NONE', 'INFO', 'FINE', 'FINER', 'FINEST'})
        MEx = MException('Springbok:IllegalArgumentException', 'Invalid level.');
        throw(MEx);
        
      end % if
      
      if ~Logger.isLoggable(level)
        return;
        
      end % if
      
      tstamp = datestr(now);
      logStk = dbstack;
      cfname = logStk(2).name;
      
      logMsg = sprintf('%s %s\n%s: %s\n', tstamp, cfname, level, label);
      
      if ischar(value)
        value = cellstr(value);
        
      end % if
      
      [nRow, nCol] = size(value);
      
      if iscell(value)
        for iRow = 1:nRow
          for iCol = 1:nCol
            logMsg = [logMsg, sprintf([' ', format], value{iRow, iCol})];
            
          end % for iCol
          logMsg = [logMsg, sprintf('\n')];
          
        end % for iRow
        
      else
        for iRow = 1:nRow
          for iCol = 1:nCol
            logMsg = [logMsg, sprintf([' ', format], value(iRow, iCol))];
            
          end % for iCol
          logMsg = [logMsg, sprintf('\n')];
          
        end % for iRow
        
      end % if
      
      fprintf(Logger.mapio('FID'), '%s', logMsg);
      
      if Logger.mapio(Logger.mapio('echo'))
        fprintf('%s', logMsg);
        
      end % if
      
    end % printVal()
    
    function printMEx(MEx)
    % Prints the contents of a MATLAB exception.
    %
    % Parameters
    %   MEx - A MATLAB exception.
      
      if strcmp(Logger.mapio('level'), 'NONE')
        return;
        
      end % if
      
      iStk = 1;
      errMsg = sprintf('- Error in %s at %d: %s', ...
                       MEx.stack(iStk).name, MEx.stack(iStk).line, MEx.message);
      
      fprintf(Logger.mapio('FID'), '%s\n', errMsg);
      
      if Logger.mapio(Logger.mapio('echo'))
        fprintf('%s\n', errMsg);
        
      end % if
      
      nStk = length(MEx.stack);
      for iStk = 2:nStk
        errMsg = sprintf('  In %s at %d', ...
                         MEx.stack(iStk).name, MEx.stack(iStk).line);
        
        fprintf(Logger.mapio('FID'), '%s\n', errMsg);
        
        if Logger.mapio(Logger.mapio('echo'))
          fprintf('%s\n', errMsg);
          
        end % if
        
      end % for
      
    end % printMEx()
    
    function close()
    % Closes the log file.
      
      if strcmp(Logger.mapio('level'), 'NONE')
        return;
        
      end % if
      
      if Logger.mapio('FID') == 0
        MEx = MException('Springbok:IOException', 'Log file not open.');
        throw(MEx);
        
      end % if
      
      fclose(Logger.mapio('FID'));
      
      Logger.mapio('FID', 0);
      
    end % close()
    
    function doLog = isLoggable(level);
    % Determines whether messages would be logged at the specified
    % level.
    %
    % Parameters
    %   level - Level for messages: 'NONE', 'INFO', 'FINE', 'FINER', 'FINEST'
    %
    % Returns
    %   doLog - Indicates whether to log messages (1) or not (0)
      
      doLog = 0;
      if Logger.mapio(level) < Logger.mapio(Logger.mapio('level')) + 1
        doLog = 1;
        
      end % if
      
    end % isLoggable()
    
    function set_level(value)
    % Sets level value.
    %
    % Parameters
    %   value - Level value: 'NONE', 'INFO', 'FINE', 'FINER', 'FINEST'
      
      if ~ismember({value}, {'NONE', 'INFO', 'FINE', 'FINER', 'FINEST'})
        MEx = MException('Springbok:IllegalArgumentException', 'Invalid level.');
        throw(MEx);
        
      end % if
      
      Logger.mapio('level', value);
      
    end % set_level()
    
    function value = get_level
    % Gets level value.
      value = Logger.mapio('level');
      
    end % get_level()
    
    function set_echo(state)
    % Sets echo state.
    %
    % Parameters
    %   state - Echo state: 'ON' or 'OFF'
      
      if ~ismember({state}, {'ON', 'OFF'})
        MEx = MException('Springbok:IllegalArgumentException', 'Invalid state.');
        throw(MEx);
        
      end % if
      
      Logger.mapio('echo', state);
      
    end % set_echo()
    
    function state = get_echo
    % Gets echo state.
      state = Logger.mapio('echo');
      
    end % get_echo()
    
    function varargout = mapio(key, value)
    % Maps keys to values for assignment to persistent variables or
    % return.
    %
    % Parameters
    %   key - The key
    %   value - The value
    %
    % Returns
    %   varargout - Nothing or a value
      
      persistent logDir % Log file directory
      persistent logFNm % Log file name
      persistent FID    % Log file identifier
      persistent level  % Log level: 'NONE', 'INFO', 'FINE', 'FINER', 'FINEST'
      persistent echo   % Echo state: 'ON', 'OFF'
      
      if isempty(logDir)
        logDir = '';
        
      end % if
      
      if isempty(logFNm)
        logFNm = '';
        
      end % if
      
      if isempty(FID)
        FID = 0;
        
      end % if
      
      if isempty(level)
        level = 'NONE';
        
      end % if
      
      if isempty(echo)
        echo = 'OFF';
        
      end % if
      
      if nargin == 2 % set
        switch key
          case 'logDir'
            logDir = value;
            
          case 'logFNm'
            logFNm = value;
            
          case 'FID'
            FID = value;
            
          case 'level'
            level = value;
            
          case 'echo'
            echo = value;
            
          otherwise
            MEx = MException('Springbok:IllegalArgumentException', 'Invalid case.');
            throw(MEx);
            
        end % switch
        
      elseif nargin == 1 % get
        switch key
          case 'logDir'
            varargout{1} = logDir;
            
          case 'logFNm'
            varargout{1} = logFNm;
            
          case 'FID'
            varargout{1} = FID;
            
          case 'level'
            varargout{1} = level;
            
          case 'echo'
            varargout{1} = echo;
            
          case 'NONE'
            varargout{1} = -1;
            
          case 'INFO'
            varargout{1} = 1;
            
          case 'FINE'
            varargout{1} = 2;
            
          case 'FINER'
            varargout{1} = 3;
            
          case 'FINEST'
            varargout{1} = 4;
            
          case 'ON'
            varargout{1} = 1;
            
          case 'OFF'
            varargout{1} = 0;
            
          otherwise
            MEx = MException('Springbok:IllegalArgumentException', 'Invalid case.');
            throw(MEx);
            
        end % switch
        
      end % if
      
    end % mapio()
    
  end % methods (Static = true)
  
end % classdef
