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
