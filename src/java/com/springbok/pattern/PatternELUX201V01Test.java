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

import org.junit.Assert;
import org.junit.Test;

import com.springbok.utility.TestUtility;

/**
 * Tests methods of PatternELUX201V01 class.
 *
 */
public class PatternELUX201V01Test {

	private static final double GainMax_input = 57.0;

	private static final double[] Phi_input = new double[] { 0.2, 0.4, 10.0, 150.0 };

	private static final double[] G_expected = new double[] { 48.675264961058339, 35.902778147007240, 4.0, -10.0, };
	private static final double[] Gx_expected = new double[] { 27.0, 27.0, 4.0, -10.0 };

	// TODO: Test PatternELUX201V01 method

	/**
	 * Tests gain method.
	 */
	@Test
	public void test_gain() {

		PatternELUX201V01 p = new PatternELUX201V01(GainMax_input);

		Gain[] gains = new Gain[Phi_input.length];
		for (int i = 0; i < gains.length; i++) {
			Gain g = p.gain(Phi_input[i]);
			gains[i] = g;
		}

		for (int i = 0; i < gains.length; i++) {
			Assert.assertTrue(Math.abs(gains[i].G - G_expected[i]) < TestUtility.HIGH_PRECISION);
			Assert.assertTrue(Math.abs(gains[i].Gx - Gx_expected[i]) < TestUtility.HIGH_PRECISION);
		}
	}
}
