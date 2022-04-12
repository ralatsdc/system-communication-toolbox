/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import org.junit.Assert;
import org.junit.Test;

import com.springbok.utility.TestUtility;

/**
 * Tests methods of PatternELUX201V01 class.
 *
 */
public class PatternELUX201V01Test {

	private static final double GainMax_input = 57.0;

	private static final double[] Phi_input = new double[] { 0.2, 0.4, 10.0, 150.0 };

	private static final double[] G_expected = new double[] { 48.675264961058339, 35.902778147007240, 4.0, -10.0, };
	private static final double[] Gx_expected = new double[] { 27.0, 27.0, 4.0, -10.0 };

	// TODO: Test PatternELUX201V01 method

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {

		PatternELUX201V01 p = new PatternELUX201V01(GainMax_input);

		Gain[] gains = new Gain[Phi_input.length];
		for (int i = 0; i < gains.length; i++) {
			Gain g = p.gain(Phi_input[i]);
			gains[i] = g;
		}

		for (int i = 0; i < gains.length; i++) {
			Assert.assertTrue(Math.abs(gains[i].G - G_expected[i]) < TestUtility.HIGH_PRECISION);
			Assert.assertTrue(Math.abs(gains[i].Gx - Gx_expected[i]) < TestUtility.HIGH_PRECISION);
		}
	}
}
