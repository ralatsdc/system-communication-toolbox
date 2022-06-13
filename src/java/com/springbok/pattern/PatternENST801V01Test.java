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
 * Tests methods of PatternENST801V01 class.
 */
public class PatternENST801V01Test {
	private static final double GainMax_input_1 = 54.4;
	private static final double Efficiency_input = 0.7;
	private static final double CoefA_input = 30.0;
	private static final double GainMax_input_2 = 34.4;
	private static final double[] Phi_input = new double[] { 0.2, 0.7, 4.0, 10.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 50.413404110801082, 30.0, 14.948500216800943, 5.0,
			-10.0 };
	private static final double[] Gx_expected_1 = new double[] { 50.413404110801082, 30.0, 14.948500216800943, 5.0,
			-10.0 };
	private static final double[] G_expected_2 = new double[] { 34.360134041108012, 33.911642003573128,
			21.504516609481065, 13.996988927012623, -3.003011072987377 };
	private static final double[] Gx_expected_2 = new double[] { 34.360134041108012, 33.911642003573128,
			21.504516609481065, 13.996988927012623, -3.003011072987377 };

	/**
	 * Tests PatternENST801V01 method.
	 */
	@Test
	public void test_PatternENST801V01() {
		PatternENST801V01 p_1 = new PatternENST801V01(GainMax_input_1, Efficiency_input, CoefA_input);

		assertTrue(TestUtility.isDoublesEquals(54.4, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.7, p_1.getEfficiency()));
		assertTrue(TestUtility.isDoublesEquals(30, p_1.getCoefA()));
		assertTrue(TestUtility.isDoublesEquals(0.494793290113959, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(1.0, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(39.810717055349734, p_1.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(199.664616023944350, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(30.0, p_1.getG1()));

		PatternENST801V01 p_2 = new PatternENST801V01(GainMax_input_2, Efficiency_input, CoefA_input);

		assertTrue(TestUtility.isDoublesEquals(34.4, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.7, p_2.getEfficiency()));
		assertTrue(TestUtility.isDoublesEquals(32, p_2.getCoefA()));
		assertTrue(TestUtility.isDoublesEquals(3.597060161830266, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(5.008398683320418, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(47.863009232263828, p_2.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(19.966461602394443, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(21.504516609481065, p_2.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternENST801V01 p_1 = new PatternENST801V01(GainMax_input_1, Efficiency_input, CoefA_input);

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

		PatternENST801V01 p_2 = new PatternENST801V01(GainMax_input_2, Efficiency_input, CoefA_input);

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
