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
 * Tests methods of PatternELUX205V01 class.
 */
public class PatternELUX205V01Test {
	private static final double GainMax_input_1 = 57;
	private static final double Efficiency_input = 0.7;

	private static final double GainMax_input_2 = 34;

	private static final double[] Phi_input = new double[] { 0.2, 0.8, 2.0, 4.5, 6.0, 8.0, 20.0, 150.0 };

	private static final double[] G_expected_1 = new double[] { 49.745588037493697, 35.454516609481068,
			21.474250108400472, 12.669687155616412, 9.546218740408911, 7.9, -0.525749891599531, -10.0 };
	private static final double[] Gx_expected_1 = new double[] { 49.745588037493697, 35.454516609481068,
			21.474250108400472, 12.669687155616412, 9.546218740408911, 7.9, -0.525749891599531, -10.0 };

	private static final double[] G_expected_2 = new double[] { 33.963641813369186, 33.418269013907022,
			30.364181336918875, 18.204516609481068, 9.546218740408911, 7.9, -0.525749891599531, -10.0 };
	private static final double[] Gx_expected_2 = new double[] { 33.963641813369186, 33.418269013907022,
			30.364181336918875, 18.204516609481068, 9.546218740408911, 7.9, -0.525749891599531, -10.0 };

	/**
	 * Tests PatternELUX205V01 method.
	 */
	@Test
	public void test_PatternELUX205V01() {
		PatternELUX205V01 p = new PatternELUX205V01(GainMax_input_1, Efficiency_input);

		assertTrue(TestUtility.isDoublesEquals(0.344672797841786, p.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(1.0, p.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(48.0, p.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(269.340155983215820, p.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(35.454516609481068, p.getG1()));

		p = new PatternELUX205V01(GainMax_input_2, Efficiency_input);

		assertTrue(TestUtility.isDoublesEquals(4.168649190696996, p.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(5.244437241325346, p.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(48.0, p.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(19.067822799368372, p.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(18.204516609481068, p.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		Gain[] gains = new Gain[Phi_input.length];
		Map<String, Object> options = new HashMap<String, Object>();
		options.put("DoValidate", false);

		PatternELUX205V01 p = new PatternELUX205V01(GainMax_input_1, Efficiency_input);
		for (int i = 0; i < gains.length; i++) {
			Gain g = p.gain(Phi_input[i], options);
			gains[i] = g;
		}
		for (int i = 0; i < gains.length; i++) {
			assertTrue(TestUtility.isDoublesEquals(G_expected_1[i], gains[i].G));
			assertTrue(TestUtility.isDoublesEquals(Gx_expected_1[i], gains[i].Gx));
		}

		p = new PatternELUX205V01(GainMax_input_2, Efficiency_input);
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
