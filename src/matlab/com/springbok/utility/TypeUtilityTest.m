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
classdef TypeUtilityTest < TestUtility
% Tests methods of TypeUtility class.
  
  properties (Constant = true)
    
    iscellstr_and_single_element = {'one'};
    ischar_and_single_row = ['one'];
    
    iscellstr_and_not_single_element = {'one', 'two'};
    ischar_and_not_single_row = ['one'; 'two'];
    iscell_and_not_iscellstr = {[1]};
    not_iscellstr_and_not_ischar = [1];
    
    iscell_and_not_iscellstr_and_single_element = {[1]};
    isnumeric_and_single_element = [1];
    islogical_and_single_element = logical([1]);
   
    iscell_and_not_single_element = {[1], [2]};
    iscell_and_single_element_containing_multiple_elements = {[1, 2]};
    isnumeric_and_not_single_element = [1, 2];
    islogical_and_not_single_element = logical([1, 2]);
    iscell_and_iscellstr = {'one'};
    not_iscell_and_not_isnumeric = ['one'];
    not_iscell_and_not_islogical = ['one'];
    
  end % properties (Constant = true)
  
  methods
    
    function this = TypeUtilityTest(logFId, testMode)
    % Constructs an TypeUtilityTest.
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
      
    end % TypeUtilityTest()
    
    function test_set_char(this)
    % Tests set_char method.
      
      output_expected = char(this.iscellstr_and_single_element);
      output_actual = TypeUtility.set_char(this.iscellstr_and_single_element);
      
      t = [];
      t = [t; strcmp(output_actual, output_expected)];
      
      output_expected = this.ischar_and_single_row;
      output_actual = TypeUtility.set_char(this.ischar_and_single_row);
      
      t = [t; strcmp(output_actual, output_expected)];
      
      try
        TypeUtility.set_char(this.iscellstr_and_not_single_element);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_char(this.ischar_and_not_single_row);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_char(this.iscell_and_not_iscellstr);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_char(this.not_iscellstr_and_not_ischar);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      this.assert_true( ...
          'TypeUtility', ...
          'set_char', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_set_char()
    
    function test_set_numeric(this)
    % Tests set_numeric method.
      
      output_expected = this.iscell_and_not_iscellstr_and_single_element{1};
      output_actual = TypeUtility.set_numeric(this.iscell_and_not_iscellstr_and_single_element);
      
      t = [];
      t = [t; isequal(output_expected, output_actual)];
      
      output_expected = this.isnumeric_and_single_element;
      output_actual = TypeUtility.set_numeric(this.isnumeric_and_single_element);
      
      t = [t; isequal(output_expected, output_actual)];
      
      try
        TypeUtility.set_numeric(this.iscell_and_not_single_element);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_numeric(this.iscell_and_single_element_containing_multiple_elements);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_numeric(this.isnumeric_and_not_single_element);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_numeric(this.iscell_and_iscellstr);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_numeric(this.not_iscell_and_not_isnumeric);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      this.assert_true( ...
          'TypeUtility', ...
          'set_numeric', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_set_numeric()
    
    function test_set_logical(this)
    % Tests set_logical method.
      
      output_expected = logical(this.iscell_and_not_iscellstr_and_single_element{1});
      output_actual = TypeUtility.set_logical(this.iscell_and_not_iscellstr_and_single_element);
      
      t = [];
      t = [t; isequal(output_expected, output_actual)];

      output_expected = this.islogical_and_single_element;
      output_actual = TypeUtility.set_logical(this.isnumeric_and_single_element);
      
      t = [t; isequal(output_expected, output_actual)];
      
      output_expected = this.islogical_and_single_element;
      output_actual = TypeUtility.set_logical(this.islogical_and_single_element);
      
      t = [t; isequal(output_expected, output_actual)];

      try
        TypeUtility.set_logical(this.iscell_and_not_single_element);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_logical(this.iscell_and_single_element_containing_multiple_elements);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_logical(this.isnumeric_and_not_single_element);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_logical(this.islogical_and_not_single_element);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try

      try
        TypeUtility.set_logical(this.iscell_and_iscellstr);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_logical(this.not_iscell_and_not_isnumeric);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      try
        TypeUtility.set_logical(this.not_iscell_and_not_islogical);
        t = [t; 0];
      catch
        t = [t; 1];
      end % try
      
      this.assert_true( ...
          'TypeUtility', ...
          'set_logical', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_set_logical()

  end % methods
  
end % classdef
