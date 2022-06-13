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
import com.celestrak.sgp4v.SatElsetException;
import com.celestrak.sgp4v.ValueOutOfRangeException;

/**
 * Defines methods required to perform orbit correction.
 * 
 * @author Raymond LeClair
 */
public interface EstimatedOrbit extends Orbit {

	/**
	 * Sets semi-major axis [er].
	 * 
	 * @param a
	 *            Semi-major axis [er]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_a(double a) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException;

	/**
	 * Gets semi-major axis [er].
	 * 
	 * @return Semi-major axis [er]
	 */
	public double get_a();

	/**
	 * Sets eccentricity [-].
	 * 
	 * @param e
	 *            Eccentricity [-]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_e(double e) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException;

	/**
	 * Gets eccentricity [-].
	 * 
	 * @return Eccentricity [-]
	 */
	public double get_e();

	/**
	 * Sets inclination [rad].
	 * 
	 * @param i
	 *            Inclination [rad]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_i(double i) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException;

	/**
	 * Gets inclination [rad].
	 * 
	 * @return Inclination [rad]
	 */
	public double get_i();

	/**
	 * Sets right ascension of the ascending node [rad].
	 * 
	 * @param Omega
	 *            Right ascension of the ascending node [rad]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_Omega(double Omega) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException;

	/**
	 * Gets right ascension of the ascending node [rad].
	 * 
	 * @return Right ascension of the ascending node [rad]
	 */
	public double get_Omega();

	/**
	 * Sets argument of perigee [rad].
	 * 
	 * @param omega
	 *            Argument of perigee [rad]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_omega(double omega) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException;

	/**
	 * Gets argument of perigee [rad].
	 * 
	 * @return Argument of perigee [rad]
	 */
	public double get_omega();

	/**
	 * Sets mean anomaly [rad].
	 * 
	 * @param M
	 *            Mean anomaly [rad]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_M(double M) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException;

	/**
	 * Gets mean anomaly [rad].
	 * 
	 * @return Mean anomaly [rad]
	 */

	public double get_M();

	/**
	 * Gets epoch MJD calendar date.
	 * 
	 * @return Epoch MJD calendar date
	 */
	public ModJulianDate get_epoch();

}
