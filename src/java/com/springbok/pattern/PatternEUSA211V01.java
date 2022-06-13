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
 * Describes the ITU antenna pattern EUSA211V01.
 */
public class PatternEUSA211V01 implements EarthPattern, TransmitPattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/* Intermediate gain calculation results */
	private double d_over_lambda;
	private double G1;
	private double phi_m;
	private double phi_r;
	private double phi_b;

	/**
	 * Constructs a PatternEUSA211V01 given a maximum antenna gain.
	 *
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 */
	public PatternEUSA211V01() {

		/* Assign properties */
		this.GainMax = 65;

		/* Compute derived properties */
		this.d_over_lambda = Math.sqrt(Math.pow(10.0, this.GainMax / 10.0) / (0.55 * Math.pow(Math.PI, 2)));
		this.G1 = -1.0 + 15.0 * Math.log10(this.d_over_lambda);
		this.phi_m = 20.0 / this.d_over_lambda * Math.sqrt(this.GainMax - this.G1);
		this.phi_r = 1.0;
		this.phi_b = Math.pow(10.0, 42.0 / 25.0);
	}

	/**
	 * Gets gainMax Maximum antenna gain [dB].
	 * 
	 * @return GainMax Maximum antenna gain [dB]
	 */
	public double getGainMax() {
		return GainMax;
	}

	/**
	 * Gets ratio of antenna diameter to wavelength.
	 * 
	 * @return Ratio of antenna diameter to wavelength
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
	 * @return Start angle of the near side lobe (logarithmic part) [degrees].
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
	public PatternEUSA211V01 copy() {
		return new PatternEUSA211V01();
	}

	/**
	 * Earth station transmitting antenna pattern for analyses under Appendix 30A
	 * for USABSS-14 and USABSS-15 networks.
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

		double G2 = 29.0 - 25.0 * Math.log10(phi);
		double G3 = 7.9;
		double G4 = Math.max(32.0 - 25.0 * Math.log10(phi), -10.0);

		double G = G0 * (0 <= phi && phi < phi_m ? 1 : 0) + G1 * (phi_m <= phi && phi < phi_r ? 1 : 0)
				+ G2 * (phi_r <= phi && phi < 7 ? 1 : 0) + G3 * (7 <= phi && phi < 9 ? 1 : 0)
				+ G4 * (9 <= phi && phi <= 180 ? 1 : 0);

		double Gx0 = GainMax - 2.5e-3 * Math.pow(d_over_lambda * phi, 2) - 30.0;
		double Gx1 = GainMax - 2.5e-3 * Math.pow(d_over_lambda * phi, 2) - 20.0;
		double Gx2 = G1 - 20.0;
		double Gx3 = 19.0 - 25.0 * Math.log10(phi);
		double Gx4 = Math.min(-2.0, G);

		double Gx = Gx0 * (0.0 <= phi && phi < phi_m / 2 ? 1 : 0) + Gx1 * (phi_m / 2.0 <= phi && phi < phi_m ? 1 : 0)
				+ Gx2 * (phi_m <= phi && phi < phi_r ? 1 : 0) + Gx3 * (phi_r <= phi && phi < 6.92 ? 1 : 0)
				+ Gx4 * (6.92 <= phi && phi <= 180.0 ? 1 : 0);

		/* Validate low level rules */
		/* None */

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
		if (!(obj instanceof PatternEUSA211V01)) {
			return false;
		}
		return true;
	}
}
