package com.springbok.sgp4v;

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import Jama.Matrix;

import com.celestrak.sgp4v.ObjectDecayed;
import com.celestrak.sgp4v.SatElsetException;
import com.celestrak.sgp4v.ValueOutOfRangeException;
import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.KeplerianOrbit;
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.TestUtility;

public class Sgp4OrbitTest {

	// Line one of a two line element set
	public String lineOne_input = "1 00001U 00001A   00001.50000000  .00000000  00000-0  00000+0 0    00";
	// Line two of a two line element set
	public String lineTwo_input = "2 00001 001.0000 045.0000 0000000 045.0000 045.0000 01.00273791  1002";

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

	// An Sgp4 orbit
	private Sgp4Orbit sgp4_orbit;

	// A Keplerian orbit
	private KeplerianOrbit kep_orbit;

	@Before
	public void setUp() throws Exception {

		// Compute derived properties
		this.sgp4_orbit = new Sgp4Orbit(this.lineOne_input, this.lineTwo_input);

		this.kep_orbit = new KeplerianOrbit(this.a_input, this.e_input, this.i_input, this.Omega_input,
				this.omega_input, this.M_input, this.epoch_input, this.method_input);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	// Tests Sgp4Orbit method.
	public void test_Sgp4Orbit() {

		String lineOne_expected = this.lineOne_input;
		String lineTwo_expected = this.lineTwo_input;
		ModJulianDate epoch_expected = this.epoch_input;

		assertTrue(this.sgp4_orbit.get_lineOne().equals(lineOne_expected));
		assertTrue(this.sgp4_orbit.get_lineTwo().equals(lineTwo_expected));
		assertTrue(this.sgp4_orbit.get_epoch().equals(epoch_expected));
	}

	@Test
	// Tests meanMotion method.
	public void test_meanMotion() {

		double n_expected = Math.sqrt(EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus * this.a_input, 3));

		double n_actual = this.sgp4_orbit.meanMotion();

		// 7.292115853967575E-5
		// 7.292115860027739E-5

		assertTrue(Math.abs(n_actual - n_expected) < TestUtility.VERY_LOW_PRECISION);
	}

	@Test
	// Tests orbitalPeriod method.
	public void test_orbitalPeriod() {

		double T_expected = 2.0 * Math.PI
				* Math.sqrt(Math.pow(this.a_input * EarthConstants.R_oplus, 3) / EarthConstants.GM_oplus);

		double T_actual = this.sgp4_orbit.orbitalPeriod();

		assertTrue(Math.abs(T_actual - T_expected) < TestUtility.VERY_LOW_PRECISION);
	}

	@Test
	// Tests r_gei method.
	public void test_r_gei() throws ObjectDecayed {

		// TODO: Need an independent value, otherwise the following test is for
		// reproducibility only
		double[][] r_gei_expected_col = { { -4.674402155068577 }, { 4.672968446400264 }, { 0.11736272703604139 } };
		Matrix r_gei_expected = new Matrix(r_gei_expected_col);

		Matrix r_gei_actual = this.sgp4_orbit.r_gei(this.epoch_input);

		Matrix delta_r_gei = r_gei_actual.minus(r_gei_expected);

		assertTrue(Math.sqrt(delta_r_gei.transpose().times(delta_r_gei).get(0, 0)) < TestUtility.HIGH_PRECISION);

		r_gei_expected = this.kep_orbit.r_gei(this.epoch_input);

		try {
			r_gei_actual = this.sgp4_orbit.r_gei(this.epoch_input);
		} catch (ObjectDecayed e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		delta_r_gei = r_gei_actual.minus(r_gei_expected);

		// TODO: Need to confirm this difference is reasonable
		assertTrue(Math.sqrt(delta_r_gei.transpose().times(delta_r_gei).get(0, 0)) < 20.0 / EarthConstants.R_oplus);
	}

	@Test
	// Tests v_gei method.
	public void test_v_gei() throws ObjectDecayed {

		// TODO: Need an independent value, otherwise the following test is for
		// reproducibility only
		double[][] v_gei_expected_col = { { -0.34082847550401105 }, { -0.3409300479868421 },
				{ -0.00009913498797831216 } };

		Matrix v_gei_expected = new Matrix(v_gei_expected_col);
		v_gei_expected = v_gei_expected.times(1.0e-03);

		Matrix rv_gei_actual = this.sgp4_orbit.rv_gei(this.epoch_input);
		Matrix v_gei_actual = rv_gei_actual.getMatrix(3, 5, 0, 0);

		Matrix delta_v_gei = v_gei_actual.minus(v_gei_expected);

		assertTrue(Math.sqrt(delta_v_gei.transpose().times(delta_v_gei).get(0, 0)) < TestUtility.HIGH_PRECISION);

		v_gei_expected = this.kep_orbit.v_gei(this.epoch_input);

		rv_gei_actual = this.sgp4_orbit.rv_gei(this.epoch_input);
		v_gei_actual = rv_gei_actual.getMatrix(3, 5, 0, 0);

		delta_v_gei = v_gei_actual.minus(v_gei_expected);

		// TODO: Need to confirm this difference is reasonable
		assertTrue(Math.sqrt(delta_v_gei.transpose().times(delta_v_gei).get(0, 0)) < 0.001 / EarthConstants.R_oplus);
	}

	@Test
	// Tests set_a method.
	public void test_set_a() throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {

		double a_expected = this.a_input;

		this.sgp4_orbit.set_a(this.a_input);

		double a_actual = this.sgp4_orbit.get_a();

		assertTrue(Math.abs(a_actual - a_expected) < TestUtility.HIGH_PRECISION);
	}

	@Test
	// Tests set_e method.
	public void test_set_e() throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {

		double e_expected = this.e_input;

		this.sgp4_orbit.set_e(this.e_input);

		double e_actual = this.sgp4_orbit.get_e();

		assertTrue(e_actual == e_expected);
	}

	@Test
	// Tests set_i method.
	public void test_set_i() throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {

		double i_expected = this.i_input;

		this.sgp4_orbit.set_i(this.i_input);

		double i_actual = this.sgp4_orbit.get_i();

		assertTrue(i_actual == i_expected);
	}

	@Test
	// Tests set_Omega method.
	public void test_set_Omega() throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {

		double Omega_expected = this.Omega_input;

		this.sgp4_orbit.set_Omega(this.Omega_input);

		double Omega_actual = this.sgp4_orbit.get_Omega();

		assertTrue(Omega_actual == Omega_expected);
	}

	@Test
	// Tests set_omega method.
	public void test_set_omega() throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {

		double omega_expected = this.omega_input;

		this.sgp4_orbit.set_omega(this.omega_input);

		double omega_actual = this.sgp4_orbit.get_omega();

		assertTrue(omega_actual == omega_expected);
	}

	@Test
	// Tests set_M method.
	public void test_set_M() throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {

		double M_expected = this.M_input;

		this.sgp4_orbit.set_M(this.M_input);

		double M_actual = this.sgp4_orbit.get_M();

		assertTrue(M_actual == M_expected);
	}
}
