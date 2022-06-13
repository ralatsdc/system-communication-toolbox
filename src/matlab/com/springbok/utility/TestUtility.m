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
classdef TestUtility < handle
% Defines properties and methods for unit testing.
  
  properties (Constant)
    
    HIGH_PRECISION = 1e-14;
    MEDIUM_PRECISION = 1e-11;
    LOW_PRECISION = 1e-8;
    VERY_LOW_PRECISION = 1e-6;
    ENGINEERING_PRECISION = 0.02;

    HIGH_PRECISION_DESC = 'Within high precision.';
    MEDIUM_PRECISION_DESC = 'Within medium precision.';
    LOW_PRECISION_DESC = 'Within low precision.';
    VERY_LOW_PRECISION_DESC = 'Within very low precision.';
    ENGINEERING_PRECISION_DESC = 'Within engineering precision.';
    
    IS_EQUAL_DESC = 'Is equal.';
    
  end % properties (Constant)
  
  properties (Access = private)
    
    % Log file identifier
    logFId = 1;
    % Test mode, if 'interactive' then beeps and pauses
    testMode = 'interactive';
    
  end % properties (SetAccess = private, GetAccess = public)
  
  methods
    
    function this = TestUtility(logFId, testMode)
    % Constructs a TestUtility. Without arguments, output is
    % directed to standard output, and is not interactive.
    %
    % Parameters
    %   logFId -Log file identifier
    %   testMode - Test mode, if 'interactive' then beeps and pauses
      
      % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Assign properties
      this.logFId = TypeUtility.set_numeric(logFId);
      this.testMode = TypeUtility.set_char(testMode);
      
    end % TestUtility()
    
    function assert_true(this, classNm, methodNm, testDesc, testRslt)
    % Reports the result of a test.
    %
    % Parameters
    %   classNm - Class name being reported
    %   methodNm - Method name being reported
    %   testDesc - Test description
    %   testRslt - Test result logical
      
      fprintf(this.logFId, ...
              '%s %s.%s (%s) ... ', datestr(now), classNm, methodNm, testDesc);
      if testRslt
        fprintf(this.logFId, 'PASS\n');
        
      else
        fprintf(this.logFId, 'FAIL\n');
        if strcmp(this.testMode, 'interactive')
          beep; pause(0.3); beep; pause(0.3); beep;
          dbstack;
          keyboard;
          
        end % if
        
      end % if
      
    end % assert_true()
    
    function testAll(this)
    % Run each method of a TestUtility whose name begins with
    % 'test_'. Exceptions are caught since no arguments are assumed
    % to be required for the method. Print a stack trace on catching
    % an exception if in 'interactive' mode.
      
      % Consider each method of the class
      tests = methods(class(this));
        nTest = length(tests);
        for iTest = 1:nTest
          test = tests{iTest};
          
          % Run the test if the name of the method begins with 'test_'
          if ~isempty(regexp(test, '^test_'))
            try
              eval(['this.', test]);
              
            catch MEx
              
              if strcmp(this.testMode, 'interactive')
                
                % Print a stack trace if interactive
                beep; pause(0.3); beep; pause(0.3); beep;
                dbstack;
                keyboard;
                
              else
                % Do nothing
                
              end % if
              
            end % try
            
          end % if
          
        end % for
        
      end % testAll()
      
  end % methods
  
  methods (Static = true)

    function testDir(dir_name)
      
      if exist(dir_name) ~= 7
        exc = MException( ...
            'Springbok:InvalidInput', ...
            sprintf('%s is not a directory', dir_name));
        throw(exc)
        
      end % if
      
      files = dir([dir_name, '/*Test.m']);
      
      nFls = length(files);
      for iFls = 1:nFls
        file_name = files(iFls).name;
        eval([strrep(file_name, '.m', ''), '(1, ''interactive'').testAll']);
        
      end % for
      
    end % function testDir()
      
  end % methods (Static = True)
  
end % classdef
