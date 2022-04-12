package com.springbok.pattern;

import java.util.Collections;
import java.util.Map;

import com.springbok.utility.PatternUtility;

public class PatternSRR_401V01 implements EarthPattern {
	/** Maximum antenna gain [dB] */
	private double GainMax;

	/** Cross-sectional half-power beamwidth, degrees **/
	private double Phi0;

	public PatternSRR_401V01(double GainMax, double Phi0) {

		this.GainMax = GainMax;

		// Check number and class of input arguments.
		PatternUtility.validate_input("Phi0", Phi0);
		this.Phi0 = Phi0;

	}

	public PatternSRR_401V01() {
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
		double G1 = this.GainMax - 22 - 20 * Math.log10(phi_over_phi0);

		double G = G0 * (0 <= phi_over_phi0 & phi_over_phi0 <= 1.45 ? 1 : 0) + G1 * (1.45 < phi_over_phi0 ? 1 : 0);

		double Gx = Math.min(this.GainMax - 30, G);

		// Apply "flooring" for absolute gain pattern.
		G = Math.max(0, G);
		Gx = Math.max(0, Gx);

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
		return new PatternSRR_401V01(GainMax, Phi0);
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
		if (!(obj instanceof PatternSRR_401V01)) {
			return false;
		}
		PatternSRR_401V01 other = (PatternSRR_401V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		return true;
	}

}
