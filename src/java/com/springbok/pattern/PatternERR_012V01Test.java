/* Copyright (C) 2022 Springbok LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
package com.springbok.pattern;

import com.springbok.utility.TestUtility;

import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternERR_012V01 class.
 */
public class PatternERR_012V01Test {
	private static final double GainMax_input_1 = 53.7;
	private static final double GainMax_input_2 = 39.7;

	private static final double[] Phi_input = new double[] { 0.2, 0.6, 2.3, 10.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 49.718928294465030, 33.5,
			19.956804099560181, 4.0, -10.0};
	private static final double[] Gx_expected_1 = new double[] { 49.718928294465030, 33.5,
			19.956804099560181, 4.0, -10.0};
	private static final double[] G_expected_2 = new double[] { 39.541510680753895, 38.273596126785002,
			19.0, 4.0, -10.0};
	private static final double[] Gx_expected_2 = new double[] { 39.541510680753895, 38.273596126785002,
			19.0, 4.0, -10.0};

	/**
	 * Tests PatternERR_012V01 method.
	 */
	@Test
	public void test_PatternERR_012V01() {
		PatternERR_012V01 p_1 = new PatternERR_012V01(GainMax_input_1);

		assertTrue(TestUtility.isDoublesEquals(53.7, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.450511291385659, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(0.660737972800482, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(36.0, p_1.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(199.526231496887870, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(33.5, p_1.getG1()));

		PatternERR_012V01 p_2 = new PatternERR_012V01(GainMax_input_2);

		assertTrue(TestUtility.isDoublesEquals(39.7, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(2.285678632768832, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(2.511886431509580, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(36.0, p_2.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(39.810717055349734, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(19.0, p_2.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternERR_012V01 p_1 = new PatternERR_012V01(GainMax_input_1);
		PatternERR_012V01 p_2 = new PatternERR_012V01(GainMax_input_2);

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
