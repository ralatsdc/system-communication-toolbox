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

/**
 * Contains year, month, day, hour, minute, and second.
 */
public class YMDHMS {

	public int year;
	public int month;
	public int day;
	public int hour;
	public int minute;
	public double second;

	/**
	 * Constructs an YMDHMS.
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
	 * @return The YMDHMS containing the year, month, day, hour, minute, and
	 *         second.
	 */
	public YMDHMS(int year, int month, int day, int hour, int minute, double second) {
		this.year = year;
		this.month = month;
		this.day = day;
		this.hour = hour;
		this.minute = minute;
		this.second = second;
	}

	public boolean isEqual(YMDHMS that) {
		return this.year == that.year && this.month == that.month && this.day == that.day && this.hour == that.hour
				&& this.minute == that.minute && this.second == that.second;
	}
}
