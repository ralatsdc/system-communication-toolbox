/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternELUX203V01 class.
 */
public class PatternELUX203V01Test {

	private static final double GainMax_input = 35.0;
	private static final double Diameter_input = 0.6;

	private static final double[] Phi_input = new double[] { 0.2, 0.8, 2, 3.4, 5.0, 10.0, 40.0, 150.0 };

	private static final double[] G_expected = new double[] { 34.930707979152366, 33.891327666437867,
			28.070797915236675, 15.374542108031763, 11.525749891599531, 4.0, -5.0, 0.0 };
	private static final double[] Gx_expected = new double[] { 13.0, 14.419899550304727, 18.0, 8.0, 8.0, 4.0, -5.0,
			0.0 };

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {

		PatternELUX203V01 p = new PatternELUX203V01(GainMax_input, Diameter_input);

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
