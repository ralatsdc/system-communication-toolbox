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
