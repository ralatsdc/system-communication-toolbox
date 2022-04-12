/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern ERR_001V01.
 */
public class PatternERR_001V01 implements EarthPattern, TransmitPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/* Intermediate gain calculation results */
	private double d_over_lambda;
	private double G1;
	private double phi_m;
	private double phi_r;
	private double phi_b;

	/**
	 * Constructs a PatternERR_001V01 given a maximum antenna gain.
	 *
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 */
	public PatternERR_001V01(double GainMax) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);

		/* Assign properties */
		this.GainMax = GainMax;

		/* Compute derived properties */
		this.d_over_lambda = Math.pow(10, (this.GainMax - 7.7) / 20);
		this.G1 = 2 + 15 * Math.log10(this.d_over_lambda);
		this.phi_m = 20 / this.d_over_lambda * Math.sqrt(this.GainMax - this.G1);
		if (this.d_over_lambda >= 100) {
			this.phi_r = 15.85 * Math.pow(this.d_over_lambda, -0.6);
		} else {
			this.phi_r = 100 / this.d_over_lambda;
		}
		this.phi_b = 48;
	}

	/**
	 * Gets maximum antenna gain [dB]
	 * 
	 * @return Mmaximum antenna gain [dB]
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
	public PatternERR_001V01 copy() {
		return new PatternERR_001V01(this.GainMax);
	}

	/**
	 * Appendix 8 (RR-2001) Earth station antenna pattern. (Former Appendix 28 and
	 * Appendix 29 antenna pattern.)
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

		double G0 = this.GainMax - 2.5e-3 * Math.pow(this.d_over_lambda * phi, 2);
		double G2, G3;
		if (this.d_over_lambda >= 100) {
			G2 = 32 - 25 * Math.log10(phi);
			G3 = -10;
		} else {
			G2 = 52 - 10 * Math.log10(this.d_over_lambda) - 25 * Math.log10(phi);
			G3 = 10 - 10 * Math.log10(this.d_over_lambda);
		}

		double G = G0 * (0 <= phi && phi < this.phi_m ? 1 : 0)
				+ this.G1 * (this.phi_m <= phi && phi < this.phi_r ? 1 : 0)
				+ G2 * (this.phi_r <= phi && phi < this.phi_b ? 1 : 0) + G3 * (this.phi_b <= phi && phi <= 180 ? 1 : 0);

		double Gx = G;

		/* Validate low level rules */
		if (this.phi_b < this.phi_r) {
			PatternUtility.logger.warn("phi_b is less than phi_r.");
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
		if (!(obj instanceof PatternERR_001V01)) {
			return false;
		}
		PatternERR_001V01 other = (PatternERR_001V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
