package com.springbok.twobody;

import com.celestrak.sgp4v.ObjectDecayed;
import Jama.Matrix;

/**
 * Defines methods required to describe an orbit using either Keplerian or
 * Equinoctial elements, and two-body or SGP4 propagation.
 *
 * @author Raymond LeClair
 */
public interface Orbit {

	/**
	 * Computes mean motion.
	 *
	 * @return Mean motion [rad/s]
	 */
	double meanMotion();

	/**
	 * Computes orbital period.
	 *
	 * @return Orbital period [s]
	 */
	double orbitalPeriod();

	/**
	 * Computes geocentric equatorial inertial position vector.
	 *
	 * @param dNm
	 *            MJD calendar date at which the position vector occurs
	 * @return Geocentric equatorial inertial position vector [er]
	 * @throws ObjectDecayed
	 */
	Matrix r_gei(ModJulianDate dNm) throws ObjectDecayed;

	/**Constructs a Orbit.

	 Returns
	 A new Orbit instance
	 */
	Orbit copy();

	ModJulianDate getEpoch();

}
