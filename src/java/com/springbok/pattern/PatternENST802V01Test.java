/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternENST802V01 class.
 */
public class PatternENST802V01Test {
	private static final double GainMax_input_1 = 35.0;
	private static final double CoefA_input_1 = 29.0;
	private static final double CoefB_input_1 = 25.0;
	private static final double CoefC_input_1 = 27.0;
	private static final double CoefD_input_1 = 28.0;
	private static final double Phi1_input_1 = 10.0;
	private static final double Gmin_input_1 = -10.0;

	private static final double GainMax_input_2 = 25.0;
	private static final double CoefA_input_2 = 32.0;
	private static final double CoefB_input_2 = 25.0;
	private static final double CoefC_input_2 = 30.0;
	private static final double CoefD_input_2 = 20.0;
	private static final double Phi1_input_2 = 10.0;
	private static final double Gmin_input_2 = -10.0;

	private static final double[] Phi_input = new double[] { 0.2, 4.0, 12.0, 40.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 35.0, 13.948500216800943, -3.217074889333489, -10.0,
			-10.0 };
	private static final double[] Gx_expected_1 = new double[] { 35.0, 13.948500216800943, -3.217074889333489, -10.0,
			-10.0 };
	private static final double[] G_expected_2 = new double[] { 25.0, 16.948500216800944, 7.0, -2.041199826559250,
			-10.0 };
	private static final double[] Gx_expected_2 = new double[] { 25.0, 16.948500216800944, 7.0, -2.041199826559250,
			-10.0 };

	/**
	 * Tests PatternENST802V01 method.
	 */
	@Test
	public void test_PatternENST802V01() {
		PatternENST802V01 p_1 = new PatternENST802V01(GainMax_input_1, CoefA_input_1, CoefB_input_1, CoefC_input_1,
				CoefD_input_1, Phi1_input_1, Gmin_input_1);

		assertTrue(TestUtility.isDoublesEquals(35, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(29, p_1.getCoefA()));
		assertTrue(TestUtility.isDoublesEquals(25, p_1.getCoefB()));
		assertTrue(TestUtility.isDoublesEquals(27, p_1.getCoefC()));
		assertTrue(TestUtility.isDoublesEquals(28, p_1.getCoefD()));
		assertTrue(TestUtility.isDoublesEquals(10, p_1.getPhi1()));
		assertTrue(TestUtility.isDoublesEquals(-10, p_1.getGmin()));

		PatternENST802V01 p_2 = new PatternENST802V01(GainMax_input_2, CoefA_input_2, CoefB_input_2, CoefC_input_2,
				CoefD_input_2, Phi1_input_2, Gmin_input_2);

		assertTrue(TestUtility.isDoublesEquals(25, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(32, p_2.getCoefA()));
		assertTrue(TestUtility.isDoublesEquals(25, p_2.getCoefB()));
		assertTrue(TestUtility.isDoublesEquals(30, p_2.getCoefC()));
		assertTrue(TestUtility.isDoublesEquals(20, p_2.getCoefD()));
		assertTrue(TestUtility.isDoublesEquals(10, p_2.getPhi1()));
		assertTrue(TestUtility.isDoublesEquals(-10, p_2.getGmin()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternENST802V01 p_1 = new PatternENST802V01(GainMax_input_1, CoefA_input_1, CoefB_input_1, CoefC_input_1,
				CoefD_input_1, Phi1_input_1, Gmin_input_1);

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

		PatternENST802V01 p_2 = new PatternENST802V01(GainMax_input_2, CoefA_input_2, CoefB_input_2, CoefC_input_2,
				CoefD_input_2, Phi1_input_2, Gmin_input_2);

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
