/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern ERR_007V01.
 */
public class PatternERR_007V01 implements EarthPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Diameter of an earth antenna [m] */
	private double Diameter;

	/* Intermediate gain calculation results */
	private double lambda;
	private double d_over_lambda;
	private double G1;
	private double phi_m;
	private double phi_r;
	private double phi_b;

	/**
	 * Constructs a PatternERR_007V01 given an antenna maximum gain, and diameter.
	 *
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 * @param Diameter
	 *            Diameter of an earth antenna [m]
	 */
	public PatternERR_007V01(double GainMax, double Diameter) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);
		PatternUtility.validate_input("Diameter", Diameter);

		/* Assign properties */
		this.GainMax = GainMax;
		this.Diameter = Diameter;

		/* Compute derived properties */
		// TODO: Speed of light should be a referenced constant
		this.lambda = 299792458 / (12.1 * 1e9);
		this.d_over_lambda = this.Diameter / this.lambda;
		this.phi_r = 95.0 / this.d_over_lambda;
		this.G1 = 29.0 - 25.0 * Math.log10(this.phi_r);
		this.phi_m = 20.0 / this.d_over_lambda * Math.sqrt(this.GainMax - this.G1);
		this.phi_b = Math.pow(10, 34.0 / 25.0);
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
	 * Gets diameter of an earth antenna [m].
	 * 
	 * @return Diameter of an earth antenna [m]
	 */
	public double getDiameter() {
		return Diameter;
	}

	/**
	 * Gets wavelength of an earth antenna [m].
	 * 
	 * @return Wavelength of an earth antenna [m]
	 */
	public double getLambda() {
		return lambda;
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
	public PatternERR_007V01 copy() {
		return new PatternERR_007V01(this.GainMax, this.Diameter);
	}

	/**
	 * Appendix 30 (RR-2003) reference receiving earth station antenna pattern for
	 * Regions 1 and 3 (WRC-97).
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
		double G3 = -5.0;
		double G4 = 0.0;

		double G = G0 * (0 <= phi && phi < phi_m ? 1 : 0) + G1 * (phi_m <= phi && phi < phi_r ? 1 : 0)
				+ G2 * (phi_r <= phi && phi < phi_b ? 1 : 0) + G3 * (phi_b <= phi && phi < 70 ? 1 : 0)
				+ G4 * (70 <= phi && phi <= 180 ? 1 : 0);

		double Gx0 = GainMax - 25.0;

		double phi_0 = 2.0 / d_over_lambda * Math.sqrt(3 / 0.0025);
		double Gx1 = GainMax - 25.0 + 8.0 * (phi - 0.25 * phi_0) / (0.19 * phi_0);
		double Gx2 = GainMax - 17.0;

		double phi_1 = phi_0 / 2.0 * Math.sqrt(10.1875);
		double S = 21.0 - 25.0 * Math.log10(phi_1) - (GainMax - 17.0);
		double Gx3 = GainMax - 17.0 + S * Math.abs((phi - phi_0) / (phi_1 - phi_0));
		double Gx4 = 21.0 - 25.0 * Math.log10(phi);
		double Gx5 = -5.0;
		double Gx6 = 0.0;

		double phi_2 = Math.pow(10.0, 26.0 / 25.0);

		double Gx = Gx0 * (0.0 <= phi && phi < 0.25 * phi_0 ? 1 : 0)
				+ Gx1 * (0.25 * phi_0 <= phi && phi < 0.44 * phi_0 ? 1 : 0)
				+ Gx2 * (0.44 * phi_0 <= phi && phi < phi_0 ? 1 : 0) + Gx3 * (phi_0 <= phi && phi < phi_1 ? 1 : 0)
				+ Gx4 * (phi_1 <= phi && phi < phi_2 ? 1 : 0) + Gx5 * (phi_2 <= phi && phi < 70.0 ? 1 : 0)
				+ Gx6 * (70.0 <= phi && phi <= 180.0 ? 1 : 0);

		/* Validate low level rules */
		if (0 < S) {
			throw new IllegalStateException("0 is less than S [6031: STDC_ERR_0_LT_S]");
		}
		if (phi_r < phi_m) {
			throw new IllegalStateException("phi_r is less than phi_m [6009: STDC_ERR_PHIR_LT_PHIM]");
		}
		if (phi_2 < phi_1) {
			throw new IllegalStateException("Phi_2 is less than Phi_1 [6008: STDC_ERR_ANG2_LT_ANG1]");
		}
		if (GainMax < G1) {
			throw new IllegalStateException("GainMax is less than G1 [6001: STDC_ERR_GNAX_LT_G1]");
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
		temp = Double.doubleToLongBits(Diameter);
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
		if (!(obj instanceof PatternERR_007V01)) {
			return false;
		}
		PatternERR_007V01 other = (PatternERR_007V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(Diameter) != Double.doubleToLongBits(other.Diameter)) {
			return false;
		}
		return true;
	}
}
