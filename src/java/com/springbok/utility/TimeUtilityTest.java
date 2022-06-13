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
package com.springbok.utility;

import static org.junit.Assert.*;

import org.junit.Test;

import com.springbok.twobody.YMDHMS;
import java.util.GregorianCalendar;

import com.springbok.twobody.ModJulianDate;

public class TimeUtilityTest {

	@Test
	public void test_date2jd() {
		// Tests date2jd method.

		// http://aa.usno.navy.mil/data/docs/JulianDate.php
		double jd_expected = 2456971.500000;

		double jd_actual = TimeUtility.date2jd(2014, 11, 10, 0, 0, 0);

		assertTrue(jd_actual == jd_expected);
	}

	@Test
	public void test_date2mjd() {
		// Tests date2mjd method.

		double mjd_expected = 56971.000000;

		double mjd_actual = TimeUtility.date2mjd(2014, 11, 10, 0, 0, 0);

		assertTrue(mjd_actual == mjd_expected);
	}

	// TODO: Implement
	public void test_days2hms() {
		// HMS hms = TimeUtility.days2hms(days);
	}

	@Test
	public void test_jd2date() {
		// Tests jd2date method.

		double jd_input = 2456971.500000;

		int year_expected = 2014;
		int month_expected = 11;
		int day_expected = 10;
		int hour_expected = 0;
		int minute_expected = 0;
		int second_expected = 0;

		YMDHMS ymdhms_expected = new YMDHMS(year_expected, month_expected, day_expected, hour_expected, minute_expected,
				second_expected);

		YMDHMS ymdhms_actual = TimeUtility.jd2date(jd_input);

		assertTrue(ymdhms_actual.isEqual(ymdhms_expected));
	}

	@Test
	public void test_mjd2date() {
		// Tests mjd2date method.

		double mjd_input = 56971.000000;

		int year_expected = 2014;
		int month_expected = 11;
		int day_expected = 10;
		int hour_expected = 0;
		int minute_expected = 0;
		double second_expected = 0;

		YMDHMS ymdhms_expected = new YMDHMS(year_expected, month_expected, day_expected, hour_expected, minute_expected,
				second_expected);

		YMDHMS ymdhms_actual = TimeUtility.mjd2date(mjd_input);

		assertTrue(ymdhms_actual.isEqual(ymdhms_expected));
	}

	@Test
	public void test_mjd2jd() {
		// Tests mjd2jd method.

		double jd_expected = 2456971.500000;

		double mjd_input = 56971.000000;

		double jd_actual = TimeUtility.mjd2jd(mjd_input);

		assertTrue(jd_actual == jd_expected);
	}

	@Test
	public void testTimeAccuracy() {
		double expectedSecInOneDay = 60.0 * 60.0 * 24.0;
		GregorianCalendar gregorianTimepoint1 = new GregorianCalendar(2018, 10, 16, 18, 1, 42);
		GregorianCalendar gregorianTimepoint2 = new GregorianCalendar(2018, 10, 17, 18, 1, 42);

		GregorianCalendar gregorianTimepoint3 = new GregorianCalendar(2018, 10, 16, 18, 1, 42);
		GregorianCalendar gregorianTimepoint4 = new GregorianCalendar(2018, 10, 16, 18, 1, 43);

		ModJulianDate mjd1 = TimeUtility.gc2mjd(gregorianTimepoint1);
		ModJulianDate mjd2 = TimeUtility.gc2mjd(gregorianTimepoint2);
		ModJulianDate mjd3 = TimeUtility.gc2mjd(gregorianTimepoint3);
		ModJulianDate mjd4 = TimeUtility.gc2mjd(gregorianTimepoint4);

		double numberOfSecondsInMJDOneDay = (expectedSecInOneDay * (mjd2.getAsDouble() - mjd1.getAsDouble()));

		double oneSecMJD = mjd4.getAsDouble() - mjd3.getAsDouble();
		double expectedOneSecMJD = 1.0 / expectedSecInOneDay;

		System.out.println("Expected number of MJD seconds in one day: " + expectedSecInOneDay);
		System.out.println("number of MJD seconds in one day: " + numberOfSecondsInMJDOneDay);
		double differenceFromExpected = Math.abs(expectedSecInOneDay - numberOfSecondsInMJDOneDay);
		System.out.println("difference is: " + differenceFromExpected);
		assertTrue(differenceFromExpected < TestUtility.HIGH_PRECISION);

		System.out.println("Expected MJD in one second: " + expectedOneSecMJD);
		System.out.println("MJD in one second: " + oneSecMJD);
		differenceFromExpected = Math.abs(expectedOneSecMJD - oneSecMJD);
		System.out.println("difference is: " + differenceFromExpected);
		assertTrue(differenceFromExpected < TestUtility.MEDIUM_PRECISION);
	}
}
