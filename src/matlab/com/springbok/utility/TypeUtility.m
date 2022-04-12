classdef TypeUtility < handle
% Defines methods for enforcing type constraints.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  methods (Static = true)

    function output = set_char(input)
    % Convert a cell array of strings or character array to a
    % character array with a single element.
    %
    % Parameters
    %   input - Input cell array of strings or character array
    %
    % Returns
    %   output - Output character array with a single element

      % Check type of input argument
      if ~(iscellstr(input) || ischar(input))
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input is not cell array of strings or character array.');
        throw(MEx);

      end % if

      % Convert a cell array of strings or character array to a
      % character array with a single element
      [nRow, nCol] = size(input);
      if iscellstr(input)
        if ~(nRow == 1 && nCol == 1)
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Cell array contains more than one element.');
          throw(MEx);

        end % if
        output = char(input);

      else % ischar(input)
        if nRow ~= 1
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Character array contains more than one row');
          throw(MEx);

        end % if
        output = input;

      end % if

    end % set_char()

    function output = set_numeric(input)
    % Convert a cell array or matrix of numbers to a scalar.
    %
    % Parameters
    %   input - Input cell array or matrix of numbers
    %
    % Returns
    %   output - Output scalar
      
      % Check type of input argument
      if ~((iscell(input) && ~iscellstr(input)) || isnumeric(input))
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input is not cell array or matrix of numbers.');
        throw(MEx);
        
      end % if         
      
      % Check size of input argument
      [nRow, nCol] = size(input);
      if ~(nRow == 1 && nCol == 1)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Cell array or matrix contains more than one element.');
        throw(MEx);
        
      end % if
      
      % Convert a cell array or matrix of numbers to a scalar
      if iscell(input)
        output = input{1};
        [nRow, nCol] = size(output);
        if ~(nRow == 1 && nCol == 1)
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Single cell array element contains more than one element.');
          throw(MEx);
          
        end % if
        
      else % isnumeric(input)
        output = input;
        
      end % if
      
    end % set_numeric()
    
    function output = set_logical(input)
    % Convert a cell array or matrix of numbers to a logical
    % scalar.
    %
    % Parameters
    %   input - Input cell array or matrix of numbers
    %
    % Returns
    %   output - Output scalar
      
      % Check type of input argument
      if ~((iscell(input) && ~iscellstr(input)) || isnumeric(input) || islogical(input))
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Input is not cell array or matrix of numbers or logicals.');
        throw(MEx);
        
      end % if         
      
      % Check size of input argument
      [nRow, nCol] = size(input);
      if ~(nRow == 1 && nCol == 1)
        MEx = MException('Springbok:IllegalArgumentException', ...
                         'Cell array or matrix contains more than one element.');
        throw(MEx);
        
      end % if
      
      % Convert a cell array or matrix of numbers to a scalar
      if iscell(input)
        output = input{1};
        [nRow, nCol] = size(output);
        if ~(nRow == 1 && nCol == 1)
          MEx = MException('Springbok:IllegalArgumentException', ...
                           'Single cell array element contains more than one element.');
          throw(MEx);
          
        end % if
        
      else % isnumeric(input) or islogical(input)
        output = logical(input);
        
      end % if
      
    end % set_numeric()

    function output = is_member(object, objects)
    % Determines if an object is equal to a member of another set of
    % objects.
    %
    % Parameters
    %   object - The object to test
    %   objects - The set of objects to test against
    %      
    % Returns
    %   output - Logicial indicating membership
      output = 0;
      nObj = length(objects);
      for iObj = 1:nObj
        if isequal(object, objects(iObj))
          output = 1;
          break;

        end % if

      end % for

    end % is_member()

  end % methods (Static = true)
  
end % classdef
