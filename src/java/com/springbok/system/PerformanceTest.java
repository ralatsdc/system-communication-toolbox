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

import java.util.Arrays;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of Performance class.
 */
public class PerformanceTest {

    // Carrier power density [dBW/Hz]
    private final double C = 1;
    // Noise power density [dBW/Hz]
    private final double N = 2;
    // Interference power density for each network [dBW/Hz]
    private final double[] i = new double[]{3, 4};
    // Interference power density total [dBW/Hz]
    private final double I = 5;
    // Equivalent power flux density for each network [dBW/m^2 in reference bandwidth]
    private final double[] epfd = new double[]{6, 7};
    // Equivalent power flux density total [dBW/m^2 in reference bandwidth]
    private final double EPFD = 8;

    /**
     * Tests the Performance constructor.
     */
    @Test
    public void test_Performance() {
        Performance performance = new Performance(this.C, this.N, this.i, this.I, this.epfd, this.EPFD);

        assertTrue(TestUtility.isDoublesEquals(C, performance.getC()));
        assertTrue(TestUtility.isDoublesEquals(N, performance.getN()));
        assertTrue(Arrays.equals(i, performance.get_i()));
        assertTrue(TestUtility.isDoublesEquals(I, performance.getI()));
        assertTrue(Arrays.equals(epfd, performance.getEpfd()));
        assertTrue(TestUtility.isDoublesEquals(EPFD, performance.getEPFD()));
    }
}
