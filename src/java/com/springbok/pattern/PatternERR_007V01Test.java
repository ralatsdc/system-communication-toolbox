/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;

import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternERR_007V01 class.
 */
public class PatternERR_007V01Test {
	private static final double GainMax_input = 35.5;
	private static final double Diameter_input = 0.6;

	private static final double[] Phi_input = new double[] { 0.2, 0.8, 2.0, 3.5, 3.85, 8.0, 40.0, 150.0 };
	private static final double[] G_expected = new double[] { 35.441354885905547, 34.561678174488776,
			29.635488590554829, 17.539933808574165, 14.159807812082960, 6.422750325201413, -5.0, 0.0 };
	private static final double[] Gx_expected = new double[] { 10.5, 11.747620246928316, 18.5, 13.256354004382899,
			10.384636946146038, -1.577249674798587, -5.0, 0.0 };

	/**
	 * Tests PatternERR_007V01 method.
	 */
	@Test
	public void test_PatternERR_007V01() {
		PatternERR_007V01 p = new PatternERR_007V01(GainMax_input, Diameter_input);

		assertTrue(TestUtility.isDoublesEquals(35.5, p.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.6, p.getDiameter()));
		assertTrue(TestUtility.isDoublesEquals(3.815164260242893, p.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(3.922904064738292, p.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(22.908676527677734, p.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(24.216753311385840, p.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(14.159807812082960, p.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternERR_007V01 p = new PatternERR_007V01(GainMax_input, Diameter_input);

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
