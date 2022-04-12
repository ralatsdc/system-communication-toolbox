/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.station;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.net.SocketTimeoutException;

import static org.junit.Assert.*;

/**
 * Tests methods of Emission class.
 */
public class EmissionTest {

    //  Emission designator
    private final String design_emi = "1K20G1D--";
    //  Maximum power density [dBW/Hz]
    private final double pwr_ds_max = -24.799999237060547;
    //  Minimum power density [dBW/Hz]
    private final Double pwr_ds_min = Double.NaN;
    //  Center frequency [MHz]
    private final double freq_mhz = 1;
    //  Required C/N [dB]
    private final Double c_to_n = Double.NaN;
    //  Power flux density [dBW/Hz/m2]
    private final double pwr_flx_ds = -40.0;
    // An emission
    private Emission emission;

    /**
     * Tests the Emission constructor.
     */
    @Test
    public void test_Emission() {
        this.emission = new Emission(this.design_emi, this.pwr_ds_max, this.pwr_ds_min,
                this.freq_mhz, this.c_to_n, this.pwr_flx_ds);

        assertTrue(this.emission.getDesign_emi().equals(design_emi));
        assertTrue(TestUtility.isDoublesEquals(pwr_ds_max, this.emission.getPwr_ds_max()));
        assertTrue(((Double) this.emission.getPwr_ds_min()).isNaN());
        assertTrue(TestUtility.isDoublesEquals(freq_mhz, this.emission.getFreq_mhz()));
        assertTrue(((Double) this.emission.getPwr_ds_min()).isNaN());
        assertTrue(TestUtility.isDoublesEquals(pwr_flx_ds, this.emission.getPwr_flx_ds()));
    }
}