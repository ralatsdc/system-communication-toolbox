package com.springbok.center;

import java.io.Serializable;
import java.util.ArrayList;

import Jama.Matrix;

import com.springbok.sgp4v.Sgp4Orbit;
import com.springbok.twobody.KeplerianOrbit;
import com.springbok.twobody.ModJulianDate;

/**
 * Describes a Hohmann transfer between two orbits which are circular (or
 * elliptical with a common line of apsides) and coplanar.
 * 
 * @author Raymond LeClair
 */
@SuppressWarnings("serial")
public class HohmannTransfer implements Serializable {

	/** Initial Keplerian orbit */
	KeplerianOrbit kep_orb_1;
	/** Final Keplerian orbit */
	KeplerianOrbit kep_orb_2;
	/** Transfer Keplerian orbit */
	KeplerianOrbit kep_orb_t;

	/**
	 * Velocity of object in initial orbit at perigee of the transfer (and
	 * initial) orbit [er/s]
	 */
	double v_1;
	/**
	 * Velocity of object in transfer orbit at perigee of the transfer (and
	 * initial) orbit [er/s]
	 */
	double v_t_p;
	/**
	 * Velocity of object in transfer orbit at apogee of the transfer (and
	 * final) orbit [er/s]
	 */
	double v_t_a;
	/**
	 * Velocity of object in final orbit at apogee of the transfer (and final)
	 * orbit [er/s]
	 */
	double v_2;

	/**
	 * Change in velocity required at perigee of the transfer (and initial)
	 * orbit [er/s]
	 */
	double delta_v_p;
	/**
	 * Change in velocity required at apogee of the transfer (and final) orbit
	 * [er/s]
	 */
	double delta_v_a;


	/**
	 * Represents the result of an orbit maneuver simulation.
	 *
	 * @author Ray LeClair
	 */
	@SuppressWarnings("serial")
	private class ManeuverResult implements Serializable {

		/**
		 * A vector of Keplerian orbits representing the states of the object
		 * throughout the transfer
		 */
		public ArrayList<KeplerianOrbit> kep_orb_s;
		/**
		 * A vector of Sgp4 orbits representing the states of the object throughout
		 * the transfer
		 */
		public ArrayList<Sgp4Orbit> sgp4_orb_s;

		/**
		 * Constructs the result of an orbit maneuver simulation.
		 *
		 * @param kep_orb_s
		 *            A vector of Keplerian orbits representing the states of the
		 *            object throughout the transfer
		 * @param sgp4_orb_s
		 *            A vector of Sgp4 orbits representing the states of the object
		 *            throughout the transfer
		 */
		public ManeuverResult(ArrayList<KeplerianOrbit> kep_orb_s, ArrayList<Sgp4Orbit> sgp4_orb_s) {
			this.kep_orb_s = kep_orb_s;
			this.sgp4_orb_s = sgp4_orb_s;
		}
	}

	/**
	 * Constructs a HohmannTransfer given the initial and final Keplerian
	 * orbits.
	 * 
	 * @param kep_orb_1
	 *            Initial Keplerian orbit
	 * @param kep_orb_2
	 *            - Final Keplerian orbit
	 */
	public HohmannTransfer(KeplerianOrbit kep_orb_1, KeplerianOrbit kep_orb_2) {

		/*
		 * Ensure the orbits which are circular (or elliptical with a common
		 * line of apsides) and coplanar
		 */
		double e_max = 0.001;
		if ((kep_orb_1.get_e() > e_max || kep_orb_2.get_e() > e_max)
				|| kep_orb_1.get_Omega() != kep_orb_2.get_Omega()) {
			throw new IllegalArgumentException("Elliptical orbits must have a common line of apsides");
		}
		if (kep_orb_1.get_Omega() != kep_orb_2.get_Omega() || kep_orb_1.get_i() != kep_orb_2.get_i()) {
			throw new IllegalArgumentException("Orbits must be coplanar");
		}

		// Assign properties
		this.kep_orb_1 = kep_orb_1;
		this.kep_orb_2 = kep_orb_2;

		// Compute derived properties
		this.computeTransferOrbit();
	}

	// Computes the Hohmann transfer orbit.
	private void computeTransferOrbit() {

		// Initial orbit perigee
		double r_1 = this.kep_orb_1.get_a() * (1 - this.kep_orb_1.get_e());
		// Final orbit apogee
		double r_2 = this.kep_orb_2.get_a() * (1 + this.kep_orb_2.get_e());

		// Transfer orbit semi-major axis [er]
		double a_t = (r_2 + r_1) / 2;
		// Transfer orbit eccentricity [-]
		double e_t = (r_2 - r_1) / (r_2 + r_1);
		// Transfer orbit inclination [rad]
		double i_t = this.kep_orb_1.get_i();
		// Transfer orbit right ascension of the ascending node [rad]
		double Omega_t = this.kep_orb_1.get_Omega();

		// Transfer orbit epoch date number (at perigee of initial orbit)
		ModJulianDate epoch_t;
		if (this.kep_orb_1.get_M() > 0) {
			epoch_t = new ModJulianDate(this.kep_orb_1.get_epoch().getAsDouble()
					+ (2 * Math.PI - this.kep_orb_1.get_M()) / this.kep_orb_1.get_n() / 86400);
		} else {
			epoch_t = this.kep_orb_1.get_epoch();
		}

		// Transfer orbit argument of perigee [rad]
		double omega_t = this.kep_orb_1.get_omega();
		// Transfer orbit mean anomaly [rad]
		double M_t = 0.0; // perigee
		// Transfer orbit method to solve Kepler's equation: 'newton' or
		// 'halley'
		String method_t = this.kep_orb_1.get_method();

		// Transfer Keplerian orbit
		this.kep_orb_t = new KeplerianOrbit(a_t, e_t, i_t, Omega_t, omega_t, M_t, epoch_t, method_t);

		// Final orbit semi-major axis [er]
		double a_2 = this.kep_orb_2.get_a();
		// Final orbit eccentricity [-]
		double e_2 = this.kep_orb_2.get_e();
		// Final orbit inclination [rad]
		double i_2 = this.kep_orb_2.get_i();
		// Final orbit right ascension of the ascending node [rad]
		double Omega_2 = this.kep_orb_2.get_Omega();

		// Final orbit epoch date number (one half period after epoch of
		// transfer orbit)
		ModJulianDate epoch_2 = new ModJulianDate(
				epoch_t.getAsDouble() + (1.0 / 2.0) * (this.kep_orb_t.get_T() / 86400));

		// Final orbit argument of perigee [rad]
		double omega_2 = this.kep_orb_2.get_omega();
		// Final orbit mean anomaly [rad]
		double M_2 = Math.PI; // apogee
		// Final orbit method to solve Kepler's equation: 'newton' or 'halley'
		String method_2 = this.kep_orb_2.get_method();

		// Final Keplerian orbit
		this.kep_orb_2 = new KeplerianOrbit(a_2, e_2, i_2, Omega_2, omega_2, M_2, epoch_2, method_2);

		/*
		 * Compute velocities of object in the initial and transfer orbit at
		 * perigee of the transfer (and initial) orbit, and in the transfer and
		 * final orbit at apogee of the transfer (and final) orbit
		 */
		Matrix v_1 = this.kep_orb_1.v_gei(this.kep_orb_t.get_epoch());
		this.v_1 = Math.sqrt(v_1.transpose().times(v_1).get(0, 0));
		Matrix v_t_p = this.kep_orb_t.v_gei(this.kep_orb_t.get_epoch());
		this.v_t_p = Math.sqrt(v_t_p.transpose().times(v_t_p).get(0, 0));
		Matrix v_t_a = this.kep_orb_t.v_gei(this.kep_orb_2.get_epoch());
		this.v_t_a = Math.sqrt(v_t_a.transpose().times(v_t_a).get(0, 0));
		Matrix v_2 = this.kep_orb_2.v_gei(this.kep_orb_2.get_epoch());
		this.v_2 = Math.sqrt(v_2.transpose().times(v_2).get(0, 0));

		/*
		 * Compute the change in velocity required to enter and exit the
		 * transfer orbit
		 */
		this.delta_v_p = this.v_t_p - this.v_1;
		this.delta_v_a = this.v_2 - this.v_t_a;
	}

	/**
	 * Simulates the two maneuvers of a Hohmann transfer over a period using a
	 * series of impulsive maneuvers directed according to the specified
	 * steering law.
	 * 
	 * @param t_cut_off
	 *            Duration of each maneuver, [s]
	 * @param n_impulse
	 *            Number of impulses used to simulate each maneuver
	 * @param mode
	 *            - steering law, valid values: 'velocity-to-be-gained'
	 *            'terminal-state-vector'
	 * 
	 * @return kep_orb_s - a vector of Keplerian orbits representing the states
	 *         of the object throughout the transfer sgp4_orb_s - a vector of
	 *         Sgp4 orbits representing the states of the object throughout the
	 *         transfer
	 */
	public ManeuverResult simulateTransferOrbit(double t_cut_off, int n_impulse, String mode) {

		// Ensure time between impulses reasonable
		if (t_cut_off / (n_impulse - 1) <= 1) {
			throw new IllegalArgumentException("Time between each impulse must be greater than one second");
		}

		/*
		 * Simulate perigee maneuver. Note that epoch of the transfer orbit
		 * occurs at perigee of the initial orbit.
		 */
		ManeuverResult manResP = simulateManeuver(this.kep_orb_1, this.kep_orb_t, this.kep_orb_t.get_epoch(), t_cut_off,
				this.delta_v_p, n_impulse, mode);

		/*
		 * Simulate apogee maneuver. Note that epoch of the final orbit occurs
		 * at one half the period of the transfer orbit after the epoch of the
		 * transfer orbit.
		 */
		ManeuverResult manResA = simulateManeuver(manResP.kep_orb_s.get(manResP.kep_orb_s.size()), this.kep_orb_2,
				new ModJulianDate(this.kep_orb_2.get_epoch().getAsDouble() - t_cut_off / 86400), t_cut_off,
				this.delta_v_a, n_impulse, mode);

		// Accumulate Keplerain and Sgp4 orbits
		manResP.kep_orb_s.addAll(manResA.kep_orb_s);
		manResP.sgp4_orb_s.addAll(manResA.sgp4_orb_s);
		return manResP;
	}

	/**
	 * Compute the series of KeplerianOrbits which result from a series of
	 * impulses directed in a specified steering direction.
	 * 
	 * @param kep_orb_i
	 *            Initial KeplerianOrbit
	 * @param kep_orb_f
	 *            Final KeplerianOrbit
	 * @param t_0
	 *            Time of maneuver, Modified Julian date
	 * @param t_cut_off
	 *            Duration of each maneuver, [s]
	 * @param delta_v
	 *            Total change of velocity required during maneuver, [er/s]
	 * @param n_impulse
	 *            Number of impulses used to simulate each maneuver
	 * @param mode
	 *            steering law, valid values: 'velocity-to-be-gained'
	 *            'terminal-state-vector'
	 * 
	 * @return kep_orb_s - a vector of Keplerian orbits representing the states
	 *         of the object throughout the transfer sgp4_orb_s - a vector of
	 *         Sgp4 orbits representing the states of the object throughout the
	 *         transfer
	 */
	public ManeuverResult simulateManeuver(KeplerianOrbit kep_orb_i, KeplerianOrbit kep_orb_f, ModJulianDate t_0,
			double t_cut_off, double delta_v, int n_impulse, String mode) {

		// Simulated and required KeplerianOrbits
		ArrayList<KeplerianOrbit> kep_orb_s = new ArrayList<KeplerianOrbit>();
		ArrayList<Sgp4Orbit> sgp4_orb_s = new ArrayList<Sgp4Orbit>();
		kep_orb_s.add(kep_orb_i);
		KeplerianOrbit kep_orb_r = kep_orb_f;

		// Impulse times from start of maneuver
		ArrayList<Double> t_impulse = new ArrayList<Double>(); // [s]
		t_impulse.add(t_cut_off / n_impulse);
		while (t_impulse.get(t_impulse.size()) < t_cut_off) {
			t_impulse.add(t_impulse.get(t_impulse.size()) + t_cut_off / n_impulse);
		}

		// Maximum delta velocity during a maneuver
		double delta_v_m = delta_v / n_impulse; // [er/s]

		// Steering law
		ModJulianDate t_1 = null;
		Matrix r_1 = null;
		Matrix v_1 = null;
		if (mode.equals("velocity-to-be-gained")) {

			// Nothing to do

		} else if (mode.equals("terminal-state-vector")) {

			// Final position and velocity
			t_1 = new ModJulianDate(t_0.getAsDouble() + t_cut_off / 86400);
			r_1 = kep_orb_f.r_gei(t_1); // [er]
			v_1 = kep_orb_f.v_gei(t_1); // [er/s]

		} else {
			throw new IllegalArgumentException("Unknown steering mode: " + mode);
		}

		// Perform specified number of impulses
		n_impulse = t_impulse.size();
		for (int i_impulse = 0; i_impulse < n_impulse; i_impulse += 1) {

			// Time of impulse
			ModJulianDate t_i = new ModJulianDate(t_0.getAsDouble() + t_impulse.get(i_impulse) / 86400);

			// Position and velocity immediately before impulse
			Matrix r_b = kep_orb_s.get(i_impulse).r_gei(t_i);
			Matrix v_b = kep_orb_s.get(i_impulse).v_gei(t_i);

			// Steering law giving direction of impulse
			Matrix delta_v_i = null;
			if (mode.equals("velocity-to-be-gained")) {

				// Required position and velocity at time of impulse
				Matrix r_r = kep_orb_r.r_gei(t_i);
				Matrix v_r = kep_orb_r.v_gei(t_i);

				// Position and velocity to be gained
				Matrix r_g = r_r.minus(r_b);
				Matrix v_g = v_r.minus(v_b);
				Matrix r_g_hat = r_g.times(1.0 / Math.sqrt(r_g.transpose().times(r_g).get(0, 0)));
				Matrix v_g_hat = v_g.times(1.0 / Math.sqrt(v_g.transpose().times(v_g).get(0, 0)));

				// Delta velocity
				delta_v_i = v_g_hat.times(delta_v_m);

			} else if (mode.equals("terminal-state-vector")) {

				// Position and velocity immediately before impulse
				Matrix r_i = r_b;
				Matrix v_i = v_b;

				// Delta velocity
				delta_v_i = v_1.minus(v_i)
						.times(4 * (t_1.getAsDouble() - t_0.getAsDouble()) / (t_1.getAsDouble() - t_i.getAsDouble()))
						.plus(r_1.minus(r_i.plus(v_1.times(t_1.getAsDouble() - t_i.getAsDouble())))
								.times(6 * (t_1.getAsDouble() - t_0.getAsDouble())
										/ (n_impulse * Math.pow(t_1.getAsDouble() - t_i.getAsDouble(), 2))));
			}

			// Position and velocity immediately after impulse
			Matrix r_a = r_b;
			Matrix v_a = v_b.plus(delta_v_i);

			/*
			 * Keplerian orbit equivalent to position and velocity immediately
			 * after impulse
			 */
			kep_orb_s.add(kep_orb_s.get(i_impulse).element_set(t_i, r_a, v_a));
		}

		// Convert each Keplerian orbit to an Sgp4 orbit
		int n_orb = kep_orb_s.size();
		for (int i_orb = 0; i_orb < n_orb; i_orb += 1) {
			sgp4_orb_s.add(Sgp4Orbit.fitSgp4OrbitFromKeplerianOrbit(0, kep_orb_s.get(i_orb)));
		}
		return new ManeuverResult(kep_orb_s, sgp4_orb_s);
	}
}
