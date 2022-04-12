/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternENST804V01 class.
 */
public class PatternENST804V01Test {
	private static final double GainMax_input_1 = 38.0;
	private static final double CoefA_input_1 = 35.0;
	private static final double CoefB_input_1 = 24.0;

	private static final double GainMax_input_2 = 30.0;
	private static final double CoefA_input_2 = 33.0;
	private static final double CoefB_input_2 = 26.0;

	private static final double[] Phi_input = new double[] { 0.2, 4.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 38.0, 20.550560208128907, -10.0 };
	private static final double[] Gx_expected_1 = new double[] { 38.0, 20.550560208128907, -10.0 };
	private static final double[] G_expected_2 = new double[] { 30.0, 17.346440225472982, -10.0 };
	private static final double[] Gx_expected_2 = new double[] { 30.0, 17.346440225472982, -10.0 };

	/**
	 * Tests PatternENST804V01 method.
	 */
	@Test
	public void test_PatternENST804V01() {
		PatternENST804V01 p_1 = new PatternENST804V01(GainMax_input_1, CoefA_input_1, CoefB_input_1);

		assertTrue(TestUtility.isDoublesEquals(38.0, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(35.0, p_1.getCoefA()));
		assertTrue(TestUtility.isDoublesEquals(24.0, p_1.getCoefB()));
		assertTrue(TestUtility.isDoublesEquals(1.0, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(74.990, p_1.getPhi_b()));

		PatternENST804V01 p_2 = new PatternENST804V01(GainMax_input_2, CoefA_input_2, CoefB_input_2);

		assertTrue(TestUtility.isDoublesEquals(30.0, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(33.0, p_2.getCoefA()));
		assertTrue(TestUtility.isDoublesEquals(26.0, p_2.getCoefB()));
		assertTrue(TestUtility.isDoublesEquals(1.0, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(45.066, p_2.getPhi_b()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternENST804V01 p_1 = new PatternENST804V01(GainMax_input_1, CoefA_input_1, CoefB_input_1);

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

		PatternENST804V01 p_2 = new PatternENST804V01(GainMax_input_2, CoefA_input_2, CoefB_input_2);
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
