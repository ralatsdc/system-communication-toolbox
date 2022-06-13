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
 * Tests methods of PatternERR_019V01 class.
 */
public class PatternERR_019V01Test {
	private static final double Diameter_input_1 = 10.0;
	private static final double Frequency_input = 4000.0;

	private static final double[] Phi_input = new double[] { 0.2, 0.7, 1.0, 1.3, 3.5, 10.0, 22.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 48.424545678314914, 33.878589326000522, 29.0,
			26.151416192329080, 15.398298891243108, 4.0, -3.5, -10.0 };
	private static final double[] Gx_expected_1 = new double[] { 48.424545678314914, 33.878589326000522, 29.0,
			26.151416192329080, 15.398298891243108, 4.0, -3.5, -10.0 };
	private static final double Diameter_input_2 = 4.5;

	private static final double[] G_expected_2 = new double[] { 42.908537425346204, 38.852927971030766,
			34.256570589473270, 28.676777032630678, 15.398298891243108, 4.0, -3.5, -10.0 };
	private static final double[] Gx_expected_2 = new double[] { 42.908537425346204, 38.852927971030766,
			34.256570589473270, 28.676777032630678, 15.398298891243108, 4.0, -3.5, -10.0 };
	private static final double Diameter_input_3 = 1.8;

	private static final double[] G_expected_3 = new double[] { 35.252556091161004, 34.603658578470537,
			33.868241397421336, 32.873265211295944, 22.707676902550116, 7.0, -1.560567020555155, -10.0 };
	private static final double[] Gx_expected_3 = new double[] { 35.252556091161004, 34.603658578470537,
			33.868241397421336, 32.873265211295944, 22.707676902550116, 7.0, -1.560567020555155, -10.0 };

	/**
	 * Tests PatternERR_019V01 method.
	 */
	@Test
	public void test_PatternERR_019V01() {
		PatternERR_019V01 p_1 = new PatternERR_019V01(Diameter_input_1, Frequency_input);

		assertTrue(TestUtility.isDoublesEquals(4000.0, p_1.getFrequency()));
		assertTrue(TestUtility.isDoublesEquals(0.605666030113178, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(0.841173715238910, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(48.0, p_1.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(133.425638079260840, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(33.878589326000522, p_1.getG1()));

		PatternERR_019V01 p_2 = new PatternERR_019V01(Diameter_input_2, Frequency_input);

		assertTrue(TestUtility.isDoublesEquals(4000.0, p_2.getFrequency()));
		assertTrue(TestUtility.isDoublesEquals(1.272446285727245, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(1.665513655555556, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(48.0, p_2.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(60.041537135667369, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(28.676777032630678, p_2.getG1()));

		PatternERR_019V01 p_3 = new PatternERR_019V01(Diameter_input_3, Frequency_input);

		assertTrue(TestUtility.isDoublesEquals(4000.0, p_3.getFrequency()));
		assertTrue(TestUtility.isDoublesEquals(2.956293654885015, p_3.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(4.163784138888889, p_3.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(48.0, p_3.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(24.016614854266951, p_3.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(22.707676902550116, p_3.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternERR_019V01 p_1 = new PatternERR_019V01(Diameter_input_1, Frequency_input);

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

		PatternERR_019V01 p_2 = new PatternERR_019V01(Diameter_input_2, Frequency_input);

		for (int i = 0; i < gains.length; i++) {
			Gain g = p_2.gain(Phi_input[i], options);
			gains[i] = g;
		}
		for (int i = 0; i < gains.length; i++) {
			assertTrue(TestUtility.isDoublesEquals(G_expected_2[i], gains[i].G));
			assertTrue(TestUtility.isDoublesEquals(Gx_expected_2[i], gains[i].Gx));
		}

		gains = new Gain[Phi_input.length];

		PatternERR_019V01 p_3 = new PatternERR_019V01(Diameter_input_3, Frequency_input);

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
