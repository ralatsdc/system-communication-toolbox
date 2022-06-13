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
 * Describes the ITU antenna pattern ERR_008V01.
 */
public class PatternERR_008V01 implements EarthPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Cross-sectional half-power beamwidth [degrees] */
	private double Phi0;

	/* Intermediate gain calculation results */

	/**
	 * Constructs a PatternERR_008V01 given an antenna maximum gain, and
	 * cross-sectional half-power beamwidth.
	 * 
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 * @param Phi0
	 *            Cross-sectional half-power beamwidth [degrees]
	 */
	public PatternERR_008V01(double GainMax, double Phi0) {

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
	 * Gets maximum antenna gain [dB].
	 * 
	 * @return Maximum antenna gain [dB]
	 */
	public double getGainMax() {
		return GainMax;
	}

	/**
	 * Gets cross-sectional half-power beamwidth [degrees].
	 * 
	 * @return Cross-sectional half-power beamwidth [degrees]
	 */
	public double getPhi0() {
		return Phi0;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	public PatternERR_008V01 copy() {
		return new PatternERR_008V01(this.GainMax, this.Phi0);
	}

	/**
	 * Appendix 30 (RR-2001) reference receiving earth station antenna pattern for
	 * Region 2 for individual reception.
	 *
	 * @param Phi
	 *            Angle for which a gain is calculated [degrees]
	 * @param options
	 *            Optional parameters (entered as key/value pairs)
	 *
	 * @param Co-polar
	 *            and cross-polar gain [dB]
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
		double G1 = GainMax - 12.0 * Math.pow(phi_over_phi0, 2);
		double G2 = GainMax - 14.0 - 25.0 * Math.log10(phi_over_phi0);
		double G3 = GainMax - 43.2;
		double G4 = GainMax - 85.2 + 27.2 * Math.log10(phi_over_phi0);
		double G5 = GainMax - 40.2;
		double G6 = GainMax + 55.2 - 51.7 * Math.log10(phi_over_phi0);
		double G7 = GainMax - 43.2;

		double G = G0 * (0 <= phi_over_phi0 && phi_over_phi0 <= 0.25 ? 1 : 0)
				+ G1 * (0.25 < phi_over_phi0 && phi_over_phi0 <= 1.13 ? 1 : 0)
				+ G2 * (1.13 < phi_over_phi0 && phi_over_phi0 <= 14.7 ? 1 : 0)
				+ G3 * (14.7 < phi_over_phi0 && phi_over_phi0 <= 35 ? 1 : 0)
				+ G4 * (35 < phi_over_phi0 && phi_over_phi0 <= 45.1 ? 1 : 0)
				+ G5 * (45.1 < phi_over_phi0 && phi_over_phi0 <= 70 ? 1 : 0)
				+ G6 * (70 < phi_over_phi0 && phi_over_phi0 <= 80 ? 1 : 0) + G7 * (80 < phi_over_phi0 ? 1 : 0);

		double Gx0 = GainMax - 25.0;

		double phix = Math.max(eps, Math.abs(phi_over_phi0 - 1.0));

		double Gx1 = GainMax - 30.0 - 40.0 * Math.log10(phix);
		double Gx2 = GainMax - 20.0;
		double Gx3 = GainMax - 17.3 - 25.0 * Math.log10(Math.abs(phi_over_phi0));
		double Gx4 = GainMax - 30.0;

		double Gx = Gx0 * (0 <= phi_over_phi0 && phi_over_phi0 <= 0.25 ? 1 : 0)
				+ Gx1 * (0.25 < phi_over_phi0 && phi_over_phi0 <= 0.44 ? 1 : 0)
				+ Gx2 * (0.44 < phi_over_phi0 && phi_over_phi0 <= 1.28 ? 1 : 0)
				+ Gx3 * (1.28 < phi_over_phi0 && phi_over_phi0 <= 3.22 ? 1 : 0) + Gx4 * (3.22 < phi_over_phi0 ? 1 : 0);

		Gx = Math.min(Gx, G);

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
		if (!(obj instanceof PatternERR_008V01)) {
			return false;
		}
		PatternERR_008V01 other = (PatternERR_008V01) obj;
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
