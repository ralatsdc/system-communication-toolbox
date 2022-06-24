function [G, Gx, fH, Specific] = APERR_020V01(Diameter, Frequency, Phi, varargin)

% Usage: [G, Gx, fH, Specific] = APERR_020V01(Diameter, Frequency, Phi, varargin)
%
% Description: Recommendation ITU-R S.1428-1 reference receiving earth
% station antenna pattern.
%
% Required Inputs:
%   Diameter = Diameter of an earth antenna, m
%   Frequency = Frequency for which a gain is calculated, MHz
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
    && isnumeric(Diameter) ...
    && isnumeric(Frequency) ...
    && isnumeric(Phi))
  exc = WException( ...
    'Wavefront:APT:InvalidInput', ...
    'Numeric Diameter, Frequency, and Phi must be provided.');
  throw(exc)
  
end % if

% Validate input parameters.

verification.validate_input('Diameter', Diameter)
verification.validate_input('Frequency', Frequency)
verification.validate_input('Phi', Phi)

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
      verification.validate_input(key, value)
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

lambda = 299792458 / (Frequency * 1e6);
d_over_lambda = Diameter / lambda;
GainMax = 7.7 + 20 * log10(d_over_lambda);

G0 = GainMax - 2.5e-3 * (d_over_lambda .* phi) .^ 2;

if d_over_lambda >= 100
  phi_b = 34.1;
  phi_r = 15.85 * (d_over_lambda) ^ (-0.6);

else % d_over_lambda < 100
  phi_b = 33.1;
  phi_r = 95 / d_over_lambda;

end % if

G1 = 29 - 25 * log10(phi_r);

phi_m = 20 / d_over_lambda * sqrt(GainMax - G1);

if d_over_lambda > 100
  G2 = 29 - 25 * log10(phi);
  G3 = 34 - 30 * log10(phi);
  G4 = -12;
  G5 = -7;
  G6 = -12;
  
  G = G0 .* (0     <= phi & phi <  phi_m) ...
    + G1 .* (phi_m <= phi & phi <  phi_r) ...
    + G2 .* (phi_r <= phi & phi <     10) ...
    + G3 .* (10    <= phi & phi <  phi_b) ...
    + G4 .* (phi_b <= phi & phi <     80) ...
    + G5 .* (80    <= phi & phi <    120) ...
    + G6 .* (120   <= phi & phi <=   180);

elseif 25 < d_over_lambda && d_over_lambda <= 100
  G2 = 29 - 25 * log10(phi);
  G3 = -9;
  G4 = -4;
  G5 = -9;
  
  G = G0 .* (0     <= phi & phi <  phi_m) ...
    + G1 .* (phi_m <= phi & phi <  phi_r) ...
    + G2 .* (phi_r <= phi & phi <= phi_b) ...
    + G3 .* (phi_b <  phi & phi <=    80) ...
    + G4 .* (80    <  phi & phi <=   120) ...
    + G5 .* (120   <  phi & phi <=   180);

elseif 20 <= d_over_lambda && d_over_lambda <= 25
  G2 = 29 - 25 * log10(phi);
  G3 = -9;
  G4 = -5;
  
  G = G0 .* (0     <= phi & phi <  phi_m) ...
    + G1 .* (phi_m <= phi & phi <  phi_r) ...
    + G2 .* (phi_r <= phi & phi <= phi_b) ...
    + G3 .* (phi_b <  phi & phi <=    80) ...
    + G4 .* (80    <  phi & phi <=   180);

end % if

Gx = G;

% Validate low level rules.

if d_over_lambda < 20
  exc = WException( ...
    'Wavefront:APT:InvalidResult', ...
    'D/lambda is less than 20.', ...
    -6002, ...
    'STDC_ERR_DLAMBDA', ...
    'D/lambda is less than 20.');
  throw(exc)

end % if

% Validate output parameters.

verification.validate_output(G, Gx, GainMax)

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
