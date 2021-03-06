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
import com.springbok.twobody.Coordinates;
import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.PatternUtility;
import com.springbok.utility.TestUtility;
import org.junit.Assert;
import org.junit.Test;

import java.util.*;

import static org.junit.Assert.assertTrue;

/**
 * Tests methods of System class.
 */
public class SystemTest {

    //Reference bandwidth [kHz]
    private double ref_bw = 40;

    // An Earth station array
    private EarthStation[] earthStations;

    // A space station array
    private SpaceStation[] spaceStations;

    // Propagation loss models to apply
    private Object[] losses;

    // Current date number
    private ModJulianDate dNm;

    // A network array
    private Network[] networks;

    // An interfering system
    private System interferingSystem;

    // A system
    private System system;

    @Test
    public void setUp() throws ObjectDecayed {
        /* TODO: Complete
        // Wanted system
        System wantedSystem = Gso_gso.getWntGsoSystem();
        wantedSystem.assignBeams(new int[]{}, 0, wantedSystem.getdNm(), new HashMap());

        // Interfering system
        interferingSystem = Gso_gso.getIntGsoSystem();
        interferingSystem.assignBeams(new int[]{}, 0, interferingSystem.getdNm(), new HashMap());

        // Assign inputs
        earthStations = wantedSystem.getEarthStations();
        spaceStations = wantedSystem.getSpaceStations();
        Beam spaceStationBeam = wantedSystem.getSpaceStations()[0].getBeams()[0];
        losses = wantedSystem.getLosses();
        dNm = wantedSystem.getSpaceStations()[0].getOrbit().getEpoch();
        networks = new Network[]{new Netw
        ork(earthStations[0], spaceStations[0], spaceStationBeam, losses, new HashMap())};
         */
    }

    /**
     * Tests System method.
     */
    @Test
    public void test_System() {
        system = new System(earthStations, spaceStations, losses, dNm, new HashMap());
        Assert.assertTrue(this.system.isTestAngleFromGsoArc());
        Assert.assertEquals(10, this.system.getAngleFromGsoArc(), TestUtility.HIGH_PRECISION);
        Assert.assertTrue(this.system.isTestAngleFromZenith());
        Assert.assertEquals(60, this.system.getAngleFromZenith(), TestUtility.HIGH_PRECISION);
        Assert.assertEquals(this.earthStations, this.system.getEarthStations());
        Assert.assertEquals(this.spaceStations, this.system.getSpaceStations());
        Assert.assertEquals(this.losses, this.system.getLosses());
        Assert.assertEquals(this.dNm, this.system.getdNm());
        //Assert.assertEquals(this.networks, this.system.getNetworks()); //TODO: Uncomment when set_Up will work
        // TODO: Include test of idxNetES and idxNetSS
    }

    /**
     *
     */
    @Test
    public void test_copy() throws ObjectDecayed {
        System wantedSystemOne = Gso_gso.getWntGsoSystem();

        System wantedSystemTwo = wantedSystemOne.copy();

        checkSystems(wantedSystemOne, wantedSystemTwo);
    }

    @Test
    public void get_assignedEarthStations() {
        // TODO: Complete
    }

    @Test
    public void test_assignBeams_by_maximum_elevation_without_multiplexing() throws ObjectDecayed {
        /* TODO: Complete
        System[] systems = Gso_leo.getSystems();
        System wantedSystem = systems[0];
        System interferingSystem = systems[1];

        wantedSystem.getNetworks()[0].set_earthStation(new EarthStation());
        wantedSystem.getNetworks()[0].set_spaceStation(new SpaceStation());
        wantedSystem.getNetworks()[0].getSpaceStation().set_beams(new Beam[]{});
        wantedSystem.getNetworks()[0].set_spaceStationBeam(new Beam("", 1, 1));
        wantedSystem.getNetworks()[0].s(new Beam("", 1, 1));
        wantedSystem.assignBeams(new int[]{}, 0, wantedSystem.getdNm(), new HashMap());
        interferingSystem.assignBeams(new int[]{}, 0, interferingSystem.getdNm(), new HashMap());

        int nSS = interferingSystem.getSpaceStations().length;
        double[] elv = new double[nSS];
        for (int iSS = 0; iSS < nSS; iSS++) {
            Matrix r_gei = interferingSystem.getSpaceStations()[iSS].getOrbit().r_gei(interferingSystem.getdNm());

            Matrix r_ltp = Coordinates.gei2ltp(r_gei, interferingSystem.getNetworks()[0].getEarthStation(),
                    interferingSystem.getdNm());

            Matrix r_rae = Coordinates.ltp2rae(r_ltp);

            elv[iSS] = r_rae.get(2, 0);
        }

        SystemUtils.ArrayMinMax arrayMinMax = SystemUtils.max(elv);
        double elv_max = arrayMinMax.getValues()[0];
        int iSS_max = arrayMinMax.getIndexes()[0];
        Assert.assertEquals(interferingSystem.getNetworks()[0].getSpaceStation(), interferingSystem.getSpaceStations()[iSS_max - 1]);

        spaceStations = interferingSystem.get_assignedSpaceStations();

        nSS = spaceStations.length;

        Assert.assertEquals(nSS, spaceStations.length);
         */
    }

    @Test
    public void test_assignBeams_randomly() {
        // TODO: Complete
    }

    @Test
    public void test_assignBeams_by_maximum_separation() {
        // TODO: Complete
    }

    @Test
    public void test_assignBeams_by_minimum_separation() {
        // TODO: Complete
    }

    @Test
    public void test_assignBeams_by_maximum_elevation_with_multiplexing() {
        // TODO: Complete
    }

    @Test
    public void test_computeUpLinkPerformance_without_multiplexing() {
        /* TODO: Complete
        system = new System(earthStations, spaceStations, losses, dNm, new HashMap());
        Performance performance_expected = new Performance(-157.8181333616310,
                -198.5991686830974,
                new double[]{-197.6363768430820},
                -197.6363768430820,
                new double[]{-147.8812253020032},
                -147.8812253020032);

        Performance[] performance_actual = this.system.computeUpLinkPerformance(this.dNm, this.interferingSystem, 1, 1, this.ref_bw, new HashMap());

        assertTrue(Math.abs(performance_actual[0].getC() - performance_expected.getC()) < TestUtility.MEDIUM_PRECISION);
        assertTrue(Math.abs(performance_actual[0].getN() - performance_expected.getN()) < TestUtility.MEDIUM_PRECISION);
        assertTrue(Math.abs(performance_actual[0].get_i()[0] - performance_expected.get_i()[0]) < TestUtility.MEDIUM_PRECISION);
        assertTrue(Math.abs(performance_actual[0].getI() - performance_expected.getI()) < TestUtility.MEDIUM_PRECISION);
        assertTrue(Math.abs(performance_actual[0].getEpfd()[0] - performance_expected.getEpfd()[0]) < TestUtility.MEDIUM_PRECISION);
        assertTrue(Math.abs(performance_actual[0].getEPFD() - performance_expected.getEPFD()) < TestUtility.MEDIUM_PRECISION);
         */
    }

    @Test
    public void test_computeUpLinkPerformance_with_multiplexing() {
        // TODO: Complete
    }

    @Test
    public void test_computeDownLinkPerformance_without_multiplexing() {
        // TODO: Complete
    }

    @Test
    public void test_computeDownLinkPerformance_with_multiplexing() throws ObjectDecayed {
        /* TODO: Complete
        double C_expected = -183.7920554531003 - 10 * Math.log10(2);

        System wantedSystem = Gso_gso.getWntGsoSystem();

        wantedSystem.assignBeams(new int[]{}, 0, wantedSystem.getdNm(), new HashMap());

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

        EarthStation[] ESArray = new EarthStation[wantedSystem.getEarthStations().length + 1];
        ESArray = wantedSystem.getEarthStations();
        ESArray[wantedSystem.getEarthStations().length] = earthStationB;
        wantedSystem.set_earthStations(ESArray);

        wantedSystem.reset();

        wantedSystem.assignBeams(new int[]{}, 0, wantedSystem.getdNm(), new HashMap());

        Performance[] performance_actual = wantedSystem.computeDownLinkPerformance(
                this.dNm, null, 1, 1, this.ref_bw, new HashMap());

        double C_actual = performance_actual[1].getC();

        Assert.assertTrue(Math.abs(C_actual - C_expected) < TestUtility.MEDIUM_PRECISION);

        double I_expected = -217.4311417991658;

        interferingSystem = Gso_gso.getIntGsoSystem();

        interferingSystem.(new int[]{}, 0, interferingSystem.getdNm(), new HashMap());

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

        List<EarthStation> list = new ArrayList<>();
        list.addAll(Arrays.asList(interferingSystem.getEarthStations()));
        list.add(earthStationB);
        interferingSystem.set_earthStations(list.toArray(new EarthStation[list.size()]));

        interferingSystem.reset();

        interferingSystem.assignBeams(new int[]{}, 0, interferingSystem.getdNm(), new HashMap());

        performance_actual = wantedSystem.computeDownLinkPerformance(
                this.dNm, interferingSystem, 1, 1, this.ref_bw, new HashMap());

        double I_actual = performance_actual[0].getI();

        Assert.assertTrue(Math.abs(I_actual - I_expected) < TestUtility.MEDIUM_PRECISION);
         */
    }

    /**
     *
     */
    @Test
    public void test_apply() {
        /* TODO: Complete
        System[] systems = Gso_leo.getSystems();
        System wantedSystemOne = systems[0];
        System interferingSystemOne = systems[1];

        Assignment wantedAssignment = wantedSystemOne.assignBeams(new int[]{}, 0, wantedSystemOne.getdNm(), new HashMap());

        System wantedSystemTwo = wantedSystemOne.copy();

        wantedSystemOne.reset();

        wantedSystemOne.apply(wantedAssignment);

        Assignment interferingAssignment = interferingSystemOne.assignBeams(new int[]{}, 0, interferingSystemOne.getdNm(), new HashMap());

        System interferingSystemTwo = interferingSystemOne.copy();

        interferingSystemOne.reset();

        interferingSystemOne.apply(interferingAssignment);

        checkSystems(wantedSystemOne, wantedSystemTwo);

        checkSystems(interferingSystemOne, interferingSystemTwo);
         */
    }

    @Test
    public void test_reset() throws ObjectDecayed {
        /* TODO: Complete
        System wantedSystemOne = Gso_gso.getWntGsoSystem();

        System wantedSystemTwo = wantedSystemOne.copy();

        wantedSystemOne.assignBeams(new int[]{}, 0, wantedSystemOne.getdNm(), new HashMap());

        wantedSystemOne.reset();

        checkSystems(wantedSystemOne, wantedSystemTwo);
         */
    }

    @Test
    public void test_computeAngleFromGsoArc() {
        /* TODO: Complete
        double[][] r_gei_ss = new double[3][1];
        double[][] r_gei_es = new double[3][1];
        r_gei_ss[0][0] = 1;
        r_gei_ss[1][0] = 0;
        r_gei_ss[2][0] = 1;

        r_gei_es[0][0] = 2;
        r_gei_es[1][0] = 0;
        r_gei_es[2][0] = 2;

        double theta_expected = 135 - Math.toDegrees(Math.atan2(EarthConstants.a_gso - 1, 1));
        double theta_actual = System.computeAngleFromGsoArc(new Matrix(r_gei_ss), new Matrix(r_gei_es));

        Assert.assertTrue(Math.abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);

        r_gei_ss[0][0] = 2;
        r_gei_ss[1][0] = 0;
        r_gei_ss[2][0] = 0;
        theta_expected = Math.toDegrees(Math.atan2(EarthConstants.a_gso - 1, 1)) - 45;
        theta_actual = System.computeAngleFromGsoArc(new Matrix(r_gei_ss), new Matrix(r_gei_es));

        Assert.assertTrue(Math.abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);

        r_gei_es[0][0] = 1;
        r_gei_es[1][0] = 0;
        r_gei_es[2][0] = 0;
        theta_expected = 0;
        theta_actual = System.computeAngleFromGsoArc(new Matrix(r_gei_ss), new Matrix(r_gei_es));

        Assert.assertTrue(Math.abs(theta_actual - theta_expected) < TestUtility.HIGH_PRECISION);
         */
    }

    @Test
    public void test_computeAngleFromZenith() {
        double[][] r_gei_ss = new double[3][1];
        double[][] r_gei_es = new double[3][1];
        r_gei_ss[0][0] = 2;
        r_gei_ss[1][0] = 2;
        r_gei_ss[2][0] = Math.sqrt(2) * 2;
        r_gei_es[0][0] = 1;
        r_gei_es[1][0] = 1;
        r_gei_es[2][0] = Math.sqrt(2);

        double theta = System.computeAngleFromZenith(new Matrix(r_gei_ss), new Matrix(r_gei_es));

        Assert.assertTrue(TestUtility.isDoublesEquals(0, theta));
        r_gei_ss[0][0] = 1;
        r_gei_ss[1][0] = 1;
        r_gei_ss[2][0] = -Math.sqrt(2);

        theta = System.computeAngleFromZenith(new Matrix(r_gei_ss), new Matrix(r_gei_es));
        Assert.assertTrue(Math.abs(theta - 135) < TestUtility.MEDIUM_PRECISION);

        r_gei_ss[0][0] = -1;
        r_gei_ss[1][0] = -1;
        r_gei_ss[2][0] = -Math.sqrt(2);

        theta = System.computeAngleFromZenith(new Matrix(r_gei_ss), new Matrix(r_gei_es));
        Assert.assertTrue(TestUtility.isDoublesEquals(180, theta));
    }

    private void checkSystems(System systemOne, System systemTwo) {
        Assert.assertEquals(systemOne.getdNm(), systemTwo.getdNm());
        Assert.assertEquals(systemOne.getIdxNetSS(), systemTwo.getIdxNetSS());
        Assert.assertEquals(systemOne.getdNm(), systemTwo.getdNm());
        Assert.assertEquals(systemOne.getIdxNetES(), systemTwo.getIdxNetES());
        Assert.assertEquals(systemOne.getAngleFromGsoArc(), systemTwo.getAngleFromGsoArc(), TestUtility.HIGH_PRECISION);
        Assert.assertEquals(systemOne.getAngleFromZenith(), systemTwo.getAngleFromZenith(), TestUtility.HIGH_PRECISION);
        Assert.assertEquals(systemOne.getEarthStations(), systemTwo.getEarthStations());
        Assert.assertEquals(systemOne.getMetrics(), systemTwo.getMetrics());
        Assert.assertEquals(systemOne.getNetworks(), systemTwo.getNetworks());
        Assert.assertEquals(systemOne.getSpaceStations(), systemTwo.getSpaceStations());
        Assert.assertEquals(systemOne.getTheta_g(), systemTwo.getTheta_g());
        Assert.assertEquals(systemOne.getTheta_z(), systemTwo.getTheta_z());
        Assert.assertEquals(systemOne.getLosses(), systemTwo.getLosses());
    }
}
