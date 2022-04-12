package com.springbok.antenna;

import static org.junit.Assert.*;

import org.junit.Test;

import com.springbok.pattern.EarthPattern;
import com.springbok.pattern.PatternELUX201V01;

public class EarthStationAntennaTest {

	/**
	 * Antenna name
	 */
	private static final String NAME = "RAMBOUILLET";
	/**
	 * Antenna emission direction
	 */
	private static final double GAIN = 54.0;
	/**
	 * Antenna pattern identifier
	 */
	private static final long PATTERN_ID = 94;
	/**
	 * Antenna pattern
	 */
	private static final EarthPattern PATTERN = new PatternELUX201V01();
	/**
	 * Antenna noise temperature [K]
	 */
	private static final double NOISE_T = Double.NaN;

	/**
	 * Test the EarthStationAntenna constructor.
	 */
	@Test
	public void testEarthStationAntennaConstructor() {
		EarthStationAntenna antenna = new EarthStationAntenna(NAME, GAIN,
				PATTERN_ID, PATTERN, NOISE_T);
		assertEquals(NAME, antenna.get_name());
		assertTrue(Math.abs(GAIN - antenna.get_gain()) < 0.00001D);
		assertEquals(PATTERN_ID, antenna.get_pattern_id());
		assertEquals(PATTERN, antenna.get_pattern());
		assertTrue(Double.isNaN(NOISE_T) && Double.isNaN(antenna.get_noise_t()));
	}

}
