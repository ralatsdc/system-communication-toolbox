/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
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