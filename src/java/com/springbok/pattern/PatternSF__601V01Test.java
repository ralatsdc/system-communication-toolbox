package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import junit.framework.Assert;

import java.util.HashMap;
import java.util.Map;

public class PatternSF__601V01Test {

	private static final double Phi0_input = 2;
	private static final double GainMax_input = 57;

	private static final double[] Phi_input = new double[] { 0.2, 1.5, 5, 150 };

	private static final double[] G_expected = new double[] { 56.880000000000003, 41.812500000000000,
			13.631706539125240, 0 };
	private static final double[] Gx_expected = new double[] { 27.000000000000000, 27.000000000000000,
			13.631706539125240, 0 };

	public void test_gain() {
		PatternSF__601V01 p = new PatternSF__601V01(Phi0_input);

		Gain[] gains = new Gain[Phi_input.length];
		Map<String, Object> options = new HashMap<String, Object>();
		options.put("GainMax", GainMax_input);
		options.put("DoValidate", false);
		for (int i = 0; i < gains.length; i++) {
			Gain g = p.gain(Phi_input[i], options);
			gains[i] = g;
		}

		for (int i = 0; i < gains.length; i++) {
			Assert.assertTrue(Math.abs(gains[i].G - this.G_expected[i]) < TestUtility.HIGH_PRECISION);
			Assert.assertTrue(Math.abs(gains[i].Gx - this.Gx_expected[i]) < TestUtility.HIGH_PRECISION);
		}
	}
}