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
