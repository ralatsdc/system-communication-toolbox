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

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.SimpleTimeZone;

import com.springbok.twobody.ModJulianDate;
import com.springbok.twobody.YMDHMS;

/**
 * Provides for handling times by enabling conversion between Modified Julian
 * Day (MJD) and the Gregorian Calendar.
 * 
 * @author Ray LeClair
 */
@SuppressWarnings("serial")
public class TimeUtility implements Serializable {

	/**
	 * Converts from Modified Julian Day to Gregorian calendar date.
	 * 
	 * @param d
	 *            Modified Julian day
	 * @return Gregorian calendar date
	 */
	public static GregorianCalendar mjd2gc(double d) {
		ModJulianDate mjd = new ModJulianDate(d);
		return mjd2gc(mjd);
	}

	/**
	 * Converts from Modified Julian Day to Gregorian calendar date.
	 * 
	 * @param d
	 *            Modified Julian day
	 * @return Gregorian calendar date
	 */
	public static GregorianCalendar mjd2gc(ModJulianDate d) {
		SimpleTimeZone stz = new SimpleTimeZone(0, "GMT");
		GregorianCalendar gc = new GregorianCalendar(stz);
		gc.clear();
		gc.set(d.getYear(), d.getMonth() - 1, d.getDay(), d.getHour(), d.getMinute(), (int) d.getSecond());
		// Note that months are 0-based.
		long millis = gc.getTimeInMillis();
		gc.clear();
		gc.setTimeInMillis(millis + (long) ((d.getSecond() - (int) d.getSecond()) * 1000));
		return gc;
	}

	/**
	 * Converts from Gregorian calendar date to Modified Julian Day.
	 * 
	 * @param gc
	 *            Gregorian calendar date
	 * @return Modified Julian day
	 */
	public static ModJulianDate gc2mjd(GregorianCalendar gc) {
		// TODO: Validate this conversion.
		return new ModJulianDate(40587 + gc.getTimeInMillis() / 86400000.0);
	}

	/**
	 * Formats a Gregorian Calendar date for logging.
	 * 
	 * @param gc
	 *            A Gregorian Calendar date
	 * @return A formatted string
	 */
	public static String format(GregorianCalendar gc) {
		return String.format("%04d-%02d-%02d %02d:%02d:%02d.%03d", gc.get(Calendar.YEAR), gc.get(Calendar.MONTH) + 1,
				gc.get(Calendar.DAY_OF_MONTH), gc.get(Calendar.HOUR_OF_DAY), gc.get(Calendar.MINUTE),
				gc.get(Calendar.SECOND), gc.get(Calendar.MILLISECOND));
	}

	/**
	 * Returns the Julian day number of the given date (Gregorian calendar) plus
	 * a fractional part depending on the time of day.
	 *
	 * Start of the JD (Julian day) count is from 0 at 12 noon 1 January -4712
	 * (4713 BC), Julian proleptic calendar. Note that this day count conforms
	 * with the astronomical convention starting the day at noon, in contrast
	 * with the civil practice where the day starts with midnight.
	 *
	 * Astronomers have used the Julian period to assign a unique number to
	 * every day since 1 January 4713 BC. This is the so-called Julian Day (JD).
	 * JD 0 designates the 24 hours from noon UTC on 1 January 4713 BC (Julian
	 * proleptic calendar) to noon UTC on 2 January 4713 BC.
	 * 
	 * Sources: - http://tycho.usno.navy.mil/mjd.html - The Calendar FAQ
	 * (http://www.faqs.org)
	 * 
	 * Author: Peter J. Acklam, Time-stamp: 2002-05-24 13:30:06 +0200, E-mail:
	 * pjacklam@online.no, URL: http://home.online.no/~pjacklam
	 * 
	 * @param year
	 *            The year
	 * @param month
	 *            The month (January == 1)
	 * @param day
	 *            The day
	 * @param hour
	 *            The hour
	 * @param minute
	 *            The minute
	 * @param second
	 *            The second (with fractional part)
	 * @return Julian day number
	 */
	public static double date2jd(int year, int month, int day, int hour, int minute, double second) {

		// The following algorithm is a modified version of the one found in the
		// Calendar FAQ
		int a = (int) Math.floor((14 - month) / 12);
		int y = year + 4800 - a;
		int m = month + 12 * a - 3;

		// For a date in the Gregorian calendar:
		double jd = day + Math.floor((153 * m + 2) / 5) + y * 365 + Math.floor(y / 4) - Math.floor(y / 100)
				+ Math.floor(y / 400) - 32045 + (second + 60 * minute + 3600 * (hour - 12)) / 86400;

		return jd;
	}

	/**
	 * Returns the modified Julian day number of the given date plus a
	 * fractional part depending on the day and time of day.
	 *
	 * Start of the MJD (modified Julian day) count is from 0 at 00:00 UTC 17
	 * November 1858 (Gregorian calendar).
	 *
	 * Author: Peter J. Acklam, Time-stamp: 2002-03-03 12:52:13 +0100, E-mail:
	 * pjacklam@online.no, URL: http://home.online.no/~pjacklam
	 * 
	 * @param year
	 *            The year
	 * @param month
	 *            The month (January == 1)
	 * @param day
	 *            The day
	 * @param hour
	 *            The hour
	 * @param minute
	 *            The minute
	 * @param second
	 *            The second (with fractional part)
	 * @return Modified Julian day number
	 */
	public static double date2mjd(int year, int month, int day, int hour, int minute, double second) {
		double jd = TimeUtility.date2jd(year, month, day, hour, minute, second);
		double mjd = jd - 2400000.5;
		return mjd;
	}

	/**
	 * Converts the number of days to hours, minutes, and seconds.
	 *
	 * The following holds (to within rounding precision):
	 *
	 * DAYS = HOUR / 24 + MINUTE / (24 * 60) + SECOND / (24 * 60 * 60) = (HOUR +
	 * (MINUTE + SECOND / 60) / 60) / 24
	 * 
	 * Author: Peter J. Acklam, Time-stamp: 2002-03-03 12:52:02 +0100, E-mail:
	 * pjacklam@online.no, URL: http://home.online.no/~pjacklam
	 * 
	 * @param days
	 *            The days to convert
	 * @return The HMS object containg the hours, minutes, and seconds
	 */
	public static HMS days2hms(double days) {
		double second = 86400 * days;
		BigDecimal value = new BigDecimal(second / 3600);
		value = value.setScale(0, RoundingMode.DOWN);
		int hour = fix(second / 3600); // get number of hours
		second = second - 3600 * hour; // remove the hours
		int minute = fix(second / 60); // get number of minutes
		second = second - 60 * minute; // remove the minutes
		return new HMS(hour, minute, second);
	}

	/**
	 * Returns the Gregorian calendar date (year, month, day, hour, minute, and
	 * second) corresponding to the Julian day number JD.
	 *
	 * Start of the JD (Julian day) count is from 0 at 12 noon 1 JAN -4712 (4713
	 * BC), Julian proleptic calendar. Note that this day count conforms with
	 * the astronomical convention starting the day at noon, in contrast with
	 * the civil practice where the day starts with midnight.
	 *
	 * Astronomers have used the Julian period to assign a unique number to
	 * every day since 1 January 4713 BC. This is the so-called Julian Day (JD).
	 * JD 0 designates the 24 hours from noon UTC on 1 January 4713 BC (Julian
	 * calendar) to noon UTC on 2 January 4713 BC.
	 * 
	 * Sources: - http://tycho.usno.navy.mil/mjd.html - The Calendar FAQ
	 * (http://www.faqs.org)
	 *
	 * Author: Peter J. Acklam, Time-stamp: 2002-05-24 15:24:45 +0200, E-mail:
	 * pjacklam@online.no, URL: http://home.online.no/~pjacklam
	 * 
	 * @param jd
	 *            The Julian day to convert
	 * @return The YMDHMS corresponding to the Julian day
	 */
	public static YMDHMS jd2date(double jd) {

		// Adding 0.5 to JD and taking FLOOR ensures that the date is correct.
		// Here are some sample values:
		//
		// MJD ... Date ..... Time
		// -1.00 = 1858-11-16 00:00 (not 1858-11-15 24:00!)
		// -0.75 = 1858-11-16 06:00
		// -0.50 = 1858-11-16 12:00
		// -0.25 = 1858-11-16 18:00
		// 00.00 = 1858-11-17 00:00 (not 1858-11-16 24:00!)
		// +0.25 = 1858-11-17 06:00
		// +0.50 = 1858-11-17 12:00
		// +0.75 = 1858-11-17 18:00
		// +1.00 = 1858-11-18 00:00 (not 1858-11-17 24:00!)
		int ijd = (int) Math.floor(jd + 0.5); // integer part

		double fjd = jd - ijd + 0.5; // fraction part
		HMS hms = TimeUtility.days2hms(fjd);

		// The following algorithm is from the Calendar FAQ.
		int a = ijd + 32044;
		int b = (int) Math.floor((4 * a + 3) / 146097);
		int c = a - (int) Math.floor((b * 146097) / 4);

		int d = (int) Math.floor((4 * c + 3) / 1461);
		int e = c - (int) Math.floor((1461 * d) / 4);
		int m = (int) Math.floor((5 * e + 2) / 153);

		int day = e - (int) Math.floor((153 * m + 2) / 5) + 1;
		int month = m + 3 - 12 * (int) Math.floor(m / 10);
		int year = b * 100 + d - 4800 + (int) Math.floor(m / 10);

		return new YMDHMS(year, month, day, hms.hour, hms.minute, hms.second);
	}

	/**
	 * Returns the Gregorian calendar date (year, month, day, hour, minute, and
	 * second) corresponding to the Julian day number JD.
	 *
	 * Start of the JD (Julian day) count is from 0 at 12 noon 1 JAN -4712 (4713
	 * BC), Julian proleptic calendar. Note that this day count conforms with
	 * the astronomical convention starting the day at noon, in contrast with
	 * the civil practice where the day starts with midnight.
	 *
	 * Astronomers have used the Julian period to assign a unique number to
	 * every day since 1 January 4713 BC. This is the so-called Julian Day (JD).
	 * JD 0 designates the 24 hours from noon UTC on 1 January 4713 BC (Julian
	 * calendar) to noon UTC on 2 January 4713 BC.
	 * 
	 * Sources: - http://tycho.usno.navy.mil/mjd.html - The Calendar FAQ
	 * (http://www.faqs.org)
	 * 
	 * Author: Peter J. Acklam, Time-stamp: 2002-03-03 12:50:30 +0100, E-mail:
	 * pjacklam@online.no, URL: http://home.online.no/~pjacklam
	 * 
	 * @param mjd
	 *            The modified Julian day to convert
	 * @return The YMDHMS corresponding to the modified Julian day
	 */
	public static YMDHMS mjd2date(double mjd) {

		/*
		 * We could have got everything by just using
		 *
		 * jd = mjd2jd(mjd); [year, month, day, hour, minute, second] =
		 * jd2date(jd);
		 *
		 * but we lose precision in the fraction part when MJD is converted to
		 * JD because of the large offset (2400000.5) between JD and MJD.
		 */
		double jd = TimeUtility.mjd2jd(mjd);
		YMDHMS ymdhms = TimeUtility.jd2date(jd);

		double fmjd = mjd - Math.floor(mjd);
		HMS hms = TimeUtility.days2hms(fmjd);

		return new YMDHMS(ymdhms.year, ymdhms.month, ymdhms.day, hms.hour, hms.minute, hms.second);
	}

	/**
	 * Converts to Modified Julian day number from Julian day number.
	 *
	 * double jd = TimeUtility.mjd2jd(double mjd) returns the Julian day number
	 * corresponding to the given modified Julian day number.
	 *
	 * See also jd2mjd, date2jd, date2mjd.
	 * 
	 * Author: Peter J. Acklam, Time-stamp: 2002-03-03 12:50:25 +0100, E-mail:
	 * pjacklam@online.no, URL: http://home.online.no/~pjacklam
	 * 
	 * @param mjd
	 *            The modified Julian Day to convert
	 * @return the Julian day corresponding to the Modified Julian day
	 */
	public static double mjd2jd(double mjd) {
		double jd = mjd + 2400000.5;
		return jd;
	}

	/**
	 * Rounds a double towards zero.
	 * 
	 * @param d
	 *            The double to round towards zero
	 * @return The integer value after rounding towards zero
	 */
	public static int fix(double d) {
		BigDecimal value = new BigDecimal(d);
		value = value.setScale(0, RoundingMode.DOWN);
		return value.intValue();
	}

	/**
	 * Contains hour, minute, and second.
	 */
	public static class HMS {
		public int hour;
		public int minute;
		public double second;

		/**
		 * Constructs an HMS.
		 * 
		 * @param hour
		 *            The hour
		 * @param minute
		 *            The minute
		 * @param second
		 *            The second (with fractional part)
		 * @return The HMS containing the hour, minute, and second
		 */
		public HMS(int hour, int minute, double second) {
			this.hour = hour;
			this.minute = minute;
			this.second = second;
		}
	}

	/**
	 * Perform a few simple tests.
	 * 
	 * @param args
	 *            Not required.
	 */
	public static void main(String[] args) {
		SimpleTimeZone stz = new SimpleTimeZone(0, "GMT");
		GregorianCalendar gc = new GregorianCalendar(stz);
		gc.clear();
		gc.set(1973, 0, 18, 3, 45, 50);
		// Note that months are 0-based.
		System.out.println("Customized format gives: " + format(gc));
	}
}
