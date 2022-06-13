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
 * Describes the ITU antenna pattern ELUX204V01.
 */
public class PatternELUX204V01 implements EarthPattern, TransmitPattern, ReceivePattern {

	/**
	 * Maximum antenna gain [dB]
	 */
	private double GainMax;

	/**
	 * Antenna efficiency, fraction
	 */
	private double Efficiency;

	/* Intermediate gain calculation results */
	private double d_over_lambda;
	private double G1;
	private double phi_m;
	private double phi_r;
	private double phi_b;

	/**
	 * Constructs a PatternELUX204V01 given a maximum antenna gain, and efficiency.
	 *
	 * @param GainMax    Maximum antenna gain [dB]
	 * @param Efficiency Antenna efficiency, fraction
	 */
	public PatternELUX204V01(double GainMax, double Efficiency) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);
		PatternUtility.validate_input("Efficiency", Efficiency);

		/* Assign properties */
		this.GainMax = GainMax;
		this.Efficiency = Efficiency;

		/* Compute derived properties */
		this.d_over_lambda = Math.sqrt(Math.pow(10, this.GainMax / 10) / (this.Efficiency * Math.pow(Math.PI, 2)));

		this.G1 = -1 + 15 * Math.log10(this.d_over_lambda);
		this.phi_m = 20 / this.d_over_lambda * Math.sqrt(this.GainMax - this.G1);
		this.phi_r = 15.85 * Math.pow((this.d_over_lambda), (-0.6));
		this.phi_b = 48;
	}

	/**
	 * Gets the maximum antenna gain [dB].
	 *
	 * @return Maximum antenna gain [dB]
	 */
	public double getGainMax() {
		return GainMax;
	}

	/**
	 * Gets the antenna efficiency, fraction.
	 *
	 * @return Antenna efficiency, fraction
	 */
	public double getEfficiency() {
		return Efficiency;
	}

	/**
	 * Gets ratio of antenna diameter to wavelength.
	 *
	 * @return Antenna aperture over wavelength []
	 */
	public double getD_over_lambda() {
		return d_over_lambda;
	}

	/**
	 * Gets gain of the first side lobe (plateau constant part) [dB]
	 *
	 * @return Gain of the first side lobe (plateau constant part) [dB]
	 */
	public double getG1() {
		return G1;
	}

	/**
	 * Gets start angle of the first side lobe (plateau constant part) [degrees].
	 *
	 * @return Start angle of the first side lobe (plateau constant part)
	 * [degrees].
	 */
	public double getPhi_m() {
		return phi_m;
	}

	/**
	 * Gets start angle of the near side lobe (logarithmic part) [degrees]
	 *
	 * @return Start angle of the near side lobe (logarithmic part) [degrees]
	 */
	public double getPhi_r() {
		return phi_r;
	}

	/**
	 * Gets start angle of the back lobe (back constant part) [degrees]
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
	public PatternELUX204V01 copy() {
		return new PatternELUX204V01(this.GainMax, this.Efficiency);
	}

	/**
	 * Earth station antenna pattern submitted by LUX for both uplinks and downlinks
	 * for analyses under Appendix 30B.
	 *
	 * @param Phi     Angle for which a gain is calculated [degrees]
	 * @param options Optional parameters (entered as key/value pairs)
	 * @return Co-polar gain and coss-polar gain [dB]
	 */
	public Gain gain(double Phi, Map options) {

		/* Validate input parameters */
		PatternUtility.validate_input("Phi", Phi);

		/* Validate input options */
		options = PatternUtility.validateOptions(options);

		/* Implement pattern */
		double eps = Math.ulp(1.0);
		double phi = Math.max(eps, Phi);

		double G0 = GainMax - 2.5e-3 * Math.pow((d_over_lambda * phi), 2);

		double G2 = 29 - 25 * Math.log10(phi);
		double G3 = 32 - 25 * Math.log10(phi);
		double G4 = -10;

		double G = G0 * (0 <= phi && phi < phi_m ? 1 : 0) + G1 * (phi_m <= phi && phi < phi_r ? 1 : 0)
				+ G2 * (phi_r <= phi && phi < 20 ? 1 : 0) + G3 * (20 <= phi && phi < phi_b ? 1 : 0)
				+ G4 * (phi_b <= phi && phi <= 180 ? 1 : 0);

		double Gx = G;

		/* Validate low level rules */
		if (d_over_lambda < 100) {
			throw new IllegalStateException("D/lambda is less than 100 [6002: STDC_ERR_DLAMBDA]");
		}
		if (GainMax < G1) {
			throw new IllegalStateException("GainMax is less than G1 [6001: STDC_ERR_GNAX_LT_G1]");
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
		if (!(obj instanceof PatternELUX204V01)) {
			return false;
		}
		PatternELUX204V01 other = (PatternELUX204V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(Efficiency) != Double.doubleToLongBits(other.Efficiency)) {
			return false;
		}
		return true;
	}
}
