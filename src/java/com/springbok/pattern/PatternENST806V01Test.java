/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternENST806V01 class.
 */
public class PatternENST806V01Test {
	private static final double GainMax_input_1 = 54.4;
	private static final double Efficiency_input = 0.7;
	private static final double CoefA_input = 35.0;

	private static final double GainMax_input_2 = 34.4;

	private static final double[] Phi_input = new double[] { 0.2, 0.7, 4.5, 20.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 50.413404110801082, 35.0, 18.669687155616412,
			2.474250108400469, -10.0 };
	private static final double[] Gx_expected_1 = new double[] { 50.413404110801082, 35.0, 18.669687155616412,
			2.474250108400469, -10.0 };
	private static final double[] G_expected_2 = new double[] { 34.360134041108012, 33.911642003573128,
			17.507527682468442, 2.474250108400469, -10.0 };
	private static final double[] Gx_expected_2 = new double[] { 34.360134041108012, 33.911642003573128,
			17.507527682468442, 2.474250108400469, -10.0 };

	/**
	 * Tests PatternENST806V01 method.
	 */
	@Test
	public void test_PatternENST806V01() {
		PatternENST806V01 p_1 = new PatternENST806V01(GainMax_input_1, Efficiency_input, CoefA_input);

		assertTrue(TestUtility.isDoublesEquals(54.4, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.7, p_1.getEfficiency()));
		assertTrue(TestUtility.isDoublesEquals(35, p_1.getCoefA()));
		assertTrue(TestUtility.isDoublesEquals(0.441194158165796, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(1.0, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(63.095734448019329, p_1.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(199.664616023944350, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(35.0, p_1.getG1()));

		PatternENST806V01 p_2 = new PatternENST806V01(GainMax_input_2, Efficiency_input, CoefA_input);

		assertTrue(TestUtility.isDoublesEquals(34.4, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.7, p_2.getEfficiency()));
		assertTrue(TestUtility.isDoublesEquals(35, p_2.getCoefA()));
		assertTrue(TestUtility.isDoublesEquals(4.116949087625147, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(5.008398683320418, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(63.095734448019329, p_2.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(19.966461602394443, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(17.507527682468442, p_2.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternENST806V01 p_1 = new PatternENST806V01(GainMax_input_1, Efficiency_input, CoefA_input);

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

		PatternENST806V01 p_2 = new PatternENST806V01(GainMax_input_2, Efficiency_input, CoefA_input);

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
