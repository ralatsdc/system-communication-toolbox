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
classdef Article22Utility < handle
% Defines properties and methods for using Article 22.
  
  properties (Constant = true)
    
    limits = Article22Utility.set_limits()
    
  end % properties (Constant = true)
  
  methods (Static = true, Access = private)
    
    function limits = set_limits()
      
      % TABLE_22_1A
      
      limits.('TABLE_22_1A').row(1).epfd = [-175.4 -174 -170.8 -165.3 -160.4 -160 -160];
      limits.('TABLE_22_1A').row(1).percentage = [0 90 99 99.73 99.991 99.997 100];
      
      limits.('TABLE_22_1A').row(2).epfd = [-181.9 -178.4 -173.4 -173 -164 -161.6 -161.4 -160.8 -160.5 -160 -160];
      limits.('TABLE_22_1A').row(2).percentage = [0 99.5 99.74 99.857 99.954 99.984 99.991 99.997 99.997 99.9993 100];
      
      limits.('TABLE_22_1A').row(3).epfd = [-190.45 -189.45 -187.45 -182.4 -182 -168 -164 -162 -160 -160];
      limits.('TABLE_22_1A').row(3).percentage = [0 90 99.5 99.7 99.855 99.971 99.988 99.995 99.999 100];
      
      limits.('TABLE_22_1A').row(4).epfd = [-195.45 -195.45 -190 -190 -172.5 -160 -160];
      limits.('TABLE_22_1A').row(4).percentage = [0 99 99.65 99.71 99.99 99.998 100];
      
      % TABLE_22_1B
      
      limits.('TABLE_22_1B').row(1).epfd = [-175.4 -175.4 -172.5 -167 -164 -164];
      limits.('TABLE_22_1B').row(1).percentage = [0 90 99 99.714 99.971 100];
      
      limits.('TABLE_22_1B').row(2).epfd = [-161.4 -161.4 -158.5 -153 -150 -150];
      limits.('TABLE_22_1B').row(2).percentage = [0 90 99 99.714 99.971 100];
      
      limits.('TABLE_22_1B').row(3).epfd = [-178.4 -178.4 -171.4 -170.5 -166 -164 -164];
      limits.('TABLE_22_1B').row(3).percentage = [0 99.4 99.9 99.913 99.971 99.977 100];
      
      limits.('TABLE_22_1B').row(4).epfd = [-164.4 -164.4 -157.4 -156.5 -152 -150 -150];
      limits.('TABLE_22_1B').row(4).percentage = [0 99.4 99.9 99.913 99.971 99.977 100];
      
      limits.('TABLE_22_1B').row(5).epfd = [-185.4 -185.4 -180 -180 -172 -164 -164];
      limits.('TABLE_22_1B').row(5).percentage = [0 99.8 99.8 99.943 99.943 99.998 100];
      
      limits.('TABLE_22_1B').row(6).epfd = [-171.4 -171.4 -166 -166 -158 -150 -150];
      limits.('TABLE_22_1B').row(6).percentage = [0 99.8 99.8 99.943 99.943 99.998 100];
      
      % TABLE_22_1C
      
      limits.('TABLE_22_1C').row(1).epfd = [-187.4 -182 -172 -154 -154];
      limits.('TABLE_22_1C').row(1).percentage = [0 71.429 97.143 99.983 100];
      
      limits.('TABLE_22_1C').row(2).epfd = [-173.4 -168 -158 -140 -140];
      limits.('TABLE_22_1C').row(2).percentage = [0 71.429 97.143 99.983 100];
      
      limits.('TABLE_22_1C').row(3).epfd = [-190.4 -181.4 -170.4 -168.6 -165 -160 -154 -154];
      limits.('TABLE_22_1C').row(3).percentage = [0 91 99.8 99.8 99.943 99.943 99.997 100];
      
      limits.('TABLE_22_1C').row(4).epfd = [-176.4 -167.4 -156.4 -154.6 -151 -146 -140 -140];
      limits.('TABLE_22_1C').row(4).percentage = [0 91 99.8 99.8 99.943 99.943 99.997 100];
      
      limits.('TABLE_22_1C').row(5).epfd = [-196.4 -162 -154 -154];
      limits.('TABLE_22_1C').row(5).percentage = [0 99.98 99.99943 100];
      
      limits.('TABLE_22_1C').row(6).epfd = [-182.4 -148 -140 -140];
      limits.('TABLE_22_1C').row(6).percentage = [0 99.98 99.99943 100];
      
      limits.('TABLE_22_1C').row(7).epfd = [-200.4 -189.4 -187.8 -184 -175 -164.2 -154.6 -154 -154];
      limits.('TABLE_22_1C').row(7).percentage = [0 90 94 97.143 99.886 99.99 99.999 99.9992 100];
      
      limits.('TABLE_22_1C').row(8).epfd = [-186.4 -175.4 -173.8 -170 -161 -150.2 -140.6 -140 -140];
      limits.('TABLE_22_1C').row(8).percentage = [0 90 94 97.143 99.886 99.99 99.999 99.9992 100];
      
      % TABLE_22_1D
      
      limits.('TABLE_22_1D').row(1).epfd = [-165.841 -165.541 -164.041 -158.6 -158.6 -158.33 -158.33];
      limits.('TABLE_22_1D').row(1).percentage = [0 25 96 98.857 99.429 99.429 100];
      
      limits.('TABLE_22_1D').row(2).epfd = [-175.441 -172.441 -169.441 -164 -160.75 -160 -160];
      limits.('TABLE_22_1D').row(2).percentage = [0 66 97.75 99.357 99.809 99.986 100];
      
      limits.('TABLE_22_1D').row(3).epfd = [-176.441 -173.191 -167.75 -162 -161 -160.2 -160 -160];
      limits.('TABLE_22_1D').row(3).percentage = [0 97.8 99.371 99.886 99.943 99.971 99.997 100];
      
      limits.('TABLE_22_1D').row(4).epfd = [-178.94 -178.44 -176.44 -171 -165.5 -163 -161 -160 -160];
      limits.('TABLE_22_1D').row(4).percentage = [0 33 98 99.429 99.714 99.857 99.943 99.991 100];
      
      limits.('TABLE_22_1D').row(5).epfd ...
          = [-182.44 -180.69 -179.19 -178.44 -174.94 -173.75 -173 -169.5 -167.8 -164 -161.9 -161 -160.4 -160];
      limits.('TABLE_22_1D').row(5).percentage ...
          = [0 90 98.9 98.9 99.5 99.68 99.68 99.85 99.915 99.94 99.97 99.99 99.998 100];
      
      limits.('TABLE_22_1D').row(6).epfd = [-184.941 -184.101 -181.691 -176.25 -163.25 -161.5 -160.35 -160 -160];
      limits.('TABLE_22_1D').row(6).percentage = [0 33 98.5 99.571 99.946 99.974 99.993 99.999 100];
      
      limits.('TABLE_22_1D').row(7).epfd = [-187.441 -186.341 -183.441 -178 -164.4 -161.9 -160.5 -160 -160];
      limits.('TABLE_22_1D').row(7).percentage = [0 33 99.25 99.786 99.957 99.983 99.994 99.999 100];
      
      limits.('TABLE_22_1D').row(8).epfd = [-191.941 -189.441 -185.941 -180.5 -173 -167 -162 -160 -160];
      limits.('TABLE_22_1D').row(8).percentage = [0 33 99.5 99.857 99.914 99.951 99.983 99.991 100];
      
      % TABLE_22_1E
      
      limits.('TABLE_22_1E').row(1).epfd = [-195.4];
      limits.('TABLE_22_1E').row(1).percentage = [100];
      
      limits.('TABLE_22_1E').row(2).epfd = [-197.9];
      limits.('TABLE_22_1E').row(2).percentage = [100];
      
      limits.('TABLE_22_1E').row(3).epfd = [-201.6];
      limits.('TABLE_22_1E').row(3).percentage = [100];
      
      limits.('TABLE_22_1E').row(4).epfd = [-203.3];
      limits.('TABLE_22_1E').row(4).percentage = [100];
      
      limits.('TABLE_22_1E').row(5).epfd = [-204.5];
      limits.('TABLE_22_1E').row(5).percentage = [100];
      
      limits.('TABLE_22_1E').row(6).epfd = [-207.5];
      limits.('TABLE_22_1E').row(6).percentage = [100];
      
      limits.('TABLE_22_1E').row(7).epfd = [-208.5];
      limits.('TABLE_22_1E').row(7).percentage = [100];
      
      limits.('TABLE_22_1E').row(8).epfd = [-212.0];
      limits.('TABLE_22_1E').row(8).percentage = [100];
      
      % TABLE_22_2
      
      limits.('TABLE_22_2').row(1).epfd = [-183.0];
      limits.('TABLE_22_2').row(1).percentage = [100];
      
      limits.('TABLE_22_2').row(2).epfd = [-160];
      limits.('TABLE_22_2').row(2).percentage = [100];
      
      limits.('TABLE_22_2').row(3).epfd = [-160];
      limits.('TABLE_22_2').row(3).percentage = [100];
      
      limits.('TABLE_22_2').row(4).epfd = [-162];
      limits.('TABLE_22_2').row(4).percentage = [100];
      
      limits.('TABLE_22_2').row(5).epfd = [-162];
      limits.('TABLE_22_2').row(5).percentage = [100];
      
      % TABLE_22_3
      
      limits.('TABLE_22_3').row(1).epfd = [-160];
      limits.('TABLE_22_3').row(1).percentage = [100];
      
      limits.('TABLE_22_3').row(2).epfd = [-160];
      limits.('TABLE_22_3').row(2).percentage = [100];
      
    end % set_limits()
    
  end % methods (Static = true, Access = private)
  
end % classdef
