/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternELUX203V01 class.
 */
public class PatternELUX204V01Test {

	private static final double GainMax_input_1 = 59;
	private static final double Efficiency_input = 0.7;

	private static final double GainMax_input_2 = 49;

	private static final double[] Phi_input = new double[] { 0.2, 0.4, 0.9, 10.0, 30.0, 150.0 };

	private static final double[] G_expected_1 = new double[] { 47.502531865315291, 36.954516609481075,
			30.143937264016877, 4.0, -4.928031367991565, -10.0 };
	private static final double[] Gx_expected_1 = new double[] { 47.502531865315291, 36.954516609481075,
			30.143937264016877, 4.0, -4.928031367991565, -10.0 };

	private static final double[] G_expected_2 = new double[] { 47.850253186531532, 44.401012746126113,
			29.454516609481065, 4.0, -4.928031367991565, -10.0 };
	private static final double[] Gx_expected_2 = new double[] { 47.850253186531532, 44.401012746126113,
			29.454516609481065, 4.0, -4.928031367991565, -10.0 };

	/**
	 * Tests PatternELUX204V01 method.
	 */
	@Test
	public void test_PatternELUX204V01() {
		PatternELUX204V01 p = new PatternELUX204V01(GainMax_input_1, Efficiency_input);

		assertTrue(TestUtility.isDoublesEquals(0.276941921655738, p.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(0.480671754000950, p.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(48.0, p.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(339.079166783875280, p.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(36.954516609481075, p.getG1()));

		p = new PatternELUX204V01(GainMax_input_2, Efficiency_input);

		assertTrue(TestUtility.isDoublesEquals(0.824616643786384, p.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(0.959066236628087, p.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(48.0, p.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(107.226247414915680, p.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(29.454516609481065, p.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		Gain[] gains = new Gain[Phi_input.length];
		Map<String, Object> options = new HashMap<String, Object>();
		options.put("DoValidate", false);

		PatternELUX204V01 p = new PatternELUX204V01(GainMax_input_1, Efficiency_input);
		for (int i = 0; i < gains.length; i++) {
			Gain g = p.gain(Phi_input[i], options);
			gains[i] = g;
		}
		for (int i = 0; i < gains.length; i++) {
			assertTrue(TestUtility.isDoublesEquals(G_expected_1[i], gains[i].G));
			assertTrue(TestUtility.isDoublesEquals(Gx_expected_1[i], gains[i].Gx));
		}

		p = new PatternELUX204V01(GainMax_input_2, Efficiency_input);
		for (int i = 0; i < gains.length; i++) {
			Gain g = p.gain(Phi_input[i], options);
			gains[i] = g;
		}
		for (int i = 0; i < gains.length; i++) {
			assertTrue(TestUtility.isDoublesEquals(G_expected_2[i], gains[i].G));
			assertTrue(TestUtility.isDoublesEquals(Gx_expected_2[i], gains[i].Gx));
		}
	}
}
