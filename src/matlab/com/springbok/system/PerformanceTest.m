classdef PerformanceTest < TestUtility
% Tests methods of Performance class.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  properties (Constant = true)
    
    % Carrier power density [dBW/Hz]
    C = 1;
    % Noise power density [dBW/Hz]
    N = 2;
    % Interference power density for each network [dBW/Hz]
    i = [3; 4];
    % Interference power density total [dBW/Hz]
    I = 5;
    % Equivalent power flux density for each network [dBW/m^2 in reference bandwidth]
    epfd = [6; 7];
    % Equivalent power flux density total [dBW/m^2 in reference bandwidth]
    EPFD = 8;

  end % properties (Constant = true)
  
  properties (Access = private)
    
    % A space station
    performance
    
  end % properties
  
  methods
    
    function this = PerformanceTest(logFId, testMode)
    % Constructs a PerformanceTest.
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
      this.performance = Performance(this.C, this.N, this.i, this.I, this.epfd, this.EPFD);

    end % PerformanceTest()
    
    function test_Performance(this)
    % Tests the Performance constructor.
      
      t = [];
      t = [t; isequal(this.performance.C, this.C)];
      t = [t; isequal(this.performance.N, this.N)];
      t = [t; isequal(this.performance.i, this.i)];
      t = [t; isequal(this.performance.I, this.I)];
      t = [t; isequal(this.performance.epfd, this.epfd)];
      t = [t; isequal(this.performance.EPFD, this.EPFD)];
      
      this.assert_true( ...
          'Performance', ...
          'Performance', ...
          this.IS_EQUAL_DESC, ...
          min(t));
      
    end % test_Performance()
    
  end % methods
  
end % classdef
