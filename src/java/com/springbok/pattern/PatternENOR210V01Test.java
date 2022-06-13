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
 * Tests methods of PatternENOR210V01 class.
 */
public class PatternENOR210V01Test {
	private static final double GainMax_input_1 = 47;
	private static final double Phi0_input = 2;
	private static final double[] Phi_input = new double[] { 0.2, 1, 10, 150 };
	private static final double[] G_expected_1 = new double[] { 47.0, 44.0, 19.025749891599531, 10.0 };
	private static final double[] Gx_expected_1 = new double[] { 47.0, 44.0, 19.025749891599531, 10.0 };
	private static final double GainMax_input_2 = 35;
	private static final double[] G_expected_2 = new double[] { 35.0, 32.0, 7.025749891599531, -2.0 };
	private static final double[] Gx_expected_2 = new double[] { 35.0, 32.0, 7.025749891599531, -2.0 };

	/**
	 * Tests PatternENOR210V01 method.
	 */
	@Test
	public void test_PatternENOR210V01() {
		PatternENOR210V01 p_1 = new PatternENOR210V01(GainMax_input_1, Phi0_input);

		assertTrue(TestUtility.isDoublesEquals(47, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(2, p_1.getPhi0()));

		PatternENOR210V01 p_2 = new PatternENOR210V01(GainMax_input_2, Phi0_input);

		assertTrue(TestUtility.isDoublesEquals(35, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(2, p_2.getPhi0()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternENOR210V01 p_1 = new PatternENOR210V01(GainMax_input_1, Phi0_input);

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

		PatternENOR210V01 p_2 = new PatternENOR210V01(GainMax_input_2, Phi0_input);

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
