package com.springbok.twobody;

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.springbok.utility.TestUtility;

public class EarthConstantsTest {

	// Input date number at which the angle coincides
	public final ModJulianDate dNm_input = new ModJulianDate(5.483250000000000e+04);

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	/* Tests Theta method. */
	public void test_Theta() {

		double theta_expected = 20720.5710265505076677;

		double theta_actual = EarthConstants.Theta(this.dNm_input);

		assertTrue(Math.abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);
	}
}
