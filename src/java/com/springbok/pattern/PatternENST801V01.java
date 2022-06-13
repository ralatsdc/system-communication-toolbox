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
 * Describes the ITU antenna pattern ENST801V01.
 */
public class PatternENST801V01 implements EarthPattern, TransmitPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Antenna efficiency, fraction */
	private double Efficiency;

	/** Sidelobe reference level [dB] */
	private double CoefA;

	/* Intermediate gain calculation results */
	private double d_over_lambda;
	private double G1;
	private double phi_m;
	private double phi_r;
	private double phi_b;

	/**
	 * Constructs a PatternENST801V01 given a maximum antenna gain.
	 *
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 * @param Efficiency
	 *            Antenna efficiency, fraction
	 * @param CoefA
	 *            Sidelobe reference level [dB]
	 */
	public PatternENST801V01(double GainMax, double Efficiency, double CoefA) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);
		PatternUtility.validate_input("Efficiency", Efficiency);
		PatternUtility.validate_input("CoefA", CoefA);

		/* Assign properties */
		this.GainMax = GainMax;
		this.Efficiency = Efficiency;
		this.CoefA = CoefA;

		/* Compute derived properties */
		this.d_over_lambda = Math.sqrt(Math.pow(10, (this.GainMax / 10)) / (this.Efficiency * Math.pow(Math.PI, 2)));
		if (this.d_over_lambda < 100) {
			this.CoefA = 32;
		}

		if (this.d_over_lambda > 100) {
			this.G1 = this.CoefA;
			this.phi_m = 20 / this.d_over_lambda * Math.sqrt(this.GainMax - this.G1);
			this.phi_r = 1;
			this.phi_b = Math.pow(10, (this.CoefA + 10) / 25);
		} else {
			this.G1 = 2 + 15 * Math.log10(this.d_over_lambda);
			this.phi_m = 20 / this.d_over_lambda * Math.sqrt(this.GainMax - this.G1);
			this.phi_r = 100 / this.d_over_lambda;
			this.phi_b = Math.pow(10, 42.0 / 25.0);
		}
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
	 * Gets antenna efficiency, fraction.
	 * 
	 * @return Antenna efficiency, fraction
	 */
	public double getEfficiency() {
		return Efficiency;
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
	 * Gets ratio of antenna diameter to frequency.
	 * 
	 * @return Ratio of antenna diameter to frequency
	 */
	public double getD_over_lambda() {
		return d_over_lambda;
	}

	/**
	 * Gets gain of the first side lobe (plateau constant part) [dB].
	 * 
	 * @return Gain of the first side lobe (plateau constant part) [dB]
	 */
	public double getG1() {
		return G1;
	}

	/**
	 * Gets start angle of the first side lobe (plateau constant part) [degrees].
	 * 
	 * @return Start angle of the first side lobe (plateau constant part) [degrees]
	 */
	public double getPhi_m() {
		return phi_m;
	}

	/**
	 * Gets start angle of the near side lobe (logarithmic part) [degrees].
	 * 
	 * @return Start angle of the near side lobe (logarithmic part) [degrees]
	 */
	public double getPhi_r() {
		return phi_r;
	}

	/**
	 * Gets start angle of the back lobe (back constant part) [degrees].
	 *
	 * @return Start angle of the back lobe (back constant part) [degrees]
	 */
	public double getPhi_b() {
		return phi_b;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	public PatternENST801V01 copy() {
		return new PatternENST801V01(this.GainMax, this.Efficiency, this.CoefA);
	}

	/**
	 * Non-standard OBSOLETE earth station antenna pattern similar to that in
	 * Recommendation ITU-R S.465-3, where the side-lobe radiation is represented by
	 * the expression CoefA - 25 log(phi).
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

		double G0 = GainMax - 2.5e-3 * Math.pow(d_over_lambda * phi, 2);
		double G2;
		double G;
		if (d_over_lambda > 100) {
			G2 = Math.max(CoefA - 25 * Math.log10(phi), -10);

			G = G0 * (0 <= phi && phi < phi_m ? 1 : 0) + G1 * (phi_m <= phi && phi < phi_r ? 1 : 0)
					+ G2 * (phi_r <= phi && phi <= 180 ? 1 : 0);

		} else {
			G2 = 52 - 10 * Math.log10(d_over_lambda) - 25 * Math.log10(phi);
			double G3 = 10 - 10 * Math.log10(d_over_lambda);

			G = G0 * (0 <= phi && phi < phi_m ? 1 : 0) + G1 * (phi_m <= phi && phi < phi_r ? 1 : 0)
					+ G2 * (phi_r <= phi && phi < phi_b ? 1 : 0) + G3 * (phi_b <= phi && phi <= 180 ? 1 : 0);
		}

		double Gx = G;

		/* Validate low level rules */
		if (CoefA < 18 || CoefA > 47) {
			throw new IllegalStateException("CoefA is out of limits [6014: STDC_ERR_COEFA_LIM");
		}
		if (phi_b < phi_r) {
			throw new IllegalStateException("phi_b is less than phi_r [6010: STDC_ERR_PHIB_LT_PHIR");
		}
		if (GainMax < G1) {
			throw new IllegalStateException("GainMax is less than G1 [6001: STDC_ERR_GNAX_LT_G1");
		}
		if (d_over_lambda < 100) {
			PatternUtility.logger.warn("D/lambda is less than 100. CoefA is ignored.");
		}
		if (phi_r < phi_m) {
			PatternUtility.logger.warn("phi_r is less than phi_m.");
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
		temp = Double.doubleToLongBits(Efficiency);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(CoefA);
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
		if (!(obj instanceof PatternENST801V01)) {
			return false;
		}
		PatternENST801V01 other = (PatternENST801V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(Efficiency) != Double.doubleToLongBits(other.Efficiency)) {
			return false;
		}
		if (Double.doubleToLongBits(CoefA) != Double.doubleToLongBits(other.CoefA)) {
			return false;
		}
		return true;
	}
}
