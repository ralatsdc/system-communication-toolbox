package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.HashMap;
import java.util.Map;

public class PatternSNOR605V01 implements Pattern {
	private double GainMax;
	private double Phi0;

	public PatternSNOR605V01(double GainMax, double Phi0) {
		PatternUtility.validate_input("Phi0", Phi0);
		PatternUtility.validate_input("GainMax", GainMax);
		this.Phi0 = Phi0;
		this.GainMax = GainMax;
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

		boolean DoValidate = true;
		if (input.containsKey("DoValidate")) {
			DoValidate = (boolean) input.get("DoValidate");
		}

		double eps = Math.ulp(1.0);
		phi = Math.max(eps, phi);

		double phi_over_phi0 = phi / this.Phi0;

		double G0 = this.GainMax - 12 * Math.pow(phi_over_phi0, 2);
		double G1 = this.GainMax - 30;
		double G2 = this.GainMax - 17.5 - 25 * Math.log10(phi_over_phi0);

		double G = G0 * (0 <= phi_over_phi0 & phi_over_phi0 <= 1.58 ? 1 : 0)
				+ G1 * (1.58 < phi_over_phi0 & phi_over_phi0 <= 3.16 ? 1 : 0) + G2 * (3.16 < phi_over_phi0 ? 1 : 0);

		G = Math.min(35, G);

		double Gx = G;

		G = Math.max(0, G);
		Gx = Math.max(0, Gx);

		if (DoValidate) {
			PatternUtility.validate_output(G, Gx, GainMax);
		}

		return new Gain(G, Gx);
	}

	@Override
	public Pattern copy() {
		return new PatternSNOR605V01(GainMax, Phi0);
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
		if (!(obj instanceof PatternSNOR605V01)) {
			return false;
		}
		PatternSNOR605V01 other = (PatternSNOR605V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		return true;
	}
}
