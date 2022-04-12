classdef (Sealed = true) TimeUtility
% Provides transformations between coordinate systems:
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  methods (Static = true)
    
    function jd = date2jd(varargin)
    % DATE2JD Julian day number from Gregorian date.
    %
    % JD = DATE2JD(YEAR, MONTH, DAY, HOUR, MINUTE, SECOND) returns the Julian
    % day number of the given date (Gregorian calendar) plus a fractional part
    % depending on the time of day.
    %
    % Any missing MONTH or DAY will be replaced by ones.  Any missing HOUR,
    % MINUTE or SECOND will be replaced by zeros.
    %
    % If no date is specified, the current date and time is used.
    %
    % Start of the JD (Julian day) count is from 0 at 12 noon 1 January -4712
    % (4713 BC), Julian proleptic calendar.  Note that this day count conforms
    % with the astronomical convention starting the day at noon, in contrast
    % with the civil practice where the day starts with midnight.
    %
    % Astronomers have used the Julian period to assign a unique number to
    % every day since 1 January 4713 BC.  This is the so-called Julian Day
    % (JD).  JD 0 designates the 24 hours from noon UTC on 1 January 4713 BC
    % (Julian proleptic calendar) to noon UTC on 2 January 4713 BC.
      
    % Sources:
    % - http://tycho.usno.navy.mil/mjd.html
    % - The Calendar FAQ (http://www.faqs.org)
      
    % Author:     Peter J. Acklam
    % Time-stamp: 2002-05-24 13:30:06 +0200
    % E-mail:     pjacklam@online.no
    % URL:        http://home.online.no/~pjacklam
      
      nargsin = nargin;
      narginchk(0, 6);
      if nargsin
        argv = {1 1 1 0 0 0};
        argv(1:nargsin) = varargin;
        
      else
        argv = num2cell(clock);
        
      end % if
      
      [year, month, day, hour, minute, second] = deal(argv{:});
      
      % The following algorithm is a modified version of the one found in the
      % Calendar FAQ.
      a = floor((14 - month)/12);
      y = year + 4800 - a;
      m = month + 12*a - 3;
      
      % For a date in the Gregorian calendar:
      jd = day + floor((153*m + 2)/5) ...
           + y*365 + floor(y/4) - floor(y/100) + floor(y/400) - 32045 ...
           + ( second + 60*minute + 3600*(hour - 12) )/86400;
      
    end % date2jd()
    
    function mjd = date2mjd(varargin)
    % DATE2MJD Modified Julian day number.
    %
    % MJD = DATE2MJD(YEAR, MONTH, DAY, HOUR, MINUTE, SECOND) returns the
    % modified Julian day number of the given date plus a fractional part
    % depending on the day and time of day.
    %
    % Any missing MONTH or DAY will be replaced by ones.  Any missing HOUR,
    % MINUTE or SECOND will be replaced by zeros.
    %
    % If no date is specified, the current date and time is used.  Gregorian
    % calendar is assumed.
    %
    % Start of the MJD (modified Julian day) count is from 0 at 00:00 UTC 17
    % November 1858 (Gregorian calendar).
      
    % Author:     Peter J. Acklam
    % Time-stamp: 2002-03-03 12:52:13 +0100
    % E-mail:     pjacklam@online.no
    % URL:        http://home.online.no/~pjacklam
      
      mjd = TimeUtility.date2jd(varargin{:}) - 2400000.5;
      
    end % date2mjd()
    
    function [hour, minute, second] = days2hms(days)
    % DAYS2HMS Convert days into hours, minutes, and seconds.
    %
    % [HOUR, MINUTE, SECOND] = DAYS2HMS(DAYS) converts the number of days to
    % hours, minutes, and seconds.
    %
    % The following holds (to within rounding precision):
    %
    % DAYS = HOUR / 24 + MINUTE / (24 * 60) + SECOND / (24 * 60 * 60)
    %      = (HOUR + (MINUTE + SECOND / 60) / 60) / 24
      
    % Author:     Peter J. Acklam
    % Time-stamp: 2002-03-03 12:52:02 +0100
    % E-mail:     pjacklam@online.no
    % URL:        http://home.online.no/~pjacklam
      
      narginchk(1, 1);
      
      % TODO: Improve the precision of this conversion
      second = 86400 * days;
      hour   = fix(second/3600);           % get number of hours
      second = second - 3600*hour;         % remove the hours
      minute = fix(second/60);             % get number of minutes
      second = second - 60*minute;         % remove the minutes
      
    end % days2hms
    
    function [year, month, day, hour, minute, second] = jd2date(jd)
    % JD2DATE Gregorian calendar date from modified Julian day number.
    %
    % [YEAR, MONTH, DAY, HOUR, MINUTE, SECOND] = JD2DATE(JD) returns the
    % Gregorian calendar date (year, month, day, hour, minute, and second)
    % corresponding to the Julian day number JD.
    %
    % Start of the JD (Julian day) count is from 0 at 12 noon 1 JAN -4712
    % (4713 BC), Julian proleptic calendar.  Note that this day count conforms
    % with the astronomical convention starting the day at noon, in contrast
    % with the civil practice where the day starts with midnight.
    %
    % Astronomers have used the Julian period to assign a unique number to
    % every day since 1 January 4713 BC.  This is the so-called Julian Day
    % (JD). JD 0 designates the 24 hours from noon UTC on 1 January 4713 BC
    % (Julian calendar) to noon UTC on 2 January 4713 BC.
      
    % Sources:
    % - http://tycho.usno.navy.mil/mjd.html
    % - The Calendar FAQ (http://www.faqs.org)
      
    % Author:     Peter J. Acklam
    % Time-stamp: 2002-05-24 15:24:45 +0200
    % E-mail:     pjacklam@online.no
    % URL:        http://home.online.no/~pjacklam
      
      nargsin = nargin;
      narginchk(1, 1);
      
      % Adding 0.5 to JD and taking FLOOR ensures that the date is correct.
      % Here are some sample values:
      %
      %  MJD     Date       Time
      %  -1.00 = 1858-11-16 00:00 (not 1858-11-15 24:00!)
      %  -0.75 = 1858-11-16 06:00
      %  -0.50 = 1858-11-16 12:00
      %  -0.25 = 1858-11-16 18:00
      %   0.00 = 1858-11-17 00:00 (not 1858-11-16 24:00!)
      %  +0.25 = 1858-11-17 06:00
      %  +0.50 = 1858-11-17 12:00
      %  +0.75 = 1858-11-17 18:00
      %  +1.00 = 1858-11-18 00:00 (not 1858-11-17 24:00!)
      ijd = floor(jd + 0.5); % integer part
      
      if nargout > 3
        fjd = jd - ijd + 0.5; % fraction part
        [hour, minute, second] = TimeUtility.days2hms(fjd);
        
      end % if
      
      % The following algorithm is from the Calendar FAQ.
      a = ijd + 32044;
      b = floor((4 * a + 3) / 146097);
      c = a - floor((b * 146097) / 4);
      
      d = floor((4 * c + 3) / 1461);
      e = c - floor((1461 * d) / 4);
      m = floor((5 * e + 2) / 153);
      
      day   = e - floor((153 * m + 2) / 5) + 1;
      month = m + 3 - 12 * floor(m / 10);
      year  = b * 100 + d - 4800 + floor(m / 10);
      
      
    end % jd2date()
    
    function [year, month, day, hour, minute, second] = mjd2date(mjd)
    % MJD2DATE Gregorian calendar date from Julian day number.
    %
    % [YEAR, MONTH, DAY, HOUR, MINUTE, SECOND] = MJD2DATE(MJD) returns the
    % Gregorian calendar date (year, month, day, hour, minute, and second)
    % corresponding to the Julian day number JDAY.
    %
    % Start of the JD (Julian day) count is from 0 at 12 noon 1 JAN -4712
    % (4713 BC), Julian proleptic calendar.  Note that this day count conforms
    % with the astronomical convention starting the day at noon, in contrast
    % with the civil practice where the day starts with midnight.
    %
    % Astronomers have used the Julian period to assign a unique number to
    % every day since 1 January 4713 BC.  This is the so-called Julian Day
    % (JD). JD 0 designates the 24 hours from noon UTC on 1 January 4713 BC
    % (Julian calendar) to noon UTC on 2 January 4713 BC.
      
    % Sources:
    % - http://tycho.usno.navy.mil/mjd.html
    % - The Calendar FAQ (http://www.faqs.org)
      
    % Author:     Peter J. Acklam
    % Time-stamp: 2002-03-03 12:50:30 +0100
    % E-mail:     pjacklam@online.no
    % URL:        http://home.online.no/~pjacklam
      
      nargsin = nargin;
      narginchk(1, 1);
      
      % We could have got everything by just using
      %
      %   jd = mjd2jd(mjd);
      %   [year, month, day, hour, minute, second] = jd2date(jd);
      %
      % but we lose precision in the fraction part when MJD is converted to JD
      % because of the large offset (2400000.5) between JD and MJD.
      jd = TimeUtility.mjd2jd(mjd);
      [year, month, day] = TimeUtility.jd2date(jd);
      
      if nargout > 3
        fmjd = mjd - floor(mjd);
        [hour, minute, second] = TimeUtility.days2hms(fmjd);
        
      end % if
      
    end % mjd2date()
    
    function jd = mjd2jd(mjd)
    % MJD2JD Modified Julian day number from Julian day number.
    %
    % JD = MJD2JD(MJD) returns the Julian day number corresponding to the
    % given modified Julian day number.
    %
    % See also JD2MJD, DATE2JD, DATE2MJD.
      
    % Author:     Peter J. Acklam
    % Time-stamp: 2002-03-03 12:50:25 +0100
    % E-mail:     pjacklam@online.no
    % URL:        http://home.online.no/~pjacklam
      
      narginchk(1, 1);
      
      jd = mjd + 2400000.5;
      
    end % mjd2jd()
    
  end % methods (Static = true)
  
end % classdef (Sealed = true) Time
