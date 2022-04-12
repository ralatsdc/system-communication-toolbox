package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.HashMap;
import java.util.Map;

public class PatternSND_499V01 implements Pattern {

	private double GainMax;

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

		// double eps = Math.ulp(1.0);
		// phi = Math.max(eps, phi);

		double G = GainMax;
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
		return new PatternSND_499V01();
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
		if (!(obj instanceof PatternSND_499V01)) {
			return false;
		}
		PatternSND_499V01 other = (PatternSND_499V01) obj;
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
