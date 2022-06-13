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
classdef TimeUtilityTest < TestUtility
% Tests methods of TimeUtility class.
  
  properties (Constant = true)
    
  end % properties (Constant = true)
  
  methods
    
    function this = TimeUtilityTest(logFId, testMode)
    % Constructs an TimeUtilityTest.
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
      
    end % TimeUtilityTest()
    
    function test_date2jd(this)
    % Tests date2jd method.
      
    % http://aa.usno.navy.mil/data/docs/JulianDate.php
      jd_expected = 2456971.500000;
      
      jd_actual = TimeUtility.date2jd(2014, 11, 10, 0, 0, 0);
      
      this.assert_true( ...
          'TimeUtility', ...
          'date2jd', ...
          this.IS_EQUAL_DESC, ...
          isequal(jd_actual, jd_expected));
      
    end % test_date2jd()
    
    function test_date2mjd(this)
    % Tests date2mjd method.
      
      mjd_expected = 56971.000000;
      
      mjd_actual = TimeUtility.date2mjd(2014, 11, 10, 0, 0, 0);
      
      this.assert_true( ...
          'TimeUtility', ...
          'date2mjd', ...
          this.IS_EQUAL_DESC, ...
          isequal(mjd_actual, mjd_expected));
      
    end % test_date2mjd()
    
    function test_jd2date(this)
    % Tests jd2date method.
      
      jd_input = 2456971.500000;
      
      year_expected   = 2014;
      month_expected  = 11;
      day_expected    = 10;
      hour_expected   = 0;
      minute_expected = 0;
      second_expected = 0;
      
      date_expected = [year_expected, month_expected, day_expected, ...
                       hour_expected, minute_expected, second_expected];
      
      [year_actual, month_actual, day_actual, ...
       hour_actual, minute_actual, second_actual] = TimeUtility.jd2date(jd_input);
      
      date_actual = [year_actual, month_actual, day_actual, ...
                     hour_actual, minute_actual, second_actual];
      
      this.assert_true( ...
          'TimeUtility', ...
          'jd2date', ...
          this.IS_EQUAL_DESC, ...
          isequal(date_actual, date_expected));
      
    end % test_jd2date()
    
    function test_mjd2date(this)
    % Tests mjd2date method.
      
      mjd_input = 56971.000000;
      
      year_expected   = 2014;
      month_expected  = 11;
      day_expected    = 10;
      hour_expected   = 0;
      minute_expected = 0;
      second_expected = 0;
      
      date_expected = [year_expected, month_expected, day_expected, ...
                       hour_expected, minute_expected, second_expected];
      
      [year_actual, month_actual, day_actual, ...
       hour_actual, minute_actual, second_actual] = TimeUtility.mjd2date(mjd_input);
      
      date_actual = [year_actual, month_actual, day_actual, ...
                     hour_actual, minute_actual, second_actual];
      
      this.assert_true( ...
          'TimeUtility', ...
          'mjd2date', ...
          this.IS_EQUAL_DESC, ...
          isequal(date_actual, date_expected));
      
    end % test_mjd2date()
    
    function test_mjd2jd(this)
    % Tests mjd2jd method.
      
      jd_expected = 2456971.500000;
      
      mjd_input = 56971.000000;
      
      jd_actual = TimeUtility.mjd2jd(mjd_input);
      
      this.assert_true( ...
          'TimeUtility', ...
          'mjd2jd', ...
          this.IS_EQUAL_DESC, ...
          isequal(jd_actual, jd_expected));
      
    end % test_mjd2jd()
    
    function test_days2hms(this)
      
      days = 1 + (2 + (3 + 4 / 60) / 60) / 24;

      hour_expected = 26;
      minute_expected = 3;
      second_expected = 4;
      
      [hour_actual, minute_actual, second_actual] = TimeUtility.days2hms(days);

      t = [];
      t = [t; isequal(hour_actual, hour_expected)];
      t = [t; isequal(minute_actual, minute_expected)];
      t = [t; abs(second_actual - second_expected) < this.LOW_PRECISION];
      
      this.assert_true( ...
          'TimeUtility', ...
          'days2hms', ...
          this.LOW_PRECISION_DESC, ...
          min(t));

    end % test_days2hms()

  end % methods
  
end % classdef
