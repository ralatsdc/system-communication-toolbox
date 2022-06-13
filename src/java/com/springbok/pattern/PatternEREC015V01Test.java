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
 * Tests methods of PatternEREC015V01 class.
 */
public class PatternEREC015V01Test {
	private static final double GainMax_input_1 = 54.4;
	private static final double Efficiency_input = 0.7;

	private static final double GainMax_input_2 = 44;

	private static final double[] Phi_input = new double[] { 0.2, 0.7, 5.0, 22.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 50.413404110801082, 32.872548999643577,
			11.525749891599531, -3.50, -10.0 };
	private static final double[] Gx_expected_1 = new double[] { 50.413404110801082, 32.872548999643577,
			11.525749891599531, -3.5, -10.0 };
	private static final double[] G_expected_2 = new double[] { 43.636418133691890, 39.546122137725618,
			11.525749891599531, -3.5, -10.0 };
	private static final double[] Gx_expected_2 = new double[] { 43.636418133691890, 39.546122137725618,
			11.525749891599531, -3.5, -10.0 };

	/**
	 * Tests PatternEREC015V01 method.
	 */
	@Test
	public void test_PatternEREC015V01() {
		PatternEREC015V01 p_1 = new PatternEREC015V01(GainMax_input_1, Efficiency_input);

		assertTrue(TestUtility.isDoublesEquals(54.4, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.7, p_1.getEfficiency()));
		assertTrue(TestUtility.isDoublesEquals(0.457883611484118, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(0.660463166200195, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(47.863009232263828, p_1.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(199.664616023944350, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(33.504516609481058, p_1.getG1()));

		PatternEREC015V01 p_2 = new PatternEREC015V01(GainMax_input_2, Efficiency_input);

		assertTrue(TestUtility.isDoublesEquals(44, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.7, p_2.getEfficiency()));
		assertTrue(TestUtility.isDoublesEquals(1.501502525147764, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(1.658436672839821, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(47.863009232263828, p_2.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(60.297750066491929, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(23.507527682468449, p_2.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternEREC015V01 p_1 = new PatternEREC015V01(GainMax_input_1, Efficiency_input);

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

		PatternEREC015V01 p_2 = new PatternEREC015V01(GainMax_input_2, Efficiency_input);

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
