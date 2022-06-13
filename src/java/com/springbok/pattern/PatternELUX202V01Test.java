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
 * Tests methods of PatternELUX202V01 class.
 */
public class PatternELUX202V01Test {

	private static final double[] Phi_input = new double[] { 0.1, 0.2, 0.4, 0.7, 0.8, 2.0, 10.0, 40.0, 150.0 };

	private static final double[] G_expected = new double[] { 46.722761244314214, 45.891044977256854,
			42.564179909027409, 33.415300971396441, 30.427425919432462, 21.474250108400472, 4.0, -5.0, 0.0 };
	private static final double[] Gx_expected = new double[] { 22.0, 23.420919257974482, 27.0, 24.440709547575768,
			18.360810911515156, 17.0, 4.0, -5.0, 0.0 };

	// TODO: Test PatternELUX202V01 method

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {

		PatternELUX202V01 p = new PatternELUX202V01();

		Gain[] gains = new Gain[Phi_input.length];
		Map<String, Object> options = new HashMap<String, Object>();
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
