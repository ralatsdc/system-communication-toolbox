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

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class StationTest {

	// Input identifier for station
	private final String stationId_input = "one";

	// A station
	private Station station;

	@Before
	public void setUp() throws Exception {

		// Compute derived properties
		this.station = new Station(this.stationId_input);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	/* Tests Station method. */
	public void test_Station() {

		String stationId_expected = this.stationId_input;

		String stationId_actual = this.station.getStationId();

		assertTrue(stationId_actual.equals(stationId_expected));
	}

	@Test
	/* Tests set_stationId method. */
	public void test_set_stationId() {

		String stationId_expected = this.stationId_input;

		this.station.set_stationId(this.stationId_input);

		String stationId_actual = this.station.getStationId();

		assertTrue(stationId_actual.equals(stationId_expected));
	}
}
