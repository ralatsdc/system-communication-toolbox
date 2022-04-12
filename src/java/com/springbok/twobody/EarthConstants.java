package com.springbok.twobody;

import java.io.Serializable;

/**
 * Defines Earth physical constants.
 * 
 * @author Raymond LeClair
 */
@SuppressWarnings("serial")
public final class EarthConstants implements Serializable {

	/** The radius of the Earth [km] */
	public static final double R_oplus = 6378.137;

	/** The flattening of the Earth [-] */
	public static final double f = 1.0 / 298.257223563;

	/** The gravitational constant of the Earth [km^3/s^2] */
	public static final double GM_oplus = 398600.4415;

	/** The leading zonal harmonic coefficient [-] */
	public static final double J_2 = 0.0010826269;

	/** The rotational period of the Earth [s] */
	public static final double T_oplus = (360 / 360.9856473) * 86400;
	// [s] = ([deg/rev] / [deg/day]) * ([h/day] * [m/h] * [s/m])

	/** Greenwich hour angle intercept [rad] */
	public static final double Theta_0 = 280.4606 * Math.PI / 180;
	// [rad] = [deg] * [rad/deg]

	/** Greenwich hour angle slope [rad/day] */
	public static final double Theta_dot = 360.9856473 * Math.PI / 180;
	// [rad/day] = [deg/day] * [rad/deg]

	/**
	 * The period [s] and semi-major axis of a circular geostationary orbit [er]
	 */
	public static final double T_gso = T_oplus;
	public static final double a_gso = Math.pow(GM_oplus * Math.pow(T_gso / (2 * Math.PI), 2), 1.0 / 3.0) / R_oplus;
	// [er] = ([km^3/s^2] * ([s/rev] / [rad/rev])^2)^(1/3) / [km/er]

	public static final ModJulianDate epoch = new ModJulianDate(51544.5);

	/**
	 * Computes the Greenwich hour angle. (MG-2.85)
	 * 
	 * @param dNm
	 *            MJD calendar date at which the angle coincides
	 * @return Greenwhich hour angle [rad]
	 */
	public static double Theta(ModJulianDate dNm) {
		return Theta_0 + Theta_dot * dNm.getOffset(epoch) / 86400.0;
		// [rad] = [rad] + [rad / day] * [decimal day]
	}
}
