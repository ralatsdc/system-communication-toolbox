/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
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
  /*      // = Wanted system
        System wantedSystem = Gso_gso.getWntGsoSystem();
        wantedSystem.assignBeams(0, 0, wantedSystem.getdNm(), new HashMap());

        EarthStation earthStationA = wantedSystem.getNetworks()[0].getEarthStation();
        SpaceStation spaceStationA = wantedSystem.getNetworks()[0].getSpaceStation();
        Beam spaceStationBeam = wantedSystem.getNetworks()[0].getSpaceStationBeam();

        earthStationA.set_doMultiplexing(true);
        spaceStationBeam.set_multiplicity(2);

        EarthStation earthStationB = new EarthStation(
                earthStationA.getStationId(),
                earthStationA.getTransmitAntenna(),
                earthStationA.getReceiveAntenna(),
                earthStationA.getEmission(),
                earthStationA.getBeam(),
                earthStationA.get_varphi(),
                earthStationA.get_lambda(),
                earthStationA.doMultiplexing());


        EarthStation[] wsesp = Arrays.copyOf(wantedSystem.getEarthStations(), wantedSystem.getEarthStations().length + 1);
        wsesp[wsesp.length - 1] = earthStationB;
        wantedSystem.set_earthStations(wsesp);

        wantedSystem.reset();

        wantedSystem.assignBeams(0, 0, wantedSystem.getdNm(), new HashMap());
    java.lang.System.out.println(333);
        // = Interfering system

        interferingSystem = Gso_gso.getIntGsoSystem();

        interferingSystem.assignBeams(0, 0, interferingSystem.getdNm(), new HashMap());

        earthStationA = interferingSystem.getNetworks()[0].getEarthStation();
        spaceStationA = interferingSystem.getNetworks()[0].getSpaceStation();
        spaceStationBeam = interferingSystem.getNetworks()[0].getSpaceStationBeam();

        earthStationA.set_doMultiplexing(true);
        spaceStationBeam.set_multiplicity(2);

        earthStationB = new EarthStation(
                earthStationA.getStationId(),
                earthStationA.getTransmitAntenna(),
                earthStationA.getReceiveAntenna(),
                earthStationA.getEmission(),
                earthStationA.getBeam(),
                earthStationA.get_varphi(),
                earthStationA.get_lambda(),
                earthStationA.doMultiplexing());
    java.lang.System.out.println(444);
        wsesp = Arrays.copyOf(interferingSystem.getEarthStations(), interferingSystem.getEarthStations().length + 1);
        wsesp[wsesp.length - 1] = earthStationB;
        interferingSystem.set_earthStations(wsesp);

        interferingSystem.reset();

        interferingSystem.assignBeams(0, 0, interferingSystem.getdNm(), new HashMap());

        // Assign inputs

        transmitStation = wantedSystem.getSpaceStations()[0];
        transmitStationBeam = wantedSystem.getSpaceStations()[0].getBeams()[0];
        receiveStation = wantedSystem.getEarthStations()[0];
        losses = new Object[0];

        // Compute derived properties
        this.link = new Link(this.transmitStation,
                this.transmitStationBeam,
                this.receiveStation,
                this.losses,
                new HashMap()
        );*/
    }

    /**
     * Tests Link method.
     */
    @Test
    public void test_Link() {
        Assert.assertEquals(this.link.getTransmitStation(), this.transmitStation);
        Assert.assertEquals(this.link.getTransmitStationBeam(), this.transmitStationBeam);
        Assert.assertEquals(this.link.getReceiveStation(), this.receiveStation);
        Assert.assertEquals(this.link.getLosses(), this.losses);
        Assert.assertEquals(this.link.isDoCheck(), true);
    }

    /*
    public void test_computePerformance() {
    performance_expected = Performance(-183.7920554531003 - 10 * log10(2),
                                             -206.8382560925405,
                                             [-220.4414417558061; -220.4414417558061],
                                             -217.4311417991658,
                                             [-172.7123681232581; -172.7123681232581],
                                             -169.7020681666177);

          warning("off");
          performance_actual = this.link.computePerformance(
              this.dNm, this.interferingSystem, 1, 1, this.ref_bw);
          warning("on");

          t = [];
          t = [t; abs(performance_actual.C - performance_expected.C) < this.MEDIUM_PRECISION];
          t = [t; abs(performance_actual.N - performance_expected.N) < this.MEDIUM_PRECISION];
          t = [t; abs(performance_actual.i - performance_expected.i) < this.MEDIUM_PRECISION];
          t = [t; abs(performance_actual.I - performance_expected.I) < this.MEDIUM_PRECISION];
          t = [t; abs(performance_actual.epfd - performance_expected.epfd) < this.MEDIUM_PRECISION];
          t = [t; abs(performance_actual.EPFD - performance_expected.EPFD) < this.MEDIUM_PRECISION];

          this.assert_true(
              "Link",
              "computePerformance",
              this.MEDIUM_PRECISION_DESC,
              min(t));

        end         // test_computePerformance()

        }
*/
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
    //TODO: Test function [idxVisES, idxVisSS, r_ger_SS] = findIdxVisEStoSS(earthStations, spaceStations, dNm)
    //TODO: Test function [idxVisSS_A, idxVisSS_B, r_ger_SS_A, r_ger_SS_B] = findIdxVisSStoSS(spaceStationsA, spaceStationsB, dNm)
    //TODO: Test function is = isEmpty(this)
/*
public Gain findIdxVisEStoSS(double earthStations, double spaceStations, double dNm) { 

}
*/
}