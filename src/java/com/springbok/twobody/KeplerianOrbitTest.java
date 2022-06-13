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

import com.springbok.utility.TestUtility;

import Jama.Matrix;

public class KeplerianOrbitTest {

	// Input semi-major axis [er]
	private final double a_input = EarthConstants.a_gso;
	// Input eccentricity [-]
	private final double e_input = 2.220446049250313e-16;
	// Input inclination [rad]
	private final double i_input = 1 * Math.PI / 180;
	// Input right ascension of the ascending node [rad]
	private final double Omega_input = Math.PI / 4;
	// Input argument of perigee [rad]
	private final double omega_input = Math.PI / 4;
	// Input mean anomaly [rad]
	private final double M_input = Math.PI / 4;
	// Input epoch date number
	private final ModJulianDate epoch_input = new ModJulianDate(5.154450000000000e+04);

	// Input method to solve Kepler's equation: 'newton' or 'halley'
	private final String method_input = "halley";

	// A Keplerian orbit
	private KeplerianOrbit keplerian_orbit;

	@Before
	public void setUp() throws Exception {

		// Compute derived properties
		this.keplerian_orbit = new KeplerianOrbit(this.a_input, this.e_input, this.i_input, this.Omega_input,
				this.omega_input, this.M_input, this.epoch_input, this.method_input);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	// Tests KeplerianOrbit method.
	public void test_KeplerianOrbit() {

		double a_expected = this.a_input;
		double e_expected = this.e_input;
		double i_expected = this.i_input;
		double Omega_expected = this.Omega_input;
		double omega_expected = this.omega_input;
		double M_expected = this.M_input;
		ModJulianDate epoch_expected = this.epoch_input;
		String method_expected = this.method_input;

		double n_expected = Math.sqrt(EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus * this.a_input, 3));
		double T_expected = 2 * Math.PI
				* Math.sqrt(Math.pow(EarthConstants.R_oplus * this.a_input, 3) / EarthConstants.GM_oplus);

		assertTrue(this.keplerian_orbit.get_a() == a_expected);
		assertTrue(this.keplerian_orbit.get_e() == e_expected);
		assertTrue(this.keplerian_orbit.get_i() == i_expected);
		assertTrue(this.keplerian_orbit.get_Omega() == Omega_expected);
		assertTrue(this.keplerian_orbit.get_omega() == omega_expected);
		assertTrue(this.keplerian_orbit.get_M() == M_expected);
		assertTrue(this.keplerian_orbit.get_epoch().equals(epoch_expected));
		assertTrue(this.keplerian_orbit.get_method() == method_expected);
		assertTrue(Math.abs(this.keplerian_orbit.get_n() - n_expected) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(this.keplerian_orbit.get_T() - T_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests meanMotion method.
	public void test_meanMotion() {

		double n_expected = Math.sqrt(EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus * this.a_input, 3));

		double n_actual = this.keplerian_orbit.meanMotion();

		assertTrue(Math.abs(n_actual - n_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests meanPosition method.
	public void test_meanPosition() {

		double delta_dNm = this.keplerian_orbit.get_T() / 86400.0;
		ModJulianDate dNm = new ModJulianDate(this.epoch_input.getAsDouble() + delta_dNm);

		double M_expected = this.M_input;

		double M_actual = this.keplerian_orbit.meanPosition(dNm);

		assertTrue(Math.abs(M_actual - M_expected) < TestUtility.LOW_PRECISION);
	}

	@Test
	// Tests orbitalPeriod method.
	public void test_orbitalPeriod() {

		double T_expected = 2 * Math.PI
				* Math.sqrt(Math.pow(EarthConstants.R_oplus * this.a_input, 3) / EarthConstants.GM_oplus);

		double T_actual = this.keplerian_orbit.orbitalPeriod();

		assertTrue(Math.abs(T_actual - T_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests visVivaLaw method.
	public void test_visVivaLaw() {

		double v_expected = Math.sqrt(EarthConstants.GM_oplus / (this.a_input * EarthConstants.R_oplus))
				/ EarthConstants.R_oplus; // e = 0, so r = a

		double v_actual = this.keplerian_orbit.visVivaLaw(this.M_input);
		// e = 0, so E = M

		assertTrue(Math.abs(v_actual - v_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests secularPerturbations method.
	public void test_secularPerturbations() {

		double p = this.a_input; // e = 0, so p = a
		double n = this.keplerian_orbit.meanMotion();

		double Omega_dot_expected = -(3.0 / 2.0) * (EarthConstants.J_2 / Math.pow(p, 2)) * Math.cos(this.i_input) * n;
		double omega_dot_expected = +(3.0 / 2.0) * (EarthConstants.J_2 / Math.pow(p, 2))
				* (2 - (5.0 / 2.0) * Math.pow(Math.sin(this.i_input), 2)) * n;
		double M_0_dot_expected = +(3.0 / 2.0) * (EarthConstants.J_2 / Math.pow(p, 2))
				* (1 - (3.0 / 2.0) * Math.pow(Math.sin(this.i_input), 2)) * n; // e
																				// =
																				// 0,
																				// 1
																				// -
																				// e^2
																				// =
																				// 1

		double Omega_dot_actual = this.keplerian_orbit.get_Omega_dot();
		double omega_dot_actual = this.keplerian_orbit.get_omega_dot();
		double M_0_dot_actual = this.keplerian_orbit.get_M_0_dot();

		assertTrue(Math.abs(Omega_dot_actual - Omega_dot_expected) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(omega_dot_actual - omega_dot_expected) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(M_0_dot_actual - M_0_dot_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests keplersEquation method.
	public void test_keplersEquation() {

		double E_expected = this.M_input; // e = 0, so E = M

		double E_actual = this.keplerian_orbit.keplersEquation(this.M_input);

		assertTrue(Math.abs(E_actual - E_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests r_goi method.
	public void test_r_goi() {

		double[][] r_goi_expected_col = { { Math.cos(Math.PI / 4.0) }, { Math.sin(Math.PI / 4.0) }, { 0 } };
		Matrix r_goi_expected = new Matrix(r_goi_expected_col).times(EarthConstants.a_gso);

		Matrix r_goi_actual = this.keplerian_orbit.r_goi(this.keplerian_orbit.keplersEquation(this.M_input));

		Matrix delta_r_goi = r_goi_actual.minus(r_goi_expected);

		assertTrue(Math.sqrt(delta_r_goi.transpose().times(delta_r_goi).get(0, 0)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// tests v_goi method.
	public void test_v_goi() {

		double[][] v_goi_expected_col = { { -Math.sin(Math.PI / 4.0) }, { +Math.cos(Math.PI / 4.0) },
				{ +0.000000000000000 } };
		Matrix v_goi_expected = new Matrix(v_goi_expected_col).times(
				Math.sqrt(EarthConstants.GM_oplus / (this.a_input * EarthConstants.R_oplus)) / EarthConstants.R_oplus); // e
																														// =
																														// 0,
																														// so
																														// v
																														// =
																														// sqrt(GM_oplus
																														// /
																														// a)

		Matrix v_goi_actual = this.keplerian_orbit.v_goi(this.M_input);

		Matrix delta_v_goi = v_goi_actual.minus(v_goi_expected);

		assertTrue(Math.sqrt(delta_v_goi.transpose().times(delta_v_goi).get(0, 0)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests r_gei method.
	public void test_r_gei() {

		double[][] R_mat = {
				{ +1 - Math.cos(this.i_input), -1 - Math.cos(this.i_input), +Math.sqrt(2) * Math.sin(this.i_input) },
				{ +1 + Math.cos(this.i_input), -1 + Math.cos(this.i_input), -Math.sqrt(2) * Math.sin(this.i_input) },
				{ Math.sqrt(2) * Math.sin(this.i_input), Math.sqrt(2) * Math.sin(this.i_input),
						2 * Math.cos(this.i_input) } };
		Matrix R = new Matrix(R_mat).times(1.0 / 2.0);

		double[][] r_goi_expected_col = { { Math.cos(Math.PI / 4.0) }, { Math.sin(Math.PI / 4.0) }, { 0.0 } };
		Matrix r_goi_expected = new Matrix(r_goi_expected_col).times(EarthConstants.a_gso);

		Matrix r_gei_expected = R.times(r_goi_expected);

		Matrix r_gei_actual = this.keplerian_orbit.r_gei(this.epoch_input);

		Matrix delta_r_gei = r_gei_actual.minus(r_gei_expected);

		assertTrue(Math.sqrt(delta_r_gei.transpose().times(delta_r_gei).get(0, 0)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests v_gei method.
	public void test_v_gei() {

		double[][] R_mat = {
				{ +1 - Math.cos(this.i_input), -1 - Math.cos(this.i_input), +Math.sqrt(2) * Math.sin(this.i_input) },
				{ +1 + Math.cos(this.i_input), -1 + Math.cos(this.i_input), -Math.sqrt(2) * Math.sin(this.i_input) },
				{ Math.sqrt(2) * Math.sin(this.i_input), Math.sqrt(2) * Math.sin(this.i_input),
						2 * Math.cos(this.i_input) } };
		Matrix R = new Matrix(R_mat).times(1.0 / 2.0);

		double[][] v_goi_expected_col = { { -Math.sin(Math.PI / 4.0) }, { +Math.cos(Math.PI / 4.0) },
				{ +0.000000000000000 } };
		Matrix v_goi_expected = new Matrix(v_goi_expected_col).times(
				Math.sqrt(EarthConstants.GM_oplus / (this.a_input * EarthConstants.R_oplus)) / EarthConstants.R_oplus); // e
																														// =
																														// 0,
																														// so
																														// v
																														// =
																														// sqrt(GM_oplus
																														// /
																														// a)

		Matrix v_gei_expected = R.times(v_goi_expected);

		Matrix v_gei_actual = this.keplerian_orbit.v_gei(this.epoch_input);

		Matrix delta_v_gei = v_gei_actual.minus(v_gei_expected);

		assertTrue(Math.sqrt(delta_v_gei.transpose().times(delta_v_gei).get(0, 0)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests element_set method.
	public void test_element_set() {

		double e_input = 0.001; // Method does not work well for small
								// eccentricity
		KeplerianOrbit keplerian_orbit_expected = new KeplerianOrbit(this.a_input, e_input, this.i_input,
				this.Omega_input, this.omega_input, this.M_input, this.epoch_input, this.method_input);

		KeplerianOrbit keplerian_orbit_actual = keplerian_orbit_expected.element_set(this.epoch_input,
				keplerian_orbit_expected.r_gei(this.epoch_input), keplerian_orbit_expected.v_gei(this.epoch_input));

		assertTrue(Math
				.abs(keplerian_orbit_actual.get_a() - keplerian_orbit_expected.get_a()) < TestUtility.MEDIUM_PRECISION);
		assertTrue(Math
				.abs(keplerian_orbit_actual.get_e() - keplerian_orbit_expected.get_e()) < TestUtility.MEDIUM_PRECISION);
		assertTrue(Math
				.abs(keplerian_orbit_actual.get_i() - keplerian_orbit_expected.get_i()) < TestUtility.MEDIUM_PRECISION);
		assertTrue(Math.abs(keplerian_orbit_actual.get_Omega()
				- keplerian_orbit_expected.get_Omega()) < TestUtility.MEDIUM_PRECISION);
		assertTrue(Math.abs(keplerian_orbit_actual.get_omega()
				- keplerian_orbit_expected.get_omega()) < TestUtility.MEDIUM_PRECISION);
		assertTrue(Math
				.abs(keplerian_orbit_actual.get_M() - keplerian_orbit_expected.get_M()) < TestUtility.MEDIUM_PRECISION);
		assertTrue(keplerian_orbit_actual.get_epoch().equals(keplerian_orbit_expected.get_epoch()));
	}

	@Test
	// Tests set_a method.
	public void test_set_a() {

		double a_expected = this.a_input;

		this.keplerian_orbit.set_a(this.a_input);

		double a_actual = this.keplerian_orbit.get_a();

		assertTrue(a_actual == a_expected);
	}

	@Test
	// Tests set_e method.
	public void test_set_e() {

		double e_expected = this.e_input;

		this.keplerian_orbit.set_e(this.e_input);

		double e_actual = this.keplerian_orbit.get_e();

		assertTrue(e_actual == e_expected);
	}

	@Test
	// Tests set_i method.
	public void test_set_i() {

		double i_expected = this.i_input;

		this.keplerian_orbit.set_i(this.i_input);

		double i_actual = this.keplerian_orbit.get_i();

		assertTrue(i_actual == i_expected);
	}

	@Test
	// Tests set_Omega method.
	public void test_set_Omega() {

		double Omega_expected = this.Omega_input;

		this.keplerian_orbit.set_Omega(this.Omega_input);

		double Omega_actual = this.keplerian_orbit.get_Omega();

		assertTrue(Omega_actual == Omega_expected);
	}

	@Test
	// Tests set_omega method.
	public void test_set_omega() {

		double omega_expected = this.omega_input;

		this.keplerian_orbit.set_omega(this.omega_input);

		double omega_actual = this.keplerian_orbit.get_omega();

		assertTrue(omega_actual == omega_expected);
	}

	@Test
	// Tests set_M method.
	public void test_set_M() {

		double M_expected = this.M_input;

		this.keplerian_orbit.set_M(this.M_input);

		double M_actual = this.keplerian_orbit.get_M();

		assertTrue(M_actual == M_expected);
	}

	@Test
	// Tests set_epoch method.
	public void test_set_epoch() {

		ModJulianDate epoch_expected = this.epoch_input;

		this.keplerian_orbit.set_epoch(this.epoch_input);

		ModJulianDate epoch_actual = this.keplerian_orbit.get_epoch();

		assertTrue(epoch_actual.equals(epoch_expected));
	}

	@Test
	// Tests set_method method.
	public void test_set_method() {

		String method_expected = this.method_input;

		this.keplerian_orbit.set_method(this.method_input);

		String method_actual = this.keplerian_orbit.get_method();

		assertTrue(method_actual.equals(method_expected));
	}
}
