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

public class PatternSRR_401V01Test {

	private static final double Phi0_input = 2;

	private static final double GainMax_input = 57;

	private static final PatternSRR_401V01 pattern = new PatternSRR_401V01(GainMax_input, Phi0_input);

	private static final double[] Phi_input = new double[] { 0.2, 0.5, 5, 150 };

	private static final double[] G_expected = new double[] { 56.880000000000003, 56.250000000000000,
			27.041199826559250, 0 };

	private static final double[] Gx_expected = new double[] { 27.000000000000000, 27.000000000000000,
			27.000000000000000, 0 };

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
