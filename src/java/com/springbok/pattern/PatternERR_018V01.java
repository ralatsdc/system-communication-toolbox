/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern ERR_018V01.
 */
public class PatternERR_018V01 implements EarthPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/* Intermediate gain calculation results */
	/* None */

	/**
	 * Constructs a PatternERR_018V01 given a maximum antenna gain.
	 *
	 * @parm GainMax Maximum antenna gain [dB]
	 */
	public PatternERR_018V01(double GainMax) {

		/* Validate input */
		PatternUtility.validate_input("GainMax", GainMax);

		/* Assign properties */
		this.GainMax = GainMax;

		/* Compute derived properties */
		/* None */
	}

	/**
	 * Gets gainMax Maximum antenna gain [dB].
	 * 
	 * @return GainMax Maximum antenna gain [dB]
	 */
	public double getGainMax() {
		return GainMax;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	public PatternERR_018V01 copy() {
		return new PatternERR_018V01(this.GainMax);
	}

	/**
	 * Appendix 30 (RR-2003) reference receiving earth station antenna pattern for
	 * Region 2 for analogue BSS assignments.
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

		double Phi0 = 1.7;
		double phi_over_phi0 = phi / Phi0;

		double G0 = GainMax;
		double G1 = GainMax - 12.0 * Math.pow(phi_over_phi0, 2);
		double G2 = GainMax - 14.0 - 25.0 * Math.log10(phi_over_phi0);
		double G3 = GainMax - 43.2;

		double G = G0 * (0.0 <= phi_over_phi0 && phi_over_phi0 <= 0.25 ? 1 : 0)
				+ G1 * (0.25 < phi_over_phi0 && phi_over_phi0 <= 1.13 ? 1 : 0)
				+ G2 * (1.13 < phi_over_phi0 && phi_over_phi0 <= 14.7 ? 1 : 0) + G3 * (14.7 < phi_over_phi0 ? 1 : 0);

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
		if (!(obj instanceof PatternERR_018V01)) {
			return false;
		}
		PatternERR_018V01 other = (PatternERR_018V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
