function validate_output(G, Gx, GainMax)

% Usage: validate_output(G, Gx, GainMax)
%
% Description: Validate output parameters.
%
% Required Inputs:
%   G = co-pol gain, dB
%   Gx = cross-pol gain, dB
%   GainMax = Maximum antenna gain, dB
%
% Outputs:
%   None

% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

% Check number and class of input arguments.

if ~(nargin == 3 ...
    && isnumeric(G) ...
    && isnumeric(Gx) ...
    && isnumeric(GainMax))
  exc = WException( ...
    'Wavefront:APT:InvalidInput', ...
    'G, and Gx, and GainMax must be numeric.');
  throw(exc)
  
end % if

% Check values of output parameters.

if G > GainMax
  exc = WException( ...
    'Wavefront:APT:InvalidOutput', ...
    'G is greater than GainMax.', ...
    -5501, ...
    'APC_ERR_G_GT_GMAX', ...
    'G is greater than GainMax.');
  throw(exc)
  
end % if

if Gx > GainMax
  exc = WException( ...
    'Wavefront:APT:InvalidOutput', ...
    'Gx is greater than GainMax.', ...
    -5502, ...
    'APC_ERR_GX_GT_GMAX', ...
    'Gx is greater than GainMax.');
  throw(exc)
  
end % if

if Gx > G
  warning( ...
    'Wavefront:APT:InvalidOutput', ...
    'Gx is greater than G.');
  
end % if

if Gx == G
  warning( ...
    'Wavefront:APT:InvalidOutput', ...
    'Cross-polar gain is not calculated.  Value is set to co-polar gain.');
  
end % if
