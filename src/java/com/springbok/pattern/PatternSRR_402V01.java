package com.springbok.pattern;

import java.util.Collections;
import java.util.Map;

import com.springbok.utility.PatternUtility;

/**
 * 
 * Pattern SRR_402V01
 *
 */

public class PatternSRR_402V01 implements EarthPattern {

	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Beamlet for fast roll-off space antennas, degrees */
	private double Beamlet;

	/** Cross-sectional half-power beamwidth, degrees **/
	private double Phi0;

	public PatternSRR_402V01(double GainMax, double Beamlet, double Phi0) {

		this.GainMax = GainMax;

		// Check number and class of input arguments.
		PatternUtility.validate_input("Beamlet", Beamlet);
		this.Beamlet = Beamlet;

		// Check number and class of input arguments.
		PatternUtility.validate_input("Phi0", Phi0);
		this.Phi0 = Phi0;

	}

	public PatternSRR_402V01() {
	}

	public Gain gain(double phi) {
		return gain(phi, Collections.EMPTY_MAP);
	}

	public Gain gain(double phi, Map options) {
		// Check number and class of input arguments.
		PatternUtility.validate_input("Phi", phi);

		if (options == null) {
			options = Collections.EMPTY_MAP;
		}
		for (Object entry : options.entrySet()) {
			Map.Entry e = (Map.Entry) entry;
			Object key = e.getKey();
			Object value = e.getValue();
			// Validate key values
		}

		// Implement pattern. phi = max(eps, Phi)
		double eps = Math.ulp(1.0);
		phi = Math.max(eps, phi);

		double phi_over_phi0 = phi / this.Phi0;

		double G0 = this.GainMax - 12 * Math.pow(phi_over_phi0, 2);

		double x = 0.5 * (1 - this.Beamlet / this.Phi0);
		double phi_1 = 1.45 / this.Phi0 * this.Beamlet + x;
		double G1 = this.GainMax - 12 * Math.pow((phi_over_phi0 - x) / (this.Beamlet / this.Phi0), 2);

		double G2 = this.GainMax - 25.23;
		double G3 = this.GainMax - 22 - 20 * Math.log10(phi_over_phi0);

		double G = G0 * (0 <= phi_over_phi0 & phi_over_phi0 <= 0.5 ? 0 : 1)
				+ G1 * (0.5 < phi_over_phi0 & phi_over_phi0 <= phi_1 ? 0 : 1)
				+ G2 * (phi_1 < phi_over_phi0 & phi_over_phi0 <= 1.45 ? 0 : 1) + G3 * (1.45 < phi_over_phi0 ? 0 : 1);

		double Gx = Math.min(this.GainMax - 30, G);

		// Apply "flooring" for absolute gain pattern.
		G = Math.max(0, G);
		Gx = Math.max(0, Gx);

		// Validate low level rules.
		if (this.Phi0 < this.Beamlet)
			throw new IllegalArgumentException("Springbok:InvalidResult: Phi0 is less than Beamlet.");

		if (this.GainMax < 30)
			throw new IllegalArgumentException("Springbok:InvalidResult: GainMax is less than 30.");

		// Validate output parameters. if DoValidate
		PatternUtility.validate_output(G, Gx, this.GainMax);

		return new Gain(G, Gx);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.springbok.pattern.EarthPattern#copy()
	 */
	@Override
	public EarthPattern copy() {
		return new PatternSRR_402V01(GainMax, Beamlet, Phi0);
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
		temp = Double.doubleToLongBits(Beamlet);
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
		if (!(obj instanceof PatternSRR_402V01)) {
			return false;
		}
		PatternSRR_402V01 other = (PatternSRR_402V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(Beamlet) != Double.doubleToLongBits(other.Beamlet)) {
			return false;
		}
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		return true;
	}

}
