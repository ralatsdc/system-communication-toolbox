/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern ERR_006V01.
 */
public class PatternERR_006V01 implements EarthPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Cross-sectional half-power beamwidth [degrees] */
	private double Phi0;

	/* Intermediate gain calculation results */
	/* None */

	/**
	 * Constructs a PatternERR_006V01 given an antenna maximum gain, and
	 * cross-sectional half-power beamwidth.
	 * 
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 * @param Phi0
	 *            Cross-sectional half-power beamwidth [degrees]
	 */
	public PatternERR_006V01(double GainMax, double Phi0) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);
		PatternUtility.validate_input("Phi0", Phi0);

		/* Assign properties */
		this.GainMax = GainMax;
		this.Phi0 = Phi0;
	}

	/**
	 * Gets aximum antenna gain [dB].
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
	public PatternERR_006V01 copy() {
		return new PatternERR_006V01(this.GainMax, this.Phi0);
	}

	/**
	 * Appendix 30 (RR-2001) reference receiving earth station antenna pattern for
	 * Regions 1 and 3 for individual reception (1977 BSS Plan).
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
		double phi_over_phi0 = phi / Phi0;
		double phix = Math.max(eps, Math.abs(phi_over_phi0 - 1.0));

		double G0 = GainMax;
		double G1 = GainMax - 12.0 * Math.pow(phi_over_phi0, 2);
		double G2 = GainMax - 9.0 - 20.0 * Math.log10(phi_over_phi0);
		double G3 = GainMax - 8.5 - 25.0 * Math.log10(phi_over_phi0);
		double G4 = GainMax - 33.0;

		double G = G0 * (0.0 <= phi_over_phi0 && phi_over_phi0 <= 0.25 ? 1 : 0)
				+ G1 * (0.25 < phi_over_phi0 && phi_over_phi0 <= 0.707 ? 1 : 0)
				+ G2 * (0.707 < phi_over_phi0 && phi_over_phi0 <= 1.26 ? 1 : 0)
				+ G3 * (1.26 < phi_over_phi0 && phi_over_phi0 <= 9.55 ? 1 : 0) + G4 * (9.55 < phi_over_phi0 ? 1 : 0);

		double Gx0 = GainMax - 25.0;
		double Gx1 = GainMax - 30.0 - 40.0 * Math.log10(phix);
		double Gx2 = GainMax - 20.0;
		double Gx3 = GainMax - 30.0 - 25.0 * Math.log10(phix);
		double Gx4 = GainMax - 30.0;

		double Gx = Gx0 * (0.0 <= phi_over_phi0 && phi_over_phi0 <= 0.25 ? 1 : 0)
				+ Gx1 * (0.25 < phi_over_phi0 && phi_over_phi0 <= 0.44 ? 1 : 0)
				+ Gx2 * (0.44 < phi_over_phi0 && phi_over_phi0 <= 1.4 ? 1 : 0)
				+ Gx3 * (1.4 < phi_over_phi0 && phi_over_phi0 <= 2.0 ? 1 : 0) + Gx4 * (2.0 < phi_over_phi0 ? 1 : 0);

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
		if (!(obj instanceof PatternERR_006V01)) {
			return false;
		}
		PatternERR_006V01 other = (PatternERR_006V01) obj;
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
