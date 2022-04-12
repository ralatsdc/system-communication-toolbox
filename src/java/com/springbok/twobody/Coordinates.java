package com.springbok.twobody;

import java.io.Serializable;

import Jama.Matrix;

import com.springbok.station.EarthStation;

/**
 * Provides transformations between coordinate systems following Satellite
 * Orbits by Montenbruck and Gill.
 * 
 * @author Raymond LeClair
 */
@SuppressWarnings("serial")
public final class Coordinates implements Serializable {

	/**
	 * Computes orthogonal transformation matrix for a rotation about the x
	 * axis. (MG-pg.27)
	 * <p>
	 * Note that for all transformation matrices, a positive phi corresponds to
	 * a positive (counterclockwise) rotation of the reference axes as viewed
	 * from the positive end of the rotation axis toward the origin.
	 * 
	 * @param phi
	 *            Angle of rotation [rad]
	 * @return Orthogonal transformation matrix
	 */
	public static Matrix R_x(double phi) {
		double[][] elements = { { 1.0, 0.0, 0.0 }, { 0.0, +Math.cos(phi), +Math.sin(phi) },
				{ 0.0, -Math.sin(phi), +Math.cos(phi) } };
		Matrix matrix = new Matrix(elements);
		// System.out.println("R_x"); matrix.print(16, 8);
		return matrix;
	}

	/**
	 * Computes orthogonal transformation matrix for a rotation about the y
	 * axis. (MG-pg.27)
	 * 
	 * @param phi
	 *            Angle of rotation [rad]
	 * @return Orthogonal transformation matrix
	 */
	public static Matrix R_y(double phi) {
		double[][] elements = { { +Math.cos(phi), 0.0, -Math.sin(phi) }, { 0.0, 1.0, 0.0 },
				{ +Math.sin(phi), 0.0, +Math.cos(phi) } };
		Matrix matrix = new Matrix(elements);
		// System.out.println("R_y"); matrix.print(16, 8);
		return matrix;
	}

	/**
	 * Computes orthogonal transformation matrix for a rotation about the z
	 * axis. (MG-pg.27)
	 * 
	 * @param phi
	 *            Angle of rotation [rad]
	 * @return Orthogonal transformation matrix
	 */
	public static Matrix R_z(double phi) {
		double[][] elements = { { +Math.cos(phi), +Math.sin(phi), 0.0 }, { -Math.sin(phi), +Math.cos(phi), 0.0 },
				{ 0.0, 0.0, 1.0 } };
		Matrix matrix = new Matrix(elements);
		// System.out.println("R_z"); matrix.print(16, 8);
		return matrix;
	}

	/**
	 * Computes the orthogonal transformation matrix from geocentric equatorial
	 * rotating coordinates to local tangent coordinates for a given sensor.
	 * (MG-2.93)
	 * 
	 * @param sensor
	 *            Sensor at which position vectors apply
	 * @return Orthogonal transformation matrix
	 */
	public static Matrix E_e2t(EarthStation sensor) {
		Matrix matrix = new Matrix(3, 3);
		int[] rows = { 0, 1, 2 };
		int[] cols = { 0 };
		matrix.setMatrix(rows, cols, e_E(sensor));
		cols[0] = 1;
		matrix.setMatrix(rows, cols, e_N(sensor));
		cols[0] = 2;
		matrix.setMatrix(rows, cols, e_Z(sensor));
		// System.out.println("E_e2t"); matrix.transpose().print(16, 8);
		return matrix.transpose();
	}

	/**
	 * Computes the orthogonal transformation matrix from local tangent
	 * coordinates to geocentric equatorial rotating coordinates for a given
	 * sensor. (MG-2.93)
	 * 
	 * @param sensor
	 *            Sensor at which position vectors apply
	 * @return Orthogonal transformation matrix
	 */
	public static Matrix E_t2e(EarthStation sensor) {
		Matrix matrix = E_e2t(sensor).transpose();
		// System.out.println("E_t2e"); matrix.print(16, 8);
		return matrix;
	}

	/**
	 * Computes the geocentric equatorial rotating position vector of a
	 * satellite given the geocentric equatorial inertial position vector at a
	 * date. (MG-2.89)
	 * 
	 * @param r_gei
	 *            Geocentric equatorial inertial position vector [er]
	 * @param dNm
	 *            MJD calendar date at which the position vectors occur
	 * @return Geocentric equatorial rotating position vector [er]
	 */
	public static Matrix gei2ger(Matrix r_gei, ModJulianDate dNm) {
		Matrix r_ger = Coordinates.R_z(EarthConstants.Theta(dNm)).times(r_gei);
		// System.out.println("r_ger"); r_ger.print(16, 8);
		return r_ger;
	}

	/**
	 * Computes the geocentric equatorial intertial position vector of a
	 * satellite given the geocentric equatorial rotating position vector at a
	 * date. (MG-2.89)
	 * 
	 * @param r_ger
	 *            Geocentric equatorial rotating position vector [er]
	 * @param dNm
	 *            MJD calendar date at which the position vectors occur
	 * @return Geocentric equatorial intertial position vector [er]
	 */
	public static Matrix ger2gei(Matrix r_ger, ModJulianDate dNm) {
		Matrix r_gei = Coordinates.R_z(EarthConstants.Theta(dNm)).transpose().times(r_ger);
		// System.out.println("r_gei"); r_gei.print(16, 8);
		return r_gei;
	}

	/**
	 * Computes the geocentric equatorial rotating position and velocity vectors
	 * of a satellite given the geocentric equatorial inertial position and
	 * velocity vectors at a date. (MG-2.89)
	 * 
	 * @param r_gei
	 *            Geocentric equatorial inertial position vector [er]
	 * @param v_gei
	 *            Geocentric equatorial inertial velocity vector [er/s]
	 * @param dNm
	 *            Date number at which the position vectors occur
	 * 
	 * @return Geocentric equatorial rotating velocity vector [er/s]
	 */
	public static Matrix gei2ger(Matrix r_gei, ModJulianDate dNm, Matrix v_gei) {
		double Theta = EarthConstants.Theta(dNm);
		Matrix R_z = Coordinates.R_z(Theta);
		// Matrix r_ger = R_z.times(r_gei);
		// [er]
		double[][] elements = { { -Math.sin(Theta), +Math.cos(Theta), 0 }, { -Math.cos(Theta), -Math.sin(Theta), 0 },
				{ 0, 0, 0 } };
		Matrix R_z_dot = new Matrix(elements).times(EarthConstants.Theta_dot / 86400);
		// [rad/s]
		Matrix v_ger = R_z.times(v_gei).plus(R_z_dot.times(r_gei));
		// [er/s] = [er/s] + [er] * [rad/day] * [day/s]
		return v_ger;
	}

	/**
	 * Computes the geocentric equatorial inertial position and velocity vectors
	 * of a satellite given the geocentric equatorial rotating position and
	 * velocity vectors at a date. (MG-2.89)
	 * 
	 * @param r_ger
	 *            Geocentric equatorial rotating position vector [er]
	 * @param v_ger
	 *            Geocentric equatorial rotating velocity vector [er/s]
	 * @param dNm
	 *            Date number at which the position vectors occur
	 * 
	 * @return Geocentric equatorial inertial velocity vector [er/s]
	 */
	public static Matrix ger2gei(Matrix r_ger, ModJulianDate dNm, Matrix v_ger) {
		double Theta = EarthConstants.Theta(dNm);
		Matrix R_z = Coordinates.R_z(Theta);
		Matrix r_gei = R_z.transpose().times(r_ger);
		// [er]
		double[][] elements = { { -Math.sin(Theta), +Math.cos(Theta), 0 }, { -Math.cos(Theta), -Math.sin(Theta), 0 },
				{ 0, 0, 0 } };
		Matrix R_z_dot = new Matrix(elements).times(EarthConstants.Theta_dot / 86400);
		// [rad/s]
		Matrix v_gei = R_z.transpose().times(v_ger).plus(R_z_dot.transpose().times(r_ger));
		// [er/s] = [er/s] + [er] * [rad/day] * [day/s]
		return v_gei;
	}

	/**
	 * Computes the latitude, longitude, and altitude of a satellite given the
	 * inertial geocentric equatorial position vector at a date. (MG-2.95)
	 * 
	 * @param r_gei
	 *            Geocentric equatorial inertial position vector [er]
	 * @param dNm
	 *            MJD calendar date at which the position vectors occur
	 * @return Latitude, longitude, and altitude [rad, rad, er]
	 */
	public static Matrix gei2lla(Matrix r_gei, ModJulianDate dNm) {
		Matrix r_ger = gei2ger(r_gei, dNm);
		double lattitude = Math.atan2(r_ger.get(2, 0),
				Math.sqrt(Math.pow(r_ger.get(0, 0), 2) + Math.pow(r_ger.get(1, 0), 2)));
		// (-pi, pi)
		double longitude = checkWrap(Math.atan2(r_ger.get(1, 0), r_ger.get(0, 0)));
		// (0, 2 * pi)
		double altitude = Math
				.sqrt(Math.pow(r_ger.get(0, 0), 2) + Math.pow(r_ger.get(1, 0), 2) + Math.pow(r_ger.get(2, 0), 2)) - 1;
		double[][] elements = { { lattitude }, { longitude }, { altitude } };
		Matrix r_lla = new Matrix(elements);
		// System.out.println("r_lla"); r_lla.print(16, 8);
		return r_lla;
	}

	/**
	 * Computes the inertial geocentric equatorial positon vector given the
	 * latitude, longitude, and altitude of a satellite at a date. (MG-2.90
	 * modified for arbitrary altitude)
	 * 
	 * @param r_lla
	 *            Latitude, longitude, and altitude [rad, rad, er]
	 * @param dNm
	 *            MJD calendar date at which the position vectors occur
	 * @return Geocentric equatorial inertial position vector [er]
	 */
	public static Matrix lla2gei(Matrix r_lla, ModJulianDate dNm) {
		double R = 1 + r_lla.get(2, 0);
		double x = R * Math.cos(r_lla.get(0, 0)) * Math.cos(r_lla.get(1, 0));
		double y = R * Math.cos(r_lla.get(0, 0)) * Math.sin(r_lla.get(1, 0));
		double z = R * Math.sin(r_lla.get(0, 0));
		double[][] elements = { { x }, { y }, { z } };
		Matrix r_ger = new Matrix(elements);
		Matrix r_gei = ger2gei(r_ger, dNm);
		// System.out.println("r_gei"); r_gei.print(16, 8);
		return r_gei;
	}

	/**
	 * Computes the local tangent position vector of a satellite observed by a
	 * sensor given the geocentric equatorial inertial position vector at a
	 * date. (MG-2.94)
	 * 
	 * @param r_gei
	 *            Geocentric equatorial inertial position vector [er]
	 * @param sensor
	 *            Sensor at which position vectors apply
	 * @param dNm
	 *            MJD calendar date at which the position vectors occur
	 * @return Local tangent position vector [er]
	 */
	public static Matrix gei2ltp(Matrix r_gei, EarthStation sensor, ModJulianDate dNm) {
		Matrix r_ltp = E_e2t(sensor).times(R_z(EarthConstants.Theta(dNm)).times(r_gei).minus(sensor.get_R_ger()));
		// System.out.println("r_ltp"); r_ltp.print(16, 8);
		return r_ltp;
	}

	/**
	 * Computes the range, azimuth, and elevation of a satellite given the local
	 * tangent position vector. (MG-2.95)
	 * 
	 * @param r_ltp
	 *            Local tangent position vector [er]
	 * @return Range, azimuth and elevation [er, rad, rad]
	 */
	public static Matrix ltp2rae(Matrix r_ltp) {
		double rng = Math.sqrt(r_ltp.transpose().times(r_ltp).get(0, 0));
		double azm = checkWrap(Math.atan2(r_ltp.get(0, 0), r_ltp.get(1, 0)));
		// (0, 2 * pi)
		int[] rows = { 0, 1 };
		int[] cols = { 0 };
		double elv = Math.atan2(r_ltp.get(2, 0),
				Math.sqrt(r_ltp.getMatrix(rows, cols).transpose().times(r_ltp.getMatrix(rows, cols)).get(0, 0)));
		// (-pi, pi)
		double[][] elements = { { rng }, { azm }, { elv } };
		Matrix r_rae = new Matrix(elements);
		// System.out.println("r_rae"); r_rae.print(16, 8);
		return r_rae;
	}

	/**
	 * Computes the local tangent position vector of a satellite given range,
	 * azimuth, and elevation.
	 * 
	 * @param r_rae
	 *            Range, azimuth and elevation [rad, rad, er]
	 * @return Local tangent position vector [er]
	 */
	public static Matrix rae2ltp(Matrix r_rae) {
		double range = r_rae.get(0, 0);
		double azimuth = r_rae.get(1, 0);
		double elevation = r_rae.get(2, 0);
		double[][] elements = { { range * Math.cos(elevation) * Math.sin(azimuth) },
				{ range * Math.cos(elevation) * Math.cos(azimuth) }, { range * Math.sin(elevation) } };
		Matrix r_ltp = new Matrix(elements);
		// System.out.println("r_ltp"); r_ltp.print(16, 8);
		return r_ltp;
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
	 *            MJD calendar date at which the position vectors occur
	 * @return Inertial geocentric equatorial position vector [er]
	 */
	public static Matrix ltp2gei(Matrix r_ltp, EarthStation sensor, ModJulianDate dNm) {
		Matrix r_gei = R_z(EarthConstants.Theta(dNm)).transpose()
				.times(E_t2e(sensor).times(r_ltp).plus(sensor.get_R_ger()));
		// System.out.println("r_gei"); r_gei.print(16, 8);
		return r_gei;
	}

	/**
	 * Ensures the angle phi lies within the interval (0, 2 * pi).
	 * 
	 * @param phi
	 *            Angle [rad]
	 * @return Angle in the interval (0, 2 * pi)
	 */
	public static double checkWrap(double phi) {
		if (phi > 2 * Math.PI) {
			phi = phi % (2 * Math.PI);
		} else if (phi < 0) {
			phi = phi % (2 * Math.PI) + 2 * Math.PI;
		}
		return phi;
	}

	/**
	 * Computes the cross product of two vectors.
	 * 
	 * @param a
	 *            Column vector
	 * @param b
	 *            Column vector
	 * @return Column vector, c = a x b
	 */
	public static Matrix cross(Matrix a, Matrix b) {
		Matrix c = new Matrix(3, 1);
		c.set(0, 0, a.get(1, 0) * b.get(2, 0) - a.get(2, 0) * b.get(1, 0));
		c.set(1, 0, a.get(2, 0) * b.get(0, 0) - a.get(0, 0) * b.get(2, 0));
		c.set(2, 0, a.get(0, 0) * b.get(1, 0) - a.get(1, 0) * b.get(0, 0));
		// System.out.println("c"); c.print(16, 8);
		return c;
	}

	/**
	 * Computes the East unit vector in geocentric equatorial rotating
	 * coordinates for a given sensor. (MG-2.92)
	 * 
	 * @param sensor
	 *            Sensor at which the unit vector applies
	 * @return Orthogonal transformation matrix
	 */
	private static Matrix e_E(EarthStation sensor) {
		double[][] elements = { { -Math.sin(sensor.get_lambda()) }, { +Math.cos(sensor.get_lambda()) }, { 0.0 } };
		Matrix matrix = new Matrix(elements);
		// System.out.println("e_E"); matrix.print(16, 8);
		return matrix;
	}

	/**
	 * Computes the North unit vector in geocentric equatorial rotating
	 * coordinates for a given sensor. (MG-2.92)
	 * 
	 * @param sensor
	 *            Sensor at which the unit vector applies
	 * @return Unit vector
	 */
	private static Matrix e_N(EarthStation sensor) {
		double[][] elements = { { -Math.sin(sensor.get_varphi()) * Math.cos(sensor.get_lambda()) },
				{ -Math.sin(sensor.get_varphi()) * Math.sin(sensor.get_lambda()) },
				{ +Math.cos(sensor.get_varphi()) } };
		Matrix matrix = new Matrix(elements);
		// System.out.println("e_N"); matrix.print(16, 8);
		return matrix;
	}

	/**
	 * Computes the Zenith unit vector in geocentric equatorial rotating
	 * coordinates for a given sensor. (MG-2.92)
	 * 
	 * @param sensor
	 *            Sensor at which the unit vector applies
	 * @return Unit vector
	 */
	private static Matrix e_Z(EarthStation sensor) {
		double[][] elements = { { +Math.cos(sensor.get_varphi()) * Math.cos(sensor.get_lambda()) },
				{ +Math.cos(sensor.get_varphi()) * Math.sin(sensor.get_lambda()) },
				{ +Math.sin(sensor.get_varphi()) } };
		Matrix matrix = new Matrix(elements);
		// System.out.println("e_Z"); matrix.print(16, 8);
		return matrix;
	}
}
