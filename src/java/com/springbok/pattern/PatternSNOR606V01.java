package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.HashMap;
import java.util.Map;

public class PatternSNOR606V01 implements Pattern {
	private double GainMax;
	private double Phi0;

	public PatternSNOR606V01(double Phi0) {
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

		double G0 = this.GainMax;
		double G1 = this.GainMax + 6 - 12 * Math.pow(Math.sqrt(3) * phi_over_phi0, 2);
		double G2 = this.GainMax - 24;
		double G3 = this.GainMax - 11.5 - 25 * Math.log10(Math.sqrt(3) * phi_over_phi0);

		double G = G0 * (0 <= phi_over_phi0 & phi_over_phi0 <= 1 / Math.sqrt(6) ? 1 : 0)
				+ G1 * (1 / Math.sqrt(6) < phi_over_phi0 & phi_over_phi0 <= 1.58 / Math.sqrt(3) ? 1 : 0)
				+ G2 * (1.58 / Math.sqrt(3) < phi_over_phi0 & phi_over_phi0 <= 3.16 / Math.sqrt(3) ? 1 : 0)
				+ G3 * (3.16 / Math.sqrt(3) < phi_over_phi0 ? 1 : 0);

		double Gx = G;

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
	public Pattern copy() {
		return new PatternSNOR606V01(Phi0);
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
		if (!(obj instanceof PatternSNOR606V01)) {
			return false;
		}
		PatternSNOR606V01 other = (PatternSNOR606V01) obj;
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
