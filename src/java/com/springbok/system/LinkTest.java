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
package com.springbok.system;

import Jama.Matrix;
import com.celestrak.sgp4v.ObjectDecayed;
import com.springbok.station.Beam;
import com.springbok.station.EarthStation;
import com.springbok.station.SpaceStation;
import com.springbok.twobody.EarthConstants;
import com.springbok.utility.TestUtility;
import com.springbok.utility.TimeUtility;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests methods of Link class.
 */
public class LinkTest {

    // Current date number
    private double dNm = TimeUtility.date2mjd(2000, 1, 1, 12, 0, 0.0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot;

    // Reference bandwidth [kHz]
    private double ref_bw = 40;

    // A transmit station
    private SpaceStation transmitStation;

    // A transmit station beam
    private Beam transmitStationBeam;

    // A receive station
    private EarthStation receiveStation;

    // Propagation loss models to apply
    private Object[] losses;

    // An interfering system
    private System interferingSystem;

    // A link
    private Link link;

    @Before
    public void setUp() throws ObjectDecayed {
        // TODO: Complete
    }

    /**
     * Tests Link method.
     */
    @Test
    public void test_Link() {
        // TODO: Complete
    }

    public void test_computePerformance() {
        // TODO: Complete
    }

    @Test
    public void test_computeDistance() {
        double[][] r_one = new double[3][1];
        double[][] r_two = new double[3][1];
        r_one[0][0] = 1;
        r_one[1][0] = 1;
        r_one[2][0] = 1;

        r_two[0][0] = 2;
        r_two[1][0] = 2;
        r_two[2][0] = 2;

        Link link = new Link();

        double distance_expected = Math.sqrt(3) * EarthConstants.R_oplus;

        double distance_actual = link.computeDistance(new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(distance_actual - distance_expected) < TestUtility.HIGH_PRECISION);
    }

    @Test
    public void test_computeTheta() {
        double[][] r_ref = new double[3][1];
        double[][] r_one = new double[3][1];
        double[][] r_two = new double[3][1];
        r_ref[0][0] = 1;
        r_ref[1][0] = 1;
        r_ref[2][0] = 1;

        r_one[0][0] = 2;
        r_one[1][0] = 2;
        r_one[2][0] = 2;

        r_two[0][0] = 3;
        r_two[1][0] = 3;
        r_two[2][0] = 3;

        double theta_expected = 0;

        Link link = new Link();
        double theta_actual = link.computeTheta(new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);

        r_one[0][0] = 1;
        r_one[1][0] = 2;
        r_one[2][0] = 1;

        r_two[0][0] = 1;
        r_two[1][0] = 1;
        r_two[2][0] = 3;

        theta_expected = 90;
        theta_actual = link.computeTheta(new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);

        r_one[0][0] = 1;
        r_one[1][0] = 2;
        r_one[2][0] = 1;

        r_two[0][0] = 1;
        r_two[1][0] = -2;
        r_two[2][0] = 1;

        theta_expected = 180;

        theta_actual = link.computeTheta(new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);
    }

    @Test
    public void test_computeAngles() {
        double[][] r_ref = new double[3][1];
        double[][] r_one = new double[3][1];
        double[][] r_two = new double[3][1];
        r_ref[0][0] = 0;
        r_ref[1][0] = 0;
        r_ref[2][0] = 1;

        r_one[0][0] = 0;
        r_one[1][0] = 0;
        r_one[2][0] = 2;

        r_two[0][0] = 0;
        r_two[1][0] = 0;
        r_two[2][0] = 2;

        double phi_expected = 0;
        double azm_expected = 0;
        double elv_expected = 0;

        Link link = new Link();

        Link.Angle angle = link.computeAngles(new EarthStation(), new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(angle.getPhi() - phi_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getAzimuth() - azm_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getElevation() - elv_expected) < TestUtility.MEDIUM_PRECISION);

        r_one[0][0] = 1;
        r_one[1][0] = 0;
        r_one[2][0] = 2;

        r_two[0][0] = Math.sqrt(3);
        r_two[1][0] = 0;
        r_two[2][0] = 2;

        phi_expected = 45;
        azm_expected = 0;
        elv_expected = 15;

        angle = link.computeAngles(new EarthStation(), new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(angle.getPhi() - phi_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getAzimuth() - azm_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getElevation() - elv_expected) < TestUtility.MEDIUM_PRECISION);

        r_two[0][0] = 0;
        r_two[1][0] = Math.sqrt(3);
        r_two[2][0] = 2;

        phi_expected = 45;
        azm_expected = 90;
        elv_expected = 69.295188945364572;

        angle = link.computeAngles(new EarthStation(), new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(angle.getPhi() - phi_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getAzimuth() - azm_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getElevation() - elv_expected) < TestUtility.MEDIUM_PRECISION);

        r_two[0][0] = 0;
        r_two[1][0] = -Math.sqrt(3);
        r_two[2][0] = 2;

        phi_expected = 45;
        azm_expected = -90;
        elv_expected = 69.295188945364572;

        angle = link.computeAngles(new EarthStation(), new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(angle.getPhi() - phi_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getAzimuth() - azm_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getElevation() - elv_expected) < TestUtility.MEDIUM_PRECISION);

        r_ref[0][0] = 0;
        r_ref[1][0] = 0;
        r_ref[2][0] = 3;

        r_one[0][0] = 0;
        r_one[1][0] = 0;
        r_one[2][0] = 2;

        r_two[0][0] = 0;
        r_two[1][0] = 0;
        r_two[2][0] = 2;

        phi_expected = 0;
        azm_expected = 0;
        elv_expected = 0;

        angle = link.computeAngles(new SpaceStation(), new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(angle.getPhi() - phi_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getAzimuth() - azm_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getElevation() - elv_expected) < TestUtility.MEDIUM_PRECISION);

        r_one[0][0] = 1;
        r_one[1][0] = 0;
        r_one[2][0] = 2;

        r_two[0][0] = Math.sqrt(3);
        r_two[1][0] = 0;
        r_two[2][0] = 2;

        phi_expected = 45;
        azm_expected = 0;
        elv_expected = 15;

        angle = link.computeAngles(new SpaceStation(), new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(angle.getPhi() - phi_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getAzimuth() - azm_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getElevation() - elv_expected) < TestUtility.MEDIUM_PRECISION);

        r_two[0][0] = 0;
        r_two[1][0] = Math.sqrt(3);
        r_two[2][0] = 2;

        phi_expected = 45;
        azm_expected = -90;
        elv_expected = 69.295188945364572;

        angle = link.computeAngles(new SpaceStation(), new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(angle.getPhi() - phi_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getAzimuth() - azm_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getElevation() - elv_expected) < TestUtility.MEDIUM_PRECISION);

        r_two[0][0] = 0;
        r_two[1][0] = -Math.sqrt(3);
        r_two[2][0] = 2;

        phi_expected = 45;
        azm_expected = 90;
        elv_expected = 69.295188945364572;

        angle = link.computeAngles(new SpaceStation(), new Matrix(r_ref), new Matrix(r_one), new Matrix(r_two));

        Assert.assertTrue(Math.abs(angle.getPhi() - phi_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getAzimuth() - azm_expected) < TestUtility.HIGH_PRECISION);
        Assert.assertTrue(Math.abs(angle.getElevation() - elv_expected) < TestUtility.MEDIUM_PRECISION);
    }

    public void test_findIdxVisEStoSS() {
        // TODO: Complete
    }
    
    public void test_findIdxVisSStoSS() {
        // TODO: Complete
    }

    public void test_isEmpty() {
        // TODO: Complete
    }
}
