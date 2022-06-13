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
classdef Emission < handle
% Describes an emission.
  
  properties (SetAccess = protected, GetAccess = public)
    
    % Emission designator
    design_emi
    % Maximum power density [dBW/Hz]
    pwr_ds_max
    % Minimum power density [dBW/Hz]
    pwr_ds_min
    % Center frequency [MHz]
    freq_mhz
    % Required C/N [dB]
    c_to_n
    % Power flux density [dBW/Hz/m2]
    pwr_flx_ds
    
  end % properties
  
  methods
    
    function this = Emission(design_emi, pwr_ds_max, pwr_ds_min, ...
                             freq_mhz, c_to_n, pwr_flx_ds)
      % Constructs an Emission.
      %
      % Parameters
      %   design_emi - Emission designator
      %   pwr_ds_max - Maximum power density [dBW/Hz]
      %   pwr_ds_min - Minimum power density [dBW/Hz]
      %   freq_mhz - Center frequency [MHz]
      %   c_to_n - Required C/N [dB]
      %   pwr_flx_ds - Power flux density [dBW/Hz/m2]
      
      % No argument constructor
      if nargin == 0
        return;
        
      end % if
      
      % Assign properties
      this.set_design_emi(design_emi);
      this.set_pwr_ds_max(pwr_ds_max);
      this.set_pwr_ds_min(pwr_ds_min);
      this.set_freq_mhz(freq_mhz);
      this.set_c_to_n(c_to_n);
      if nargin == 6 && ~isempty(pwr_flx_ds)
        this.set_pwr_flx_ds(pwr_flx_ds);

      end % if

    end % Emission()
    
    function that = copy(this)
    % Copies an Emission.
    %
    % Returns
    %   that - A new Emission instance
        that = Emission(this.design_emi, this.pwr_ds_max, this.pwr_ds_min, ...
                        this.freq_mhz, this.c_to_n, ...
                        this.pwr_flx_ds);

    end % copy()

    function set_design_emi(this, design_emi)
    % Sets emission designator.
    %
    % Parameters
    %   design_emi - Emission designator
      this.design_emi = TypeUtility.set_char(design_emi);

    end % set_design_emi()
    
    function set_pwr_ds_max(this, pwr_ds_max)
    % Sets maximum power density [dBW/Hz].
    %
    % Parameters
    %   pwr_ds_max - Maximum power density [dBW/Hz]
      this.pwr_ds_max = TypeUtility.set_numeric(pwr_ds_max);

    end % set_pwr_ds_max()
    
    function set_pwr_ds_min(this, pwr_ds_min)
    % Sets minimum power density [dBW/Hz].
    %
    % Parameters
    %   pwr_ds_min - Minimum power density [dBW/Hz]
      this.pwr_ds_min = TypeUtility.set_numeric(pwr_ds_min);

    end % set_pwr_ds_min()
    
    function set_freq_mhz(this, freq_mhz)
    % Sets center frequency [MHz].
    %
    % Parameters
    %   freq_mhz - Center frequency [MHz]
      this.freq_mhz = TypeUtility.set_numeric(freq_mhz);

    end % set_freq_mhz()
    
    function set_c_to_n(this, c_to_n)
    % Sets required C/N [dB].
    %
    % Parameters
    %   c_to_n - Required C/N [dB]
      this.c_to_n = TypeUtility.set_numeric(c_to_n);

    end % set_c_to_n()
    
    function set_pwr_flx_ds(this, pwr_flx_ds)
    % Sets power flux density [dBW/Hz/m2].
    %
    % Parameters
    %   pwr_flx_ds - Power flux density [dBW/Hz/m2]
      this.pwr_flx_ds = TypeUtility.set_numeric(pwr_flx_ds);

    end % set_pwr_flx_ds()
    

  end % methods
  
end % classdef
