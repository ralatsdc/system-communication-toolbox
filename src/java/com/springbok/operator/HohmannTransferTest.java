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

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.KeplerianOrbit;
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.TestUtility;

// Tests methods of HohmannTransfer class.
public class HohmannTransferTest {

	// Input initial orbit semi-major axis [er]
	private final double a_1 = 1 + 300 / EarthConstants.R_oplus;
	// Input initial orbit eccentricity [-]
	private final double e_1 = 0.001;
	// Input initial orbit inclination [rad]
	private final double i_1 = 1 * Math.PI / 180;
	// Input initial orbit right ascension of the ascending node [rad]
	private final double Omega_1 = Math.PI / 4;
	// Input initial orbit argument of perigee [rad]
	private final double omega_1 = 0.0;
	// Input initial orbit mean anomaly [rad]
	private final double M_1 = 0.0;
	// Input initial orbit epoch date number
	// epoch_1 = datenum('01/01/2000 12:00:00');
	private final ModJulianDate epoch_1 = new ModJulianDate(5.154450000000000e+04);
	// Input initial orbit method to solve Kepler's equation: "newton" or
	// "halley"
	private final String method_1 = "halley";

	// Input final orbit semi-major axis [er]
	private final double a_2 = EarthConstants.a_gso;
	// Input final orbit eccentricity [-]
	private final double e_2 = 0.001;
	// Input final orbit inclination [rad]
	private final double i_2 = 1 * Math.PI / 180;
	// Input final orbit right ascension of the ascending node [rad]
	private final double Omega_2 = Math.PI / 4;
	// Input final orbit argument of perigee [rad]
	private final double omega_2 = 0.0;
	// Input final orbit mean anomaly [rad]
	private final double M_2 = 0.0;
	// Input final orbit epoch date number
	// epoch_2 = datenum('01/01/2000 12:00:00');
	private final ModJulianDate epoch_2 = new ModJulianDate(5.154450000000000e+04);
	// Input final orbit method to solve Kepler's equation: "newton" or "halley"
	private final String method_2 = "halley";

	// Input initial Keplerian orbit
	private KeplerianOrbit kep_orb_1_input;
	// Input final Keplerian orbit
	private KeplerianOrbit kep_orb_2_input;
	// A HohmannTransfer
	private HohmannTransfer hohmann_transfer;

	@Before
	public void setUp() throws Exception {

		// Assign properties
		this.kep_orb_1_input = new KeplerianOrbit(this.a_1, this.e_1, this.i_1, this.Omega_1, this.omega_1, this.M_1,
				this.epoch_1, this.method_1);
		this.kep_orb_2_input = new KeplerianOrbit(this.a_2, this.e_2, this.i_2, this.Omega_2, this.omega_2, this.M_2,
				this.epoch_2, this.method_2);

		// Compute derived properties
		this.hohmann_transfer = new HohmannTransfer(this.kep_orb_1_input, this.kep_orb_2_input);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	// Tests HohmannTransfer method. Note that the HohmannTransfer method
	// invokes the computeTransferOrbit method, which is therefore tested
	// implicitly.
	public void test_HohmannTransfer() {

		// Expected initial Keplerian orbit
		KeplerianOrbit kep_orb_1_expected = this.kep_orb_1_input;

		// Input initial orbit perigee
		double r_1 = this.kep_orb_1_input.get_a() * (1.0 - this.kep_orb_1_input.get_e());
		// Input final orbit apogee
		double r_2 = this.kep_orb_2_input.get_a() * (1.0 + this.kep_orb_2_input.get_e());

		// Expected transfer orbit semi-major axis [er]
		double a_t = (r_2 + r_1) / 2.0;
		// Expected transfer orbit eccentricity [-]
		double e_t = (r_2 - r_1) / (r_2 + r_1);
		// Expected transfer orbit inclination [rad]
		double i_t = 1 * Math.PI / 180.0;
		// Expected transfer orbit right ascension of the ascending node [rad]
		double Omega_t = Math.PI / 4.0;
		// Expected transfer orbit argument of perigee [rad]
		double omega_t = 0.0;
		// Expected transfer orbit mean anomaly [rad]
		double M_t = 0.0; // perigee
		// Expected transfer orbit epoch date number
		ModJulianDate epoch_t = this.kep_orb_1_input.get_epoch();
		// Expected transfer orbit method to solve Kepler's equation: "newton"
		// or "halley"
		String method_t = "halley";

		// Expected transfer Keplerian orbit
		KeplerianOrbit kep_orb_t_expected = new KeplerianOrbit(a_t, e_t, i_t, Omega_t, omega_t, M_t, epoch_t, method_t);

		// Expected final Keplerian orbit
		KeplerianOrbit kep_orb_2_expected = new KeplerianOrbit(this.a_2, this.e_2, this.i_2, this.Omega_2, this.omega_2,
				this.M_2, this.epoch_2, this.method_2);

		// Expected final orbit epoch date number
		ModJulianDate epoch_2 = new ModJulianDate(kep_orb_t_expected.get_epoch().getAsDouble()
				+ (1.0 / 2.0) * (kep_orb_t_expected.get_T() / (60.0 * 60.0 * 24.0)));
		// Expected final orbit mean anomaly [rad]
		double M_2 = Math.PI; // apogee
		kep_orb_2_expected.set_epoch(epoch_2);
		kep_orb_2_expected.set_M(M_2);

		// Expected velocities of object in the initial and transfer orbit at
		// perigee of the transfer orbit, and in the transfer and final orbit at
		// apogee of the transfer orbit
		double GM_oplus = EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus, 3);
		// [er^3/s^2] = [km^3/s^2] / [km/er]^3
		double v_1_expected = Math.sqrt(GM_oplus / r_1);
		double v_t_p_expected = Math.sqrt(GM_oplus * (2.0 / r_1 - 1.0 / a_t));
		double v_t_a_expected = Math.sqrt(GM_oplus * (2.0 / r_2 - 1.0 / a_t));
		double v_2_expected = Math.sqrt(GM_oplus / r_2);

		// Expected change in velocity required to enter and exit the transfer
		// orbit
		double delta_v_p_expected = v_t_p_expected - v_1_expected;
		double delta_v_a_expected = v_2_expected - v_t_a_expected;

		assertTrue(this.isEqualKepOrb(this.hohmann_transfer.kep_orb_1, kep_orb_1_expected, TestUtility.HIGH_PRECISION));
		assertTrue(this.isEqualKepOrb(this.hohmann_transfer.kep_orb_2, kep_orb_2_expected, TestUtility.HIGH_PRECISION));
		assertTrue(this.isEqualKepOrb(this.hohmann_transfer.kep_orb_t, kep_orb_t_expected, TestUtility.HIGH_PRECISION));

		assertTrue(Math.abs(this.hohmann_transfer.v_1 - v_1_expected) < SimulationConstants.precision_E);
		assertTrue(Math.abs(this.hohmann_transfer.v_t_p - v_t_p_expected) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(this.hohmann_transfer.v_t_a - v_t_a_expected) < TestUtility.HIGH_PRECISION);
		assertTrue(Math.abs(this.hohmann_transfer.v_2 - v_2_expected) < SimulationConstants.precision_E);

		assertTrue(Math.abs(this.hohmann_transfer.delta_v_p - delta_v_p_expected) < SimulationConstants.precision_E);
		assertTrue(Math.abs(this.hohmann_transfer.delta_v_a - delta_v_a_expected) < SimulationConstants.precision_E);
	}

	// Tests equality of two KeplerianOrbits with the specified precision.
	private boolean isEqualKepOrb(KeplerianOrbit kep_orb_1, KeplerianOrbit kep_orb_2, double precision) {

		boolean t = true;
		t = t && Math.abs(kep_orb_2.get_a() - kep_orb_1.get_a()) < precision;
		t = t && Math.abs(kep_orb_2.get_e() - kep_orb_1.get_e()) < precision;
		t = t && Math.abs(kep_orb_2.get_i() - kep_orb_1.get_i()) < precision;
		t = t && Math.abs(kep_orb_2.get_Omega() - kep_orb_1.get_Omega()) < precision;
		t = t && Math.abs(kep_orb_2.get_omega() - kep_orb_1.get_omega()) < precision;
		t = t && Math.abs(kep_orb_2.get_M() - kep_orb_1.get_M()) < precision;
		t = t && kep_orb_2.get_epoch().equals(kep_orb_1.get_epoch());
		// 51544.71998465962678890 == 51544.50000000000000000
		t = t && kep_orb_2.get_method().equals(kep_orb_1.get_method());

		return t;
	}
}
