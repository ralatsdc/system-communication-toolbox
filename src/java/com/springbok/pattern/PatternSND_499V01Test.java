package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import junit.framework.Assert;

import java.util.HashMap;
import java.util.Map;

public class PatternSND_499V01Test {

	private static final double GainMax_input = 35;

	private static final double[] Phi_input = new double[] { 0.2, 2, 10, 150 };

	private static final double[] G_expected = new double[] { 35, 35, 35, 35, };
	private static final double[] Gx_expected = new double[] { 35, 35, 35, 35 };

	public void test_gain() {
		PatternSND_499V01 p = new PatternSND_499V01();

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
