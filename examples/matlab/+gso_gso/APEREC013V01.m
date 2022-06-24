function [G, Gx, fH, Specific] = APEREC013V01(GainMax, Efficiency, Phi, varargin)

% Usage: [G, Gx, fH, Specific] = APEREC013V01(GainMax, Efficiency, Phi, varargin)
%
% Description: Recommendation ITU-R S.465-5 reference Earth station
% antenna pattern for earth stations coordinated after 1993.
%
% Required Inputs:
%   GainMax = Maximum antenna gain, dB
%   Efficiency = Antenna efficiency, fraction
%   Phi = Angle for which a gain is calculated, degrees
%
% Optional Inputs (entered as key/value pairs):
%   PlotFlag = Flag to indicate plot, true or {false}
%
% Outputs:
%   G = Co-polar gain, dB
%   Gx = Cross-polar gain, dB
%   fH = figure handle
%   Specific = structure containing intermediate gain calculation results

% Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.

% Check number and class of input arguments.

if ~(nargin >= 3 ...
    && isnumeric(GainMax) ...
    && isnumeric(Efficiency) ...
    && isnumeric(Phi))
  exc = WException( ...
    'Wavefront:APT:InvalidInput', ...
    'Numeric GainMax, Efficiency, and Phi must be provided.');
  throw(exc)
  
end % if

% Validate input parameters.

gso_gso.validate_input('GainMax', GainMax)
gso_gso.validate_input('Efficiency', Efficiency)
gso_gso.validate_input('Phi', Phi)

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

if ~exist('PlotFlag', 'var')
  PlotFlag = false;
  
end % if

% Implement pattern.

phi = max(eps, Phi); 

d_over_lambda = sqrt((10 ^ (GainMax / 10)) / (Efficiency * pi ^ 2));

G0 = GainMax - 2.5e-3 * (d_over_lambda .* phi) .^ 2;

if d_over_lambda > 100
  G1 = 32;
  phi_r = 1;
  
else
  G1 = -18 + 25 * log10(d_over_lambda);
  phi_r = 100 / d_over_lambda;
  
end % if

G2 = 32 - 25 * log10(phi);
G3 = -10;

phi_m = 20 / d_over_lambda * sqrt(GainMax - G1);
phi_b = 10 ^ (42 / 25);

G = G0 .* (0     <= phi & phi <  phi_m) ...
  + G1 .* (phi_m <= phi & phi <  phi_r) ...
  + G2 .* (phi_r <= phi & phi <  phi_b) ...
  + G3 .* (phi_b <= phi & phi <=   180);

Gx = G;

% Validate low level rules.

if phi_b < phi_r
  exc = WException( ...
    'Wavefront:APT:InvalidResult', ...
    'Phi_b is less than Phi_r.', ...
    -6010, ...
    'STDC_ERR_PHIB_LT_PHIR', ...
    'Phi_b is less than Phi_r.');
  throw(exc)

end % if

if GainMax < G1
  exc = WException( ...
    'Wavefront:APT:InvalidResult', ...
    'GainMax is less than G1.', ...
    -6001, ...
    'STDC_ERR_GNAX_LT_G1', ...
    'GainMax is less than G1.');
  throw(exc)

end % if

% Validate output parameters.

gso_gso.validate_output(G, Gx, GainMax)

% Assign Specific results.

Specific.phi_m = phi_m;
Specific.phi_r = phi_r;
Specific.phi_b = phi_b;
Specific.d_over_lambda = d_over_lambda;
Specific.G1 = G1;

% Plot results, if requested.

if PlotFlag == true
  fH = figure;
  semilogx(phi, G, 'k')
  grid on
  hold on
  semilogx(phi, Gx, 'k')
  v = axis;
  axis([0.1 180 v(3) v(4)])
  title([strrep(mfilename, '_', '\_'), ' Reference Antenna Pattern'])
  xlabel('Phi (degrees)')
  ylabel('Gain (dB)')
  
else
  fH = [];
  
end % if
