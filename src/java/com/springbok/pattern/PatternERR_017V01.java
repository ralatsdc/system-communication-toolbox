/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern ERR_017V01.
 */
public class PatternERR_017V01 implements EarthPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Diameter of an earth antenna [m] */
	private double Diameter;

	/** Frequency for which a gain is calculated [MHz] */
	private double Frequency;

	/* Intermediate gain calculation results */
	private double lambda;
	private double d_over_lambda;
	private double G1;
	private double phi_m;
	private double phi_r;

	/**
	 * Constructs a PatternERR_017V01 given a maximum antenna gain.
	 *
	 * @param GainMax Maximum antenna gain [dB]
	 * @param Diameter Diameter of an earth antenna [m]
	 * @param Frequency Frequency for which a gain is calculated [MHz]
	 */
	public PatternERR_017V01(double GainMax, double Diameter, double Frequency) {
	
		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);
		PatternUtility.validate_input("Diameter", Diameter);
		PatternUtility.validate_input("Frequency", Frequency);

		/* Assign properties */
		this.GainMax = GainMax;
		this.Diameter = Diameter;
		this.Frequency = Frequency;

		/* Compute derived properties */
		this.lambda = 299792458 / (this.Frequency * 1e6);
		this.d_over_lambda = this.Diameter / this.lambda;
		this.phi_r = 95 / this.d_over_lambda;
		this.G1 = 29 - 25 * Math.log10(this.phi_r);
		this.phi_m = 20 / this.d_over_lambda * Math.sqrt(this.GainMax - this.G1);
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
	 * Gets frequency for which a gain is calculated [MHz].
	 * 
	 * @return Frequency for which a gain is calculated [MHz]
	 */
	public double getFrequency() {
		return Frequency;
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

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	public PatternERR_017V01 copy() {
		return new PatternERR_017V01(this.GainMax, this.Diameter, this.Frequency);
	}

	/**
	 * Appendix 30 (RR-2003) reference receiving earth station antenna pattern for
	 * Regions 1, 2 and 3 for digital BSS assignments.
	 *
	 * @param Phi Angle for which a gain is calculated [degrees]
	 * @param options Optional parameters (entered as key/value pairs)
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
		double G2 = Math.max(29.0 - 25.0 * Math.log10(phi), 0);

		double G = G0 * (0 <= phi && phi < phi_m ? 1 : 0)
				+ G1 * (phi_m <= phi && phi < phi_r ? 1 : 0)
				+ G2 * (phi_r <= phi && phi <= 180 ? 1 : 0);

		double Gx = G;

		/* Validate low level rules */
		if (phi_r < phi_m) {
			throw new IllegalStateException("phi_r is less than phi_m [6009: STDC_ERR_PHIR_LT_PHIM]");
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
		temp = Double.doubleToLongBits(Diameter);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(Frequency);
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
		if (!(obj instanceof PatternERR_017V01)) {
			return false;
		}
		PatternERR_017V01 other = (PatternERR_017V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(Diameter) != Double.doubleToLongBits(other.Diameter)) {
			return false;
		}
		if (Double.doubleToLongBits(Frequency) != Double.doubleToLongBits(other.Frequency)) {
			return false;
		}
		return true;
	}
}
