/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern SRR_404V01.
 */
public class PatternSRR_404V01 implements SpacePattern, ReceivePattern {

	/**
	 * Maximum antenna gain [dB]
	 */
	private double GainMax;

	/**
	 * Cross-sectional half-power beamwidth [degrees]
	 */
	private double Phi0;

	/**
	 * Constructs a PatternSRR_404V01 given a cross-sectional half-power beamwidth.
	 *
	 * @param Phi0 Cross-sectional half-power beamwidth [degrees]
	 */
	public PatternSRR_404V01(double Phi0) {
		/* Validate input parameters */
		PatternUtility.validate_input("Phi0", Phi0);

		/* Assign properties */
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
	 * Gets Cross-sectional half-power beamwidth [degrees].
	 *
	 * @return Cross-sectional half-power beamwidth [degrees]
	 */
	public double getPhi0() {
		return Phi0;
	}

	/**
	 * Copies a PatternSRR_404V01 given a maximum antenna gain.
	 */
	public PatternSRR_404V01 copy() {
		return new PatternSRR_404V01(this.Phi0);
	}

	/**
	 * Appendix 30A (RR-2001) reference receiving space station antenna pattern for
	 * Regions 1 and 3 (WRC-97).
	 *
	 * @param Phi     Angle for which a gain is calculated [degrees]
	 * @param options Optional parameter (entered as key/value pairs)
	 * @return Co-polar and cross-polar gain [dB]
	 */
	public Gain gain(double Phi, Map options) {
		/* Validate input parameters */
		PatternUtility.validate_input("Phi", Phi);
		/* Validate input options */
		options = PatternUtility.validateOptions(options);

		// TODO: Test constructor optional agruments
		GainMax = 0;
		boolean absolute_pattern = false;
		if (options.containsKey("GainMax")) {
			GainMax = (double) options.get("GainMax");
			absolute_pattern = true;

		}
		/* Implement pattern */
		double eps = Math.ulp(1.0);
		double phi = Math.max(eps, Phi);

		double phi_over_phi0 = phi / Phi0;

		double G0 = GainMax - 12 * Math.pow(phi_over_phi0, 2);
		double G1 = GainMax - 17.5 - 25 * Math.log10(phi_over_phi0);

		double G = G0 * (0 <= phi_over_phi0 && phi_over_phi0 < 1.3 ? 1 : 0)
				+ G1 * (1.3 <= phi_over_phi0 ? 1 : 0);

		double Gx0 = GainMax - 35;
		double phix = Math.max(eps, phi_over_phi0 - 1);
		double Gx1 = GainMax - 40 - 40 * Math.log10(phix);

		double Gx = Gx0 * (0 <= phi_over_phi0 && phi_over_phi0 < 1.75 ? 1 : 0)
				+ Gx1 * (1.75 <= phi_over_phi0 ? 1 : 0);

		/* Apply "flooring" for absolute gain pattern */
		if (absolute_pattern) {
			G = Math.max(0, G);
			Gx = Math.max(0, Gx);

		}
		/* Validate low level rules */
		if (GainMax < 35 && absolute_pattern) {
			PatternUtility.logger.warn("GainMax is less than 35.");
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
		if (!(obj instanceof PatternSRR_404V01)) {
			return false;
		}
		PatternSRR_404V01 other = (PatternSRR_404V01) obj;
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
