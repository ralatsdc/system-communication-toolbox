function [G, Gx, fH] = APSREC408V01(Phi, Phi0, varargin)

% Usage: [G, Gx, fH] = APSREC408V01(Phi, Phi0, varargin)
%
% Description: Recommendation ITU-R S.672-4 space station antenna pattern
% in FSS for Ls = -20 dB.
%
% Required Inputs:
%   Phi = Angle for which a gain is calculated, degrees
%   Phi0 = Cross-sectional half-power beamwidth, degrees
%
% Optional Inputs (entered as key/value pairs):
%   GainMax = Maximum antenna gain, dB (omit for relative gain pattern)
%   PlotFlag = Flag to indicate plot, true or {false}
%
% Note from ITU-R APL Manual:
%   "For absolute gain calculations a flooring of 0 dB is applied. This
%   ensures positive values for both co-polar and cross-polar gains.
%   For relative gain calculations this flooring is not applied. Relative 
%   gains always have decreasing negative values."
%
% Outputs:
%   G = Co-polar gain, dB
%   Gx = Cross-polar gain, dB
%   fH = figure handle

% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

% Check number and class of input arguments.

if ~(nargin >= 2 ...
    && isnumeric(Phi) ...
    && isnumeric(Phi0))
  exc = WException( ...
    'Wavefront:APT:InvalidInput', ...
    'Numeric Phi and Phi0 must be provided.');
  throw(exc)
  
end % if

% Validate input parameters.

gso_gso.validate_input('Phi', Phi)
gso_gso.validate_input('Phi0', Phi0)

% Handle optional inputs.

if ~isempty(varargin)
  nVarargin = size(varargin, 2);
  
  if rem(nVarargin, 2)
    exc = WException( ...
      'Wavefront:APT:InvalidInput', ...
      'Inputs must be key/value pairs.');
    throw(exc)
    
  else
    for iVarargin = 1:2:nVarargin
      key = varargin{iVarargin};
      value = varargin{iVarargin + 1};
      gso_gso.validate_input(key, value)
      eval([key, ' = value;'])
      
    end % for
    
  end % if
  
end % if

% Assign default values to any optional input parameters that were not
% included in varargin.

if ~exist('GainMax', 'var')
  GainMax = 0;
  absolute_pattern = false;
  
else
  absolute_pattern = true;
  
end % if
 
if ~exist('PlotFlag', 'var')
  PlotFlag = false;
  
end % if

% Implement pattern.

phi = max(eps, Phi); 
phi_over_phi0 = phi ./ Phi0;

Ls = -20;
a = 2.58;
b = 6.32;

G0 = GainMax - 12 * phi_over_phi0 .^ 2;
G1 = GainMax + Ls;
G2 = GainMax + Ls + 20 - 25 * log10(2 * phi_over_phi0);

G = G0 .* (0   <= phi_over_phi0 & phi_over_phi0 <= a/2) ...
  + G1 .* (a/2 <  phi_over_phi0 & phi_over_phi0 <= b/2) ...
  + G2 .* (b/2 <  phi_over_phi0);

Gx = G;

% Apply "flooring" for absolute gain pattern.

if absolute_pattern
  G = max(0, G);
  Gx = max(0, Gx);
  
end % if

% Validate low level rules.

% None.

% Validate output parameters.

gso_gso.validate_output(G, Gx, GainMax)

% Plot results, if requested.

if PlotFlag == true
  fH = figure;
  semilogx(phi, G, 'k')
  grid on
  hold on
  semilogx(phi, Gx, 'k')
  v = axis;
  axis([0.1 180 v(3) v(4)])
  
  if absolute_pattern
    ttlStr = [strrep(mfilename, '_', '\_'), ' Absolute Reference Antenna Pattern'];
    
  else
    ttlStr = [strrep(mfilename, '_', '\_'), ' Relative Reference Antenna Pattern'];

  end % if
  
  title(ttlStr)
  xlabel('Phi (degrees)')
  ylabel('Gain (dB)')
  
else
  fH = [];
  
end % if
