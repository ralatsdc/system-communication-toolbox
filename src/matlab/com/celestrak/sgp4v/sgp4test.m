% whichconst: 721, 72, 84
% typerun:
%   'c' compare 1 year of full satcat data
%   'v' verification run, requires modified elm file with
%   'm' maunual operation - either mfe, epoch, or dayof yr start stop and delta times
% typeinput: m (mfe), e (epoch (YMDHMS)), or d (dayofyr)

global tumin radiusearthkm xke j2 j3 j4 j3oj2  

whichconst = 84;

getgravc(whichconst);

deg2rad = pi / 180.0; %  0.01745329251994330; % [deg/rad]
xpdotp = 1440.0 / (2.0*pi); % 229.1831180523293; % [rev/day] / [rad/min]

revnum = 0; 
elnum  = 0;
year   = 0; 
satrec.error = 0;

longstr1 = '1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753';
longstr2 = '2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667';
typerun = 'm';
typeinput = 'd';

% parse first line
carnumb = str2num(longstr1(1));
satrec.satnum = str2num(longstr1(3:7));
classification = longstr1(8);
intldesg = longstr1(10:17);
satrec.epochyr = str2num(longstr1(19:20));
satrec.epochdays = str2num(longstr1(21:32));
satrec.ndot = str2num(longstr1(34:43));
satrec.nddot = str2num(longstr1(44:50));
nexp = str2num(longstr1(51:52));
satrec.bstar = str2num(longstr1(53:59));
ibexp = str2num(longstr1(60:61));
numb = str2num(longstr1(63));
elnum = str2num(longstr1(65:68));
 
% parse second line
cardnumb = str2num(longstr2(1));
satrec.satnum = str2num(longstr2(3:7));
satrec.inclo = str2num(longstr2(8:16));
satrec.nodeo = str2num(longstr2(17:25));
satrec.ecco = str2num(longstr2(26:33));
satrec.argpo = str2num(longstr2(34:42));
satrec.mo = str2num(longstr2(43:51));
satrec.no = str2num(longstr2(52:63));
revnum = str2num(longstr2(64:68));

% ---- find no, ndot, nddot ----
satrec.no   = satrec.no / xpdotp; %//* rad/min
satrec.nddot= satrec.nddot * 10.0^nexp;
satrec.bstar= satrec.bstar * 10.0^ibexp;

% ---- convert to sgp4 units ----
satrec.a    = (satrec.no*tumin)^(-2/3);                % [er]
satrec.ndot = satrec.ndot  / (xpdotp*1440.0);          % [rad/min^2]
satrec.nddot= satrec.nddot / (xpdotp*1440.0*1440);     % [rad/min^3]

% ---- find standard orbital elements ----
satrec.inclo = satrec.inclo  * deg2rad;
satrec.nodeo = satrec.nodeo * deg2rad;
satrec.argpo = satrec.argpo  * deg2rad;
satrec.mo    = satrec.mo     *deg2rad;

satrec.alta = satrec.a*(1.0 + satrec.ecco) - 1.0;
satrec.altp = satrec.a*(1.0 - satrec.ecco) - 1.0;

% -----------------------------------------------------------------
% find sgp4epoch time of element set
% remember that sgp4 uses units of days from 0 jan 1950 (sgp4epoch)
% and minutes from the epoch (time)
% -----------------------------------------------------------------

% ------------- temp fix for years from 1957-2056 -----------------
% ------ correct fix will occur when year is 4-digit in 2le -------
if (satrec.epochyr < 57)
    year = satrec.epochyr + 2000;
else
    year = satrec.epochyr + 1900;
end
[mon, day, hr, minute, sec] = days2mdh(year, satrec.epochdays);
satrec.jdsatepoch = jday( year,mon,day,hr,minute,sec );
sgp4epoch = satrec.jdsatepoch - 2433281.5; % days since 0 Jan 1950

% ------------- initialize the orbit at sgp4epoch -----------------
[satrec] = sgp4init(whichconst, satrec, satrec.bstar, satrec.ecco, sgp4epoch, ...
                    satrec.argpo, satrec.inclo, satrec.mo, satrec.no, satrec.nodeo);

% propagate orbit
[satrec, ro ,vo] = sgp4 (satrec,  0.0);
