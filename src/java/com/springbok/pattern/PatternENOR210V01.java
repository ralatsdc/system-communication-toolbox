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
 * Describes the ITU antenna pattern ENOR210V01.
 */
public class PatternENOR210V01 implements EarthPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Cross-sectional half-power beamwidth [degrees] */
	private double Phi0;

	/* Intermediate gain calculation results */
	/* None */

	/**
	 * Constructs a PatternENOR210V01 given a maximum antenna gain.
	 *
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 * @param Phi0
	 *            Cross-sectional half-power beamwidth, degrees
	 */
	public PatternENOR210V01(double GainMax, double Phi0) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);
		PatternUtility.validate_input("Phi0", Phi0);

		/* Assign properties */
		this.GainMax = GainMax;
		this.Phi0 = Phi0;

		/* Compute derived properties */
		/* None */
	}

	/**
	 * Gets maximum co-polar gain [dB].
	 * 
	 * @return Maximum co-polar gain [dB]
	 */
	public double getGainMax() {
		return GainMax;
	}

	/**
	 * Gets half-power beamwidth [degrees].
	 * 
	 * @return Half-power beamwidth [degrees]
	 */
	public double getPhi0() {
		return Phi0;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	public PatternENOR210V01 copy() {
		return new PatternENOR210V01(this.GainMax, this.Phi0);
	}

	/**
	 * Earth station receiving antenna pattern for analyses under Appendix 30B for
	 * the BIFROST receiving antenna.
	 * 
	 * @param Phi
	 *            Angle for which a gain is calculated [degrees]
	 * @param options
	 *            Optional parameters (entered as key/value pairs)
	 *
	 * @return Co-polar and c ross-polar gain [dB]
	 */
	public Gain gain(double Phi, Map options) {

		/* Validate input parameters */
		PatternUtility.validate_input("Phi", Phi);

		/* Validate input options */
		options = PatternUtility.validateOptions(options);

		/* Implement pattern */
		double eps = Math.ulp(1.0);
		double phi = Math.max(eps, Phi);

		double phi_over_phi0 = phi / Phi0;

		double G0 = GainMax;
		double G1 = GainMax - 12 * Math.pow(phi_over_phi0, 2);
		double G2 = GainMax - 10.5 - 25 * Math.log10(phi_over_phi0);

		double G = G0 * (0 <= phi_over_phi0 && phi_over_phi0 <= 0.25 ? 1 : 0)
				+ G1 * (0.25 < phi_over_phi0 && phi_over_phi0 <= 0.86 ? 1 : 0) + G2 * (0.86 < phi_over_phi0 ? 1 : 0);

		G = Math.max(GainMax - 37, G);

		double Gx = G;

		/* Validate low level rules */
		if (Phi0 < 0.1 || Phi0 > 5.0) {
			PatternUtility.logger.warn("Phi0 is out of limits.");
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
		if (!(obj instanceof PatternENOR210V01)) {
			return false;
		}
		PatternENOR210V01 other = (PatternENOR210V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		return true;
	}
}
