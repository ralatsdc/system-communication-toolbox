/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern ENST802V01.
 */
public class PatternENST802V01 implements EarthPattern, TransmitPattern, ReceivePattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Near sidelobe reference level [dB] */
	private double CoefA;

	/** Near sidelobe roll-off level [dB] */
	private double CoefB;

	/** Far sidelobe reference level [dB] */
	private double CoefC;

	/** Far sidelobe roll-off level [dB] */
	private double CoefD;

	/** Angular extent of near sidelobe [degrees] */
	private double Phi1;

	/** Minimum antenna gain [dB] */
	private double Gmin;

	/* Intermediate gain calculation results */
	/* None */

	/**
	 * Constructs a PatternENST802V01 given a maximum antenna gain.
	 *
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 * @param CoefA
	 *            Near sidelobe reference level [dB]
	 * @param CoefB
	 *            Near sidelobe roll-off level [dB]
	 * @param CoefC
	 *            Far sidelobe reference level [dB]
	 * @param CoefD
	 *            Far sidelobe roll-off level [dB]
	 * @param Phi1
	 *            Angular extent of near sidelobe [degrees]
	 * @param Gmin
	 *            Minimum antenna gain [dB]
	 */
	public PatternENST802V01(double GainMax, double CoefA, double CoefB, double CoefC, double CoefD, double Phi1,
			double Gmin) {

		/* Validate input parameters */
		PatternUtility.validate_input("GainMax", GainMax);
		PatternUtility.validate_input("CoefA", CoefA);
		PatternUtility.validate_input("CoefB", CoefB);
		PatternUtility.validate_input("CoefC", CoefC);
		PatternUtility.validate_input("CoefD", CoefD);
		PatternUtility.validate_input("Phi1", Phi1);
		PatternUtility.validate_input("Gmin", Gmin);

		/* Assign properties */
		this.GainMax = GainMax;
		this.CoefA = CoefA;
		this.CoefB = CoefB;
		this.CoefC = CoefC;
		this.CoefD = CoefD;
		this.Phi1 = Phi1;
		this.Gmin = Gmin;

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
	 * Gets ear sidelobe reference level [dB].
	 * 
	 * @return Near sidelobe reference level [dB]
	 */
	public double getCoefA() {
		return CoefA;
	}

	/**
	 * Gets near sidelobe roll-off level [dB].
	 * 
	 * @return Near sidelobe roll-off level [dB]
	 */
	public double getCoefB() {
		return CoefB;
	}

	/**
	 * Gets far sidelobe reference level [dB].
	 * 
	 * @return Far sidelobe reference level [dB]
	 */
	public double getCoefC() {
		return CoefC;
	}

	/**
	 * Gets far sidelobe roll-off level [dB].
	 * 
	 * @return Far sidelobe roll-off level [dB]
	 */
	public double getCoefD() {
		return CoefD;
	}

	/**
	 * Gets angular extent of near sidelobe [degrees].
	 * 
	 * @return Angular extent of near sidelobe [degrees]
	 */
	public double getPhi1() {
		return Phi1;
	}

	/**
	 * Gets minimum antenna gain [dB].
	 * 
	 * @return Minimum antenna gain [dB]
	 */
	public double getGmin() {
		return Gmin;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	public PatternENST802V01 copy() {
		return new PatternENST802V01(this.GainMax, this.CoefA, this.CoefB, this.CoefC, this.CoefD, this.Phi1,
				this.Gmin);
	}

	/**
	 * Non-standard generic earth station antenna pattern described by 4 main
	 * coefficients: A, B, C, D and angle phi1. Minimum antenna gain (Gmin) must be
	 * provided.
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
		double G1 = CoefA - CoefB * Math.log10(phi);
		double G_phi1 = CoefA - CoefB * Math.log10(Phi1);
		double G2 = Math.max(Math.min(G_phi1, CoefC - CoefD * Math.log10(phi)), Gmin);

		double G = G0 * (0 <= phi && phi < 1 ? 1 : 0) + G1 * (1 <= phi && phi <= Phi1 ? 1 : 0)
				+ G2 * (Phi1 < phi && phi <= 180 ? 1 : 0);

		G = Math.min(GainMax, G);
		G = Math.max(Gmin, G);

		double Gx = G;

		/* Validate low level rules */
		if (Gmin < -100 || Gmin > GainMax) {
			throw new IllegalStateException("Gmin is out of limits [6020: STDC_ERR_GMIN]");
		}
		if (Phi1 < 1 || Phi1 > 99.9) {
			throw new IllegalStateException("Phi1 is out of limits [6018: STDC_ERR_NSTD_PHI1]");
		}
		if (CoefD < 10 || CoefD > 50) {
			throw new IllegalStateException("CoefD is out of limits [6017: STDC_ERR_COEFD]");
		}
		if (CoefC < 18 || CoefC > 47) {
			throw new IllegalStateException("CoefC is out of limits [6016: STDC_ERR_COEFC]");
		}
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
		temp = Double.doubleToLongBits(CoefC);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(CoefD);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(Phi1);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(Gmin);
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
		if (!(obj instanceof PatternENST802V01)) {
			return false;
		}
		PatternENST802V01 other = (PatternENST802V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(CoefA) != Double.doubleToLongBits(other.CoefA)) {
			return false;
		}
		if (Double.doubleToLongBits(CoefB) != Double.doubleToLongBits(other.CoefB)) {
			return false;
		}
		if (Double.doubleToLongBits(CoefC) != Double.doubleToLongBits(other.CoefC)) {
			return false;
		}
		if (Double.doubleToLongBits(CoefD) != Double.doubleToLongBits(other.CoefD)) {
			return false;
		}
		if (Double.doubleToLongBits(Phi1) != Double.doubleToLongBits(other.Phi1)) {
			return false;
		}
		if (Double.doubleToLongBits(Gmin) != Double.doubleToLongBits(other.Gmin)) {
			return false;
		}
		return true;
	}
}
