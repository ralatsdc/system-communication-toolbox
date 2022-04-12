/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternERR_001V01 class.
 */
public class PatternERR_001V01Test {
	private static final double GainMax_input_1 = 53.7;

	private static final double GainMax_input_2 = 33.7;

	private static final double[] Phi_input = new double[] { 0.2, 0.5, 4.5, 150.0 };
	private static final double[] G_expected_1 = new double[] { 49.718928294465030, 36.5, 15.669687155616412, -10.0 };
	private static final double[] Gx_expected_1 = new double[] { 49.718928294465030, 36.5, 15.669687155616412, -10.0 };
	private static final double[] G_expected_2 = new double[] { 33.660189282944650, 33.451183018404066, 21.5, -3.0 };
	private static final double[] Gx_expected_2 = new double[] { 33.660189282944650, 33.451183018404066, 21.5, -3.0 };

	/**
	 * Tests PatternERR_001V01 method.
	 */
	@Test
	public void test_PatternERR_001V01() {
		PatternERR_001V01 p_1 = new PatternERR_001V01(GainMax_input_1);

		assertTrue(TestUtility.isDoublesEquals(53.7, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.415713587085940, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(0.660737972800482, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(48.0, p_1.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(199.526231496887870, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(36.5, p_1.getG1()));

		PatternERR_001V01 p_2 = new PatternERR_001V01(GainMax_input_2);

		assertTrue(TestUtility.isDoublesEquals(33.7, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(3.501143496883088, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(5.011872336272720, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(48.0, p_2.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(19.952623149688808, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(21.5, p_2.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternERR_001V01 p_1 = new PatternERR_001V01(GainMax_input_1);

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

		PatternERR_001V01 p_2 = new PatternERR_001V01(GainMax_input_2);

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
