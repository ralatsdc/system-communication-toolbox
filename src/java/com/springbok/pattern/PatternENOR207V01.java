/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern ENOR207V01.
 */
public class PatternENOR207V01 implements EarthPattern, TransmitPattern {

	/* Maximum antenna gain [dB] */
	private double GainMax;

	/* Intermediate gain calculation results */
	/* None */

	/**
	 * Constructs a PatternENOR207V01.
	 */
	public PatternENOR207V01() {

		// Assign properties
		this.GainMax = 50.7;
	}

	/**
	 * Gets the maximum co-polar gain [dB].
	 * 
	 * @return Maximum co-polar gain [dB]
	 */
	public double getGainMax() {
		return GainMax;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	public PatternENOR207V01 copy() {
		return new PatternENOR207V01();
	}

	/**
	 * Earth station transmitting antenna pattern for analyses under Appendix 30B
	 * for the BIFROST terminal type I transmitting antenna.
	 *
	 * Parameters: Phi Angle for which a gain is calculated [degrees] options
	 * Optional parameters (entered as key/value pairs)
	 *
	 * @return Co-polar and cross-polar gain [dB] fH - figure handle
	 */
	public Gain gain(double Phi, Map options) {

		/* Validate input parameters */
		PatternUtility.validate_input("Phi", Phi);

		/* Validate input options */
		options = PatternUtility.validateOptions(options);

		/* Implement pattern */
		double eps = Math.ulp(1.0);
		double phi = Math.max(eps, Phi);

		double G0 = 50.7 - 42.3 * Math.pow(phi, 2);
		double G1 = 33.7;
		double G2 = 29 - 25 * Math.log10(phi);
		double G3 = -10;

		double G = G0 * (0 <= phi && phi < 0.634 ? 1 : 0) + G1 * (0.634 <= phi && phi < 0.649 ? 1 : 0)
				+ G2 * (0.649 <= phi && phi < 48 ? 1 : 0) + G3 * (48 <= phi && phi <= 180 ? 1 : 0);

		double Gx = G;

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
		if (!(obj instanceof PatternENOR207V01)) {
			return false;
		}
		PatternENOR207V01 other = (PatternENOR207V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
