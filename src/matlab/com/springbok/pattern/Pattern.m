classdef Pattern < handle
% Defines methods required to describe an ITU antenna pattern.
  
% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

  methods (Abstract = true)
    
    [G, Gx, fH] = gain(this, phi, varargin)
    % Implements an ITU antenna pattern.
    %
    % Parameters:
    %   Phi - Angle for which a gain is calculated [degrees]
    %
    % Optional parameters (entered as key/value pairs):
    %   PlotFlag - Flag to indicate plot, true or {false}
    %
    % Returns:
    %   G - Co-polar gain [dB]
    %   Gx - Cross-polar gain [dB]
    %   fH - figure handle
    
  end % methods (Abstract = true)
  
end % classdef
