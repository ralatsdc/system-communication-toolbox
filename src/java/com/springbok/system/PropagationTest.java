/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
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