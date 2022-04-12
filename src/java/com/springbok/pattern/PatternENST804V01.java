/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern ENST804V01.
 */
public class PatternENST804V01 implements EarthPattern, TransmitPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Sidelobe reference level [dB] */
	private double CoefA;

	/** Sidelobe roll-off level [dB] */
	private double CoefB;

	/* Intermediate gain calculation results */
	private double phi_r;
	private double phi_b;

	/**
	 * Constructs a PatternENST804V01 given a maximum antenna gain.
	 *
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 * @param CoefA
	 *            Sidelobe reference level [dB]
	 * @param CoefB
	 *            Sidelobe roll-off level [dB]
	 */
	public PatternENST804V01(double GainMax, double CoefA, double CoefB) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);
		PatternUtility.validate_input("CoefA", CoefA);
		PatternUtility.validate_input("CoefB", CoefB);

		/* Assign properties */
		this.GainMax = GainMax;
		this.CoefA = CoefA;
		this.CoefB = CoefB;

		/* Compute derived properties */
		this.phi_r = 1.0;
		this.phi_b = 0.0;
		double g1 = this.CoefA - this.CoefB * Math.log10(this.phi_b);
		while (g1 > -10) {
			this.phi_b += 0.001;
			g1 = this.CoefA - this.CoefB * Math.log10(this.phi_b);
		}
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
	 * Get Sidelobe roll-off level [dB].
	 * 
	 * @return Sidelobe roll-off level [dB]
	 */
	public double getCoefB() {
		return CoefB;
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
	public PatternENST804V01 copy() {
		return new PatternENST804V01(this.GainMax, this.CoefA, this.CoefB);
	}

	/**
	 * Non-standard generic earth station antenna pattern described by 2 main
	 * coefficients: A and B.
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

		double G = G0 * (0 <= phi && phi <= phi_r ? 1 : 0) + G1 * (phi_r < phi && phi <= 180 ? 1 : 0);

		G = Math.min(GainMax, G);

		double Gx = G;

		/* Validate low level rules */
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
		if (!(obj instanceof PatternENST804V01)) {
			return false;
		}
		PatternENST804V01 other = (PatternENST804V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(CoefA) != Double.doubleToLongBits(other.CoefA)) {
			return false;
		}
		if (Double.doubleToLongBits(CoefB) != Double.doubleToLongBits(other.CoefB)) {
			return false;
		}
		return true;
	}
}
