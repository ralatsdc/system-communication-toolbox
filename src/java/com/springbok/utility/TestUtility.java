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