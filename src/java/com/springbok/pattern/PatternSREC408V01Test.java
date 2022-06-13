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

import junit.framework.Assert;

public class PatternSREC408V01Test {

	private static final double Phi0_input = 4.0;

	private static final double GainMax_input = 40;

	private static final PatternSREC408V01 pattern = new PatternSREC408V01(GainMax_input, Phi0_input);

	private static final double[] Phi_input = new double[] { 0.2, 2, 10, 150 };

	private static final double[] G_expected = new double[] { 39.969999999999999, 37.000000000000000,
			20.000000000000000, 0 };

	private static final double[] Gx_expected = new double[] { 39.969999999999999, 37.000000000000000,
			20.000000000000000, 0 };

	@SuppressWarnings("static-access")
	public void test_gain() {

		Gain[] gains = new Gain[Phi_input.length];
		for (int i = 0; i < gains.length; i++) {
			Gain g = this.pattern.gain(this.Phi_input[i]);
			gains[i] = g;
		}

		for (int i = 0; i < gains.length; i++) {

			Assert.assertTrue(Math.abs(gains[i].G - this.G_expected[i]) < TestUtility.HIGH_PRECISION);
			Assert.assertTrue(Math.abs(gains[i].Gx - this.Gx_expected[i]) < TestUtility.HIGH_PRECISION);
		}

	}
}
