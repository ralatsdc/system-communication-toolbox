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
package com.springbok.operator;

import java.io.Serializable;
import java.util.EnumSet;
import java.util.logging.Level;

import Jama.Matrix;
import com.celestrak.sgp4v.SatElsetException;
import com.celestrak.sgp4v.ValueOutOfRangeException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.springbok.sgp4v.Sgp4Orbit;
import com.springbok.twobody.Coordinates;
import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.EstimatedOrbit;
import com.springbok.twobody.KeplerianOrbit;
import com.springbok.twobody.ModJulianDate;

@SuppressWarnings("serial")
public class OrbitDetermination implements Serializable {

	public static Logger logger = LogManager.getLogger(OrbitDetermination.class.getName());

	/**
	 * Represents the result of a line search operation performed as part of a
	 * differential orbit correction. The objective of the line search is to
	 * determine the magnitude of the differential correction which minimizes the
	 * sum of squared differences between the measured and modeled observations.
	 *
	 * @author Ray LeClair
	 */
	@SuppressWarnings("serial")
	private static class SearchResult implements Serializable {

		/** The orbit at step i+1 */
		public EstimatedOrbit estOrb_ip1;
		/** The sum of squared residuals [er^2] */
		public double sSq;

		/**
		 * Constructs the result of a line search operation.
		 *
		 * @param estOrb_ip1
		 *            The orbit after the last iteration
		 * @param sSq
		 *            The sum of squared residuals [er^2]
		 */
		public SearchResult(EstimatedOrbit estOrb_ip1, double sSq) {
			this.estOrb_ip1 = estOrb_ip1;
			this.sSq = sSq;
		}
	}

	/**
	 * Represents the result of an orbit determination operation.
	 *
	 * @author Ray LeClair
	 */
	@SuppressWarnings("serial")
	public static class DeterminationResult implements Serializable {

		/** The corrected orbit */
		public EstimatedOrbit estOrb;
		/** A status message */
		public String status;

		/**
		 * Constructs the result of an orbit determination operation.
		 *
		 * @param estOrb
		 *            The orbit determined by the operation
		 * @param status
		 *            The status of the operation
		 */
		public DeterminationResult(EstimatedOrbit estOrb, String status) {
			this.estOrb = estOrb;
			this.status = status;
		}
	}


	/**
	 * Represents the result of a differential correction operation.
	 *
	 * @author Ray LeClair
	 */
	@SuppressWarnings("serial")
	protected static class CorrectionResult implements Serializable {

		/** Iteration option: "Levenberg-Marquardt" or "Guass-Newton" */
		public String option;
		/** Damping parameter */
		public double nu;
		/** Damping parameter */
		public double lambda;

		/** The position residuals [er] */
		public Matrix dz;
		/** The Jacobian */
		public Matrix H;
		/** The differential corrections */
		public double[] dx;

		/**
		 * Constructs the result of a differential correction operation.
		 *
		 * @param option
		 *            Iteration option "Levenberg-Marquardt" or "Guass-Newton"
		 */
		protected CorrectionResult(String option) {
			this.option = option;
			if (option.equals("Levenberg-Marquardt")) {

				// Initialize the damping parameters.

				nu = 2.0;
				lambda = 0.1;

			} else if (option.equals("Guass-Newton")) {

				// No initialization required.

			}
		}
	}

	/**
	 * Determine an element set in Earth radii and radians at a date number
	 * given two position vectors in Earth radii at two date numbers. Note that
	 * position vectors are inertial geocentric. This is Gauss's method.
	 * 
	 * @param dNm_a
	 *            First date number
	 * @param r_a
	 *            First inertial geocentric position vector
	 * @param dNm_b
	 *            Second date number
	 * @param r_b
	 *            Second inertial geocentric position vector
	 * @return The preliminary orbit
	 */
	public static KeplerianOrbit podGauss(ModJulianDate dNm_a, Matrix r_a, ModJulianDate dNm_b, Matrix r_b) {

		KeplerianOrbit popOrbP = null;

		/*
		 * Compute a normalized measure of time between the two position
		 * vectors. (2.99)
		 */
		double tau = Math.sqrt(EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus, 3))
				* (dNm_b.getOffset(dNm_a));
		// [-] = sqrt([km^3/s^2] / [km^3]) * [s]

		/*
		 * Iteratively estimate the ratio of the areas of the sector and
		 * triangle defined by the two position vectors. (2.101, 2.108, 2.107,
		 * 2.105)
		 */
		double m = Math.pow(tau, 2) / Math.pow(Math.sqrt(
				2 * (Math.sqrt(r_a.transpose().times(r_a).get(0, 0)) * Math.sqrt(r_b.transpose().times(r_b).get(0, 0))
						+ r_a.transpose().times(r_b).get(0, 0))),
				3);
		// [-]
		double l = (Math.sqrt(r_a.transpose().times(r_a).get(0, 0)) + Math.sqrt(r_b.transpose().times(r_b).get(0, 0)))
				/ (2 * Math.sqrt(2 * (Math.sqrt(r_a.transpose().times(r_a).get(0, 0))
						* Math.sqrt(r_b.transpose().times(r_b).get(0, 0)) + r_a.transpose().times(r_b).get(0, 0))))
				- (1 / 2.0);
		// [-]

		double eta_0 = (12 / 22.0) + (10 / 22.0) * Math.sqrt(1 + (44 / 9.0) * (m / (l + 5 / 6.0)));
		// double eta_im1 = eta_0 + 0.01;
		double eta_im1 = eta_0 + 0.1;
		double eta_i = eta_0;
		double eta_ip1 = eta_i - f_(eta_i, m, l) * ((eta_i - eta_im1) / (f_(eta_i, m, l) - f_(eta_im1, m, l)));
		// [-]

		int nItn = 0;
		while (Math.abs(eta_ip1 - eta_i) > SimulationConstants.precision_eta) {
			nItn += 1;
			if (nItn > SimulationConstants.max_iteration) {
				System.out.println("Maximum iterations exceeded.");
				break;
			}

			eta_im1 = eta_i;
			eta_i = eta_ip1;

			eta_ip1 = eta_i - f_(eta_i, m, l) * ((eta_i - eta_im1) / (f_(eta_i, m, l) - f_(eta_im1, m, l)));
		}

		/*
		 * Construct orthogonal unit vectors which lie in the orbital plane.
		 * (2.109, 2.100)
		 */
		Matrix e_a = r_a.times(1 / Math.sqrt(r_a.transpose().times(r_a).get(0, 0)));
		// [-]
		Matrix r_0 = r_b.minus(e_a.times(r_b.transpose().times(e_a).get(0, 0)));
		// [-]
		Matrix e_0 = r_0.times(1 / Math.sqrt(r_0.transpose().times(r_0).get(0, 0)));
		// [-]

		/*
		 * Construct the Gaussian vector which is a unit vector normal to the
		 * orbital plane.
		 */
		Matrix W = new Matrix(new double[][] { { +e_a.get(1, 0) * e_0.get(2, 0) - e_a.get(2, 0) * e_0.get(1, 0) },
				{ -e_a.get(0, 0) * e_0.get(2, 0) + e_a.get(2, 0) * e_0.get(0, 0) },
				{ +e_a.get(0, 0) * e_0.get(1, 0) - e_a.get(1, 0) * e_0.get(0, 0) } });
		// [-]

		/*
		 * Compute the inclination and right ascension of the ascending node.
		 * (2.58)
		 */
		double i = Math.atan2(Math.sqrt(Math.pow(W.get(0, 0), 2) + Math.pow(W.get(1, 0), 2)), W.get(2, 0));
		// [rad]
		double Omega = Math.atan2(W.get(0, 0), -W.get(1, 0));
		// [rad]

		/* Compute the argument of lattitude. (2.111) */

		double u_a = Math.atan2(r_a.get(2, 0), -r_a.get(0, 0) * W.get(1, 0) + r_a.get(1, 0) * W.get(0, 0));
		// [rad]
		// -pi <= atan2 <= pi

		/*
		 * Compute the area of the triangle defined by the two position vectors.
		 * (2.113)
		 */
		double Delta = (1 / 2.0) * Math.sqrt(r_a.transpose().times(r_a).get(0, 0))
				* Math.sqrt(r_0.transpose().times(r_0).get(0, 0));
		// [-]

		/* Compute the semi-latus rectum. (2.112) */

		double p = Math.pow(2 * Delta * eta_ip1 / tau, 2);
		// [er]

		/*
		 * Compute the eccentricity and true anomaly corresponding to the first
		 * position vector. (2.116)
		 */
		double e_c = p / Math.sqrt(r_a.transpose().times(r_a).get(0, 0)) - 1;
		// [-]
		double e_s = ((p / Math.sqrt(r_a.transpose().times(r_a).get(0, 0)) - 1)
				* (r_b.transpose().times(e_a).get(0, 0) / Math.sqrt(r_b.transpose().times(r_b).get(0, 0)))
				- (p / Math.sqrt(r_b.transpose().times(r_b).get(0, 0)) - 1))
				* (Math.sqrt(r_b.transpose().times(r_b).get(0, 0)) / Math.sqrt(r_0.transpose().times(r_0).get(0, 0)));
		// [-]

		double e = Math.sqrt(Math.pow(e_c, 2) + Math.pow(e_s, 2));
		// [-]
		double nu_a = Math.atan2(e_s, e_c);
		// [rad]

		/* Compoute the argument of perigee. (2.117) */

		double omega = u_a - nu_a;
		// [rad]

		/* Compute the semi-major axis. (2.118) */

		double a = p / (1 - Math.pow(e, 2));
		// [er]

		/*
		 * Compute the eccentric and mean anomaly corresponding to the first
		 * position vector. (2.121, 2.119)
		 */
		double E_a = Math.atan2(Math.sqrt(1 - Math.pow(e, 2)) * Math.sin(nu_a), Math.cos(nu_a) + e);
		// [er]
		double M = E_a - e * Math.sin(E_a);
		// [rad]

		/* Construct an orbit. */

		Omega = Coordinates.checkWrap(Omega);
		omega = Coordinates.checkWrap(omega);
		M = Coordinates.checkWrap(M);

		if (e > 0 && e < 1 // orbit is elliptical
				&& a * (1 - e) > 1 // orbit does not hit Earth
				&& a * (1 + e) < 7) { // orbit not more than six Earth radii
										// from surface of Earth
			popOrbP = new KeplerianOrbit(a, e, i, Omega, omega, M, dNm_a, "halley");
		}
		return popOrbP;
	}

	/**
	 * Perform differential correction of a preliminary orbit using the
	 * Gauss-Newton or Levenberg-Marquardt method.
	 * 
	 * @param popOrbP
	 *            The preliminary orbit
	 * @param obs_dNm
	 *            Date numbers of measured position
	 * @param obs_gei
	 *            Measured geocentric equatorial intertial position
	 * @param option
	 *            The numerical technique used: 'Levenberg-Marquardt' or
	 *            'Guass-Newton'
	 * @return Corrected orbit, if successful, and relevant information
	 * @throws ValueOutOfRangeException
	 * @throws SatElsetException
	 */
	public static DeterminationResult docNumerical(EstimatedOrbit popOrbP, ModJulianDate[] obs_dNm, Matrix[] obs_gei,
			String option) throws SatElsetException, ValueOutOfRangeException {

		logger.debug("== in ==");

		EstimatedOrbit popOrbC = null;
		String status = "differential correction diverged";
		if (popOrbP == null) {
			return new DeterminationResult(popOrbC, status);
		}

		/*
		 * Initialize the algorithm for computing the differential correction.
		 */

		// TODO: Set option as property.
		CorrectionResult ctnRes = new CorrectionResult(option);

		/* Apply first optimal differential correction. */

		int nItn = 1;

		EstimatedOrbit popOrb_i = null;
		if (popOrbP instanceof KeplerianOrbit) {
			popOrb_i = new KeplerianOrbit((KeplerianOrbit) popOrbP);
		} else if (popOrbP instanceof Sgp4Orbit) {
			popOrb_i = new Sgp4Orbit((Sgp4Orbit) popOrbP);
		}
		SearchResult schRes = searchLine(popOrb_i, obs_dNm, obs_gei, ctnRes);
		EstimatedOrbit popOrb_ip1 = schRes.estOrb_ip1;
		double cur_sSq = schRes.sSq;

		double cur_time_offset = (popOrb_ip1.get_M() - popOrb_i.get_M()) / popOrb_i.meanMotion();

		logger.warn(String.format("Time offset ip1-i: %f (s) - nItn: %d", cur_time_offset, nItn));

		/*
		 * Continue to apply differential corrections until the mean anomaly is
		 * determined to the given precision or the maximum number of iterations
		 * is exceeded.
		 */
		status = "differential correction successful";

		double min_sSq = Double.POSITIVE_INFINITY;

		while (Math.abs(cur_time_offset) > SimulationConstants.max_time_diff) {
			nItn += 1;
			if (nItn > SimulationConstants.max_iteration) {
				logger.info("Maximum iterations exceeded.");
				status = "maximum iterations exceeded";
				break;
			}

			if (cur_sSq < min_sSq) {
				min_sSq = cur_sSq;

			} else {
				logger.info(String.format("Differential correction diverging (%d).", nItn));
				if (popOrb_i instanceof KeplerianOrbit) {
					popOrbC = new KeplerianOrbit((KeplerianOrbit) popOrb_i);
				} else if (popOrb_i instanceof Sgp4Orbit) {
					popOrbC = new Sgp4Orbit((Sgp4Orbit) popOrb_i);
				}
				status = "differential correction diverged";
				return new DeterminationResult(popOrbC, status);
			}

			/* Apply the current optimal differential correction. */

			if (popOrb_ip1 instanceof KeplerianOrbit) {
				popOrb_i = new KeplerianOrbit((KeplerianOrbit) popOrb_ip1);
			} else if (popOrb_ip1 instanceof Sgp4Orbit) {
				popOrb_i = new Sgp4Orbit((Sgp4Orbit) popOrb_ip1);
			}
			schRes = searchLine(popOrb_i, obs_dNm, obs_gei, ctnRes);
			popOrb_ip1 = schRes.estOrb_ip1;
			cur_sSq = schRes.sSq;

			cur_time_offset = (popOrb_ip1.get_M() - popOrb_i.get_M()) / popOrb_i.meanMotion();

			logger.info(String.format("Time offset ip1-i: %f (s) - nItn: %d", cur_time_offset, nItn));
		}
		popOrbC = popOrb_ip1;
		return new DeterminationResult(popOrbC, status);
	}

	/**
	 * Evaluates equation (2.106).
	 */
	private static double f_(double x, double m, double l) {
		if (x <= 1) {
			throw new IllegalArgumentException("Argument must be greater than one.");
		}
		return 1 - x + (m / Math.pow(x, 2)) * W_(m / Math.pow(x, 2) - l);
	}

	/**
	 * Evaluates equation (2.103).
	 */
	private static double W_(double w) {
		if (w < 0) {
			throw new IllegalArgumentException("Argument must be positive.");
		} else if (w == 0) {
			return 4.0 / 3.0;
		} else {
			double g = 2 * Math.asin(Math.sqrt(w));
			return (2 * g - Math.sin(2 * g)) / Math.pow(Math.sin(g), 3);
		}
	}

	/**
	 * Perform a line search to find the optimum fraction of the differential
	 * correction to apply.
	 * 
	 * @param popOrb_i
	 *            The orbit at step i
	 * @param obs_dNm
	 *            Date numbers of measured position
	 * @param obs_gei
	 *            Measured geocentric equatorial inertial position
	 * @param ctnRes
     *            Result of a differential correction operation.
     *
	 * @return Line search result
	 * @throws ValueOutOfRangeException
	 * @throws SatElsetException
	 */
	private static SearchResult searchLine(EstimatedOrbit popOrb_i, ModJulianDate[] obs_dNm, Matrix[] obs_gei,
			CorrectionResult ctnRes) throws SatElsetException, ValueOutOfRangeException {

		/* Compute the differential correction. */

		computeCorrection(popOrb_i, obs_dNm, obs_gei, ctnRes);

		/*
		 * Use bisection to find the optimum fraction between zero and one of
		 * the differential correction to apply.
		 */
		SearchResult schRes;

		double alpha_l = 0.0;
		schRes = applyCorrection(popOrb_i, ctnRes.dx, alpha_l, obs_dNm, obs_gei);
		double sSq_l = schRes.sSq;

		double alpha_r = 1.0;
		schRes = applyCorrection(popOrb_i, ctnRes.dx, alpha_r, obs_dNm, obs_gei);
		double sSq_r = schRes.sSq;

		while (alpha_r - alpha_l > 0.001) {
			double alpha_m = (alpha_l + alpha_r) / 2;
			if (sSq_l < sSq_r) {
				alpha_r = alpha_m;
				schRes = applyCorrection(popOrb_i, ctnRes.dx, alpha_m, obs_dNm, obs_gei);
				sSq_r = schRes.sSq;

			} else {
				alpha_l = alpha_m;
				schRes = applyCorrection(popOrb_i, ctnRes.dx, alpha_m, obs_dNm, obs_gei);
				sSq_l = schRes.sSq;
			}
		}
		return schRes;
	}

	/**
	 * Compute the difference between the modeled and measured observations, the
	 * corresponding elements of the Jacobian, and the resulting differential
	 * correction.
	 * 
	 * @param popOrb_i
	 *            The orbit at step i
	 * @param obs_dNm
	 *            Date numbers of measured position
	 * @param obs_gei
	 *            Measured geocentric equatorial intertial position
     * @param ctnRes
     *            Result of a differential correction operation.
     *
	 * @throws ValueOutOfRangeException
	 * @throws SatElsetException
	 */
	private static void computeCorrection(EstimatedOrbit popOrb_i, ModJulianDate[] obs_dNm, Matrix[] obs_gei,
			CorrectionResult ctnRes) throws SatElsetException, ValueOutOfRangeException {

		/*
		 * Compute the difference between the modeled and measured observations,
		 * and the corresponding elements of the Jacobian.
		 */
		int[] diagIdx = new int[] { 0, 1, 2, 3, 4, 5 };

		int rowBeg = -1;
		int rowEnd = -1;
		int colBeg = -1;
		int colEnd = -1;

		int nDNm = obs_dNm.length;

		Matrix dz = new Matrix(3 * nDNm, 1);
		Matrix H = new Matrix(3 * nDNm, 6);
		Matrix D = new Matrix(6, 6);

		for (int iDNm = 0; iDNm < nDNm; iDNm++) {
			Matrix mdl_gei = popOrb_i.r_gei(obs_dNm[iDNm]);
			rowBeg = 3 * iDNm;
			rowEnd = 3 * iDNm + 2;
			colBeg = 0;
			colEnd = 0;
			// dz.print(16, 8);
			dz.setMatrix(rowBeg, rowEnd, colBeg, colEnd, obs_gei[iDNm].minus(mdl_gei));
			// dz.print(16, 8);
			colBeg = 0;
			colEnd = 5;
			// H.print(16, 8);
			H.setMatrix(rowBeg, rowEnd, colBeg, colEnd, jacobianNumerical(popOrb_i, obs_dNm[iDNm]));
			// H.setMatrix(rowIdxH, colIdxH, jacobianNumerical(popOrb_i,
			// obs_dNm[iDNm]));
			// H.print(16, 8);
		}

		/* Compute the resulting differential correction. */

		ctnRes.dz = dz;
		ctnRes.H = H;
		if (ctnRes.option.equals("Levenberg-Marquardt")) {

			/* Apply the full differential correction. */

			double alpha = 1;

			/*
			 * Compute the sum of the squared differences (between the modeled
			 * and measured observations) without differential correction.
			 */
			double[] dx_0 = new double[] { 0, 0, 0, 0, 0, 0 };
			SearchResult schRes = applyCorrection(popOrb_i, dx_0, alpha, obs_dNm, obs_gei);
			double sSq_0 = schRes.sSq;

			/*
			 * Compute the sum of the squared differences with differential
			 * correction computed using the _lesser_ damping factor.
			 */
			// dx_l = (H' * H + (lambda / nu) * diag(diag(H' * H))) \ (H' * dz);
			// D.print(16, 8);
			for (int idx : diagIdx) {
				D.set(idx, idx, H.transpose().times(H).get(idx, idx));
			}
			// D.setMatrix(diagIdx, diagIdx,
			// H.transpose().times(H).getMatrix(diagIdx, diagIdx));
			// D.print(16, 8);
			double[] dx_l = H.transpose().times(H).plus(D.times(ctnRes.lambda / ctnRes.nu))
					.solve(H.transpose().times(dz)).getRowPackedCopy();
			schRes = applyCorrection(popOrb_i, dx_l, alpha, obs_dNm, obs_gei);
			double sSq_l = schRes.sSq;

			/*
			 * Compute the sum of the squared differences with differential
			 * correction computed using the _greater_ damping factor.
			 */
			// dx_g = (H' * H + lambda * diag(diag(H' * H))) \ (H' * dz);
			double[] dx_g = H.transpose().times(H).plus(D.times(ctnRes.lambda)).solve(H.transpose().times(dz))
					.getRowPackedCopy();
			schRes = applyCorrection(popOrb_i, dx_g, alpha, obs_dNm, obs_gei);
			double sSq_g = schRes.sSq;

			/*
			 * Increase the damping factor until a reduction in the sum of the
			 * squared differences results.
			 */
			while (sSq_l > sSq_0 && sSq_g > sSq_0 && ctnRes.lambda < 9) {
				ctnRes.lambda = ctnRes.nu * ctnRes.lambda;

				// dx_l = (H' * H + (lambda / nu) * diag(diag(H' * H))) \ (H' *
				// dz);
				dx_l = H.transpose().times(H).plus(D.times(ctnRes.lambda / ctnRes.nu)).solve(H.transpose().times(dz))
						.getRowPackedCopy();
				schRes = applyCorrection(popOrb_i, dx_l, alpha, obs_dNm, obs_gei);
				sSq_l = schRes.sSq;

				// dx_g = (H' * H + lambda * diag(diag(H' * H))) \ (H' * dz);
				dx_g = H.transpose().times(H).plus(D.times(ctnRes.lambda)).solve(H.transpose().times(dz))
						.getRowPackedCopy();
				schRes = applyCorrection(popOrb_i, dx_g, alpha, obs_dNm, obs_gei);
				sSq_g = schRes.sSq;
			}

			/*
			 * Retain the least damping factor that gives a reduction in the sum
			 * of the squared differences, and assign the corresponding
			 * differential correction.
			 */
			if (sSq_l < sSq_0) {
				ctnRes.lambda = ctnRes.lambda / ctnRes.nu;
				ctnRes.dx = dx_l;

			} else {

				/* lambda is unchanged. */

				ctnRes.dx = dx_g;
			}

		} else { // 'Guass-Newton'

			/* Compute the differential correction. */

			// dx = (H' * H) \ (H' * dz);
			ctnRes.dx = H.transpose().times(H).solve(H.transpose().times(dz)).getRowPackedCopy();
		}
	}

	/**
	 * Differentially correct the given element set. Measure the fit by
	 * computing the sum of the squared differences between the modeled and
	 * measured observations.
	 * 
	 * @param popOrb_i
	 *            The orbit at step i
	 * @param dx
	 *            The differential corrections
	 * @param alpha
	 *            The differential correction fraction applied
	 * @param obs_dNm
	 *            Date numbers of measured position
	 * @param obs_gei
	 *            Measured geocentric equatorial intertial position
	 * @return Line search result
	 * @throws ValueOutOfRangeException
	 * @throws SatElsetException
	 */
	private static SearchResult applyCorrection(EstimatedOrbit popOrb_i, double[] dx, double alpha,
			ModJulianDate[] obs_dNm, Matrix[] obs_gei) throws SatElsetException, ValueOutOfRangeException {

		/* Differentially correct the given element set. */

		// popOrb_ip1.id = popOrb_i.id;

		// TODO: Check that these limits make sense.
		double a = Math.max(alpha * dx[0] + popOrb_i.get_a(), 1.0);
		double e = Math.min(Math.max(alpha * dx[1] + popOrb_i.get_e(), 0.000001), 0.999999);
		double i = Math.min(Math.max(alpha * dx[2] + popOrb_i.get_i(), 0.0), Math.PI);
		double Omega = Math.min(Math.max(alpha * dx[3] + popOrb_i.get_Omega(), 0.0), 2 * Math.PI);
		double omega = Math.min(Math.max(alpha * dx[4] + popOrb_i.get_omega(), 0.0), 2 * Math.PI);
		double M = Math.min(Math.max(alpha * dx[5] + popOrb_i.get_M(), 0.0), 2 * Math.PI);

		ModJulianDate epoch = (ModJulianDate) popOrb_i.get_epoch().clone();

		// KeplerianOrbit popOrb_ip1 = new KeplerianOrbit(a, e, i, Omega, omega,
		// M, epoch, "halley");
		KeplerianOrbit kepOrb = new KeplerianOrbit(a, e, i, Omega, omega, M, epoch, "halley");
		EstimatedOrbit popOrb_ip1 = null;
		if (popOrb_i instanceof KeplerianOrbit) {
			popOrb_ip1 = new KeplerianOrbit(kepOrb);
		} else if (popOrb_i instanceof Sgp4Orbit) {
			Sgp4Orbit sgp4Orb = new Sgp4Orbit((long) 99999, kepOrb);
			popOrb_ip1 = sgp4Orb;
		}

		/*
		 * Enforce sensible physical limits.
		 * 
		 * // TODO: Check that these limits make sense. //
		 * popOrb_ip1.set_a(max([1, popOrb_ip1.a])); // TODO: Fix the
		 * eccentricity limit. // popOrb_ip1.set_e(max([0.0001, min([0.9999,
		 * popOrb_ip1.e])])); //
		 * popOrb_ip1.set_i(Coordinates.check_wrap(popOrb_ip1.i)); //
		 * popOrb_ip1.set_Omega(Coordinates.check_wrap(popOrb_ip1.Omega)); //
		 * popOrb_ip1.set_omega(Coordinates.check_wrap(popOrb_ip1.omega)); //
		 * popOrb_ip1.set_M(Coordinates.check_wrap(popOrb_ip1.M));
		 */

		/*
		 * Measure the fit by computing the sum of the squared differences
		 * between the modeled and measured observations.
		 */
		double sSq = 0.0;
		int nDNm = obs_dNm.length;
		for (int iDNm = 0; iDNm < nDNm; iDNm++) {
			Matrix mdl_gei = popOrb_ip1.r_gei(obs_dNm[iDNm]);
			Matrix obs_res = obs_gei[iDNm].minus(mdl_gei);
			sSq = obs_res.norm2();
		}
		return new SearchResult(popOrb_ip1, sSq);
	}

	private enum OrbProps {
		a, e, i, Omega, omega, M
	};

	private static EnumSet<OrbProps> orbProps = EnumSet.allOf(OrbProps.class);

	/**
	 * Compute the Jacobian for differential orbit correction using a centered
	 * difference. (7.108)
	 * 
	 * @param popOrbU
	 *            The orbit
	 * @param dNm
	 *            The date number
	 * @return The Jacobian
	 * @throws ValueOutOfRangeException
	 * @throws SatElsetException
	 */
	private static Matrix jacobianNumerical(EstimatedOrbit popOrbU, ModJulianDate dNm)
			throws SatElsetException, ValueOutOfRangeException {

		/*
		 * Compute geocentric equatorial inertial position corresponding to the
		 * unmodified orbit.
		 */
		Matrix r_gei_1 = popOrbU.r_gei(dNm);

		/*
		 * Differentially modify each property of the orbit, and compute the
		 * geocentric equatorial inertial position of the modified orbit and
		 * elements of the Jacobian matrix.
		 */
		Matrix H = new Matrix(3, 6);

		int rowBeg = 0;
		int rowEnd = 2;
		int colBeg = -1;
		int colEnd = -1;

		EstimatedOrbit popOrbM = null;
		if (popOrbU instanceof KeplerianOrbit) {
			popOrbM = new KeplerianOrbit((KeplerianOrbit) popOrbU);
		} else if (popOrbU instanceof Sgp4Orbit) {
			popOrbM = new Sgp4Orbit((Sgp4Orbit) popOrbU);
		}

		double dx = 0.0;
		Matrix dhp = null;
		Matrix dhm = null;
		int iPrp = -1;
		for (OrbProps p : orbProps) {
			iPrp++;
			switch (p) {
			case a:
				dx = popOrbU.get_a() * SimulationConstants.decimal_delta;

				popOrbM.set_a(popOrbU.get_a() + dx / 2);
				dhp = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_a(popOrbU.get_a() - dx / 2);
				dhm = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_a(popOrbU.get_a());
				break;

			case e:
				dx = popOrbU.get_e() * SimulationConstants.decimal_delta;

				popOrbM.set_e(popOrbU.get_e() + dx / 2);
				dhp = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_e(popOrbU.get_e() - dx / 2);
				dhm = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_e(popOrbU.get_e());
				break;

			case i:
				dx = popOrbU.get_i() * SimulationConstants.decimal_delta;

				popOrbM.set_i(popOrbU.get_i() + dx / 2);
				dhp = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_i(popOrbU.get_i() - dx / 2);
				dhm = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_i(popOrbU.get_i());
				break;

			case Omega:
				dx = popOrbU.get_Omega() * SimulationConstants.decimal_delta;

				popOrbM.set_Omega(popOrbU.get_Omega() + dx / 2);
				dhp = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_Omega(popOrbU.get_Omega() - dx / 2);
				dhm = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_Omega(popOrbU.get_Omega());
				break;

			case omega:
				dx = popOrbU.get_omega() * SimulationConstants.decimal_delta;

				popOrbM.set_omega(popOrbU.get_omega() + dx / 2);
				dhp = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_omega(popOrbU.get_omega() - dx / 2);
				dhm = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_omega(popOrbU.get_omega());
				break;

			case M:
				dx = popOrbU.get_M() * SimulationConstants.decimal_delta;

				popOrbM.set_M(popOrbU.get_M() + dx / 2);
				dhp = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_M(popOrbU.get_M() - dx / 2);
				dhm = popOrbM.r_gei(dNm).minus(r_gei_1);

				popOrbM.set_M(popOrbU.get_M());
				break;
			}
			colBeg = iPrp;
			colEnd = iPrp;
			// H.print(16, 8);
			H.setMatrix(rowBeg, rowEnd, colBeg, colEnd, dhp.minus(dhm).times(1 / dx));
			// H.print(16, 8);
		}
		return H;
	}
}
