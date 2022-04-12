classdef EmissionTest < TestUtility
% Tests methods of Emission class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    % Emission designator
    design_emi = '1K20G1D--';
    % Maximum power density [dBW/Hz]
    pwr_ds_max = -24.799999237060547;
    % Minimum power density [dBW/Hz]
    pwr_ds_min = NaN;
    % Center frequency [MHz]
    freq_mhz = 1;
    % Required C/N [dB]
    c_to_n = NaN;
    % Power flux density [dBW/Hz/m2]
    pwr_flx_ds = -40.0;

  end % properties (Constant = true)
  
  properties (Access = private)
    
    % An emission
    emission
    
  end % properties (Access = private)
  
  methods
    
    function this = EmissionTest(logFId, testMode)
    % Constructs an EmissionTest.
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
      
      % Compute derived properties
      this.emission = Emission(this.design_emi, ...
                               this.pwr_ds_max, ...
                               this.pwr_ds_min, ...
                               this.freq_mhz, ...
                               this.c_to_n, ...
                               this.pwr_flx_ds);

    end % EmissionTest()
    
    function test_Emission(this)
    % Tests the Emission constructor.
      
      t = [];
      t = [t; strcmp(this.emission.design_emi, this.design_emi)];
      t = [t; isequalwithequalnans(this.emission.pwr_ds_max, this.pwr_ds_max)];
      t = [t; isequalwithequalnans(this.emission.pwr_ds_min, this.pwr_ds_min)];
      t = [t; isequalwithequalnans(this.emission.freq_mhz, this.freq_mhz)];
      t = [t; isequalwithequalnans(this.emission.c_to_n, this.c_to_n)];
      t = [t; isequalwithequalnans(this.emission.pwr_flx_ds, this.pwr_flx_ds)];

      this.assert_true( ...
          'Emission', ...
          'Emission', ...
          this.IS_EQUAL_DESC, ...
          min(t));

    end % test_Emission()
    
  end % methods
  
end % classdef
