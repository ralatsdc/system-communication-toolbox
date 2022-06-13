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
 * Tests methods of PatternENOR207V01 class.
 */
public class PatternENOR207V01Test {
	private static final double[] Phi_input = new double[] { 0.2, 4.0, 150.0 };
	private static final double[] G_expected = new double[] { 49.008000000000003, 13.948500216800943, -10.0 };
	private static final double[] Gx_expected = new double[] { 49.008000000000003, 13.948500216800943, -10.0 };

	/**
	 * Tests PatternENOR207V01 method.
	 */
	@Test
	public void test_PatternENOR207V01() {
		PatternENOR207V01 p = new PatternENOR207V01();

		assertTrue(TestUtility.isDoublesEquals(50.7, p.getGainMax()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternENOR207V01 p = new PatternENOR207V01();

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
