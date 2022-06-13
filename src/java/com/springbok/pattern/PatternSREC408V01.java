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

import java.util.Collections;
import java.util.Map;

import com.springbok.utility.PatternUtility;

/**
 * 
 * Pattern SREC408V01
 *
 */

public class PatternSREC408V01 implements SpacePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Cross-sectional half-power beamwidth, degrees */
	private double Phi0;

	public PatternSREC408V01(double GainMax, double Phi0) {

		this.GainMax = GainMax;

		// Check number and class of input arguments.
		PatternUtility.validate_input("Phi0", Phi0);
		this.Phi0 = Phi0;

	}

	public PatternSREC408V01(double Phi0) {
		// Check number and class of input arguments.
		PatternUtility.validate_input("Phi0", Phi0);
		this.Phi0 = Phi0;

	}

	public PatternSREC408V01() {
	}

	public Gain gain(double phi) {
		return gain(phi, Collections.EMPTY_MAP);
	}

	public Gain gain(double phi, Map options) {
		// Check number and class of input arguments.
		PatternUtility.validate_input("Phi", phi);

		if (options == null) {
			options = Collections.EMPTY_MAP;
		}
		for (Object entry : options.entrySet()) {
			Map.Entry e = (Map.Entry) entry;
			Object key = e.getKey();
			Object value = e.getValue();
			// Validate key values
		}

		// Implement pattern. phi = max(eps, Phi)
		double eps = Math.ulp(1.0);
		phi = Math.max(eps, phi);

		double phi_over_phi0 = phi / this.Phi0;

		double Ls = -20, a = 2.58, b = 6.32;

		double G0 = this.GainMax - 12 * Math.pow(phi_over_phi0, 2);
		double G1 = this.GainMax + Ls;
		double G2 = this.GainMax + Ls + 20 - 25 * Math.log10(2 * phi_over_phi0);

		double G = G0 * (0 <= phi_over_phi0 & phi_over_phi0 <= a / 2 ? 0 : 1)
				+ G1 * (a / 2 < phi_over_phi0 & phi_over_phi0 <= b / 2 ? 0 : 1) + G2 * (b / 2 < phi_over_phi0 ? 0 : 1);

		double Gx = G;

		// Apply "flooring" for absolute gain pattern.
		G = Math.max(0, G);
		Gx = Math.max(0, Gx);

		// Validate output parameters. if DoValidate
		PatternUtility.validate_output(G, Gx, this.GainMax);

		return new Gain(G, Gx);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	@Override
	public SpacePattern copy() {
		return new PatternSREC408V01(GainMax, Phi0);
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
		temp = Double.doubleToLongBits(Phi0);
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
		if (!(obj instanceof PatternSREC408V01)) {
			return false;
		}
		PatternSREC408V01 other = (PatternSREC408V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		return true;
	}

}
