package com.springbok.twobody;

import Jama.Matrix;
import com.celestrak.sgp4v.ObjectDecayed;

/**
 * Defines methods required to describe a two-body orbit using either Keplerian
 * or Equinoctial elements.
 * 
 * @author Raymond LeClair
 */
public interface TwoBodyOrbit {

	/**
	 * Computes mean position at the given date.
	 * 
	 * @param dNm
	 *            MJD calendar date at which mean position occurs
	 * @return Mean position [rad]
	 */
	double meanPosition(ModJulianDate dNm);

	/**
	 * Solves conventional or generalized Kepler's equation using Newton's or
	 * Halley's method for the eccentric position.
	 * 
	 * @param MP
	 *            Mean position (anomaly or longitude) [rad]
	 * @return Eccentric position (anomaly or longitude) [rad]
	 */
	double keplersEquation(double MP);

	/**
	 * Computes orbital plane inertial position vector.
	 * 
	 * @param EP
	 *            Eccentric position (anomaly or longitude) [rad]
	 * @return Orbital plane inertial position vector [er]
	 */
	Matrix r_goi(double EP);

}
