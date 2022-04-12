/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternENOR209V01 class.
 */
public class PatternENOR209V01Test {
	private static final double[] Phi_input = new double[] { 0.2, 0.7, 10.0, 150.0 };
	private static final double[] G_expected = new double[] { 49.008000000000003, 30.699999999999999, 4.0, -10.0 };
	private static final double[] Gx_expected = new double[] { 49.008000000000003, 30.699999999999999, 4.0, -10.0 };

	/**
	 * Tests PatternENOR209V01 method.
	 */
	@Test
	public void test_PatternENOR209V01() {
		PatternENOR209V01 p = new PatternENOR209V01();

		assertTrue(TestUtility.isDoublesEquals(50.7, p.getGainMax()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternENOR209V01 p = new PatternENOR209V01();

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
