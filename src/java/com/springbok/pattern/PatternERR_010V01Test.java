/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;

import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternERR_010V01 class.
 */
public class PatternERR_010V01Test {
	private static final double GainMax_input = 57.0;
	private static final double[] Phi_input = new double[] { 0.08, 0.2, 0.4, 10.0, 150.0 };
	private static final double[] G_expected = new double[] { 57.0, 49.979400086720375, 42.787999999999997, 4.0,
			-10.0 };
	private static final double[] Gx_expected = new double[] { 22.0, 22.0, 22.0, 4.0, -10.0 };

	/**
	 * Tests PatternERR_010V01 method.
	 */
	@Test
	public void test_PatternERR_010V01() {
		PatternERR_010V01 p = new PatternERR_010V01(this.GainMax_input);

		assertTrue(TestUtility.isDoublesEquals(57, p.getGainMax()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternERR_010V01 p = new PatternERR_010V01(GainMax_input);

		Gain[] gains = new Gain[Phi_input.length];
		Map<String, Object> options = new HashMap<String, Object>();
		options.put("DoValidate", false);

		for (int i = 0; i < gains.length; i++) {
			Gain g = p.gain(Phi_input[i], options);
			gains[i] = g;
		}
		for (int i = 0; i < gains.length; i++) {
			assertTrue(TestUtility.isDoublesEquals(G_expected[i], gains[i].G));
			assertTrue(TestUtility.isDoublesEquals(Gx_expected[i], gains[i].Gx));
		}
	}
}
