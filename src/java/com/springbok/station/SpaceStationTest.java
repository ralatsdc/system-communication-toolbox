/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.station;

import com.springbok.antenna.EarthStationAntenna;
import com.springbok.antenna.SpaceStationAntenna;
import com.springbok.pattern.PatternELUX201V01;
import com.springbok.pattern.PatternSRR_405V01;
import com.springbok.twobody.KeplerianOrbit;
import com.springbok.utility.TestUtility;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

/**
 * Tests methods of SpaceStation class.
 */
public class SpaceStationTest {

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
    private final SpaceStationAntenna transmitAntenna = new SpaceStationAntenna(
            "transmit", 50, 1, new PatternSRR_405V01(3));
    // Receive antenna gain, pattern, and noise temperature
    private final EarthStationAntenna receiveAntenna = new EarthStationAntenna(
            "transmit", 50, 1, new PatternELUX201V01());

    // Signal power, frequency, and requirement
    private final Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, pwr_flx_ds);
    // Beam array
    private Beam[] beams = new Beam[]{new Beam("one", 1, 100), new Beam("two", 2, 100), new Beam("three", 3, 100)};

    // Orbit
    private final KeplerianOrbit orbit = new KeplerianOrbit();

    // A space station
    private SpaceStation spaceStation;

    @Before
    public void setUp() throws Exception {
        // Compute derived properties
        this.spaceStation = new SpaceStation(this.stationId,
                this.transmitAntenna,
                this.receiveAntenna,
                this.emission,
                this.beams,
                this.orbit);
    }

    /**
     * Tests the SpaceStation constructor.
     */
    @Test
    public void test_SpaceStation() {
        assertTrue(this.spaceStation.getStationId().equals(stationId));
        assertEquals(transmitAntenna, spaceStation.getTransmitAntenna());
        assertEquals(receiveAntenna, spaceStation.getReceiveAntenna());
        assertEquals(emission, spaceStation.getEmission());
        assertArrayEquals(beams, spaceStation.getBeams());
        assertEquals(orbit, spaceStation.getOrbit());

    }

    @Test
    public void test_assign_without_multiplexing() {
        boolean doMultiplexing = false;
        this.spaceStation = new SpaceStation(this.stationId,
                this.transmitAntenna,
                this.receiveAntenna,
                this.emission,
                this.beams,
                this.orbit);

        beams = new Beam[]{new Beam("one", 1, 100), new Beam("two", 2, 100), new Beam("three", 3, 100)};

        this.spaceStation.set_beams(beams);
        assertTrue(this.spaceStation.isAvailable());

        Beam beam = this.spaceStation.assign(doMultiplexing);
        assertEquals(beam, beams[0]);
        assertTrue(this.spaceStation.isAvailable());

        beam = this.spaceStation.assign(doMultiplexing);
        assertEquals(beam, beams[1]);
        assertTrue(this.spaceStation.isAvailable());

        beam = this.spaceStation.assign(doMultiplexing);
        assertEquals(beam, beams[2]);
        assertFalse(this.spaceStation.isAvailable());
    }

    @Test
    public void test_assign_with_multiplexing() {
        boolean doMultiplexing = true;
        this.spaceStation = new SpaceStation(this.stationId,
                this.transmitAntenna,
                this.receiveAntenna,
                this.emission,
                this.beams,
                this.orbit);

        beams = new Beam[]{new Beam("one", 1, 100), new Beam("two", 2, 100), new Beam("three", 3, 100)};

        this.spaceStation.set_beams(beams);
        assertTrue(this.spaceStation.isAvailable());

        Beam beam = this.spaceStation.assign(doMultiplexing);

        assertEquals(beam, beams[0]);
        assertTrue(this.spaceStation.isAvailable());

        for (int idx = 0; idx < this.beams[1].getMultiplicity() - 1; idx++) {
            beam = this.spaceStation.assign(doMultiplexing);
            assertEquals(beam, beams[1]);
            assertTrue(this.spaceStation.isAvailable());
        }

        beam = this.spaceStation.assign(doMultiplexing);

        assertEquals(beam, beams[1]);
        assertTrue(this.spaceStation.isAvailable());

        for (int idx = 0; idx < this.beams[2].getMultiplicity() - 1; idx++) {
            beam = this.spaceStation.assign(doMultiplexing);
            assertEquals(beam, beams[2]);
            assertTrue(this.spaceStation.isAvailable());
        }

        beam = this.spaceStation.assign(doMultiplexing);
        assertEquals(beam, beams[2]);
        assertFalse(this.spaceStation.isAvailable());
    }

    // TODO: Test function r_gei = compute_r_gei(this, dNm)
    // TODO: Test function r_ger = compute_r_ger(this, dNm)

    @Test
    public void test_reset() {
        boolean doMultiplexing = false;

        this.spaceStation = new SpaceStation(this.stationId,
                this.transmitAntenna,
                this.receiveAntenna,
                this.emission,
                this.beams,
                this.orbit);

        beams = new Beam[]{new Beam("one", 1, 100), new Beam("two", 2, 100), new Beam("three", 3, 100)};

        this.spaceStation.set_beams(beams);

        assertTrue(this.spaceStation.isAvailable());

        Beam beam = this.spaceStation.assign(doMultiplexing);

        assertEquals(beam, beams[0]);
        assertTrue(this.spaceStation.isAvailable());

        beam = this.spaceStation.assign(doMultiplexing);

        assertEquals(beam, beams[1]);
        assertTrue(this.spaceStation.isAvailable());

        beam = this.spaceStation.assign(doMultiplexing);

        assertEquals(beam, beams[2]);
        assertFalse(this.spaceStation.isAvailable());

        this.spaceStation.reset();

        for (Beam beamItem : this.spaceStation.getBeams()) {
            assertTrue(beamItem.isAvailable());
            assertFalse(beamItem.isMultiplexed());
            assertTrue(TestUtility.isDoublesEquals(0, beamItem.getDivisions()));
        }

        assertTrue(this.spaceStation.isAvailable());
    }
}