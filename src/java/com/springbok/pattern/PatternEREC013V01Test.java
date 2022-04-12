/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternEREC013V01 class.
 */
public class PatternEREC013V01Test {
	private static final double GainMax_input_1 = 54.4;
	private static final double Efficiency_input = 0.7;

	private static final double GainMax_input_2 = 34.4;

	private static final double[] Phi_input = new double[] { 0.2, 0.6, 10.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 50.413404110801082, 32.0, 7.0, -10.0 };
	private static final double[] Gx_expected_1 = new double[] { 50.413404110801082, 32.0, 7.0, -10.0 };
	private static final double[] G_expected_2 = new double[] { 34.360134041108012, 34.041206369972095, 7.0, -10.0 };
	private static final double[] Gx_expected_2 = new double[] { 34.360134041108012, 34.041206369972095, 7.0, -10.0 };

	/**
	 * Tests PatternEREC013V01 method.
	 */
	@Test
	public void test_PatternEREC013V01() {
		PatternEREC013V01 p_1 = new PatternEREC013V01(GainMax_input_1, Efficiency_input);

		assertTrue(TestUtility.isDoublesEquals(54.4, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.7, p_1.getEfficiency()));
		assertTrue(TestUtility.isDoublesEquals(0.474081379137515, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(1.0, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(47.863009232263828, p_1.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(199.664616023944350, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(32.0, p_1.getG1()));

		PatternEREC013V01 p_2 = new PatternEREC013V01(GainMax_input_2, Efficiency_input);

		assertTrue(TestUtility.isDoublesEquals(34.4, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.7, p_2.getEfficiency()));
		assertTrue(TestUtility.isDoublesEquals(4.467589582160365, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(5.008398683320418, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(47.863009232263828, p_2.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(19.966461602394443, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(14.507527682468442, p_2.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternEREC013V01 p_1 = new PatternEREC013V01(GainMax_input_1, Efficiency_input);

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

		PatternEREC013V01 p_2 = new PatternEREC013V01(GainMax_input_2, Efficiency_input);

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
