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
