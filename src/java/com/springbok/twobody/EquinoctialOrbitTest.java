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

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import Jama.Matrix;

import com.springbok.utility.TestUtility;

public class EquinoctialOrbitTest {

	// Input direct or retrograde orbit indicator [-]
	private final int j_input = 1;
	// Input semi-major axis [er]
	private final double a_input = EarthConstants.a_gso;
	// Input epoch date number
	private final ModJulianDate epoch_input = new ModJulianDate(5.154450000000000e+04);

	// Input method to solve Kepler's equation: "newton" or "halley"
	private final String method_input = "halley";

	// Eccentricity [-]
	private final double e = 2.220446049250313e-16;
	// Inclination [rad]
	private final double i = 1 * Math.PI / 180;
	// Right ascension of the ascending node [rad]
	private final double Omega = Math.PI / 4;
	// Argument of perigee [rad]
	private final double omega = Math.PI / 4;
	// Mean anomaly [rad]
	private final double M = Math.PI / 4;

	// Input Y component of the eccentricity vector [-]
	double h_input;
	// Input X component of the eccentricity [-]
	double k_input;
	// Input Y component of the nodal vector [-]
	double p_input;
	// Input X component of the nodal vector [-]
	double q_input;
	// Input mean longitude [rad]
	double lambda_input;

	// An equinoctial orbit
	private EquinoctialOrbit equinoctial_orbit;

	@Before
	public void setUp() throws Exception {

		// Compute derived properties
		this.h_input = this.e * Math.sin(this.Omega + this.omega);
		this.k_input = this.e * Math.cos(this.Omega + this.omega);
		this.p_input = Math.tan(this.i / 2) * Math.sin(this.Omega);
		this.q_input = Math.tan(this.i / 2) * Math.cos(this.Omega);
		this.lambda_input = this.Omega + this.omega + this.M;

		this.equinoctial_orbit = new EquinoctialOrbit(this.j_input, this.a_input, this.h_input, this.k_input,
				this.p_input, this.q_input, this.lambda_input, this.epoch_input, this.method_input);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	// Tests EquinotialOrbit method.
	public void test_EquinoctialOrbit() {

		int j_expected = 1;
		double a_expected = this.a_input;
		double h_expected = this.h_input;
		double k_expected = this.k_input;
		double p_expected = this.p_input;
		double q_expected = this.q_input;
		double lambda_expected = this.lambda_input;
		ModJulianDate epoch_expected = this.epoch_input;
		String method_expected = this.method_input;

		double n_expected = Math.sqrt(EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus * this.a_input, 3));
		double T_expected = 2 * Math.PI
				* Math.sqrt(Math.pow(EarthConstants.R_oplus * this.a_input, 3) / EarthConstants.GM_oplus);

		assertTrue(this.equinoctial_orbit.get_j() == j_expected);
		assertTrue(this.equinoctial_orbit.get_a() == a_expected);
		assertTrue(this.equinoctial_orbit.get_h() == h_expected);
		assertTrue(this.equinoctial_orbit.get_k() == k_expected);
		assertTrue(this.equinoctial_orbit.get_p() == p_expected);
		assertTrue(this.equinoctial_orbit.get_q() == q_expected);
		assertTrue(this.equinoctial_orbit.get_lambda() == lambda_expected);
		assertTrue(this.equinoctial_orbit.get_epoch() == epoch_expected);
		assertTrue(this.equinoctial_orbit.get_method() == method_expected);
		assertTrue(Math.abs(this.equinoctial_orbit.get_n() - n_expected) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(this.equinoctial_orbit.get_T() - T_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests meanMotion method.
	public void test_meanMotion() {

		double n_expected = Math.sqrt(EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus * this.a_input, 3));

		double n_actual = this.equinoctial_orbit.meanMotion();

		assertTrue(Math.abs(n_actual - n_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests meanPosition method.
	public void test_meanPosition() {

		double delta_dNm = this.equinoctial_orbit.get_T() / 86400.0;
		ModJulianDate dNm = new ModJulianDate(this.epoch_input.getAsDouble() + delta_dNm);

		double lambda_expected = this.lambda_input;

		double lambda_actual = this.equinoctial_orbit.meanPosition(dNm);

		assertTrue(Math.abs(lambda_actual - lambda_expected) < TestUtility.LOW_PRECISION);
	}

	@Test
	// Tests orbitalPeriod method.
	public void test_orbitalPeriod() {

		double T_expected = 2 * Math.PI
				* Math.sqrt(Math.pow(EarthConstants.R_oplus * this.a_input, 3) / EarthConstants.GM_oplus);

		Double T_actual = this.equinoctial_orbit.orbitalPeriod();

		assertTrue(Math.abs(T_actual - T_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests of keplersEquation method.
	public void test_keplersEquation() {

		double F_expected = this.lambda_input; // for GSO, e = 0, so F = lambda

		double F_actual = this.equinoctial_orbit.keplersEquation(this.lambda_input);

		assertTrue(Math.abs(F_actual - F_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests r_goi method.
	public void test_r_goi() {

		double[][] r_goi_expected_col = { { -Math.sin(Math.PI / 4.0) }, { +Math.cos(Math.PI / 4.0) }, { 0 } };
		Matrix r_goi_expected = new Matrix(r_goi_expected_col).times(EarthConstants.a_gso); // e
																							// =
																							// 0,
																							// so
																							// r
																							// =
																							// a,
																							// equinoctial
																							// coordinate
																							// system

		Matrix r_goi_actual = this.equinoctial_orbit.r_goi(this.equinoctial_orbit.keplersEquation(this.lambda_input));

		Matrix delta_r_goi = r_goi_actual.minus(r_goi_expected);

		assertTrue(Math.sqrt(delta_r_goi.transpose().times(delta_r_goi).get(0, 0)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests r_gei method.
	public void test_r_gei() {

		double[][] R_mat = { { +1 - Math.cos(this.i), -1 - Math.cos(this.i), +Math.sqrt(2) * Math.sin(this.i) },
				{ +1 + Math.cos(this.i), -1 + Math.cos(this.i), -Math.sqrt(2) * Math.sin(this.i) },
				{ Math.sqrt(2) * Math.sin(this.i), Math.sqrt(2) * Math.sin(this.i), 2 * Math.cos(this.i) } };
		Matrix R = new Matrix(R_mat).times(1.0 / 2.0);

		double[][] r_goi_expected_col = { { Math.cos(Math.PI / 4.0) }, { Math.sin(Math.PI / 4.0) }, { 0 } };
		Matrix r_goi_expected = new Matrix(r_goi_expected_col).times(EarthConstants.a_gso); // e
																							// =
																							// 0,
																							// so
																							// r
																							// =
																							// a,
																							// Keplerian
																							// coordinate
																							// system

		Matrix r_gei_expected = R.times(r_goi_expected);

		Matrix r_gei_actual = this.equinoctial_orbit.r_gei(this.epoch_input);

		Matrix delta_r_gei = r_gei_actual.minus(r_gei_expected);

		assertTrue(Math.sqrt(delta_r_gei.transpose().times(delta_r_gei).get(0, 0)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests set_a method.
	public void test_set_a() {

		double a_expected = this.a_input;

		this.equinoctial_orbit.set_a(this.a_input);

		double a_actual = this.equinoctial_orbit.get_a();

		assertTrue(a_actual == a_expected);
	}

	@Test
	// Test set_h method.
	public void test_set_h() {

		double h_expected = this.h_input;

		this.equinoctial_orbit.set_h(this.h_input);

		double h_actual = this.equinoctial_orbit.get_h();

		assertTrue(h_actual == h_expected);
	}

	@Test
	// Tests set_k method.
	public void test_set_k() {

		double k_expected = this.k_input;

		this.equinoctial_orbit.set_k(this.k_input);

		double k_actual = this.equinoctial_orbit.get_k();

		assertTrue(k_actual == k_expected);
	}

	@Test
	// Test set_p method.
	public void test_set_p() {

		double p_expected = this.p_input;

		this.equinoctial_orbit.set_p(this.p_input);

		double p_actual = this.equinoctial_orbit.get_p();

		assertTrue(p_actual == p_expected);
	}

	@Test
	// Test set_q method.
	public void test_set_q() {

		double q_expected = this.q_input;

		this.equinoctial_orbit.set_q(this.q_input);

		double q_actual = this.equinoctial_orbit.get_q();

		assertTrue(q_actual == q_expected);
	}

	@Test
	// Tests set_lambda method.
	public void test_set_lambda() {

		double lambda_expected = this.lambda_input;

		this.equinoctial_orbit.set_lambda(this.lambda_input);

		double lambda_actual = this.equinoctial_orbit.get_lambda();

		assertTrue(lambda_actual == lambda_expected);
	}

	@Test
	// Tests set_epoch method.
	public void test_set_epoch() {

		ModJulianDate epoch_expected = this.epoch_input;

		this.equinoctial_orbit.set_epoch(this.epoch_input);

		ModJulianDate epoch_actual = this.equinoctial_orbit.get_epoch();

		assertTrue(epoch_actual == epoch_expected);
	}

	@Test
	// Tests set_method method.
	public void test_set_method() {

		String method_expected = this.method_input;

		this.equinoctial_orbit.set_method(this.method_input);

		String method_actual = this.equinoctial_orbit.get_method();

		assertTrue(method_actual.equals(method_expected));
	}
}
