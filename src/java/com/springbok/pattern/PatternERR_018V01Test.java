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
 * Tests methods of PatternERR_018V01 class.
 */
public class PatternERR_018V01Test {
	private static final double GainMax_input = 43.2;

	private static final double[] Phi_input = new double[] { 0.2, 1.0, 10.0, 150.0 };
	private static final double[] G_expected = new double[] { 43.2, 39.047750865051903, 9.961223034456850, 0.0 };
	private static final double[] Gx_expected = new double[] { 43.2, 39.047750865051903, 9.961223034456850, 0.0 };

	/**
	 * Tests PatternERR_018V01 method.
	 */
	@Test
	public void test_PatternERR_018V01() {
		PatternERR_018V01 p = new PatternERR_018V01(GainMax_input);

		assertTrue(TestUtility.isDoublesEquals(43.2, p.getGainMax()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternERR_018V01 p = new PatternERR_018V01(GainMax_input);

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
