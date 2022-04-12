/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.center;

import Jama.Matrix;
import com.springbok.sgp4v.Sgp4Orbit;
import com.springbok.twobody.KeplerianOrbit;
import com.springbok.twobody.ModJulianDate;
import org.junit.BeforeClass;
import org.junit.Test;

import java.time.Instant;
import java.util.Date;

/**
 * Tests methods of OrbitDetermination class.
 */
public class OrbitDeterminationTest {

    // Semi-major axis [er]
    private static final double a = 6.618108053001019;

    // Eccentricity [-]
    private static final double e = 0.1;

    // Inclination [rad]
    private static final double i = 1 * Math.PI / 180;

    // Right ascension of the ascending node [rad]
    private static final double Omega = Math.PI / 4;

    // Argument of perigee [rad]
    private static final double omega = Math.PI / 4;

    // Mean anomaly [rad]
    private static final double M = Math.PI / 4;

    //Epoch date number
    private static final ModJulianDate epoch = new ModJulianDate(
            Date.from(Instant.parse("2000-01-01T12:00:00.00Z")).getTime()
    );

    // Method to solve Kepler's equation: 'newton' or 'halley'
    // 'halley' expected from podGuass()
    private static final String method = "halley";

    // First date number
    // epoch expected from podGuass()
    private static final ModJulianDate dNm_a = new ModJulianDate(
            Date.from(Instant.parse("2000-01-01T12:00:00.00Z")).getTime()
    );
    // Second date number
    private static final ModJulianDate dNm_b = new ModJulianDate(
            Date.from(Instant.parse("2000-01-01T14:00:00.00Z")).getTime()
    );

    // A Keplerian orbit
    private static KeplerianOrbit kep_orb;

    // First inertial geocentric position vector
    private static Matrix kep_r_a;

    // Second inertial geocentric position vector
    private static Matrix kep_r_b;

    // The preliminary Keplerian orbit
    private static KeplerianOrbit kep_orb_p;
/*
    // Date numbers of measured position
    kep_obs_dNm
    % Measured geocentric equatorial inertial position
    kep_obs_gei
*/
    // A corrected orbit
    private static KeplerianOrbit kep_orb_c;

    // A Sgp4 orbit
    private static Sgp4Orbit sgp4_orb;

    // First inertial geocentric position vector
    private static Matrix sgp4_r_a;
    // Second inertial geocentric position vector
    private static Matrix sgp4_r_b;

    // The preliminary Sgp4 orbit
    private static Sgp4Orbit sgp4_orb_p;
/*
    % Date numbers of measured position
    sgp4_obs_dNm
    % Measured geocentric equatorial inertial position
    sgp4_obs_gei
*/
    // A corrected orbit
    private static Sgp4Orbit sgp4_orb_c;

    // The numerical technique used: 'Levenberg-Marquardt' or 'Guass-Newton'
    private static String option;
    // A status message
    private static String status;

    @BeforeClass
    public static void setUp() {
        kep_orb = new KeplerianOrbit (a, e, i, Omega, omega, M, epoch, method);
        kep_r_a = kep_orb.r_gei(dNm_a);
        kep_r_b = kep_orb.r_gei(dNm_b);
        kep_orb_p = kep_orb;

        //TODO for dNm = this.dNm_a : (2.0 / 24.0) / (4 * 6) : this.dNm_b
        //        this.kep_obs_dNm = [this.kep_obs_dNm, dNm];
        //        this.kep_obs_gei = [this.kep_obs_gei, this.kep_orb.r_gei(dNm)];
        //      end

        kep_orb_c = kep_orb;
        // TODO Sgp4Orbit do not have needed constructor
        // sgp4_orb = new Sgp4Orbit(a, e, i, Omega, omega, M, epoch, method);
    }

    @Test
    public void test1() {
        System.out.println("test1");
    }

    @Test
    public void test2() {
        System.out.println("test2");
    }
}
