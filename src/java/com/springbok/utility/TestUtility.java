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

/**
 * Defines properties and methods for unit testing.
 * 
 * @author Raymond LeClair
 */
public final class TestUtility {

	public static final double HIGH_PRECISION = 1e-14;
	public static final double MEDIUM_PRECISION = 1e-11;
	public static final double LOW_PRECISION = 1e-7;
	public static final double VERY_LOW_PRECISION = 1e-4;

	public static final String HIGH_PRECISION_DESC = "Within high precision.";
	public static final String MEDIUM_PRECISION_DESC = "Within medium precision.";
	public static final String LOW_PRECISION_DESC = "Within low precision.";
	public static final String VERY_LOW_PRECISION_DESC = "Within very low precision.";

	public static boolean isDoublesEquals (double first, double second) {
		return Math.abs(first - second) < LOW_PRECISION;
	}
}
