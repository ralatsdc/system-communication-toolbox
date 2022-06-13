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
 * Describes the ITU antenna pattern ENST805V01.
 */
public class PatternENST805V01 implements EarthPattern, TransmitPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Sidelobe reference level [dB] */
	private double CoefA;

	/** Sidelobe roll-off level [dB] */
	private double CoefB;

	/** Angular extent of sidelobe [degrees] */
	private double Phi1;

	/* Intermediate gain calculation results */
	/* None */

	/**
	 * Constructs a PatternENST805V01 given a maximum antenna gain.
	 *
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 * @param CoefA
	 *            Sidelobe reference level [dB]
	 * @param CoefB
	 *            Sidelobe roll-off level [dB]
	 * @param Phi1
	 *            Angular extent of sidelobe [degrees]
	 */
	public PatternENST805V01(double GainMax, double CoefA, double CoefB, double Phi1) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);
		PatternUtility.validate_input("CoefA", CoefA);
		PatternUtility.validate_input("CoefB", CoefB);
		PatternUtility.validate_input("Phi1", Phi1);

		/* Assign properties */
		this.GainMax = GainMax;
		this.CoefA = CoefA;
		this.CoefB = CoefB;
		this.Phi1 = Phi1;

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
	 * Gets sidelobe reference level [dB].
	 * 
	 * @return Sidelobe reference level [dB]
	 */
	public double getCoefA() {
		return CoefA;
	}

	/**
	 * Gets sidelobe roll-off level [dB].
	 * 
	 * @return Sidelobe roll-off level [dB]
	 */
	public double getCoefB() {
		return CoefB;
	}

	/**
	 * Gets angular extent of sidelobe [degrees].
	 * 
	 * @return Angular extent of sidelobe [degrees]
	 */
	public double getPhi1() {
		return Phi1;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	public PatternENST805V01 copy() {
		return new PatternENST805V01(this.GainMax, this.CoefA, this.CoefB, this.Phi1);
	}

	/**
	 * Non-standard generic earth station antenna pattern that is a combination of a
	 * non-standard pattern described by 2 main coefficients: A and B, within a
	 * certain range and the Appendix 8 (RR- 2001) earth station antenna pattern
	 * onwards.
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
		double G1 = Math.max(CoefA - CoefB * Math.log10(phi), -10);

		double G_AB_Phi1 = CoefA - CoefB * Math.log10(Phi1);
		PatternERR_001V01 p = new PatternERR_001V01(GainMax);
		double G_AP8_Phi1 = p.gain(Phi1, options).G;
		double G_AP8 = p.gain(phi, options).G;

		double G2;
		if (G_AP8_Phi1 > G_AB_Phi1) {
			G2 = Math.min(G_AB_Phi1, G_AP8);
		} else {
			G2 = G_AP8;
		}

		double G = G0 * (0 <= phi && phi < 1 ? 1 : 0) + G1 * (1 <= phi && phi <= Phi1 ? 1 : 0)
				+ G2 * (Phi1 < phi && phi <= 180 ? 1 : 0);

		G = Math.min(GainMax, G);
		G = Math.max(-10, G);

		double Gx = G;

		/* Validate low level rules */
		if (Phi1 < 1 || Phi1 > 99.9) {
			throw new IllegalStateException("Phi1 is out of limits [6018: STDC_ERR_NSTD_PHI1]");
		}
		if (CoefB < 10 || CoefB > 50) {
			throw new IllegalStateException("CoefB is out of limits [6015: STDC_ERR_COEFB]");
		}
		if (CoefA < 18 || CoefA > 47) {
			throw new IllegalStateException("CoefA is out of limits [6014: STDC_ERR_COEFA_LIM]");
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
		temp = Double.doubleToLongBits(CoefA);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(CoefB);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(Phi1);
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
		if (!(obj instanceof PatternENST805V01)) {
			return false;
		}
		PatternENST805V01 other = (PatternENST805V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(CoefA) != Double.doubleToLongBits(other.CoefA)) {
			return false;
		}
		if (Double.doubleToLongBits(CoefB) != Double.doubleToLongBits(other.CoefB)) {
			return false;
		}
		if (Double.doubleToLongBits(Phi1) != Double.doubleToLongBits(other.Phi1)) {
			return false;
		}
		return true;
	}
}
