/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternENOR208V01 class.
 */
public class PatternENOR208V01Test {
	private static final double GainMax_input_1 = 57;
	private static final double Phi0_input = 2;
	private static final double[] Phi_input = new double[] { 0.2, 1.0, 10.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 57.0, 54.0, 27.025749891599531, 15.0 };
	private static final double[] Gx_expected_1 = new double[] { 57.0, 54.0, 27.025749891599531, 15.0 };
	private static final double GainMax_input_2 = 47;
	private static final double[] G_expected_2 = new double[] { 47.0, 44.0, 17.025749891599531, 5.0 };
	private static final double[] Gx_expected_2 = new double[] { 47.0, 44.0, 17.025749891599531, 5.0 };

	/**
	 * Tests PatternENOR208V01 method.
	 */
	@Test
	public void test_PatternENOR208V01() {
		PatternENOR208V01 p_1 = new PatternENOR208V01(GainMax_input_1, Phi0_input);

		assertTrue(TestUtility.isDoublesEquals(57, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(2, p_1.getPhi0()));

		PatternENOR208V01 p_2 = new PatternENOR208V01(GainMax_input_2, Phi0_input);

		assertTrue(TestUtility.isDoublesEquals(47, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(2, p_2.getPhi0()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternENOR208V01 p_1 = new PatternENOR208V01(GainMax_input_1, Phi0_input);

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

		PatternENOR208V01 p_2 = new PatternENOR208V01(GainMax_input_2, Phi0_input);

		gains = new Gain[Phi_input.length];
		options.put("DoValidate", false);

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