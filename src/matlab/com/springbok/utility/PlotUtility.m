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
classdef (Sealed = true) PlotUtility
% Provides plot utilities.
  
  methods (Static = true)
    
    function trim_plot(off)
      
      set(gca, 'units', 'normalized')
      % [left, bottom, right, top]
      ins = get(gca, 'TightInset');
      % off = [0.01, 0.01, 0.05, 0.10];
      tot = ins + off;
      % [left, bottom, width, height]
      pos = [tot(1), tot(2), 1 - tot(1) - tot(3), 1 - tot(2) - tot(4)];
      set(gca, 'Position', pos);
      
      set(gca, 'units', 'centimeters')
      % [left, bottom, right, top]
      ins_cm = get(gca, 'TightInset');
      off_cm([1, 3]) = off([1, 3]) * ins_cm(1) / ins(1);
      off_cm([2, 4]) = off([2, 4]) * ins_cm(2) / ins(2);
      tot_cm = ins_cm + off_cm;
      % [left, bottom, width, height]
      pos_cm = get(gca, 'Position');
      set(gcf, 'PaperUnits', 'centimeters');
      set(gcf, 'PaperSize', [pos_cm(3) + tot_cm(1) + tot_cm(3), pos_cm(4) + tot_cm(2) + tot_cm(4)]);
      set(gcf, 'PaperPositionMode', 'manual');
      set(gcf, 'PaperPosition', [0, 0, pos_cm(3) + tot_cm(1) + tot_cm(3), pos_cm(4) + tot_cm(2) + tot_cm(4)]);
      
    end % function trim_plot(off)
      
  end % methods (Static = true)
  
end % classdef (Sealed = true) Time
