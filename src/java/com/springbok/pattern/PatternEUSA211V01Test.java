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
 * Tests methods of PatternEUSA211V01 class.
 */
public class PatternEUSA211V01Test {

	private static final double[] Phi_input = new double[] { 0.02, 0.1, 0.5, 3.0, 8.0, 15.0, 30.0, 150.0 };
	private static final double[] G_expected = new double[] { 64.417444153574579, 50.436103839364428,
			42.240031738381155, 17.071968632008442, 7.9, 2.597718523607966, -4.928031367991565, -10.0 };
	private static final double[] Gx_expected = new double[] { 34.417444153574579, 30.436103839364428,
			22.240031738381155, 7.071968632008440, -2.0, -2.0, -4.928031367991565, -10.0 };

	/**
	 * Tests PatternEUSA211V01 method.
	 */
	@Test
	public void test_PatternEUSA211V01() {
		PatternEUSA211V01 p = new PatternEUSA211V01();

		assertTrue(TestUtility.isDoublesEquals(65.0, p.getGainMax()));
		assertTrue(TestUtility.isDoublesEquals(0.125010657437172, p.getPhi_m()));
		assertTrue(TestUtility.isDoublesEquals(1.0, p.getPhi_r()));
		assertTrue(TestUtility.isDoublesEquals(47.863009232263828, p.getPhi_b()));
		assertTrue(TestUtility.isDoublesEquals(763.253461456561580, p.getD_over_lambda()));
		assertTrue(TestUtility.isDoublesEquals(42.240031738381155, p.getG1()));
	}

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {
		PatternEUSA211V01 p = new PatternEUSA211V01();

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
