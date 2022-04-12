/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.antenna;

import com.springbok.pattern.PatternSF__601V01;
import com.springbok.pattern.SpacePattern;
import com.springbok.utility.TestUtility;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

/**
 * Tests methods of SpaceStationAntenna class.
 */
public class SpaceStationAntennaTest {

    private static final double Phi0_input = 2;

    // Antenna name
    private static final String name = "RM";

    // Antenna gain [dB]
    private static final double gain = 28.000000000000000;

    // Antenna pattern identifier
    private static final long pattern_id = 94L;

    // Antenna pattern
    private static final SpacePattern pattern = new PatternSF__601V01(Phi0_input);

    // Antenna noise temperature [K]
    private static final double noise_t = 525D;


    /**
     * Test the SpaceStationAntenna constructor.
     */
    @Test
    public void testSpaceStationAntennaConstructor() {
        SpaceStationAntenna antenna = new SpaceStationAntenna(
                name,
                gain,
                pattern_id,
                pattern,
                noise_t
        );
        assertEquals(name, antenna.get_name());
        assertTrue(TestUtility.isDoublesEquals(gain, antenna.get_gain()));
        assertEquals(pattern_id, antenna.get_pattern_id());
        assertEquals(pattern, antenna.get_pattern());
        assertTrue(TestUtility.isDoublesEquals(noise_t, antenna.get_noise_t()));
    }
}