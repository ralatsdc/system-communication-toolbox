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

import com.springbok.utility.TestUtility;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * Tests methods of Beam class.
 */
public class BeamTest {

    private final String name = "RAMBOUILLET";

    /**
     * Tests Beam method.
     */
    @Test
    public void test_Beam() {
        int multiplicity = 1;
        double dutyCycle = 100;

        Beam beam = new Beam(this.name, multiplicity, dutyCycle);

        assertTrue(beam.getName().equals(name));
        assertEquals(multiplicity, beam.getMultiplicity());
        assertTrue(TestUtility.isDoublesEquals(dutyCycle, beam.getDutyCycle()));
    }

    @Test
    public void test_assign_with_multiplicity_one_and_without_multiplexing() {
        int multiplicity = 1;
        boolean doMultiplexing = false;
        double dutyCycle = 100;

        Beam beam = new Beam(this.name, multiplicity, dutyCycle);

        assertTrue(beam.isAvailable());
        assertFalse(beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(0, beam.getDivisions()));

        boolean isAssigned = beam.assign(doMultiplexing);

        assertTrue(isAssigned);
        assertFalse(beam.isAvailable());
        assertEquals(doMultiplexing, beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(1, beam.getDivisions()));

        isAssigned = beam.assign(doMultiplexing);

        assertFalse(isAssigned);
        assertFalse(beam.isAvailable());
        assertEquals(doMultiplexing, beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(1, beam.getDivisions()));
    }

    @Test
    public void test_assign_with_multiplicity_one_and_with_multiplexing() {
        int multiplicity = 1;
        boolean doMultiplexing = true;
        double dutyCycle = 100;

        Beam beam = new Beam(this.name, multiplicity, dutyCycle);

        assertTrue(beam.isAvailable());
        assertFalse(beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(0, beam.getDivisions()));

        boolean isAssigned = beam.assign(doMultiplexing);

        assertTrue(isAssigned);
        assertFalse(beam.isAvailable());
        assertEquals(doMultiplexing, beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(1, beam.getDivisions()));

        isAssigned = beam.assign(doMultiplexing);

        assertFalse(isAssigned);
        assertFalse(beam.isAvailable());
        assertEquals(doMultiplexing, beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(1, beam.getDivisions()));
    }

    @Test
    public void test_assign_with_multiplicity_three_and_without_multiplexing() {
        int multiplicity = 3;
        boolean doMultiplexing = false;
        double dutyCycle = 100;

        Beam beam = new Beam(this.name, multiplicity, dutyCycle);

        assertTrue(beam.isAvailable());
        assertFalse(beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(0, beam.getDivisions()));

        boolean isAssigned = beam.assign(doMultiplexing);

        assertTrue(isAssigned);
        assertFalse(beam.isAvailable());
        assertEquals(doMultiplexing, beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(1, beam.getDivisions()));

        isAssigned = beam.assign(doMultiplexing);

        assertFalse(isAssigned);
        assertFalse(beam.isAvailable());
        assertEquals(doMultiplexing, beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(1, beam.getDivisions()));
    }

    @Test
    public void test_assign_with_multiplicity_three_and_with_multiplexing() {
        int multiplicity = 3;
        boolean doMultiplexing = true;
        double dutyCycle = 100;

        Beam beam = new Beam(this.name, multiplicity, dutyCycle);

        assertTrue(beam.isAvailable());
        assertFalse(beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(0, beam.getDivisions()));

        for (int idx = 1; idx < multiplicity; idx++) {
            boolean isAssigned = beam.assign(doMultiplexing);

            assertTrue(isAssigned);
            assertTrue(beam.isAvailable());
            assertEquals(doMultiplexing, beam.isMultiplexed());
            assertTrue(TestUtility.isDoublesEquals(idx, beam.getDivisions()));
        }

        boolean isAssigned = beam.assign(doMultiplexing);

        assertTrue(isAssigned);
        assertFalse(beam.isAvailable());
        assertEquals(doMultiplexing, beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(multiplicity, beam.getDivisions()));

        isAssigned = beam.assign(doMultiplexing);

        assertFalse(isAssigned);
        assertFalse(beam.isAvailable());
        assertEquals(doMultiplexing, beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(multiplicity, beam.getDivisions()));
    }

    @Test
    public void test_reset() {
        int multiplicity = 1;
        boolean doMultiplexing = true;
        double dutyCycle = 100;

        Beam beam = new Beam(this.name, multiplicity, dutyCycle);

        assertTrue(beam.isAvailable());
        assertFalse(beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(0, beam.getDivisions()));

        boolean isAssigned = beam.assign(doMultiplexing);

        assertTrue(isAssigned);
        assertFalse(beam.isAvailable());
        assertEquals(doMultiplexing, beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(1, beam.getDivisions()));

        beam.reset();

        assertTrue(beam.isAvailable());
        assertFalse(beam.isMultiplexed());
        assertTrue(TestUtility.isDoublesEquals(0, beam.getDivisions()));
    }
}
