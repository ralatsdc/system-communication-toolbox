/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import com.springbok.utility.TestUtility;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of PatternSRR_406V01 class
 */
public class PatternSRR_406V01Test {
	private static final double Beamlet_input = 0.6;
	private static final double Phi0_input = 2.0;
	private static final double GainMax_input = 57.0;

	private static final double[] Phi_input = new double[]{0.2, 2.0, 4.0, 150.0};
	private static final double[] G_expected = new double[]{56.88, 31.699999999999999,
			27.0, 0.0};
	private static final double[] Gx_expected = new double[]{18.830299622427006, 24.0,
			17.0, 0.0};

	/**
	 * Tests PatternSRR_406V01 method
	 */
	@Test
	public void test_PatternSRR_406V01() {
		PatternSRR_406V01 p = new PatternSRR_406V01(Beamlet_input, Phi0_input);

		assertTrue(TestUtility.isDoublesEquals(0.6, p.getBeamlet()));
		assertTrue(TestUtility.isDoublesEquals(2.0, p.getPhi0()));
	}

	/**
	 * Tests gain method
	 */
	@Test
	public void test_gain() {
		PatternSRR_406V01 p = new PatternSRR_406V01(Beamlet_input, Phi0_input);

		Gain[] gains = new Gain[Phi_input.length];
		Map<String, Object> options = new HashMap<String, Object>();
		options.put("DoValidate", false);
		options.put("GainMax", GainMax_input);

		for (int i = 0; i < gains.length; i++) {
			Gain g = p.gain(Phi_input[i], options);
			gains[i] = g;
		}
		for (int i = 0; i < gains.length; i++) {
			assertTrue(TestUtility.isDoublesEquals(G_expected[i], gains[i].G));
			assertTrue(TestUtility.isDoublesEquals(Gx_expected[i], gains[i].Gx));
		}
	}
}