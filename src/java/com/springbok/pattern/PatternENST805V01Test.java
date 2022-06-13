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
 * Tests methods of PatternENST805V01 class.
 */
public class PatternENST805V01Test {
	private static final double GainMax_input_1 = 51.2;
	private static final double CoefA_input_1 = 35.0;
	private static final double CoefB_input_1 = 24.0;
	private static final double Phi1_input_1 = 10.0;

	private static final double GainMax_input_2 = 27.0;
	private static final double CoefA_input_2 = 30.0;
	private static final double CoefB_input_2 = 25.0;
	private static final double Phi1_input_2 = 7.0;

	private static final double[] Phi_input = new double[] { 0.2, 4.0, 15.0, 30.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 51.2, 20.550560208128907, 2.597718523607966,
			-4.928031367991565, -10.0 };
	private static final double[] Gx_expected_1 = new double[] { 51.2, 20.550560208128907, 2.597718523607966,
			-4.928031367991565, -10.0 };
	private static final double[] G_expected_2 = new double[] { 27.0, 14.948500216800943, 8.872548999643577,
			5.421968632008436, 0.35 };
	private static final double[] Gx_expected_2 = new double[] { 27.0, 14.948500216800943, 8.872548999643577,
			5.421968632008436, 0.35 };

	/**
	 * Tests PatternENST805V01 method.
	 */
	@Test
	public void test_PatternENST805V01() {
		PatternENST805V01 p_1 = new PatternENST805V01(GainMax_input_1, CoefA_input_1, CoefB_input_1, Phi1_input_1);

		assertTrue(TestUtility.isDoublesEquals(51.2, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(35, p_1.getCoefA()));
		assertTrue(TestUtility.isDoublesEquals(24, p_1.getCoefB()));
		assertTrue(TestUtility.isDoublesEquals(10, p_1.getPhi1()));

		PatternENST805V01 p_2 = new PatternENST805V01(GainMax_input_2, CoefA_input_2, CoefB_input_2, Phi1_input_2);

		assertTrue(TestUtility.isDoublesEquals(27, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(30, p_2.getCoefA()));
		assertTrue(TestUtility.isDoublesEquals(25, p_2.getCoefB()));
		assertTrue(TestUtility.isDoublesEquals(7, p_2.getPhi1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternENST805V01 p_1 = new PatternENST805V01(GainMax_input_1, CoefA_input_1, CoefB_input_1, Phi1_input_1);

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

		PatternENST805V01 p_2 = new PatternENST805V01(GainMax_input_2, CoefA_input_2, CoefB_input_2, Phi1_input_2);

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
