package com.springbok.pattern;

import com.springbok.utility.TestUtility;

import junit.framework.Assert;

public class PatternSRR_401V01Test {

	private static final double Phi0_input = 2;

	private static final double GainMax_input = 57;

	private static final PatternSRR_401V01 pattern = new PatternSRR_401V01(GainMax_input, Phi0_input);

	private static final double[] Phi_input = new double[] { 0.2, 0.5, 5, 150 };

	private static final double[] G_expected = new double[] { 56.880000000000003, 56.250000000000000,
			27.041199826559250, 0 };

	private static final double[] Gx_expected = new double[] { 27.000000000000000, 27.000000000000000,
			27.000000000000000, 0 };

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
