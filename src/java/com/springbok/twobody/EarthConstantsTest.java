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
package com.springbok.twobody;

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.springbok.utility.TestUtility;

public class EarthConstantsTest {

	// Input date number at which the angle coincides
	public final ModJulianDate dNm_input = new ModJulianDate(5.483250000000000e+04);

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	/* Tests Theta method. */
	public void test_Theta() {

		double theta_expected = 20720.5710265505076677;

		double theta_actual = EarthConstants.Theta(this.dNm_input);

		assertTrue(Math.abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);
	}
}
