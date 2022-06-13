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
 * Describes the ITU antenna pattern ELUX201V01.
 *
 * @author raymondleclair
 */
public class PatternELUX201V01 implements EarthPattern {

	/**
	 * Maximum antenna gain [dB]
	 */
	private double GainMax;

	/* Intermediate gain calculation results */
	private double d_over_lambda;
	private double G1;
	private double phi_m;
	private double phi_r;
	private double phi_b;

	/**
	 * Constructs a PatternELUX201V01 given a maximum antenna gain.
	 *
	 * @param GainMax Maximum antenna gain [dB]
	 */
	public PatternELUX201V01(double GainMax) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);

		/* Assign properties */
		this.GainMax = GainMax;

		/* Compute derived properties */
		d_over_lambda = Math.sqrt(Math.pow(10.0, GainMax / 10.0) / (0.61 * Math.PI * Math.PI));
		G1 = -1 + 15 * Math.log10(d_over_lambda);
		phi_m = 20 / d_over_lambda * Math.sqrt(GainMax - G1);
		phi_r = 15.85 * Math.pow(d_over_lambda, -0.6);
		phi_b = Math.pow(10.0, 39.0 / 25.0);
	}

	/**
	 * Transmitting earth station antenna pattern submitted by LUX for analyses
	 * under Appendix 30A.
	 *
	 * @param phi Angle for which a gain is calculated [degrees]
	 * @return Co-polar and cross-polar gain [dB]
	 */
	public Gain gain(double phi) {
		return gain(phi, Collections.EMPTY_MAP);
	}

	/**
	 * Transmitting earth station antenna pattern submitted by LUX for analyses
	 * under Appendix 30A.
	 *
	 * @param phi     Angle for which a gain is calculated [degrees]
	 * @param options Optional parameters (entered as key/value pairs): None
	 * @return Co-polar and cross-polar gain [dB]
	 */
	public Gain gain(double phi, Map options) {

		/* Validate input parameters */
		PatternUtility.validate_input("Phi", phi);

		/* Validate input options */
		options = PatternUtility.validateOptions(options);

		/* Implement pattern */
		double eps = Math.ulp(1.0);
		phi = Math.max(eps, phi);
		double G0 = GainMax - 2.5e-3 * (d_over_lambda * phi) * (d_over_lambda * phi);
		double G2 = 29 - 25 * Math.log10(phi);
		double G3 = -10;

		double G = G0 * (0 <= phi && phi < phi_m ? 1 : 0) + G1 * (phi_m <= phi & phi < phi_r ? 1 : 0)
				+ G2 * (phi_r <= phi && phi < phi_b ? 1 : 0) + G3 * (phi_b <= phi && phi <= 180 ? 1 : 0);

		double Gx0 = GainMax - 30;
		double Gx1 = 29 - 25 * Math.log10(phi);
		double Gx2 = -10;
		double phi_x = Math.pow(10, ((59 - GainMax) / 25));
		double Gx = Gx0 * (0 <= phi && phi < phi_x ? 1 : 0) + Gx1 * (phi_x <= phi && phi < phi_b ? 1 : 0)
				+ Gx2 * (phi_b <= phi && phi <= 180 ? 1 : 0);

		/* Validate low level rules */
		if (G < Gx) {
			throw new IllegalStateException("Co-polar curve is less than cross-polar curve.");
		}
		if (phi_b < phi_x) {
			throw new IllegalStateException("Phi_b is less than Phi_x.");
		}
		if (phi_r < phi_m) {
			throw new IllegalStateException("Phi_r is less than Phi_m.");
		}

		/* Validate output parameters */
		if ((boolean) options.get("DoValidate")) {
			PatternUtility.validate_output(G, Gx, GainMax);
		}
		return new Gain(G, Gx);
	}

	/*
	 * (non-Javadoc)
	 *
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	@Override
	public EarthPattern copy() {
		return new PatternELUX201V01(GainMax);
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
		temp = Double.doubleToLongBits(G1);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(GainMax);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(d_over_lambda);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(phi_b);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(phi_m);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(phi_r);
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
		if (!(obj instanceof PatternELUX201V01)) {
			return false;
		}
		PatternELUX201V01 other = (PatternELUX201V01) obj;
		if (Double.doubleToLongBits(G1) != Double.doubleToLongBits(other.G1)) {
			return false;
		}
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(d_over_lambda) != Double.doubleToLongBits(other.d_over_lambda)) {
			return false;
		}
		if (Double.doubleToLongBits(phi_b) != Double.doubleToLongBits(other.phi_b)) {
			return false;
		}
		if (Double.doubleToLongBits(phi_m) != Double.doubleToLongBits(other.phi_m)) {
			return false;
		}
		if (Double.doubleToLongBits(phi_r) != Double.doubleToLongBits(other.phi_r)) {
			return false;
		}
		return true;
	}
}
