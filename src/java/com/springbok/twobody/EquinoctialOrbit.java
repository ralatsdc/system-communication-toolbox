package com.springbok.twobody;

import java.io.Serializable;

import com.springbok.center.SimulationConstants;

import Jama.Matrix;

/**
 * Describes an orbit using equinoctial elements by solving the generalize
 * Kepler's equation and computing position in the orbit plane and relative to
 * the Earth center.
 * 
 * Note the the implementation of the OrbitCorrection interface is a stub only.
 * 
 * @author Raymond LeClair
 */
@SuppressWarnings("serial")
public class EquinoctialOrbit implements Orbit, TwoBodyOrbit, EstimatedOrbit, Serializable {

	/** Direct or retrograde orbit indicator [-] */
	private int j;
	/** Semi-major axis [er] */
	private double a;
	/** y component of the eccentricity vector [-] */
	private double h;
	/** x component of the eccentricity vector [-] */
	private double k;
	/** y component of the nodal vector [-] */
	private double p;
	/** x component of the nodal vector [-] */
	private double q;
	/** Mean longitude [rad] */
	private double lambda;
	/** Epoch MJD calendar date */
	private ModJulianDate epoch;

	/** Method to sovle Kepler's equation: "newton" or "halley" */
	private String method;

	/** Mean motion [rad/s] */
	private double n;
	/** Orbital period [s] */
	private double T;

	@Override
	public ModJulianDate getEpoch() {
		return epoch;
	}

	/**
	 * Constructs an EquinoctialOrbit given equinoctial elements.
	 * 
	 * @param j
	 *            Direct or retrograde orbit indicator [-]
	 * @param a
	 *            Semi-major axis [er]
	 * @param h
	 *            Y component of the eccentricity vector [-]
	 * @param k
	 *            X component of the eccentricity vector [-]
	 * @param p
	 *            Y component of the nodal vector [-]
	 * @param q
	 *            X component of the nodal vector [-]
	 * @param lambda
	 *            Mean longitude [rad]
	 * @param epoch
	 *            Epoch MJD calendar date
	 * @param method
	 *            Method to sovle Kepler's equation: "newton" or "halley"
	 */
	public EquinoctialOrbit(int j, double a, double h, double k, double p, double q, double lambda, ModJulianDate epoch,
			String method) {

		// Fundamental values.

		this.j = j;
		this.a = a;
		this.h = h;
		this.k = k;
		this.p = p;
		this.q = q;
		this.lambda = lambda;
		this.epoch = epoch;

		this.method = method;

		// Derived values.

		this.n = meanMotion();
		this.T = orbitalPeriod();
	}

	/**
	 * Constructs an EquinoctialOrbit given equinoctial elements.
	 * 
	 * @param eqiOrb
	 *            An EquinoctialOrbit to copy
	 */
	public EquinoctialOrbit(EquinoctialOrbit eqiOrb) {

		// Fundamental values.

		this.j = eqiOrb.j;
		this.a = eqiOrb.a;
		this.h = eqiOrb.h;
		this.k = eqiOrb.k;
		this.p = eqiOrb.p;
		this.q = eqiOrb.q;
		this.lambda = eqiOrb.lambda;
		this.epoch = eqiOrb.epoch;

		this.method = eqiOrb.method;

		// Derived values.

		this.n = meanMotion();
		this.T = orbitalPeriod();
	}

	/**
	 * Constructs an EquinoctialOrbit.
	 */
	public EquinoctialOrbit() {

		// Fundamental values.

		this.j = 0;
		this.a = 0.0;
		this.h = 0.0;
		this.k = 0.0;
		this.p = 0.0;
		this.q = 0.0;
		this.lambda = 0.0;
		this.epoch = new ModJulianDate(0.0);

		this.method = "halley";

		// Derived values.

		this.n = 0.0;
		this.T = 0.0;
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
	}

	/**
	 * Computes the mean longitude at the given date (LCVF-3-271).
	 * 
	 * @param dNm
	 *            MJD calendar date at which mean longitude occurs
	 * @return Mean longitude [rad]
	 */
	public double meanPosition(ModJulianDate dNm) {
		return Coordinates.checkWrap(lambda + n * (dNm.getOffset(epoch)));
		// [rad] = [rad] + [rad/s] * [ms] / [ms/s]
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
	 * Solve generalized Kepler's equation using Newton's or Halley's method to
	 * solve for the eccentric longitude (LCVF-3-230).
	 * 
	 * @param lambda
	 *            mean longitude [rad]
	 * @return Eccentric longitude [rad]
	 */
	public double keplersEquation(double lambda) {
		double F_i, F_iplus1;
		double f_i, f_p_i, f_pp_i;
		int nItn = 0;

		F_i = lambda;

		f_i = F_i + h * Math.cos(F_i) - k * Math.sin(F_i) - lambda;
		f_p_i = 1 - h * Math.sin(F_i) - k * Math.cos(F_i);

		if (method.equals("newton")) {
			F_iplus1 = F_i - F_i / f_p_i;
		} else if (method.equals("halley")) {
			f_pp_i = -h * Math.cos(F_i) + k * Math.sin(F_i);

			F_iplus1 = F_i - (2 * f_i * f_p_i) / (2 * Math.pow(f_p_i, 2) - F_i * f_pp_i);
		} else {
			throw new IllegalStateException("Invalid method.");
		}
		nItn = 0;
		while (Math.abs(F_iplus1 - F_i) > SimulationConstants.precision_E) {
			nItn++;
			if (nItn > SimulationConstants.max_iteration) {
				System.out.println("Maximum iterations exceeded.");
				break;
			}
			F_i = F_iplus1;

			f_i = F_i + h * Math.cos(F_i) - k * Math.sin(F_i) - lambda;
			f_p_i = 1 - h * Math.sin(F_i) - k * Math.cos(F_i);

			if (method.equals("newton")) {
				F_iplus1 = F_i - F_i / f_p_i;
			} else if (method.equals("halley")) {
				f_pp_i = -h * Math.cos(F_i) + k * Math.sin(F_i);

				F_iplus1 = F_i - (2 * f_i * f_p_i) / (2 * Math.pow(f_p_i, 2) - F_i * f_pp_i);
			}
		}
		return F_iplus1;
	}

	/**
	 * Computes orbital plane inertial position vector (LCVF-3-236).
	 * 
	 * @param F
	 *            Eccentric longitude [rad]
	 * @return Orbital plane inertial position vector [er]
	 */
	public Matrix r_goi(double F) {
		double beta;
		double X_1, Y_1;
		beta = 1 / (1 + Math.sqrt(1 - Math.pow(h, 2) - Math.pow(k, 2)));
		X_1 = a * ((1 - Math.pow(h, 2) * beta) * Math.cos(F) + h * k * beta * Math.sin(F) - k);
		Y_1 = a * ((1 - Math.pow(k, 2) * beta) * Math.sin(F) + h * k * beta * Math.cos(F) - h);
		double[][] elements = { { X_1 }, { Y_1 }, { 0.0 } };
		Matrix matrix = new Matrix(elements);
		// System.out.println("r_goi"); matrix.print(16, 8);
		return matrix;
	}

	/**
	 * Computes geocentric equatorial intertial position vector (LCVF-3-238).
	 * 
	 * @param dNm
	 *            MJD calendar date at which the position vector occurs
	 * @return Geocentric equatorial intertial position vector [er]
	 */
	public Matrix r_gei(ModJulianDate dNm) {
		double m = 1 + Math.pow(p, 2) + Math.pow(q, 2);
		double[][] f_elements = { { (1 - Math.pow(p, 2) + Math.pow(q, 2)) / m }, { (2 * p * q) / m },
				{ (-2 * p * j) / m } };
		Matrix f = new Matrix(f_elements);
		double[][] g_elements = { { (2 * p * q * j) / m }, { ((1 + Math.pow(p, 2) - Math.pow(q, 2)) * j) / m },
				{ (2 * q) / m } };
		Matrix g = new Matrix(g_elements);
		Matrix r_goi = r_goi(keplersEquation(meanPosition(dNm)));
		double X_1 = r_goi.get(0, 0);
		double Y_1 = r_goi.get(1, 0);
		Matrix r_gei = f.times(X_1).plus(g.times(Y_1));
		// System.out.println("r_gei"); r_gei.print(16, 8);
		return r_gei;
	}

	/**
	 * Gets direct or retrograde orbit indicator [-]
	 * 
	 * @return Direct or retrograde orbit indicator [-]
	 */
	public int get_j() {
		return j;
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
	 * Sets y component of the eccentricity vector [-].
	 * 
	 * @param h
	 *            Y component of the eccentricity vector [-]
	 */
	public void set_h(double h) {
		this.h = h;
	}

	/**
	 * Gets y component of the eccentricity vector [-].
	 * 
	 * @return Y component of the eccentricity vector [-]
	 */
	public double get_h() {
		return h;
	}

	/**
	 * Sets x component of the eccentricity [-].
	 * 
	 * @param k
	 *            X component of the eccentricity [-]
	 */
	public void set_k(double k) {
		this.k = k;
	}

	/**
	 * Gets x component of the eccentricity [-].
	 * 
	 * @return X component of the eccentricity [-]
	 */
	public double get_k() {
		return k;
	}

	/**
	 * Sets y component of the nodal vector [-].
	 * 
	 * @param p
	 *            Y component of the nodal vector [-]
	 */
	public void set_p(double p) {
		this.p = p;
	}

	/**
	 * Gets y component of the nodal vector [-].
	 * 
	 * @return Y component of the nodal vector [-]
	 */
	public double get_p() {
		return p;
	}

	/**
	 * Sets x component of the nodal vector [-].
	 * 
	 * @param q
	 *            X component of the nodal vector [-]
	 */
	public void set_q(double q) {
		this.q = q;
	}

	/**
	 * Gets x component of the nodal vector [-].
	 * 
	 * @return X component of the nodal vector [-]
	 */
	public double get_q() {
		return q;
	}

	/**
	 * Sets mean longitude [rad].
	 * 
	 * @param lambda
	 *            Mean longitude [rad]
	 */
	public void set_lambda(double lambda) {
		this.lambda = lambda;
	}

	/**
	 * Gets mean longitude [rad].
	 * 
	 * @return Mean longitude [rad]
	 */
	public double get_lambda() {
		return lambda;
	}

	/**
	 * Sets epoch MJD calendar date.
	 * 
	 * @param epoch
	 *            MJD calendar date
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
	 * Sets eccentricity [-].
	 * 
	 * @param e
	 *            Eccentricity [-]
	 */
	public void set_e(double e) {
		;
	}

	/**
	 * Gets eccentricity [-].
	 * 
	 * @return Eccentricity [-]
	 */
	public double get_e() {
		return 0.0;
	}

	/**
	 * Sets inclination [rad].
	 * 
	 * @param i
	 *            Inclination [rad]
	 */
	public void set_i(double i) {
		;
	}

	/**
	 * Gets inclination [rad].
	 * 
	 * @return Inclination [rad]
	 */
	public double get_i() {
		return 0.0;
	}

	/**
	 * Sets right ascension of the ascending node [rad].
	 * 
	 * @param Omega
	 *            Right ascension of the ascending node [rad]
	 */
	public void set_Omega(double Omega) {
		;
	}

	/**
	 * Gets right ascension of the ascending node [rad].
	 * 
	 * @return Right ascension of the ascending node [rad]
	 */
	public double get_Omega() {
		return 0.0;
	}

	/**
	 * Sets argument of perigee [rad].
	 * 
	 * @param omega
	 *            Argument of perigee [rad]
	 */
	public void set_omega(double omega) {
		;
	}

	/**
	 * Gets argument of perigee [rad].
	 * 
	 * @return Argument of perigee [rad]
	 */
	public double get_omega() {
		return 0.0;
	}

	/**
	 * Sets mean anomaly [rad].
	 * 
	 * @param M
	 *            Mean anomaly [rad]
	 */
	public void set_M(double M) {
		;
	}

	/**
	 * Gets mean anomaly [rad].
	 * 
	 * @return Mean anomaly [rad]
	 */
	public double get_M() {
		return 0.0;
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

	@Override
	public Orbit copy() {
		return new EquinoctialOrbit(this);
	}
}
