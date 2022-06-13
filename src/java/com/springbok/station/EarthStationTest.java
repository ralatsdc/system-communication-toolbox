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
package com.springbok.station;

import static org.junit.Assert.*;

import com.springbok.antenna.EarthStationAntenna;
import com.springbok.pattern.PatternELUX201V01;
import com.springbok.pattern.PatternELUX202V01;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.springbok.utility.TestUtility;

public class EarthStationTest {

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

    // Identifier for station
    private final String stationId = "one";
    // Transmit antenna gain, and pattern
    private final EarthStationAntenna transmitAntenna = new EarthStationAntenna(
            "transmit", 50, 1, new PatternELUX201V01(50));
    // Receive antenna gain, pattern, and noise temperature
    private final EarthStationAntenna receiveAntenna = new EarthStationAntenna("transmit", 50, 1, new PatternELUX202V01(), 290);
    // Signal power, frequency, and requirement
    private final Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, pwr_flx_ds);
    // Beam
    private final Beam beam = new Beam("one", 1, 100);

    // Geodetic latitude [rad]
    private final double varphi = -0.388146681233106;
    // Longitude [rad]
    private final double lambda = 1.991134636453675;

    // Flag indicating whether to do multiplexing, or not
    private final boolean doMultiplexing = true;


    private EarthStation earthStation;

    @Before
    public void setUp() throws Exception {
        // Compute derived properties
        beam.set_isMultiplexed(true);
        this.earthStation = new EarthStation(this.stationId,
                this.transmitAntenna,
                this.receiveAntenna,
                this.emission,
                this.beam,
                this.varphi,
                this.lambda,
                this.doMultiplexing);
    }

    @After
    public void tearDown() throws Exception {
    }

    @Test
    /*
     * Tests the EarthStation constructor. Note that the private method
     * compute_R_ger can only be tested implicitly.
     */
    public void test_EarthStation() {

        String stationId_expected = this.stationId;
        double varphi_expected = this.varphi;
        double lambda_expected = this.lambda;

        String stationId_actual = this.earthStation.getStationId();
        double varphi_actual = this.earthStation.varphi;
        double lambda_actual = this.earthStation.lambda;

        boolean t = stationId_actual.equals(stationId_expected) && varphi_actual == varphi_expected
                && lambda_actual == lambda_expected;

        assertTrue(t);
    }

    // TODO: test r_gei method

    @Test
    /* Tests the set_varphi method. */
    public void test_set_varphi() {
        double varphi_expected = this.varphi;
        this.earthStation.set_varphi(this.varphi);
        double varphi_actual = this.earthStation.varphi;
        assertEquals(varphi_actual, varphi_expected, TestUtility.HIGH_PRECISION);
    }

    @Test
    /* Tests the set_lambda method. */
    public void test_set_lambda() {
        double lambda_expected = this.lambda;
        this.earthStation.set_lambda(this.lambda);
        double lambda_actual = this.earthStation.lambda;
        assertEquals(lambda_actual, lambda_expected, TestUtility.HIGH_PRECISION);
    }
}
