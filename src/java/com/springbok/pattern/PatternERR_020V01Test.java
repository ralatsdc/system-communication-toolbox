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
 * Tests methods of PatternERR_020V01 class.
 */
public class PatternERR_020V01Test {
	private static final double Diameter_input_1 = 3.0;
	private static final double Frequency_input = 11000.0;
	private static final double Diameter_input_2 = 1.0;
	private static final double Diameter_input_3 = 0.6;

	private static final double[] Phi_input = new double[] { 0.2, 0.9, 2.0, 10.0, 60.0, 100.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 47.322188827956808, 29.624666890405141,
			21.474250108400472, 4.0, -12.0, -7.0, -12.0 };
	private static final double[] Gx_expected_1 = new double[] { 47.322188827956808, 29.624666890405141,
			21.474250108400472, 4.0, -12.0, -7.0, -12.0 };
	private static final double[] G_expected_2 = new double[] { 38.856808987823463, 36.265168844760574,
			25.528373966357172, 4.0, -9.0, -4.0, -9.0 };
	private static final double[] Gx_expected_2 = new double[] { 38.856808987823463, 36.265168844760574,
			25.528373966357172, 4.0, -9.0, -4.0, -9.0 };
	private static final double[] G_expected_3 = new double[] { 34.505997615837138, 33.573007164334498,
			29.707761008109269, 4.0, -9.0, -5.0, -5.0 };
	private static final double[] Gx_expected_3 = new double[] { 34.505997615837138, 33.573007164334498,
			29.707761008109269, 4.0, -9.0, -5.0, -5.0 };

	/**
	 * Tests PatternERR_020V01 method.
	 */
	@Test
	public void test_PatternERR_020V01() {
		PatternERR_020V01 p_1 = new PatternERR_020V01(Diameter_input_1, Frequency_input);

		assertTrue(TestUtility.isDoublesEquals(11000.0, p_1.getFrequency()));
		assertTrue(TestUtility.isDoublesEquals(0.790084081312813, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(0.944089841015923, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(34.1, p_1.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(110.076151415390170, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(29.624666890405141, p_1.getG1()));

		PatternERR_020V01 p_2 = new PatternERR_020V01(Diameter_input_2, Frequency_input);

		assertTrue(TestUtility.isDoublesEquals(11000.0, p_2.getFrequency()));
		assertTrue(TestUtility.isDoublesEquals(2.457097134567086, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(2.589116682727273, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(33.1, p_2.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(36.692050471796726, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(18.671209423536244, p_2.getG1()));

		PatternERR_020V01 p_3 = new PatternERR_020V01(Diameter_input_3, Frequency_input);

		assertTrue(TestUtility.isDoublesEquals(11000.0, p_3.getFrequency()));
		assertTrue(TestUtility.isDoublesEquals(4.205450430304155, p_3.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(4.315194471212122, p_3.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(33.1, p_3.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(22.015230283078033, p_3.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(13.124990683127333, p_3.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternERR_020V01 p_1 = new PatternERR_020V01(Diameter_input_1, Frequency_input);

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

		PatternERR_020V01 p_2 = new PatternERR_020V01(Diameter_input_2, Frequency_input);

		for (int i = 0; i < gains.length; i++) {
			Gain g = p_2.gain(Phi_input[i], options);
			gains[i] = g;
		}
		for (int i = 0; i < gains.length; i++) {
			assertTrue(TestUtility.isDoublesEquals(G_expected_2[i], gains[i].G));
			assertTrue(TestUtility.isDoublesEquals(Gx_expected_2[i], gains[i].Gx));
		}
		gains = new Gain[Phi_input.length];

		PatternERR_020V01 p_3 = new PatternERR_020V01(Diameter_input_3, Frequency_input);

		for (int i = 0; i < gains.length; i++) {
			Gain g = p_3.gain(Phi_input[i], options);
			gains[i] = g;
		}
		for (int i = 0; i < gains.length; i++) {
			assertTrue(TestUtility.isDoublesEquals(G_expected_3[i], gains[i].G));
			assertTrue(TestUtility.isDoublesEquals(Gx_expected_3[i], gains[i].Gx));
		}
	}
}
