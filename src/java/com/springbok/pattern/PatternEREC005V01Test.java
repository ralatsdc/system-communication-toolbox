/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternEREC005V01 class.
 */
public class PatternEREC005V01Test {
	private static final double GainMax_input_1 = 24.6;
	private static final double GainMax_input_2 = 19.7;
	private static final double[] Phi_input = new double[] { 0.2, 10.0, 20.0, 40.0, 150.0 };

	private static final double[] G_expected_1 = new double[] { 24.595102211806317, 14.674999999999999,
			11.024250108400466, 3.498500216800935, 0.0 };
	private static final double[] Gx_expected_1 = new double[] { 24.595102211806317, 14.674999999999999,
			11.024250108400466, 3.498500216800935, 0.0 };
	private static final double[] G_expected_2 = new double[] { 19.698415106807538, 15.737767018847217,
			11.0, 5.948500216800937, 0.0 };
	private static final double[] Gx_expected_2 = new double[] { 19.698415106807538, 15.737767018847217,
			11.0, 5.948500216800937, 0.0 };

	/**
	 * Tests PatternEREC005V01 method.
	 */
	@Test
	public void test_PatternEREC005V01() {
		PatternEREC005V01 p_1 = new PatternEREC005V01(GainMax_input_1);

		assertTrue(TestUtility.isDoublesEquals(24.6, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(9.003165910021892, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(14.288939585111025, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(55.103761540424230, p_1.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(6.998419960022736, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(14.674999999999999, p_1.getG1()));

		PatternEREC005V01 p_2 = new PatternEREC005V01(GainMax_input_2);

		assertTrue(TestUtility.isDoublesEquals(19.7, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(14.818001075688557, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(25.118864315095802, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(69.052792480458834, p_2.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(3.981071705534972, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(11.0, p_2.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternEREC005V01 p_1 = new PatternEREC005V01(GainMax_input_1);

		Gain[] gains = new Gain[Phi_input.length];
		Map<String, Object> options = new HashMap<String, Object>();
		options.put("DoValidate", false);

		for (int i = 0; i < gains.length; i++) {
			Gain g = p_1.gain(Phi_input[i], options);
			gains[i] = g;
		}
		for (int i = 0; i < gains.length; i++) {
			assertTrue(TestUtility.isDoublesEquals(G_expected_1[i], gains[i].G));
			assertTrue(TestUtility.isDoublesEquals(Gx_expected_1[i], gains[i].Gx));
		}

		PatternEREC005V01 p_2 = new PatternEREC005V01(GainMax_input_2);

		gains = new Gain[Phi_input.length];

		for (int i = 0; i < gains.length; i++) {
			Gain g = p_2.gain(Phi_input[i], options);
			gains[i] = g;
		}
		for (int i = 0; i < gains.length; i++) {
			assertTrue(TestUtility.isDoublesEquals(G_expected_2[i], gains[i].G));
			assertTrue(TestUtility.isDoublesEquals(Gx_expected_2[i], gains[i].Gx));
		}
	}
}
