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

import com.springbok.station.EarthStation;
import com.springbok.utility.JamaUtils;
import com.springbok.utility.TestUtility;

import Jama.Matrix;

public class CoordinatesTest {

	// Input position vector [er]
	private final double[][] r_input_row = { { 1, 1, 1 } };
	private final Matrix r_input = new Matrix(r_input_row);
	// Input rotation angle [rad]
	private final double phi_input = 45 * (Math.PI / 180);

	// Input station identifier
	private final String stationId_input = "one";
	// Input geodetic latitude [deg]
	private final double varphi_input = -22.239166666666666;
	// Input longitude [deg]
	private final double lambda_input = 114.0836111111111;

	// Input date number at which the position vectors occur
	private final ModJulianDate dNm_input = new ModJulianDate(51544.5);
	// Input geocentric equatorial inertial position vector [er]
	private final double[][] r_gei_input_col = { { -2 }, { 2 }, { -2 } };
	private final Matrix r_gei_input = new Matrix(r_gei_input_col);
	// Input geocentric equatorial rotating position vector [er]
	private final double[][] r_ger_input_col = { { -2.329878657530266 }, { -1.603641306896578 },
			{ -2.000000000000000 } };
	private final Matrix r_ger_input = new Matrix(r_ger_input_col); // (MG-2.89)
	// Input latitude, longitude, and altitude [rad, rad, er]
	private final double[][] r_lla_input_col = { { -0.615479708670387 }, { +3.744418905253123 },
			{ +2.464101615137754 } };
	private final Matrix r_lla_input = new Matrix(r_lla_input_col);
	// Inverse of MG-2.90 modified for arbitrary altitude, See also MG-5.88

	// Input East unit vector in geocentric equatorial rotating coordinates for
	// the input Earth station
	private final double[][] e_E_col = { { -0.833976634492313 }, { +0.551799758173990 }, { +0.0 } };
	private final Matrix e_E = new Matrix(e_E_col); // (MG-2.92)
	// Input North unit vector in geocentric equatorial rotating coordinates for
	// the input Earth station
	private final double[][] e_N_col = { { -0.135457558746091 }, { -0.204727235353353 }, { -0.969400850465442 } };
	private final Matrix e_N = new Matrix(e_N_col); // (MG-2.92)
	// Input zenith unit vector in geocentric equatorial rotating coordinates
	// for the input Earth station
	private final double[][] e_Z_col = { { -0.534915154860491 }, { -0.808457658745156 }, { +0.245483178887837 } };
	private final Matrix e_Z = new Matrix(e_Z_col); // (MG-2.92)

	// Input local tangent position vector [er]
	private final double[][] r_ltp_input_col = { { +1.058175476239208 }, { +2.581117033547451 },
			{ +1.051998870244891 } };
	private final Matrix r_ltp_input = new Matrix(r_ltp_input_col); // (MG-2.94)
	// Input range, azimuth, and elevation [er, rad, rad]
	private final double rng = 2.981375874052011;
	private final double azm = 0.389069865097019;
	private final double elv = 0.360622584861772; // (MG-2.95)

	// An Earth station
	private EarthStation earthStation;
	// Expected range, azimuth, and elevation [er, rad, rad]
	private Matrix r_rae_expected;

	@Before
	public void setUp() throws Exception {

		// Compute derived properties
		this.earthStation = new EarthStation(this.stationId_input, this.varphi_input, this.lambda_input);
		double[][] r_rae_expected_col = { { this.rng }, { this.azm }, { this.elv } };
		this.r_rae_expected = new Matrix(r_rae_expected_col);
	}

	@Test
	/* Tests R_x method. (MG-p.27) */
	public void test_R_x() {

		double[][] row = { { 1, 0, Math.sqrt(2) } };
		Matrix r_expected = new Matrix(row);

		Matrix r_actual = this.r_input.times(Coordinates.R_x(this.phi_input));

		Matrix delta_r = r_actual.minus(r_expected);

		assertTrue(Math.abs(delta_r.get(0, 0)) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(delta_r.get(0, 1)) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(delta_r.get(0, 2)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests R_y method. (MG-p.27) */
	public void test_R_y() {

		double[][] row = { { Math.sqrt(2), 1, 0 } };
		Matrix r_expected = new Matrix(row);

		Matrix r_actual = this.r_input.times(Coordinates.R_y(this.phi_input));

		Matrix delta_r = r_actual.minus(r_expected);

		assertTrue(Math.abs(delta_r.get(0, 0)) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(delta_r.get(0, 1)) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(delta_r.get(0, 2)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests R_z method. (MG-p.27) */
	public void test_R_z() {

		double[][] row = { { 0, Math.sqrt(2), 1 } };
		Matrix r_expected = new Matrix(row);

		Matrix r_actual = this.r_input.times(Coordinates.R_z(this.phi_input));

		Matrix delta_r = r_actual.minus(r_expected);

		assertTrue(Math.abs(delta_r.get(0, 0)) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(delta_r.get(0, 1)) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(delta_r.get(0, 2)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests E_e2t method. (MG-2.93) */
	public void test_E_e2t() {

		Matrix E_e2t_expected = new Matrix(3, 3);

		JamaUtils.setcol(E_e2t_expected, 0, this.e_E);
		JamaUtils.setcol(E_e2t_expected, 1, this.e_N);
		JamaUtils.setcol(E_e2t_expected, 2, this.e_Z);
		E_e2t_expected = E_e2t_expected.transpose();

		Matrix E_e2t_actual = Coordinates.E_e2t(this.earthStation);

		Matrix delta_E_e2t = E_e2t_actual.minus(E_e2t_expected);

		assertTrue(JamaUtils.getAbsMax(delta_E_e2t) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests E_t2e method. (MG-2.93) */
	public void test_E_t2e() {

		Matrix E_t2e_expected = new Matrix(3, 3);

		JamaUtils.setcol(E_t2e_expected, 0, this.e_E);
		JamaUtils.setcol(E_t2e_expected, 1, this.e_N);
		JamaUtils.setcol(E_t2e_expected, 2, this.e_Z);

		Matrix E_t2e_actual = Coordinates.E_t2e(this.earthStation);

		Matrix delta_E_t2e = E_t2e_expected.minus(E_t2e_actual);

		assertTrue(JamaUtils.getAbsMax(delta_E_t2e) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests gei2ger method. (MG-2.89) */
	public void test_gei2ger() {

		Matrix r_ger_expected = this.r_ger_input;

		Matrix r_ger_actual = Coordinates.gei2ger(this.r_gei_input, this.dNm_input);

		assertTrue(JamaUtils.getAbsMax(r_ger_actual.minus(r_ger_expected)) < TestUtility.HIGH_PRECISION);

		double[][] r_gei_input_col = { { 0.739662856554726 }, { 0.739662856554726 }, { 0 } };
		Matrix r_gei_input = new Matrix(r_gei_input_col);

		ModJulianDate dNm_input = new ModJulianDate(5.154450000000000e+04);

		double[][] v_gei_input_col = { { -0.858654494744699 }, { +0.858654494744699 }, { +0.021196048963813 } };
		Matrix v_gei_input = new Matrix(v_gei_input_col);
		v_gei_input = v_gei_input.times(1.0e-03);

		double[][] r_ger_expected_col = { { -0.593076954974138 }, { +0.861662351627364 }, { +0 } };
		r_ger_expected = new Matrix(r_ger_expected_col);

		double[][] v_ger_expected_col_a = { { -0.937446973798365 }, { -0.645239049402607 }, { +0.021196048963813 } };
		Matrix v_ger_expected = new Matrix(v_ger_expected_col_a);
		v_ger_expected = v_ger_expected.times(1.0e-03);

		r_ger_actual = Coordinates.gei2ger(r_gei_input, dNm_input);
		Matrix v_ger_actual = Coordinates.gei2ger(r_gei_input, dNm_input, v_gei_input);

		assertTrue(JamaUtils.getAbsMax(r_ger_actual.minus(r_ger_expected)) < TestUtility.HIGH_PRECISION);
		assertTrue(JamaUtils.getAbsMax(v_ger_actual.minus(v_ger_expected)) < TestUtility.HIGH_PRECISION);

		ModJulianDate dNm = new ModJulianDate(5.698482582483208e+04);

		double a = EarthConstants.a_gso;
		double e = 0;
		double i = 0;
		double Omega = 0;
		double omega = 0;
		double M = 0;
		ModJulianDate epoch = dNm;
		String method = "halley";

		KeplerianOrbit ko = new KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method);

		Matrix r_gei = ko.r_gei(ko.get_epoch());
		Matrix v_gei = ko.v_gei(ko.get_epoch());
		r_ger_actual = Coordinates.gei2ger(r_gei, ko.get_epoch());
		v_ger_actual = Coordinates.gei2ger(r_gei, ko.get_epoch(), v_gei);

		double[][] v_ger_expected_col_b = { { 0 }, { 0 }, { 0 } };
		v_ger_expected = new Matrix(v_ger_expected_col_b);

		Matrix delta_v_ger = v_ger_actual.minus(v_ger_expected);

		assertTrue(Math.sqrt(delta_v_ger.transpose().times(delta_v_ger).get(0, 0)) < TestUtility.HIGH_PRECISION);

		i = 90 * Math.PI / 180;

		ko = new KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method);

		r_gei = ko.r_gei(ko.get_epoch());
		v_gei = ko.v_gei(ko.get_epoch());
		r_ger_actual = Coordinates.gei2ger(r_gei, ko.get_epoch());
		v_ger_actual = Coordinates.gei2ger(r_gei, ko.get_epoch(), v_gei);

		double[][] v_ger_expected_col_c = { { 0 }, { -v_gei.get(2, 0) }, { +v_gei.get(2, 0) } };
		v_ger_expected = new Matrix(v_ger_expected_col_c);

		delta_v_ger = v_ger_actual.minus(v_ger_expected);

		assertTrue(Math.sqrt(delta_v_ger.transpose().times(delta_v_ger).get(0, 0)) < TestUtility.MEDIUM_PRECISION);
	}

	@Test
	/* Tests ger2gei method. (MG-2.89) */
	public void test_ger2gei() {

		Matrix r_gei_expected = this.r_gei_input;

		Matrix r_gei_actual = Coordinates.ger2gei(this.r_ger_input, this.dNm_input);

		assertTrue(JamaUtils.getAbsMax(r_gei_actual.minus(r_gei_expected)) < TestUtility.HIGH_PRECISION);

		double[][] r_ger_input_col = { { -0.593076954974138 }, { +0.861662351627364 }, { +0 } };
		Matrix r_ger_input = new Matrix(r_ger_input_col);

		ModJulianDate dNm_input = new ModJulianDate(5.154450000000000e+04);

		double[][] v_ger_input_col = { { -0.937446973798365 }, { -0.645239049402607 }, { +0.021196048963813 } };
		Matrix v_ger_input = new Matrix(v_ger_input_col);
		v_ger_input = v_ger_input.times(1.0e-03);

		double[][] r_gei_expected_col = { { +0.739662856554726 }, { +0.739662856554726 }, { +0 } };
		r_gei_expected = new Matrix(r_gei_expected_col);

		double[][] v_gei_expected_col = { { -0.858654494744699 }, { +0.858654494744699 }, { +0.021196048963813 } };
		Matrix v_gei_expected = new Matrix(v_gei_expected_col);
		v_gei_expected = v_gei_expected.times(1.0e-03);

		r_gei_actual = Coordinates.ger2gei(r_ger_input, dNm_input);
		Matrix v_gei_actual = Coordinates.ger2gei(r_ger_input, dNm_input, v_ger_input);

		assertTrue(JamaUtils.getAbsMax(r_gei_actual.minus(r_gei_expected)) < TestUtility.HIGH_PRECISION);
		assertTrue(JamaUtils.getAbsMax(v_gei_actual.minus(v_gei_expected)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/*
	 * Tests gei2lla method. (Inverse of MG-2.90 modified for arbitrary
	 * altitude, See also MG-5.88)
	 */
	public void test_gei2lla() {

		Matrix r_lla_expected = this.r_lla_input;

		Matrix r_lla_actual = Coordinates.gei2lla(this.r_gei_input, this.dNm_input);

		assertTrue(JamaUtils.getAbsMax(r_lla_actual.minus(r_lla_expected)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests lla2gei method. (MG-2.90 modified for arbitrary altitude) */
	public void test_lla2gei() {

		Matrix r_gei_expected = this.r_gei_input;

		Matrix r_gei_actual = Coordinates.lla2gei(this.r_lla_input, this.dNm_input);

		assertTrue(JamaUtils.getAbsMax(r_gei_actual.minus(r_gei_expected)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests gei2ltp method. (MG-2.94) */
	public void test_gei2ltp() {

		Matrix r_ltp_expected = this.r_ltp_input;

		Matrix r_ltp_actual = Coordinates.gei2ltp(this.r_gei_input, this.earthStation, this.dNm_input);

		assertTrue(JamaUtils.getAbsMax(r_ltp_actual.minus(r_ltp_expected)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests ltp2rae method. (MG-2.95) */
	public void test_ltp2rae() {

		Matrix r_rae_actual = Coordinates.ltp2rae(this.r_ltp_input);

		assertTrue(JamaUtils.getAbsMax(r_rae_actual.minus(this.r_rae_expected)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests rae2ltp method. (Inverse of MG-2.95) */
	public void test_rae2ltp() {

		Matrix r_ltp_expected = this.r_ltp_input;

		Matrix r_ltp_actual = Coordinates.rae2ltp(this.r_rae_expected);

		assertTrue(JamaUtils.getAbsMax(r_ltp_actual.minus(r_ltp_expected)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests ltp2gei method. (Inverse of MG-2.94) */
	public void test_ltp2gei() {

		Matrix r_gei_expected = this.r_gei_input;

		Matrix r_ltp_actual = Coordinates.rae2ltp(this.r_rae_expected);

		Matrix r_gei_actual = Coordinates.ltp2gei(r_ltp_actual, this.earthStation, this.dNm_input);

		assertTrue(JamaUtils.getAbsMax(r_gei_actual.minus(r_gei_expected)) < TestUtility.HIGH_PRECISION);
	}

	@Test
	/* Tests check_wrap method. */
	public void test_check_wrap() {

		double phi_expected = 4;

		double phi = phi_expected + 3 * 2 * Math.PI;

		double phi_actual = Coordinates.checkWrap(phi);

		assertTrue(Math.abs(phi_actual - phi_expected) < TestUtility.HIGH_PRECISION);

		phi = phi_expected - 3 * 2 * Math.PI;

		phi_actual = Coordinates.checkWrap(phi);

		assertTrue(Math.abs(phi_actual - phi_expected) < TestUtility.HIGH_PRECISION);
	}
}
