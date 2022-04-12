package com.springbok.twobody;

import java.io.Serializable;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.springbok.center.SimulationConstants;

import Jama.Matrix;

/**
 * Describes an orbit using Keplerian elements by solving Kepler's equation and
 * computing position in the orbit plane and relative to the Earth center.
 * 
 * @author Raymond LeClair
 */
@SuppressWarnings("serial")
public class KeplerianOrbit implements Orbit, TwoBodyOrbit, EstimatedOrbit, Serializable {

	private static Logger logger = Logger.getLogger("com.synterein.twobody.KeplerianOrbit");

	/** Semi-major axis [er] */
	private double a;
	/** Eccentricity [-] */
	private double e;
	/** Inclination [rad] */
	private double i;
	/** Right ascension of the ascending node [rad] */
	private double Omega;
	/** Argument of perigee [rad] */
	private double omega;
	/** Mean anomaly [rad] */
	private double M;
	/** Epoch Modified Julian date */
	private ModJulianDate epoch;

	/** Method to solve Kepler's equation: "newton" or "halley" */
	private String method;

	/** Mean motion [rad/s] */
	private double n;
	/** Orbital period [s] */
	private double T;

	/** Right ascension of the ascending node time rate of change [rad/s] */
	private double Omega_dot;
	/** Argument of perigee time rate of change [rad/s] */
	private double omega_dot;
	/** Initial mean anomaly time rate of change [rad/s] */
	private double M_0_dot;

	@Override
	public ModJulianDate getEpoch() {
		return epoch;
	}

	/**
	 * Constructs a KeplerianOribt given Keplerian elements.
	 * 
	 * @param a
	 *            semi-major axis [er]
	 * @param e
	 *            eccentricity [-]
	 * @param i
	 *            inclination [rad]
	 * @param Omega
	 *            right ascension of the ascending node [rad]
	 * @param omega
	 *            argument of perigee [rad]
	 * @param M
	 *            mean anomaly [rad]
	 * @param epoch
	 *            Epoch MJD calendar date
	 * @param method
	 *            Method to sovle Kepler's equation: "newton" or "halley"
	 */
	public KeplerianOrbit(double a, double e, double i, double Omega, double omega, double M, ModJulianDate epoch,
			String method) {

		// Fundamental values.

		this.a = a;
		this.e = e;
		this.i = i;
		this.Omega = Omega;
		this.omega = omega;
		this.M = M;
		this.epoch = epoch;

		this.method = method;

		// Derived values.

		this.n = meanMotion();
		this.T = orbitalPeriod();
		secularPerturbations();
	}

	/**
	 * Constructs a KeplerianOrbit given a KeplerianOrbit.
	 * 
	 * @param kepOrb
	 *            A KeplerianOrbit to copy
	 */
	public KeplerianOrbit(KeplerianOrbit kepOrb) {

		// Fundamental values.

		this.a = kepOrb.a;
		this.e = kepOrb.e;
		this.i = kepOrb.i;
		this.Omega = kepOrb.Omega;
		this.omega = kepOrb.omega;
		this.M = kepOrb.M;
		this.epoch = kepOrb.epoch;

		this.method = kepOrb.method;

		// Derived values.

		this.n = meanMotion();
		this.T = orbitalPeriod();
		secularPerturbations();
	}

	/**
	 * Constructs a KeplerianOrbit.
	 */
	public KeplerianOrbit() {

		// Fundamental values.

		this.a = 0.0;
		this.e = 0.0;
		this.i = 0.0;
		this.Omega = 0.0;
		this.omega = 0.0;
		this.M = 0.0;
		this.epoch = new ModJulianDate(0.0);

		this.method = "halley";

		// Derived values.

		this.n = 0.0;
		this.T = 0.0;

		this.Omega_dot = 0.0;
		this.omega_dot = 0.0;
		this.M_0_dot = 0.0;
	}

	/**
	 * Sets method for solving Kepler's equation.
	 * 
	 * @param method
	 *            Method for solving Kepler's equation: "newton" or "halley"
	 */
	public void set_method(String method) {
		if (!method.equals("newton") && !method.equals("halley")) {
			throw new IllegalArgumentException("Method must be either \"newton\" or \"halley\".");
		}
		this.method = method;
	}

	/**
	 * Gets method for solving Kepler's equation.
	 * 
	 * @return Method for solving Kepler's equation
	 */
	public String get_method() {
		return method;
	}

	/**
	 * Computes mean motion (MG-2.35).
	 * 
	 * @return Mean motion [rad/s]
	 */
	public double meanMotion() {
		return Math.sqrt(EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus * a, 3));
		// [rad/s] = [ [km^3/s^2] / [ [km/er] * [er] ]^3 ]^(1/2)
	}

	/**
	 * Computes the mean anomaly at the given date (MG-2.37).
	 * 
	 * @param dNm
	 *            MJD caldendar date at which mean anomaly occurs
	 * @return Mean anomaly [rad]
	 */
	public double meanPosition(ModJulianDate dNm) {
		return Coordinates.checkWrap(M + n * (dNm.getOffset(epoch)));
		// [rad] = [rad] + [rad/s]
	}

	/**
	 * Computes orbital period.
	 * 
	 * @return Orbital period [s]
	 */
	public double orbitalPeriod() {
		return (2 * Math.PI) * Math.sqrt(Math.pow(EarthConstants.R_oplus * a, 3) / EarthConstants.GM_oplus);
		// [s/rev] = [rad/rev] * sqrt(([km] * [-])^3 / [km^3/s^2])
	}

	/**
	 * Compute orbital velocity using the vis-viva law (MG-2.22).
	 * 
	 * @param E
	 *            Eccentric anomaly [rad]
	 * 
	 * @return Orbital velocity [er/s]
	 */
	public double visVivaLaw(double E) {
		double GM_oplus = EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus, 3);
		// [er^3/s^2] = [km^3/s^2] / [km/er]^3
		double r = Math.sqrt(this.r_goi(E).transpose().times(this.r_goi(E)).get(0, 0));
		// [er]
		double v = Math.sqrt(GM_oplus * (2 / r - 1 / this.a));
		// [er/s] = sqrt([er^3/s^2] * (1 / [er]))
		return v;
	}

	/**
	 * Compute first-order secular perturbations (E-10.29-32) or (V-9-38-41).
	 * 
	 * @return Omega_dot - Right ascension of the ascending node time rate of
	 *         change [rad/s] omega_dot - Argument of perigee time rate of
	 *         change [rad/s] M_0_dot - Initial mean anomaly time rate of change
	 *         [rad/s]
	 */
	private void secularPerturbations() {
		double p = this.a * (1 - Math.pow(this.e, 2));
		// [er]
		this.Omega_dot = -((3.0 / 2.0) * (EarthConstants.J_2 / Math.pow(p, 2)) * Math.cos(this.i)) * this.n;
		// [rad/s]
		this.omega_dot = +((3.0 / 2.0) * (EarthConstants.J_2 / Math.pow(p, 2))
				* (2 - (5.0 / 2.0) * Math.pow(Math.sin(this.i), 2))) * this.n;
		// [rad/s]
		this.M_0_dot = +((3.0 / 2.0) * (EarthConstants.J_2 / Math.pow(p, 2)) * Math.sqrt(1 - Math.pow(this.e, 2))
				* (1 - (3.0 / 2.0) * Math.pow(Math.sin(this.i), 2))) * this.n;
		// [rad/s]
	}

	/**
	 * Solve conventional Kepler's equation using Newton's or Halley's method to
	 * solve for the eccentric anomaly (MG-2.42).
	 * 
	 * @param M
	 *            mean anomaly [rad]
	 * @return Eccentric anomaly [rad]
	 */
	public double keplersEquation(double M) {

		double E_i, E_iplus1;
		double f_i, f_p_i, f_pp_i;
		int nItn = 0;

		if (e < 0.8) {
			E_i = M;
		} else {
			E_i = Math.PI;
		}
		f_i = E_i - e * Math.sin(E_i) - M;
		f_p_i = 1 - e * Math.cos(E_i);

		if (method.equals("newton")) {
			E_iplus1 = E_i - f_i / f_p_i;
		} else if (method.equals("halley")) {
			f_pp_i = e * Math.sin(E_i);

			E_iplus1 = E_i - (2 * f_i * f_p_i) / (2 * Math.pow(f_p_i, 2) - f_i * f_pp_i);
		} else {
			throw new IllegalStateException("Invalid method.");
		}
		nItn = 0;
		while (Math.abs(E_iplus1 - E_i) > SimulationConstants.precision_E) {
			nItn++;
			if (nItn > SimulationConstants.max_iteration) {
				System.out.println("Maximum iterations exceeded.");
				break;
			}
			E_i = E_iplus1;

			f_i = E_i - e * Math.sin(E_i) - M;
			f_p_i = 1 - e * Math.cos(E_i);

			if (method.equals("newton")) {
				E_iplus1 = E_i - f_i / f_p_i;
			} else if (method.equals("halley")) {
				f_pp_i = e * Math.sin(E_i);

				E_iplus1 = E_i - (2 * f_i * f_p_i) / (2 * Math.pow(f_p_i, 2) - f_i * f_pp_i);
			}
		}
		return E_iplus1;
	}

	/**
	 * Computes orbital plane inertial position vector (MG-2.30).
	 * 
	 * @param E
	 *            eccentric anomaly [rad]
	 * @return Orbital plane inertial position vector [er]
	 */
	public Matrix r_goi(double E) {
		double x = a * (Math.cos(E) - e);
		double y = a * Math.sqrt(1 - Math.pow(e, 2)) * Math.sin(E);
		double[][] elements = { { x }, { y }, { 0.0 } };
		Matrix r_goi = new Matrix(elements);
		// System.out.println("r_goi"); matrix.print(16, 8);
		return r_goi;
	}

	/**
	 * Computes orbital plane inertial velocity vector (MG-2.44).
	 * 
	 * @param E
	 *            eccentric anomaly [rad]
	 * @return Orbital plane inertial velocity vector [er/s]
	 */
	public Matrix v_goi(double E) {
		double GM_oplus = EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus, 3);
		// [er^3/s^2] = [km^3/s^2] / [km/er]^3
		double r = a * (1 - e * Math.cos(E));
		// [er] = [er] * [-] (MG-2.31)
		double x = -Math.sqrt(GM_oplus * a) / r * Math.sin(E);
		double y = +Math.sqrt(GM_oplus * a) / r * Math.sqrt(1 - Math.pow(e, 2)) * Math.cos(E);
		double z = 0;
		// [er/s] = sqrt([er^3/s^2] * [er]) / [er] * [-]
		double[][] elements = { { x }, { y }, { z } };
		Matrix v_goi = new Matrix(elements);
		// System.out.println("v_goi"); matrix.print(16, 8);
		return v_goi;
	}

	/**
	 * Computes geocentric equatorial inertial position vector (MG-2.50).
	 * 
	 * @param dNm
	 *            MJD calendar date at which the position vector occurs
	 * @return Geocentric equatorial inertial position vector [er]
	 */
	public Matrix r_gei(ModJulianDate dNm) {
		Matrix r_gei = Coordinates.R_z(-Omega).times(Coordinates.R_x(-i)).times(Coordinates.R_z(-omega))
				.times(r_goi(keplersEquation(meanPosition(dNm))));
		// System.out.println("r_gei"); r_gei.print(16, 8);
		return r_gei;
	}

	/**
	 * Computes geocentric equatorial inertial velocity vector (MG-2.50).
	 * 
	 * @param dNm
	 *            Date number at which the velocity vector occurs
	 * @return Geocentric equatorial inertial velocity vector [er/s]
	 */
	public Matrix v_gei(ModJulianDate dNm) {
		Matrix v_gei = Coordinates.R_z(-Omega).times(Coordinates.R_x(-i)).times(Coordinates.R_z(-omega))
				.times(v_goi(keplersEquation(meanPosition(dNm))));
		// System.out.println("v_gei"); v_gei.print(16, 8);
		return v_gei;
	}

	/**
	 * Computes the element set corresponding to the geocentric equatorial
	 * inertial position and velocity vectors.
	 * 
	 * @param epoch
	 *            Epoch Modified Julian date
	 * @param r_gei
	 *            Geocentric equatorial inertial position vector [er]
	 * @param v_gei
	 *            Geocentric equatorial inertial velocity vector [er/s]
	 */
	public KeplerianOrbit element_set(ModJulianDate epoch, Matrix r_gei, Matrix v_gei) {

		// Alert the user if numerical precision issues might occur
		if (this.e < 0.001) {
			logger.logp(Level.WARNING, "KeplerianOrbit", "element_set",
					"Method works poorly for eccentricity less than 0.001");
		}

		// Compute the areal velocity vector
		Matrix h = Coordinates.cross(r_gei, v_gei);
		// [er^2/s] = [er] * [er/s]
		Matrix W = h.times(1.0 / Math.sqrt(h.transpose().times(h).get(0, 0)));
		// [-]

		// Compute the inclination, and right ascension of the ascending node
		double i = Math.atan2(Math.sqrt(Math.pow(W.get(0, 0), 2) + Math.pow(W.get(1, 0), 2)), W.get(2, 0));
		// [rad]
		double Omega = Math.atan2(W.get(0, 0), -W.get(1, 0));
		// [rad]

		// Compute the semi-latus rectum, semi-major axis, and eccentricity
		double GM_oplus = EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus, 3);
		// [er^3/s^2] = [km^3/s^2] / [km/er]^3
		double p = (h.transpose().times(h).get(0, 0)) / GM_oplus;
		// [er] = ([er^2/s] * [er^2/s]) / [er^3/s^2]
		double a = 1.0 / (2.0 / Math.sqrt(r_gei.transpose().times(r_gei).get(0, 0))
				- v_gei.transpose().times(v_gei).get(0, 0) / GM_oplus);
		// [er] = 1 / (1 / [er] - [er/s]^2 / [er^3/s^2])
		double e = Math.sqrt(1 - p / a);
		// [-]

		// Compute the mean motion, eccentric anomaly, and mean anomaly
		double n = Math.sqrt(GM_oplus / Math.pow(a, 3));
		// [rad/s] = sqrt([er^3/s^2] / [er]^3)
		double E = Math.atan2(((r_gei.transpose().times(v_gei).get(0, 0)) / (Math.pow(a, 2) * n)),
				(1 - Math.sqrt(r_gei.transpose().times(r_gei).get(0, 0)) / a));
		// [rad] = atan2(([er] * [er/s]) / ([er]^2 * [rad/s]), [rad] - [er] /
		// [er])
		double M = E - e * Math.sin(E);
		// [rad]

		// Compute the argument of latitude, true anomaly, and argument of
		// perigee
		double u = Math.atan2(r_gei.get(2, 0), -r_gei.get(0, 0) * W.get(1, 0) + r_gei.get(1, 0) * W.get(0, 0));
		// [rad] = atan2([er], [er] * [-])
		double nu = Math.atan2(Math.sqrt(1 - Math.pow(e, 2)) * Math.sin(E), Math.cos(E) - e);
		// [rad] = atan2([rad], [rad])
		double omega = u - nu;
		// [rad]

		// Collect the elements of the set
		return new KeplerianOrbit(a, e, i, Omega, omega, M, epoch, this.method);
	}

	/**
	 * Sets semi-major axis [er].
	 * 
	 * @param a
	 *            Semi-major axis [er]
	 */
	public void set_a(double a) {
		this.a = a;
		n = meanMotion();
		T = orbitalPeriod();
		secularPerturbations();
	}

	/**
	 * Gets semi-major axis [er].
	 * 
	 * @return Semi-major axis [er]
	 */
	public double get_a() {
		return a;
	}

	/**
	 * Sets eccentricity [-].
	 * 
	 * @param e
	 *            Eccentricity [-]
	 */
	public void set_e(double e) {
		this.e = e;
		secularPerturbations();
	}

	/**
	 * Gets eccentricity [-].
	 * 
	 * @return Eccentricity [-]
	 */
	public double get_e() {
		return e;
	}

	/**
	 * Sets inclination [rad].
	 * 
	 * @param i
	 *            Inclination [rad]
	 */
	public void set_i(double i) {
		this.i = Coordinates.checkWrap(i);
		secularPerturbations();
	}

	/**
	 * Gets inclination [rad].
	 * 
	 * @return Inclination [rad]
	 */
	public double get_i() {
		return i;
	}

	/**
	 * Sets right ascension of the ascending node [rad].
	 * 
	 * @param Omega
	 *            Right ascension of the ascending node [rad]
	 */
	public void set_Omega(double Omega) {
		this.Omega = Coordinates.checkWrap(Omega);
	}

	/**
	 * Gets right ascension of the ascending node [rad].
	 * 
	 * @return Right ascension of the ascending node [rad]
	 */
	public double get_Omega() {
		return Omega;
	}

	/**
	 * Sets argument of perigee [rad].
	 * 
	 * @param omega
	 *            Argument of perigee [rad]
	 */
	public void set_omega(double omega) {
		this.omega = Coordinates.checkWrap(omega);
	}

	/**
	 * Gets argument of perigee [rad].
	 * 
	 * @return Argument of perigee [rad]
	 */
	public double get_omega() {
		return omega;
	}

	/**
	 * Sets mean anomaly [rad].
	 * 
	 * @param M
	 *            Mean anomaly [rad]
	 */
	public void set_M(double M) {
		this.M = Coordinates.checkWrap(M);
	}

	/**
	 * Gets mean anomaly [rad].
	 * 
	 * @return Mean anomaly [rad]
	 */
	public double get_M() {
		return M;
	}

	/**
	 * Sets epoch MJD calendar date.
	 * 
	 * @param epoch
	 *            Epoch MJD calendar date
	 */
	public void set_epoch(ModJulianDate epoch) {
		this.epoch = epoch;
	}

	/**
	 * Gets epoch MJD calendar date.
	 * 
	 * @return Epoch MJD calendar date
	 */
	public ModJulianDate get_epoch() {
		return epoch;
	}

	/**
	 * Gets mean motion [rad/s].
	 * 
	 * @return Mean motion [rad/s]
	 */
	public double get_n() {
		return n;
	}

	/**
	 * Gets orbital period [s].
	 * 
	 * @return Orbital period [s]
	 */
	public double get_T() {
		return T;
	}

	/**
	 * Gets right ascension of the ascending node time rate of change [rad/s].
	 * 
	 * @return Right ascension of the ascending node time rate of change [rad/s]
	 */
	public double get_Omega_dot() {
		return Omega_dot;
	}

	/**
	 * Gets argument of perigee time rate of change [rad/s].
	 * 
	 * @return Argument of perigee time rate of change [rad/s]
	 */
	public double get_omega_dot() {
		return omega_dot;
	}

	/**
	 * Gets initial mean anomaly time rate of change [rad/s]
	 * 
	 * @return Initial mean anomaly time rate of change [rad/s]
	 */
	public double get_M_0_dot() {
		return M_0_dot;
	}

	@Override
	public Orbit copy() {
		return new KeplerianOrbit(this);
	}
}
