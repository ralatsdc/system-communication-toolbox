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
package com.springbok.simulation;

import java.util.GregorianCalendar;

import com.springbok.station.EarthStation;
import com.springbok.twobody.Coordinates;
import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.KeplerianOrbit;
import com.springbok.twobody.ModJulianDate;

import Jama.Matrix;

public class Timing {

	public static void main(String[] args) {

		/** Station identifier */
		String stationId = "one";
		/** Geodetic latitude [rad] */
		double varphi = 0.0;
		/** Longitude [rad] */
		double lambda = 0.0;

		/** Semi-major axis [er] */
		double a = 6 * EarthConstants.R_oplus;
		/** Eccentricity [-] */
		double e = 0.001;
		/** Inclination [rad] */
		double i = 0.01;
		/** Right ascension of the ascending node [rad] */
		double Omega = 0.0;
		/** Argument of perigee [rad] */
		double omega = 0.0;
		/** Mean anomaly [rad] */
		double M = 0.0;
		/** Epoch Gregorian calendar date */
		ModJulianDate epoch = new ModJulianDate(0.0);
		/** Method to solve Kepler's equation: "newton" or "halley" */
		String method = "halley";

		EarthStation earthStation = new EarthStation(stationId, varphi, lambda);

		KeplerianOrbit orbit = new KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method);

		Matrix r_gei_tmp = null;

		long startTime = System.currentTimeMillis();

		double d_epoch = 1.0 / 86400;

		for (int i_epoch = 0; i_epoch < 100000; i_epoch++) {

			// TODO: Remove
			// epoch.setTimeInMillis(epoch.getTimeInMillis() + d_epoch);
			// epoch.addOffset(d_epoch);
			
			Matrix r_gei_es = earthStation.r_gei(epoch);

			Matrix r_gei_ss = orbit.r_gei(epoch);

			Matrix r_ltp_ss = Coordinates.gei2ltp(r_gei_ss, earthStation, epoch);

			r_gei_tmp = r_gei_es.plus(r_ltp_ss);
		}

		long stopTime = System.currentTimeMillis();

		System.out.println(r_gei_tmp.toString());

		long elapsedTime = stopTime - startTime;

		System.out.println("Elapsed time is " + elapsedTime / 1000.0 + " seconds.");
	}
}
