package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class PatternSF__601V01 implements SpacePattern {

	private double GainMax;
	private double Phi0;

	public PatternSF__601V01(double Phi0) {
		PatternUtility.validate_input("Phi0", Phi0);
		this.Phi0 = Phi0;
	}

	public Gain gain(double phi, Map options) {
		PatternUtility.validate_input("Phi", phi);
		Map<String, Object> input = new HashMap<>();
		for (Object entry : options.entrySet()) {
			Map.Entry e = (Map.Entry) entry;
			Object key = e.getKey();
			String strKey;
			if (key instanceof String) {
				strKey = (String) key;
			} else {
				throw new IllegalArgumentException("Options keys must be String");
			}
			Object value = e.getValue();
			input = PatternUtility.validate_input(strKey, value, input);
		}

		boolean absolute_pattern;
		boolean DoValidate = true;
		if (input.containsKey("GainMax")) {
			this.GainMax = (Double) input.get("GainMax");
			absolute_pattern = true;
		} else {
			this.GainMax = 0;
			absolute_pattern = false;
		}
		if (input.containsKey("DoValidate")) {
			DoValidate = (boolean) input.get("DoValidate");
		}

		double eps = Math.ulp(1.0);
		phi = Math.max(eps, phi);

		double phi_over_phi0 = phi / this.Phi0;
		double Beamlet = 0.8;

		double G0 = this.GainMax - 12 * Math.pow(phi_over_phi0, 2);

		double x = 0.5 * (1 - Beamlet / this.Phi0);
		double phi1 = 1.45 / this.Phi0 * Beamlet + x;
		double G1 = this.GainMax - 12 * Math.pow((phi_over_phi0 - x) / (Beamlet / this.Phi0), 2);

		double G2 = this.GainMax - 25.23 + 40 * Math.log10(phi1) - 40 * Math.log10(phi_over_phi0);

		double G = G0 * (0 <= phi_over_phi0 & phi_over_phi0 <= 0.5 ? 1 : 0)
				+ G1 * (0.5 < phi_over_phi0 & phi_over_phi0 <= phi1 ? 1 : 0) + G2 * (phi1 < phi_over_phi0 ? 1 : 0);

		double Gx = Math.min(this.GainMax - 30, G);

		if (absolute_pattern) {
			G = Math.max(0, G);
			Gx = Math.max(0, Gx);
		}

		if (DoValidate) {
			PatternUtility.validate_output(G, Gx, GainMax);
		}

		return new Gain(G, Gx);
	}

	@Override
	public SpacePattern copy() {
		return new PatternSF__601V01(Phi0);
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
		if (!(obj instanceof PatternSF__601V01)) {
			return false;
		}
		PatternSF__601V01 other = (PatternSF__601V01) obj;
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
