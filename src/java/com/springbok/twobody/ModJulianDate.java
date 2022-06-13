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
package com.springbok.twobody;

import java.util.Calendar;
import java.util.GregorianCalendar;

import com.springbok.utility.TimeUtility;

/**
 * Provides methods for working with modified Julian dates.
 */
public class ModJulianDate {

	/** The modified Julian date */
	private double value;
	/** The year, month, day, hour, minute, and second */
	private YMDHMS ymdhms;

	/**
	 * Constructs a modified Julian date.
	 * 
	 * @param value
	 *            The modified Julian date value
	 */
	public ModJulianDate(double value) {
		setAsDouble(value);
	}

	/**
	 * Sets the modified Julian date value and corresponding year, month, day,
	 * hour, minute, and second.
	 * 
	 * @param value
	 *            The modified Julian date value
	 */
	public void setAsDouble(double value) {
		this.value = value;
		this.ymdhms = TimeUtility.mjd2date(value);
	}

	/**
	 * Gets the modified Julian date value.
	 * 
	 * @return the modified Julian date value.
	 */
	public double getAsDouble() {
		return value;
	}

	/**
	 * Get the year corresponding to the modified Julian date.
	 * 
	 * @return the year corresponding to the modified Julian date
	 */
	public int getYear() {
		return ymdhms.year;
	}

	/**
	 * Get the month corresponding to the modified Julian date.
	 * 
	 * @return the month corresponding to the modified Julian date
	 */
	public int getMonth() {
		return ymdhms.month;
	}

	/**
	 * Get the day corresponding to the modified Julian date.
	 * 
	 * @return the day corresponding to the modified Julian date
	 */
	public int getDay() {
		return ymdhms.day;
	}

	/**
	 * Get the hour corresponding to the modified Julian date.
	 * 
	 * @return the hour corresponding to the modified Julian date
	 */
	public int getHour() {
		return ymdhms.hour;
	}

	/**
	 * Get the minute corresponding to the modified Julian date.
	 * 
	 * @return the minute corresponding to the modified Julian date
	 */
	public int getMinute() {
		return ymdhms.minute;
	}

	/**
	 * Get the second corresponding to the modified Julian date.
	 * 
	 * @return the second corresponding to the modified Julian date
	 */
	public double getSecond() {
		return ymdhms.second;
	}

	/**
	 * Get the day of year corresponding to the modified Julian date.
	 * 
	 * @return the day of year corresponding to the modified Julian date
	 */
	// TODO: Confirm type
	public int getDayOfYear() {
		GregorianCalendar gc = new GregorianCalendar();
		gc.set(GregorianCalendar.DAY_OF_MONTH, ymdhms.day);
		gc.set(GregorianCalendar.MONTH, ymdhms.month - 1);
		gc.set(GregorianCalendar.YEAR, ymdhms.year);
		return gc.get(GregorianCalendar.DAY_OF_YEAR);
	}

	/**
	 * Get the fractional part of the day of year corresponding to the modified
	 * Julian date.
	 * 
	 * @return the fractional part of the day of year corresponding to the
	 *         modified Julian date
	 */
	public double getFraction() {
		return (ymdhms.hour + (ymdhms.minute + ymdhms.second / 60.0) / 60.0) / 24.0;
	}

	/**
	 * Add an offset in days to the modified Julian date.
	 * 
	 * @param offset
	 *            an offset in days
	 */
	public void addOffset(double offset) {
		setAsDouble(value += offset);
	}

	/**
	 * Get the offset in days of a specified modified Julian date relative to
	 * this modified Julian date.
	 * 
	 * @param mjd
	 * @return the offset in days
	 */
	public double getOffset(ModJulianDate mjd) {
		return (this.value - mjd.value) * 86400;
	}

	/**
	 * Converts a year and day of year, including a fractional part, to a
	 * modified Julian date.
	 * 
	 * @param year
	 *            The year
	 * @param dayOfYear
	 *            The day of year
	 * @return The modified Julian date
	 */
	public static ModJulianDate convertDayOfYear(int year, double dayOfYear) {
		// Note that day of year is 1 at the beginning of the year
		return new ModJulianDate(TimeUtility.date2mjd(year, 1, 0, 0, 0, 0.0) + dayOfYear);
	}

	/**
	 * Tests equality of modified Julian date value.
	 * 
	 * @param that
	 *            A modified Julian date to compare to this modified Julian date
	 * @return The boolean indicating equality
	 */
	public boolean equals(ModJulianDate that) {
		return this.value == that.value;
	}

	/**
	 * Clones this modified Julian date.
	 */
	public ModJulianDate clone() {
		return new ModJulianDate(this.value);
	}
}
