/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternEREC014V01 class.
 */
public class PatternEREC014V01Test {
	private static final double GainMax_input_1 = 54.4;
	private static final double Efficiency_input = 0.7;

	private static final double GainMax_input_2 = 44.0;

	private static final double[] Phi_input = new double[] { 0.2, 0.6, 1.5, 10.0, 22.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 50.413404110801082, 33.504516609481058,
			24.597718523607970, 4.0, -3.5, -10.0 };
	private static final double[] Gx_expected_1 = new double[] { 50.413404110801082, 33.504516609481058,
			24.597718523607970, 4.0, -3.5, -10.0 };
	private static final double[] G_expected_2 = new double[] { 43.636418133691890, 40.727763203226985,
			26.507527682468449, 7.0, -1.560567020555155, -10.0 };
	private static final double[] Gx_expected_2 = new double[] { 43.636418133691890, 40.727763203226985,
			26.507527682468449, 7.0, -1.560567020555155, -10.0 };

	/**
	 * Tests PatternEREC014V01 method.
	 */
	@Test
	public void test_PatternEREC014V01() {
		PatternEREC014V01 p_1 = new PatternEREC014V01(GainMax_input_1, Efficiency_input);

		assertTrue(TestUtility.isDoublesEquals(54.4, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.7, p_1.getEfficiency()));
		assertTrue(TestUtility.isDoublesEquals(0.457883611484118, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(0.660463166200195, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(47.863009232263828, p_1.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(199.664616023944350, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(33.504516609481058, p_1.getG1()));

		PatternEREC014V01 p_2 = new PatternEREC014V01(GainMax_input_2, Efficiency_input);

		assertTrue(TestUtility.isDoublesEquals(44, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.7, p_2.getEfficiency()));
		assertTrue(TestUtility.isDoublesEquals(1.387249209510213, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(1.658436672839821, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(47.863009232263828, p_2.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(60.297750066491929, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(26.507527682468449, p_2.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternEREC014V01 p_1 = new PatternEREC014V01(GainMax_input_1, Efficiency_input);

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

		PatternEREC014V01 p_2 = new PatternEREC014V01(GainMax_input_2, Efficiency_input);

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
