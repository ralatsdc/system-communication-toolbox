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
package com.springbok.sgp4v;

import java.io.Serializable;

import Jama.Matrix;

import com.springbok.station.EarthStation;
import com.springbok.twobody.ModJulianDate;

/**
 * Provides transformations between coordinate systems using methods provided by
 * Arthur Lue. The following acronyms are used:
 * <ul>
 * <li>TEMED - True Equator Mean Equinox of Date (Earth Centered, precession and
 * less accurate nutation modeled)</li>
 * <li>TETED - True Equator True Equinox of Date (Earth Centered, precession and
 * more accurate nutation modeled)</li>
 * <li>CIRS - Celestial Intermediate Reference System (Earth Centered,
 * precession and more accurate nutation modeled)</li>
 * <li>TIRS - Terrestrial Intermediate Reference System (Earth Centered and
 * fixed, precession and more accurate nutation modeled)</li>
 * <li>ITRS - International Terrestrial Reference System (Earth Centered and
 * fixed, precession, more accurate nutation, and polar motion modeled)</li>
 * <li>SEZ - South–East–Zenith</li>
 * </ul>
 * See doc/java/com/synterein/sgp4v/Time-Space-Coordinate-Conventions.pdf.
 * 
 * @author Raymond LeClair
 */
@SuppressWarnings("serial")
public final class Sgp4Coordinates implements Serializable {

	/**
	 * Computes the local tangent position vector of a satellite observed by a
	 * sensor given the geocentric equatorial inertial position vector at a
	 * date.
	 * 
	 * @param r_gei
	 *            Geocentric equatorial inertial position vector [er]
	 * @param sensor
	 *            Sensor at which position vectors apply
	 * @param dNm
	 *            Modified Julian date at which the position vectors occur
	 * @return Local tangent position vector [er]
	 */
	public static Matrix gei2ltp(Matrix r_gei, EarthStation sensor, ModJulianDate dNm) {
		Matrix TEMED = r_gei; // Returned by SGP4
		Matrix TETED = TEMED; // Ignores difference due to less accurate
								// nutation model
		Matrix CIRS = TETEDToCIRS(dNm, TETED);
		Matrix TIRS = CIRSToTIRS(dNm, CIRS);
		Matrix ITRS = TIRS; // Ignores polar motion
		Matrix ITRS_0 = sensor.get_R_ger();
		double geodetic_latitude = sensor.get_varphi();
		double longitude = sensor.get_lambda();
		Matrix SEZ = ITRSToSEZ(ITRS, ITRS_0, geodetic_latitude, longitude);
		Matrix r_ltp = com.springbok.twobody.Coordinates.R_z(Math.PI / 2.0).times(SEZ);
		// System.out.println("r_ltp"); r_ltp.print(16, 8);
		return r_ltp;
	}

	/**
	 * Converts TETED to CIRS.
	 * 
	 * @param dNm
	 *            Modified Julian day
	 * @param TETED
	 *            Position vector in the True Equator True Equinox of Date
	 *            coordinate system (Earth Centered, precession and more
	 *            accurate nutation modeled)
	 * @return Position vector in the (CIRS) Celestial Intermediate Reference
	 *         System (Earth Centered, precession and more accurate nutation
	 *         modeled)
	 */
	public static Matrix TETEDToCIRS(ModJulianDate dNm, Matrix TETED) {
		double T = (dNm.getAsDouble() - 51544.5) / 36525.0;
		double epsilon = (Math.PI / (180.0 * 3600.0)) * (-0.014506 - 4612.156534 * T - 1.3915817 * Math.pow(T, 2)
				+ 0.00000044 * Math.pow(T, 3) + 0.000029956 * Math.pow(T, 4) + 0.0000000368 * Math.pow(T, 5));
		Matrix CIRS = com.springbok.twobody.Coordinates.R_z(-epsilon).times(TETED);
		return CIRS;
	}

	/**
	 * Converts CIRS to TIRS
	 * 
	 * @param dNm
	 *            Modified Julian day
	 * @param CIRS
	 *            Position vector in the Celestial Intermediate Reference System
	 *            (Earth Centered, precession and more accurate nutation
	 *            modeled)
	 * @return Position vector in the (TIRS) Terrestrial Intermediate Reference
	 *         System (Earth Centered and fixed, precession and more accurate
	 *         nutation modeled)
	 */
	public static Matrix CIRSToTIRS(ModJulianDate dNm, Matrix CIRS) {
		double T = dNm.getAsDouble() - 51544.5;
		double angle = 2 * Math.PI * (0.7790572732640 + 1.00273781191135448 * T);
		Matrix TIRS = com.springbok.twobody.Coordinates.R_z(angle).times(CIRS);
		return TIRS;
	}

	/**
	 * Converts ITRS to SEZ.
	 * 
	 * @param ITRS
	 *            Position vector in the International Terrestrial Reference
	 *            System (Earth Centered and fixed, precession, more accurate
	 *            nutation, and polar motion modeled)
	 * @param ITRS_0
	 *            Site position vector in the International Terrestrial
	 *            Reference System (Earth Centered and fixed, precession, more
	 *            accurate nutation, and polar motion modeled)
	 * @return Position vector in the (SEZ) Site South–East–Zenith coordinate
	 *         system
	 */
	public static Matrix ITRSToSEZ(Matrix ITRS, Matrix ITRS_0, double geodetic_latitude, double longitude) {
		Matrix X1 = ITRS.minus(ITRS_0);
		Matrix X2 = com.springbok.twobody.Coordinates.R_z(longitude).times(X1);
		Matrix SEZ = com.springbok.twobody.Coordinates.R_y(Math.PI / 2 - geodetic_latitude).times(X2);
		return SEZ;
	}

	/**
	 * Converts SEZ to ITRS.
	 * 
	 * @param SEZ
	 *            Position vector in the South–East–Zenith coordinate system
	 * @param ITRS_0
	 *            Site position vector in the International Terrestrial
	 *            Reference System (Earth Centered and fixed, precession, more
	 *            accurate nutation, and polar motion modeled)
	 * @return Position vector in the (ITRS) International Terrestrial Reference
	 *         System (Earth Centered and fixed, precession, more accurate
	 *         nutation, and polar motion modeled)
	 */
	public static Matrix SEZToITRS(Matrix SEZ, Matrix ITRS_0, double geodetic_latitude, double longitude) {
		Matrix X1 = com.springbok.twobody.Coordinates.R_y(geodetic_latitude - Math.PI / 2.0).times(SEZ);
		Matrix X2 = com.springbok.twobody.Coordinates.R_z(-longitude).times(X1);
		Matrix ITRS = X2.plus(ITRS_0);
		return ITRS;
	}

	/**
	 * Converts CIRS to TIRS
	 * 
	 * @param dNm
	 *            Modified Julian day
	 * @param TIRS
	 *            Position vector in the Terrestrial Intermediate Reference
	 *            System (Earth Centered and fixed, precession and more accurate
	 *            nutation modeled)
	 * @return Position vector in the (CIRS) Celestial Intermediate Reference
	 *         System (Earth Centered, precession and more accurate nutation
	 *         modeled)
	 */
	public static Matrix TIRSToCIRS(ModJulianDate dNm, Matrix TIRS) {
		double T = dNm.getAsDouble() - 51544.5;
		double angle = 2.0 * Math.PI * (0.7790572732640 + 1.00273781191135448 * T);
		Matrix CIRS = com.springbok.twobody.Coordinates.R_z(-angle).times(TIRS);
		return CIRS;
	}

	/**
	 * Converts TETED to CIRS.
	 * 
	 * @param dNm
	 *            Modified Julian day
	 * @param CIRS
	 *            Position vector in the Celestial Intermediate Reference System
	 *            (Earth Centered, precession and more accurate nutation
	 *            modeled)
	 * @return Position vector in the (TETED) True Equator True Equinox of Date
	 *         coordinate system (Earth Centered, precession and more accurate
	 *         nutation modeled)
	 */
	public static Matrix CIRSToTETED(ModJulianDate dNm, Matrix CIRS) {
		double T = (dNm.getAsDouble() - 51544.5) / 36525.0;
		double epsilon = (Math.PI / (180.0 * 3600.0)) * (-0.014506 - 4612.156534 * T - 1.3915817 * Math.pow(T, 2)
				+ 0.00000044 * Math.pow(T, 3) + 0.000029956 * Math.pow(T, 4) + 0.0000000368 * Math.pow(T, 5));
		Matrix TETED = com.springbok.twobody.Coordinates.R_z(epsilon).times(CIRS);
		return TETED;
	}

	/**
	 * Computes the inertial geocentric equatorial position vector of a
	 * satellite given the local tangent position vector observed at a date by a
	 * given sensor.
	 * 
	 * @param r_ltp
	 *            Local tangent position vector [er]
	 * @param sensor
	 *            Sensor at which position vectors apply
	 * @param dNm
	 *            Modified Julian date at which the position vectors occur
	 * @return Inertial geocentric equatorial position vector [er]
	 */
	public static Matrix ltp2gei(Matrix r_ltp, EarthStation sensor, ModJulianDate dNm) {
		Matrix SEZ = com.springbok.twobody.Coordinates.R_z(-Math.PI / 2.0).times(r_ltp);
		Matrix ITRS_0 = sensor.get_R_ger();
		double geodetic_latitude = sensor.get_varphi();
		double longitude = sensor.get_lambda();
		Matrix ITRS = SEZToITRS(SEZ, ITRS_0, geodetic_latitude, longitude);
		Matrix TIRS = ITRS; // Ignores polar motion
		Matrix CIRS = TIRSToCIRS(dNm, TIRS);
		Matrix TETED = CIRSToTETED(dNm, CIRS);
		Matrix TEMED = TETED; // Ignores difference due to less accurate
								// nutation model
		Matrix r_gei = TEMED; // Returned by SGP4
		// System.out.println("r_gei"); r_gei.print(16, 8);
		return r_gei;
	}
}
