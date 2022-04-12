/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternENOR207V01 class.
 */
public class PatternENOR207V01Test {
	private static final double[] Phi_input = new double[] { 0.2, 4.0, 150.0 };
	private static final double[] G_expected = new double[] { 49.008000000000003, 13.948500216800943, -10.0 };
	private static final double[] Gx_expected = new double[] { 49.008000000000003, 13.948500216800943, -10.0 };

	/**
	 * Tests PatternENOR207V01 method.
	 */
	@Test
	public void test_PatternENOR207V01() {
		PatternENOR207V01 p = new PatternENOR207V01();

		assertTrue(TestUtility.isDoublesEquals(50.7, p.getGainMax()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternENOR207V01 p = new PatternENOR207V01();

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