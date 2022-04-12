classdef SampledPatternTest < TestUtility
% Tests methods of SampledPattern class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)

    % Name of file containing antenna pattern gain samples
    patternFNm = 'dat/matlab/com/springbok/pattern/spx_antenna_gain_vs_el_az_steer.mat';

    % Sampled scan angle vector [deg]
    % phi_index = [41, 42, 42, 42];
    phi = [38, 39, 39, 39];

    % Sampled antenna coordinate system azimuth matrix [deg]
    % azimuth_index = [148, 148, 149, 149];
    azimuth = [147, 147, 148, 148];

    % Sampled antenna coordinate system elevation matrix [deg]
    % elevation_index = [7, 7, 7, 8];
    elevation = [0.6, 0.6, 0.6, 0.7];

    G = [ ...
        34.872207633056874, ...
        34.764122946599770, ...
        34.770165190390898, ...
        34.542276055456050
        ];

    Gx = [ ...
        34.872207633056874, ...
        34.764122946599770, ...
        34.770165190390898, ...
        34.542276055456050
                  ];

  end % properties (Constant = true)

  properties (Access = private)
    
    % A sampled pattern
    sampledPattern
    
  end % properties (Access = private)

  methods
    
    function this = SampledPatternTest(logFId, testMode)
    % Constructs a SampledPatternTest.
    %
    % Parameters:
    %   logFId - Log file identifier
    %   testMode - Test mode, if 'interactive' then beeps and pauses
      
    % Invoke superclass constructor
      if nargin == 0
        superArgs = {};
        
      else
        superArgs{1} = logFId;
        superArgs{2} = testMode;
        
      end % if
      this@TestUtility(superArgs{:});
      
      % Compute derived properties
      this.sampledPattern = SampledPattern(this.patternFNm);

    end % SampledPattern()
    
    function test_SampledPattern(this)
    % Tests SampledPattern method.
      
      t = [];
      t = [t; strcmp(this.sampledPattern.patternFNm, this.patternFNm)];

      this.assert_true( ...
          'SampledPattern', ...
          'SampledPattern', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_SampledPattern()
    
    function test_gain(this)
    % Tests gain method.
      
      t = [];

      nT = length(this.phi);
      for iT = 1:nT
        [G, Gx] = this.sampledPattern.gain(this.phi(iT), ...
                                           this.azimuth(iT), ...
                                           this.elevation(iT));

        t = [t; abs(G - this.G(iT)) < this.HIGH_PRECISION];
        t = [t; abs(Gx - this.Gx(iT)) < this.HIGH_PRECISION];
      
      end % for

      [G, Gx] = this.sampledPattern.gain((this.phi(1) + this.phi(2)) / 2, ...
                                         this.azimuth(2), ...
                                         this.elevation(2));

      t = [t; abs(G - (this.G(1) + this.G(2)) / 2) < this.HIGH_PRECISION];
      t = [t; abs(Gx - (this.Gx(1) + this.Gx(2)) / 2) < this.HIGH_PRECISION];

      [G, Gx] = this.sampledPattern.gain(this.phi(3), ...
                                         (this.azimuth(2) + this.azimuth(3)) / 2, ...
                                         this.elevation(3));

      t = [t; abs(G - (this.G(2) + this.G(3)) / 2) < this.HIGH_PRECISION];
      t = [t; abs(Gx - (this.Gx(2) + this.Gx(3)) / 2) < this.HIGH_PRECISION];

      [G, Gx] = this.sampledPattern.gain(this.phi(4), ...
                                         this.azimuth(4), ...
                                         (this.elevation(3) + this.elevation(4)) / 2);

      t = [t; abs(G - (this.G(3) + this.G(4)) / 2) < this.HIGH_PRECISION];
      t = [t; abs(Gx - (this.Gx(3) + this.Gx(4)) / 2) < this.HIGH_PRECISION];

      this.assert_true( ...
          'SampledPattern', ...
          'gain', ...
          this.HIGH_PRECISION_DESC, ...
          min(t));
      
    end % test_gain()
    
  end % methods
  
end % classdef
