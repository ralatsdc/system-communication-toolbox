package com.springbok.pattern;

import com.springbok.utility.TestUtility;

import junit.framework.Assert;

public class PatternSREC408V01Test {

	private static final double Phi0_input = 4.0;

	private static final double GainMax_input = 40;

	private static final PatternSREC408V01 pattern = new PatternSREC408V01(GainMax_input, Phi0_input);

	private static final double[] Phi_input = new double[] { 0.2, 2, 10, 150 };

	private static final double[] G_expected = new double[] { 39.969999999999999, 37.000000000000000,
			20.000000000000000, 0 };

	private static final double[] Gx_expected = new double[] { 39.969999999999999, 37.000000000000000,
			20.000000000000000, 0 };

	@SuppressWarnings("static-access")
	public void test_gain() {

		Gain[] gains = new Gain[Phi_input.length];
		for (int i = 0; i < gains.length; i++) {
			Gain g = this.pattern.gain(this.Phi_input[i]);
			gains[i] = g;
		}

		for (int i = 0; i < gains.length; i++) {

			Assert.assertTrue(Math.abs(gains[i].G - this.G_expected[i]) < TestUtility.HIGH_PRECISION);
			Assert.assertTrue(Math.abs(gains[i].Gx - this.Gx_expected[i]) < TestUtility.HIGH_PRECISION);
		}

	}
}
