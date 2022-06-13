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
 * Describes the ITU antenna pattern ELUX202V01.
 */
public class PatternELUX202V01 implements EarthPattern, ReceivePattern {

	/* Maximum antenna gain [dB] */
	private double GainMax;

	/* Intermediate gain calculation results */
	private double d_over_lambda;
	private double phi_r;
	private double G1;
	private double phi_m;
	private double phi_b;

	/**
	 * Constructs a PatternELUX202V01 given a maximum antenna gain.
	 */
	public PatternELUX202V01() {

		/* Assign properties */
		GainMax = 47;

		/* Compute derived properties */
		d_over_lambda = 96.942890;
		phi_r = 85 / d_over_lambda;
		G1 = 29 - 25 * Math.log10(phi_r);
		phi_m = 1 / d_over_lambda * Math.sqrt((GainMax - G1) / 0.00295);
		phi_b = Math.pow(10, (34.0 / 25));
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	@Override
	public PatternELUX202V01 copy() {
		return new PatternELUX202V01();
	}

	/**
	 * Receiving earth station antenna pattern submitted by LUX for community
	 * reception for analysis under Appendix 30.
	 *
	 * @param Phi     Angle for which a gain is calculated [degrees]
	 * @param options Optional parameters (entered as key/value pairs): None
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

		double G0 = GainMax - 2.95e-3 * Math.pow((d_over_lambda * phi), 2);

		double G2 = 29 - 25 * Math.log10(phi);
		double G3 = -5;
		double G4 = 0;

		double G = G0 * (0 <= phi && phi < phi_m ? 1 : 0) + G1 * (phi_m <= phi && phi < phi_r ? 1 : 0)
				+ G2 * (phi_r <= phi && phi < phi_b ? 1 : 0) + G3 * (phi_b <= phi && phi < 70 ? 1 : 0)
				+ G4 * (70 <= phi && phi <= 180 ? 1 : 0);

		double Gx0 = GainMax - 25;

		double phi_0 = 2 / d_over_lambda * Math.sqrt(3 / 0.00295);
		double Gx1 = GainMax - 25 + 5 * ((phi - 0.25 * phi_0) / (0.19 * phi_0));
		double Gx2 = GainMax - 20;
		double Gx3 = GainMax - 20 - 40 * (phi / phi_0 - 1);
		double Gx4 = GainMax - 30;
		double Gx5 = G;

		double phi_1 = 0.25 * phi_0;
		double phi_2 = 0.44 * phi_0;
		double phi_3 = 1.25 * phi_0;
		double phi_x = Math.pow(10, (59 - GainMax) / 25);

		double Gx = Gx0 * (0 <= phi && phi < phi_1 ? 1 : 0) + Gx1 * (phi_1 <= phi & phi < phi_2 ? 1 : 0)
				+ Gx2 * (phi_2 <= phi & phi < phi_0 ? 1 : 0) + Gx3 * (phi_0 <= phi & phi < phi_3 ? 1 : 0)
				+ Gx4 * (phi_3 <= phi & phi < phi_x ? 1 : 0) + Gx5 * (phi_x <= phi & phi <= 180 ? 1 : 0);

		/* Validate low level rules: Not required */

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

		/*
		 * As all fields are set with constants any two PatternELUX202V01 will be equal
		 */
		return true;
	}
}
