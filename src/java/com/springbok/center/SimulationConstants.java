package com.springbok.center;

import java.io.Serializable;

/**
 * Definess simulation constants.
 * 
 * @author Raymond LeClair.
 */
@SuppressWarnings("serial")
public final class SimulationConstants implements Serializable {

	/**
	 * The difference in successive values of eccentric anomaly at which
	 * iterative solution of Kepler's equation ends
	 */
	public static final double precision_E = 1e-6;

	/**
	 * The maximum number of iterations permitted in solving Kepler's equation
	 */
	public static final long max_iteration = 10000;

	/**
	 * The maximum number of iterations permitted in estimating the ratio of the
	 * areas of the sector and triangle defined by the two position vectors
	 */
	public static final double precision_eta = 1e-9;

	/**
	 * Differential modification of each property of the orbit used in computing
	 * the elements of the Jacobian matrix
	 */
	public static final double decimal_delta = 1e-6;

	/**
	 * Maximum difference between the preliminary orbit and the corrected orbit
	 * [s]
	 */
	public static final double max_time_diff = 1.0;

	// TODO: Remove?
	/** Maximum SOAP or Java call attempts. */
	public static final int maximum_call_attempts = 5;

	// TODO: Remove?
	/** Delay between call attempts. [ms] */
	public static final int delay_between_attempts = 1000;

}
