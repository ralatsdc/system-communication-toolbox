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
 * Tests methods of PatternEND_099V01Test class.
 */
public class PatternEND_099V01Test {
	private static final double GainMax_input = 35.5;

	private static final double[] Phi_input = new double[] { 0.2, 2.0, 10.0, 150.0 };

	private static final double[] G_expected = new double[] { 35.5, 35.5, 35.5, 35.5 };
	private static final double[] Gx_expected = new double[] { 35.5, 35.5, 35.5, 35.5 };

	/**
	 * Tests PatternEND_099V01 method.
	 */
	@Test
	public void test_PatternEND_099V01() {
		PatternEND_099V01 p = new PatternEND_099V01(GainMax_input);

		assertTrue(TestUtility.isDoublesEquals(GainMax_input, p.getGainMax()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		Gain[] gains = new Gain[Phi_input.length];
		Map<String, Object> options = new HashMap<String, Object>();
		options.put("DoValidate", false);

		PatternEND_099V01 p = new PatternEND_099V01(GainMax_input);
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
