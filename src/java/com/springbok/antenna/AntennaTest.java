/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.antenna;

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests methods of Antenna class.
 * 
 * @author raymondleclair
 */
public class AntennaTest {

	// Antenna name
	private final String name = "RAMBOUILLET";
	// Antenna gain [dB]
	private final double gain = 54.0;
	// Antenna noise temperature [K]
	private final double noise_t = Double.NaN;

	// An antenna
	private Antenna antenna;

	@Before
	public void setUp() throws Exception {

		// Compute derived properties
		this.antenna = new Antenna(this.name, this.gain, this.noise_t);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	/*
	 * Tests Antenna method.
	 */
	public void test_Antenna() {
		assertEquals(this.antenna.get_name(), this.name);
		assertEquals(this.antenna.get_gain(), this.gain, 1.0e-16);
		assertTrue(Double.isNaN(this.antenna.get_noise_t()));
	}
}
