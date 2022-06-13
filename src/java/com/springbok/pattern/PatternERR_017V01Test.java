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
 * Tests methods of PatternERR_017V01 class.
 */
public class PatternERR_017V01Test {
	private static final double GainMax_input_1 = 35.5;
	private static final double Diameter_input_1 = 0.6;
	private static final double Frequency_input_1 = 11700.0;
	private static final double GainMax_input_2 = 33.3;
	private static final double Diameter_input_2 = 0.45;
	private static final double Frequency_input_2 = 12200.0;

	private static final double[] Phi_input = new double[] { 0.2, 4.5, 10.0, 150.0 };
	private static final double[] G_expected_1 = new double[] { 35.445168160177658, 12.669687155616412,
			4.0, 0.0 };
	private static final double[] Gx_expected_1 = new double[] { 35.445168160177658, 12.669687155616412,
			4.0, 0.0 };
	private static final double[] G_expected_2 = new double[] { 33.266464616045532, 16.322711873053777,
			4.0, 0.0 };
	private static final double[] Gx_expected_2 = new double[] { 33.266464616045532, 16.322711873053777,
			4.0, 0.0 };

	/**
	 * Tests PatternERR_017V01 method.
	 */
	@Test
	public void test_PatternERR_017V01() {
		PatternERR_017V01 p_1 = new PatternERR_017V01(GainMax_input_1, Diameter_input_1,
				Frequency_input_1);

		assertTrue(TestUtility.isDoublesEquals(35.5, p_1.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.6, p_1.getDiameter()));
		assertTrue(TestUtility.isDoublesEquals(11700, p_1.getFrequency()));
		assertTrue(TestUtility.isDoublesEquals(3.979195541957924, p_1.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(4.057020443019943, p_1.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(23.416199482910272, p_1.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(13.794820097825752, p_1.getG1()));

		PatternERR_017V01 p_2 = new PatternERR_017V01(GainMax_input_2, Diameter_input_2,
				Frequency_input_2);

		assertTrue(TestUtility.isDoublesEquals(33.3, p_2.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.45, p_2.getDiameter()));
		assertTrue(TestUtility.isDoublesEquals(12200, p_2.getFrequency()));
		assertTrue(TestUtility.isDoublesEquals(5.142843453175333, p_2.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(5.187665484517304, p_2.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(18.312668826378548, p_2.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(11.125700905832915, p_2.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternERR_017V01 p_1 = new PatternERR_017V01(GainMax_input_1, Diameter_input_1,
				Frequency_input_1);

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

		PatternERR_017V01 p_2 = new PatternERR_017V01(GainMax_input_2, Diameter_input_2,
				Frequency_input_2);

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
