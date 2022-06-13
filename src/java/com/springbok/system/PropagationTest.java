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
package com.springbok.system;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of Propagation class.
 */
public class PropagationTest {

    @Test
    public void test_computeFSL() {
        double FSL_expected = 32.447783221883370;

        double FSL_actual = Propagation.computeFSL(1, 1);

        assertTrue(TestUtility.isDoublesEquals(FSL_actual, FSL_expected));
    }

    @Test
    public void test_computeSL() {
        double SL_expected = 70.992098640220973;

        double SL_actual = Propagation.computeSL(1);

        assertTrue(TestUtility.isDoublesEquals(SL_actual, SL_expected));
    }
}
