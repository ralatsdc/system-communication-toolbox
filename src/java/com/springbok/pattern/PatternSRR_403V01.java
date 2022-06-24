/* Copyright (C) 2022 Springbok LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern SRR_403V01.
 */
public class PatternSRR_403V01 implements SpacePattern, ReceivePattern {

	// Maximum antenna gain [dB]
	private double GainMax;

	// Cross-sectional half-power beamwidth, degrees
	private double Phi0;

	public double getGainMax() {
		return GainMax;
	}

	public double getPhi0() {
		return Phi0;
	}

	/**
	 * Constructs a PatternSRR_403V01 given a maximum antenna gain.
	 * <p>
	 * Parameters Phi0 - Cross-sectional half-power beamwidth, degrees
	 */
	public PatternSRR_403V01(double Phi0) {
		// Validate input parameters.
		PatternUtility.validate_input("Phi0", Phi0);

		// Assign properties
		this.Phi0 = Phi0;

		// Compute derived properties
		// None
	}

	/**
	 * Copies a PatternSRR_403V01 given a maximum antenna gain.
	 * <p>
	 * Parameters None
	 */
	public PatternSRR_403V01 copy() {
		return new PatternSRR_403V01(this.Phi0);
	}

	/**
	 * Appendix 30A (RR-2001) reference receiving space station antenna pattern for
	 * Regions 1 and 3 (WARC Orb-88).
	 * <p>
	 * Parameters: Phi - Angle for which a gain is calculated [degrees]
	 * <p>
	 * Optional parameters (entered as key/value pairs): None
	 * <p>
	 * Returns: G - Co-polar gain [dB] Gx - Cross-polar gain [dB] fH - figure handle
	 */
	public Gain gain(double Phi, Map options) {
		// Validate input parameters.
		PatternUtility.validate_input("Phi", Phi);
		Map<String, Object> input = PatternUtility.validateOptions(options);

		// TODO: Test constructor optional agruments
		this.GainMax = 0;
		boolean absolute_pattern = false;
		if (input.containsKey("GainMax")) {
			this.GainMax = (double) input.get("GainMax");
			absolute_pattern = true;

		}
		boolean DoValidate = true;
		if (input.containsKey("DoValidate")) {
			DoValidate = (boolean) input.get("DoValidate");
		}

		// Implement pattern.
		double eps = Math.ulp(1.0);
		double phi = Math.max(eps, Phi);

		double phi_over_phi0 = phi / this.Phi0;

		double G0 = this.GainMax - 12 * Math.pow(phi_over_phi0, 2);
		double G1 = this.GainMax - 17.5 - 25 * Math.log10(phi_over_phi0);

		double G = 0 <= phi_over_phi0 && phi_over_phi0 < 1.3 ? G0 : G1;
		double Gx0 = this.GainMax - 30 - 12 * Math.pow(phi_over_phi0, 2);
		double Gx1 = this.GainMax - 33;

        double phix = Math.max(eps, phi_over_phi0 - 1);
        double Gx2 = this.GainMax - 40 - 40 * Math.log10(phix);
        double Gx = 0 <= phi_over_phi0 && phi_over_phi0 <= 0.5 ? Gx0 : 0.5 < phi_over_phi0 && phi_over_phi0 <= 1.67 ? Gx1 : Gx2;

        // Apply "flooring" for absolute gain pattern.
		if (absolute_pattern) {
			G = Math.max(0, G);
			Gx = Math.max(0, Gx);

		}

		// Validate low level rules.
		if (this.GainMax < 30 && absolute_pattern) {
			PatternUtility.logger.warn("Springbok:InvalidResult", "GainMax is less than 30.");
		}

		// Validate output parameters.
		if (DoValidate) {
			PatternUtility.validate_output(G, Gx, GainMax);
		}
		return new Gain(G, Gx);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		long temp;
		temp = Double.doubleToLongBits(Phi0);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(GainMax);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		return result;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		if (!(obj instanceof PatternSRR_403V01)) {
			return false;
		}
		PatternSRR_403V01 other = (PatternSRR_403V01) obj;
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
