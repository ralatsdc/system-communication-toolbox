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
 * Describes the ITU antenna pattern ERR_009V01.
 */
public class PatternERR_009V01 implements EarthPattern, TransmitPattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/* Intermediate gain calculation results */
	/* None */

	/**
	 * Constructs a PatternERR_009V01 given a maximum antenna gain.
	 *
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 */
	public PatternERR_009V01(double GainMax) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);

		/* Assign properties */
		this.GainMax = GainMax;
	}

	/**
	 * Gets maximum antenna gain [dB].
	 * 
	 * @return Maximum antenna gain [dB]
	 */
	public double getGainMax() {
		return GainMax;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	public PatternERR_009V01 copy() {
		return new PatternERR_009V01(this.GainMax);
	}

	/**
	 * Appendix 30A (RR-2001) reference transmitting earth station antenna pattern
	 * for Regions 1 and 3 (WARC Orb-88).
	 *
	 * @param Phi
	 *            Angle for which a gain is calculated [degrees]
	 * @param options
	 *            Optional parameters (entered as key/value pairs)
	 * 
	 * @return Co-polar and cross-polar gain [dB]
	 */
	public Gain gain(double Phi, Map options) {

		/* Validate input parameters */
		PatternUtility.validate_input("Phi", Phi);

		/* Validate input options */
		options = PatternUtility.validateOptions(options);

		/* Implement pattern */
		double eps = Math.ulp(1.0);
		double phi = Math.max(eps, Phi);
		double G0 = GainMax;
		double G1 = GainMax - 21.0 - 20.0 * Math.log10(phi);
		double G2 = GainMax - 5.7 - 53.2 * Math.pow(phi, 2);
		double G3 = GainMax - 25.0 - 25.0 * Math.log10(phi);
		double G4 = GainMax - 67.0;

		double G = G0 * (0 <= phi && phi <= 0.1 ? 1 : 0) + G1 * (0.1 < phi && phi <= 0.32 ? 1 : 0)
				+ G2 * (0.32 < phi && phi <= 0.44 ? 1 : 0) + G3 * (0.44 < phi && phi <= 48 ? 1 : 0)
				+ G4 * (48 < phi && phi <= 180 ? 1 : 0);

		double Gx = Math.min(GainMax - 30, G);

		/* Validate output parameters */
		if ((boolean) options.get("DoValidate")) {
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
		if (!(obj instanceof PatternERR_009V01)) {
			return false;
		}
		PatternERR_009V01 other = (PatternERR_009V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
