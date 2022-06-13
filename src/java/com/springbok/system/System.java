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
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.MException;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import static com.springbok.system.SystemUtils.randperm;
import static com.springbok.utility.PatternUtility.warning;

/**
 * Manages a set of networks.
 */
public class System {

    // An Earth station array
    private EarthStation[] earthStations;

    // A space station array
    private SpaceStation[] spaceStations;

    // Propagation loss models to apply
    private Object[] losses;

    // Flag for avoiding GSO arc
    private boolean testAngleFromGsoArc;

    // Angle for avoiding GSO arc
    private double angleFromGsoArc;

    // Flag for avoiding low passes
    private boolean testAngleFromZenith;

    // Angle for avoiding low passes
    private double angleFromZenith;

    // Current date number
    private ModJulianDate dNm;

    // Angle between space station position vector relative to the
    // Earth station and GSO arc
    private double[][] theta_g;

    // Angle between space station position vector relative to the
    // Earth station and Earth station zenith direction
    private double[][] theta_z;

    // Metric used to select space station for each Earth station
    private double[][] metrics;

    // A network array
    private Network[] networks;

    // Index of each Earth station assigned to a network
    private int[] idxNetES;

    // Index of each space station assigned to a network
    private int[] idxNetSS;

    public ModJulianDate getdNm() {
        return dNm;
    }

    public Network[] getNetworks() {
        return networks;
    }

    public EarthStation[] getEarthStations() {
        return earthStations;
    }

    public SpaceStation[] getSpaceStations() {
        return spaceStations;
    }

    public Object[] getLosses() {
        return losses;
    }

    public boolean isTestAngleFromGsoArc() {
        return testAngleFromGsoArc;
    }

    public double getAngleFromGsoArc() {
        return angleFromGsoArc;
    }

    public boolean isTestAngleFromZenith() {
        return testAngleFromZenith;
    }

    public double getAngleFromZenith() {
        return angleFromZenith;
    }

    public double[][] getTheta_g() {
        return theta_g;
    }

    public double[][] getTheta_z() {
        return theta_z;
    }

    public double[][] getMetrics() {
        return metrics;
    }

    public int[] getIdxNetES() {
        return idxNetES;
    }

    public int[] getIdxNetSS() {
        return idxNetSS;
    }

    /**
     * Constructs a System.
     *
     * @param earthStations       An Earth station array
     * @param spaceStations       A space station array
     * @param losses              Propagation loss models to apply
     * @param dNm                 Current date number
     * @param TestAngleFromGsoArc Flag for avoiding GSO arc (default is
     *                            1)
     * @param AngleFromGsoArc     Angle for avoiding GSO arc [deg] (default
     *                            is 10)
     * @param TestAngleFromZenith Flag for avoiding low passes (default
     *                            is 1)
     * @param AngleFromZenith     Angle for avoiding low passes [deg]
     *                            (default is 60)
     */

    public System(EarthStation[] earthStations, SpaceStation[] spaceStations, Object[] losses, ModJulianDate dNm, Map options) {
        // Assign properties
        this.set_earthStations(earthStations);
        this.set_spaceStations(spaceStations);
        this.set_losses(losses);
        this.dNm = dNm;         // Set on construction,
        // or assignment only

        // Parse variable input arguments
        this.testAngleFromGsoArc = (boolean) options.getOrDefault("TestAngleFromGsoArc", true);
        this.angleFromGsoArc = (double) options.getOrDefault("AngleFromGsoArc", 10.0);
        this.testAngleFromZenith = (boolean) options.getOrDefault("TestAngleFromZenith", true);
        this.angleFromZenith = (double) options.getOrDefault("AngleFromZenith", 60.0);

        // Derive properties
        this.networks = new Network[]{new Network()};
    }

    /**
     * Copies a System.
     *
     * @return A new System instance
     */
    public System copy() {
        int nES = this.earthStations.length;
        for (int iES = 0; iES < nES; iES++) {
            earthStations[iES] = this.earthStations[iES].copy();
        }

        int nSS = this.spaceStations.length;
        for (int iSS = 0; iSS < nES; iSS++) {
            spaceStations[iSS] = this.spaceStations[iSS].copy();
        }
        Map options = new HashMap();
        options.put("testAngleFromGsoArc", this.testAngleFromGsoArc);
        options.put("testAngleFromZenith", this.testAngleFromZenith);
        System that = new System(earthStations, spaceStations, this.losses, this.dNm, options);

        that.set_theta_g(this.theta_g);
        that.set_theta_z(this.theta_z);
        that.set_metrics(this.metrics);
        int nNet = this.networks.length;
        for (int iNet = 0; iNet < nNet; iNet++) {
            networks[iNet] = this.networks[iNet].copy();
        }
        that.set_networks(networks);
        that.set_idxNetES(this.idxNetES);
        that.set_idxNetSS(this.idxNetSS);

        return that;
    }

    /**
     * Set the Earth stations.
     *
     * @param earthStations The Earth stations
     */
    public void set_earthStations(EarthStation[] earthStations) {
        this.earthStations = earthStations;
    }

    /**
     * Set the space stations.
     *
     * @param spaceStations The space stations
     */
    public void set_spaceStations(SpaceStation[] spaceStations) {
        this.spaceStations = spaceStations;
    }

    /**
     * Sets propagation loss models to apply
     *
     * @param losses Propagation loss models to apply
     */
    public void set_losses(Object[] losses) {
        this.losses = losses;
    }

    /**
     * Sets Angle between space station position vector relative to
     * the Earth station and GSO arc.
     *
     * @param theta_g Angle between space station position vector
     *                relative to the Earth station and GSO arc
     */
    public void set_theta_g(double[][] theta_g) {
        this.theta_g = theta_g;
    }

    /**
     * Sets Angle between space station position vector relative to
     * the Earth station and Earth station zenith direction.
     *
     * @param theta_z Angle between space station position vector
     *                relative to the Earth station and Earth station zenith
     *                direction
     */
    public void set_theta_z(double[][] theta_z) {
        this.theta_z = theta_z;
    }

    /**
     * Sets metric used to select space station for each Earth
     * station.
     *
     * @param metrics Metric used to select space station for each
     *                Earth station
     */
    public void set_metrics(double[][] metrics) {
        this.metrics = metrics;
    }

    /**
     * Sets a network array.
     *
     * @param networks A network array
     */
    public void set_networks(Network[] networks) {
        this.networks = networks;
    }

    /**
     * Sets index of each Earth station assigned to a network.
     *
     * @param idxNetES Index of each Earth station assigned to a
     *                 network
     */
    public void set_idxNetES(int[] idxNetES) {
        this.idxNetES = idxNetES;
    }

    /**
     * Sets index of each space station assigned to a network.
     *
     * @param idxNetSS Index of each space station assigned to a
     *                 network
     */
    public void set_idxNetSS(int[] idxNetSS) {
        this.idxNetSS = idxNetSS;

    }

    /**
     * Gets assigned Earth stations as a column vector.
     *
     * @return An array of Earth stations
     */
    public EarthStation[] get_assignedEarthStations() {
        return new EarthStation[]{this.networks[0].getEarthStation()};
    }

    /**
     * Gets assigned Earth station beamss as a column vector.
     *
     * @return An array of Earth station beams
     */
    public Beam[] get_assignedEarthStationBeams() {
        return new Beam[]{this.networks[0].getEarthStationBeam()};
    }

    /**
     * Gets assigned space stations as a column vector.
     *
     * @return An array of space stations
     */
    public SpaceStation[] get_assignedSpaceStations() {
        return new SpaceStation[]{this.networks[0].getSpaceStation()};
    }

    /**
     * Gets assigned space station beams as a column vector.
     *
     * @return An array of space station beams
     */
    public Beam[] get_assignedSpaceStationBeams() {
        return new Beam[]{this.networks[0].getSpaceStationBeam()};
    }

    /**
     * Establish a one-to-one correspondence between each Earth
     * station and a space station and beam.
     *
     * @param idxSelES Index of Earth stations selected for assignment
     * @param numSmpSS Number of samples of selected space stations
     * @param dNm      Date number of assignment
     * @param Method   Method for assigning space to Earth stations:
     *                 'MaxElv', 'MaxSep', 'MinSep', 'Random' (default is
     *                 'MaxElv')
     * @param DoCheck  Flag for checking input values (default is 1)
     * @return Beam assignment instance
     */
    public Assignment assignBeams(int[] idxSelES, int numSmpSS, ModJulianDate dNm, Map options) {
        //Assign index of selected Earth stations
        int nES = this.earthStations.length;

        //Assign index, and number of samples, of selected space
        //stations. The space station indexes are randomized for
        //sampling.
        int nSS = this.spaceStations.length;
        int[] idxSelSS = randperm(nSS);

        if (numSmpSS == 0) {
            numSmpSS = nSS;
        } else if (numSmpSS > nSS / 10) {
            throw new MException("Springbok:IllegalArgumentException",
                    "Number of selected Space stations invalid");
        }

        //Assign date number of assignement
        this.dNm = dNm;

        //Parse variable input arguments
        String method = (String) options.getOrDefault("Method", "MaxElv");
        boolean doCheck = (boolean) options.getOrDefault("DoCheck", true);

        method = method.toLowerCase();
        boolean method_is_maxsep_or_minsep = false;
        boolean method_is_maxelv_or_random = false;

        if (method.equals("maxsep") || method.equals("minsep")) {
            method_is_maxsep_or_minsep = true;
        } else if (method.equals("maxelv") || method.equals("random")) {
            method_is_maxelv_or_random = true;
        } else {
            throw new MException("Springbok:IllegalArgumentException",
                    "Unexpected value for parameter " + method);
        }

        //Reset so that stations and beams can be assigned
        this.reset();

        //Initialize angles, metrics, networks, and their station
        //indexes. No networks are assured.
        this.theta_g = SystemUtils.getNanArray(nES, nSS);
        this.theta_z = SystemUtils.getNanArray(nES, nSS);
        this.metrics = SystemUtils.getNanArray(nES, nSS);
        this.networks[nES - 1] = new Network();
        this.idxNetES = new int[nES];
        this.idxNetSS = new int[nES];

        //Assign space stations, and their position, for elimination
        //of each space station after assignment
        nSS = idxSelSS.length;
        Matrix[] r_ger_SS = new Matrix[nSS];

        for (int iSS = 0; iSS < nSS; iSS++) {
            try {
                r_ger_SS[iSS] = this.spaceStations[idxSelSS[iSS] - 1].compute_r_ger(dNm);
            } catch (ObjectDecayed objectDecayed) {
                objectDecayed.printStackTrace();
            }
        }

        int[] idxEmpty = new int[]{};
        //Consider each selected Earth station in order to assign a
        //space station and beam
        Matrix[] r_ger_ES = new Matrix[idxSelES.length];
        for (int iES = 0; iES < idxSelES.length; iES++) {
            r_ger_ES[iES] = this.earthStations[iES].get_R_ger();

            //Initialize local metrics, and indexes of assignable space
            //stations
            nSS = idxSelSS.length;
            double[] theta_g = SystemUtils.getNanArray(1, nSS)[0];
            double[] theta_z = SystemUtils.getNanArray(1, nSS)[0];
            metrics = SystemUtils.getNanArray(1, nSS);

            //Consider a sample from the remaining space stations in
            //order to find the space station by the specified method
            for (int iSS = 0; iSS < nSS; iSS += Math.max(1, Math.floor(nSS / numSmpSS))) {
                //Compute angle between space station position vector
                //relative to the Earth station and GSO arc
                if (method_is_maxsep_or_minsep || this.testAngleFromGsoArc) {
                    theta_g[iSS] = computeAngleFromGsoArc(r_ger_SS[iSS], r_ger_ES[iSS]);
                    this.theta_g[iES][idxSelSS[iSS]] = theta_g[iSS];

                    // Skip the current space station if the current space
                    // and Earth station require the current  Earth station
                    // to broadcast too directly toward the GSO arc
                    if (this.testAngleFromGsoArc && theta_g[iSS] < this.angleFromGsoArc) {
                        continue;
                    }

                    //Assign metric for selection
                    if (method_is_maxsep_or_minsep) {
                        metrics[0][iSS] = theta_g[iSS];
                    }
                }
                //Compute angle between space station position vector
                //relative to the Earth station and Earth station zenith
                //direction
                if (method_is_maxelv_or_random || this.testAngleFromZenith) {
                    theta_z[iSS] = computeAngleFromZenith(r_ger_SS[iSS], r_ger_ES[iSS]);
                    this.theta_z[iES][idxSelSS[iSS]] = theta_z[iSS];

                    //Skip the current space station if it is too near the
                    //current Earth station horizon
                    if (this.testAngleFromZenith && theta_z[iSS] > this.angleFromZenith) {
                        continue;
                    }

                    //Assign metric for selection
                    if (method_is_maxelv_or_random) {
                        metrics[0][iSS] = theta_z[iSS];
                    }
                }

                //Assign metric used to select the space station for the
                //current Earth station
                this.metrics[iES][idxSelSS[iSS]] = metrics[0][iSS];
            }

            //Select a space station to assign to the current Earth
            //station
            double[][] mmetrics = metrics;
            boolean[][] nans = SystemUtils.isnan(mmetrics);
            int[] iSS_sel;
            double[] metric_sel;
            int[] iSS_vld;

            switch (method) {
                case "minsep":
                    //Find the minimum angle between space station position
                    //vector relative to the Earth station and GSO arc
                case "maxelv":
                    //Find the minimum angle between space station position
                    //vector relative to the Earth station and Earth
                    //station zenith direction
                    mmetrics = SystemUtils.positiveInfArr(mmetrics, nans);
                    SystemUtils.ArrayMinMax min = SystemUtils.min(mmetrics);
                    metric_sel = min.getValues();
                    iSS_sel = min.getIndexes();
                    break;
                case "maxsep":
                    //Find the maximum angle between space station position
                    //vector relative to the Earth station and GSO arc
                    mmetrics = SystemUtils.negativeInfArr(mmetrics, nans);
                    SystemUtils.ArrayMinMax max = SystemUtils.max(mmetrics);
                    metric_sel = max.getValues();
                    iSS_sel = max.getIndexes();
                    break;
                case "random":
                    //Find valid indexes of assigned space stations then
                    //select one at random
                    iSS_vld = SystemUtils.find(SystemUtils.notIsnan(metrics));
                    if (iSS_vld.length != 0) {
                        iSS_sel = new int[]{new Random().nextInt(iSS_vld.length) + 1};
                    } else {
                        iSS_sel = null;
                    }
                    break;
                default:
                    throw new MException("Springbok:IllegalArgumentException",
                            "The method for assigning beams must be " +
                                    "'maxelv', 'maxsep', 'minsep', or 'random'");
            }

            //Assign a space station to the current Earth station
            if (iSS_sel != null) { //todo I'm not sure about iSS_sel
                Beam beam = this.spaceStations[idxSelSS[iSS_sel[0]]].assign(this.earthStations[iES].doMultiplexing());
                Map map = new HashMap();
                map.put("doCheck", doCheck);
                this.networks[iES] = new Network(this.earthStations[iES],
                        this.spaceStations[idxSelSS[iSS_sel[0]]], beam, this.losses, map);
                this.idxNetES[iES] = iES;
                this.idxNetSS[iES] = idxSelSS[iSS_sel[0]];

                //Eliminate the space station index and position from
                //further assignment, if unavailable. Note that the space
                //station array is not used in the Earth station loop.
                if (!this.spaceStations[idxSelSS[iSS_sel[0]]].isAvailable()) {
                    idxSelSS[iSS_sel[0]] = 0;
                    r_ger_SS[iSS_sel[0]] = null;
                }
                idxEmpty = SystemUtils.findReverse(this.idxNetES);
            }
        }

        //Eliminate empty networks
        //int[] idxEmpty = SystemUtils.findReverse(this.idxNetES);
        this.networks = SystemUtils.eliminateEmpty(this.networks, idxEmpty);
        this.idxNetES = SystemUtils.eliminateEmpty(this.idxNetES, idxEmpty);
        this.idxNetSS = SystemUtils.eliminateEmpty(this.idxNetSS, idxEmpty);

        //Consider each network
        int nNet = this.networks.length;
        boolean[] isAvailable_SS = new boolean[nNet];
        boolean[] isAvailable_SS_Bm = new boolean[nNet];
        boolean[] isMultiplexed_SS_Bm = new boolean[nNet];
        int[] divisions_SS_Bm = new int[nNet];
        double[] dutyCycle_ES_Bm = new double[nNet];

        for (int iNet = 0; iNet < nNet; iNet++) {
            //Compute duty cycle for the Earth station of each
            this.networks[iNet].getEarthStation().getBeam().set_dutyCycle(100.0
                    / this.networks[iNet].getSpaceStationBeam().getDivisions());

            //Collect assignement properties
            isAvailable_SS[iNet] = this.networks[iNet].getSpaceStation().isAvailable();
            isAvailable_SS_Bm[iNet] = this.networks[iNet].getSpaceStationBeam().isAvailable();
            isMultiplexed_SS_Bm[iNet] = this.networks[iNet].getSpaceStationBeam().isMultiplexed();
            divisions_SS_Bm[iNet] = this.networks[iNet].getSpaceStationBeam().getDivisions();
            dutyCycle_ES_Bm[iNet] = this.networks[iNet].getEarthStationBeam().getDutyCycle();
        }

        //Check the number of networks
        if (nNet != idxSelES.length) {
            warning("Springbok:UnassignedStations",
                    "The number of networks and selected Earth stations are not equal");
        }

        //Create assignment, and set properties, for return
        return new Assignment(dNm,
                theta_g,
                theta_z,
                metrics,
                networks,
                this.idxNetES,
                this.idxNetSS,
                isAvailable_SS,
                isAvailable_SS_Bm,
                isMultiplexed_SS_Bm,
                divisions_SS_Bm,
                dutyCycle_ES_Bm);
    }

    /**
     * Establish a one-to-one correspondence between each Earth
     * station and a space station and beam from the networks
     * assigned in the system high. This must be system low.
     *
     * @param dNm        Date number of assignment
     * @param cellsHigh  Structure relating system low to high cells
     * @param systemHigh System high with Earth stations based on
     *                   cells high
     * @param numSmpBm   Number of samples of space station beams to
     *                   assign
     * @param DoCheck    Flag for checking input values (default is 1)
     */
    public void assignBeamsFromHigh(ModJulianDate dNm, Map<String, Object> cellsHigh, System systemHigh, int numSmpBm, Map options) {
        // Assign current date number
        this.dNm = dNm;

        // Parse variable input arguments
        boolean doCheck = (boolean) options.getOrDefault("DoCheck", true);

        // Reset so that stations and beams can be assigned
        this.reset();

        // Initialize angles, metrics, networks, and their station
        // indexes
        int nES = this.earthStations.length;
        int nSS = this.spaceStations.length;
        this.theta_g = SystemUtils.getNanArray(nES, nSS);
        this.theta_z = SystemUtils.getNanArray(nES, nSS);
        this.metrics = SystemUtils.getNanArray(nES, nSS);
        this.networks[nES] = new Network();
        this.idxNetES = new int[nES];
        this.idxNetSS = new int[nES];

        // Consider each system high network
        int nNet = systemHigh.networks.length;
        for (int iNet = 0; iNet < nNet; iNet++) {
            // System high Earth stations correspond to cells high
            int iCell = systemHigh.idxNetES[iNet];

            // Each cell corresponds to a latitude and longitude bin
            int iLatBin = ((int[]) cellsHigh.get("iLatBin"))[iCell];
            int iLonBin = ((int[]) cellsHigh.get("iLonBin"))[iCell];

            // Each bin contains a set of system low Earth station
            // indexes
            int[] idxBinES = ((int[][][]) cellsHigh.get("lonValIdx"))[iLatBin][iLonBin];

            // System high and low space station indexes agree by design
            int iSS = systemHigh.getIdxNetSS()[iNet];

            // Assign the space station to each Earth station in the
            // bin. Bins contain no more Earth stations than can be
            // assigned to one space station.
            for (int iES = 0; iES < idxBinES.length; iES += numSmpBm) {


                Beam beam = this.spaceStations[iSS].assign(this.earthStations[iES].doMultiplexing());
                Map map = new HashMap();
                map.put("doCheck", doCheck);
                this.networks[iES] = new Network(this.earthStations[iES], this.spaceStations[iSS], beam, this.losses, map);
                this.idxNetES[iES] = iES;
                this.idxNetSS[iES] = iSS;

                // Collect assignement properties
                this.theta_g[iES][iSS] = systemHigh.theta_g[iCell][iSS];
                this.theta_z[iES][iSS] = systemHigh.theta_z[iCell][iSS];
                this.metrics[iES][iSS] = systemHigh.metrics[iCell][iSS];
            }
        }

        // Eliminate empty networks
        int[] idxEmpty = SystemUtils.findReverse(this.idxNetES);
        this.networks = SystemUtils.eliminateEmpty(this.networks, idxEmpty);
        this.idxNetES = SystemUtils.eliminateEmpty(this.idxNetES, idxEmpty);
        this.idxNetSS = SystemUtils.eliminateEmpty(this.idxNetSS, idxEmpty);

        // Compute duty cycle for the Earth station of each network
        nNet = this.networks.length;
        boolean[] isAvailable_SS = new boolean[nNet];
        boolean[] isAvailable_SS_Bm = new boolean[nNet];
        boolean[] isMultiplexed_SS_Bm = new boolean[nNet];
        int[] divisions_SS_Bm = new int[nNet];
        double[] dutyCycle_ES_Bm = new double[nNet];
        for (int iNet = 0; iNet < nNet; iNet++) {
            this.networks[iNet].getEarthStation().getBeam().set_dutyCycle(
                    100.0 / this.networks[iNet].getSpaceStationBeam().getDivisions());

            // Collect assignement properties
            isAvailable_SS[iNet] = this.networks[iNet].getSpaceStation().isAvailable();
            isAvailable_SS_Bm[iNet] = this.networks[iNet].getSpaceStationBeam().isAvailable();
            isMultiplexed_SS_Bm[iNet] = this.networks[iNet].getSpaceStationBeam().isMultiplexed();
            divisions_SS_Bm[iNet] = this.networks[iNet].getSpaceStationBeam().getDivisions();
            dutyCycle_ES_Bm[iNet] = this.networks[iNet].getEarthStationBeam().getDutyCycle();

        }

        // Create assignment, and set properties, for return
        Assignment assignment = new Assignment(this.dNm,
                this.theta_g,
                this.theta_z,
                this.metrics,
                this.networks,
                this.idxNetES,
                this.idxNetSS,
                isAvailable_SS,
                isAvailable_SS_Bm,
                isMultiplexed_SS_Bm,
                divisions_SS_Bm,
                dutyCycle_ES_Bm);
    }

    /**
     * Compute performance measures for the up link of each wanted
     * network.
     *
     * @param dNm               Current date number
     * @param interferingSystem Interfering system
     * @param numSmpES          Ratio of the number of Earth stations to the
     *                          number for which asisgnment is attempted
     * @param numSmpBm          Ratio of the number of Beams to the number which
     *                          is assigned
     * @param ref_bw            Reference bandwidth [kHz]
     * @param DoIS              Flag for computing up link performance in the
     *                          presence of inter-satellite interference (default is 0)
     * @return Up link performance
     */
    public Performance[] computeUpLinkPerformance(ModJulianDate dNm, System interferingSystem, double numSmpES, double numSmpBm, double ref_bw, Map options) {
        // Compute up link performance
        int nNet = this.networks.length;
        Performance[] performances = new Performance[nNet];
        for (int iNet = 0; iNet < nNet; iNet++) {
            try {
                performances[iNet] = this.networks[iNet]
                        .getUp_Link()
                        .computePerformance(dNm, interferingSystem, numSmpES, numSmpBm, ref_bw, options);
            } catch (ObjectDecayed objectDecayed) {
                objectDecayed.printStackTrace();
            }

        }
        return performances;
    }

    /**
     * Compute performance measures for the down link of each wanted
     * network.
     *
     * @param dNm               Current date number
     * @param interferingSystem Interfering system
     * @param numSmpES          Ratio of the number of Earth stations to the
     *                          number for which asisgnment is attempted
     * @param numSmpBm          Ratio of the number of Beams to the number which
     *                          is assigned
     * @param ref_bw            Reference bandwidth [kHz]
     * @return Down link performance
     */
    public Performance[] computeDownLinkPerformance(ModJulianDate dNm, System interferingSystem,
                                                    double numSmpES, double numSmpBm, double ref_bw, Map options) {
        int nNet = this.networks.length;
        Performance[] performances = new Performance[nNet];
        for (int iNet = 0; iNet < nNet; iNet++) {
            try {
                performances[iNet] = this.networks[iNet]
                        .getDn_Link()
                        .computePerformance(dNm, interferingSystem, numSmpES, numSmpBm, ref_bw, options);
            } catch (ObjectDecayed objectDecayed) {
                objectDecayed.printStackTrace();
            }

        }
        return performances;
    }

    /**
     * Set derived properties of associated stations to values from
     * specified assignment.
     */
    public void apply(Assignment assignment) {
        // TODO: Assignment needs a reference to system, which needs
        // to be tested here

        // Set derived properties of this System instance
        this.dNm = assignment.getdNm();
        this.theta_g = assignment.getTheta_g();
        this.theta_z = assignment.getTheta_z();
        this.metrics = assignment.getMetrics();
        this.networks = assignment.getNetworks();
        this.idxNetES = assignment.getIdxNetES();
        this.idxNetSS = assignment.getIdxNetSS();

        // Consider each network
        int nNet = assignment.getNetworks().length;
        for (int iNet = 0; iNet < nNet; iNet++) {
            // Set derived properties of the associated space station,
            // space station beam, and Earth station beam instances.
            this.networks[iNet].getSpaceStation().set_isAvailable(assignment.getIsAvailable_SS()[iNet]);
            this.networks[iNet].getSpaceStationBeam().set_isAvailable(assignment.getIsAvailable_SS_Bm()[iNet]);
            this.networks[iNet].getSpaceStationBeam().set_isMultiplexed(assignment.getIsMultiplexed_SS_Bm()[iNet]);
            this.networks[iNet].getSpaceStationBeam().set_divisions(assignment.getDivisions_SS_Bm()[iNet]);
            this.networks[iNet].getEarthStationBeam().set_dutyCycle(assignment.getDutyCycle_ES_Bm()[iNet]);
        }

        // Consider each space station, assigned, or not, in order to
        // compute positions at the date number specified
        int nSS = this.spaceStations.length;
        for (int iSS = 0; iSS < nSS; iSS++) {
            try {
                this.spaceStations[iSS].compute_r_ger(this.dNm);
            } catch (ObjectDecayed objectDecayed) {
                objectDecayed.printStackTrace();
            }
        }
    }

    /**
     * Reset derived properties of associated stations to initial
     * values.
     */
    public void reset() {
        int nSS = this.spaceStations.length;
        for (int iSS = 0; iSS < nSS; iSS++) {
            this.spaceStations[iSS].reset();
        }

        // dNm
        this.theta_g = null;
        this.theta_z = null;
        this.metrics = null;
        this.networks = new Network[]{new Network()};
        this.idxNetES = null;
        this.idxNetSS = null;
    }

    /**
     * Compute the (approximate) minimum angle between the line from
     * the current Earth station to the current space station, and a
     * line from the current Earth station to a point on the GSO
     * arc.
     */
    public static double computeAngleFromGsoArc(Matrix r_SS, Matrix r_ES) {
        Matrix r_SS_ES = r_SS.minus(r_ES);
        double alpha = Math.atan2(r_SS_ES.get(1, 0), r_SS_ES.get(0, 0));

        Matrix r_gso_ES = new Matrix(new double[]{Math.cos(alpha), Math.sin(alpha), 0}, 1).transpose().times(EarthConstants.a_gso).minus(r_ES);
        Matrix e_SS_ES = r_SS_ES.times(1 / Math.sqrt(r_SS_ES.transpose().times(r_SS_ES).get(0, 0)));
        Matrix e_gso_ES = r_gso_ES.times(1 / Math.sqrt(r_gso_ES.transpose().times(r_gso_ES).get(0, 0)));

        return Math.toDegrees(Math.acos(e_SS_ES.transpose().times(e_gso_ES).get(0, 0)));
    }

    /**
     * Determine the angle between the current Earth station zenith
     * and a line from the current Earth station to the current
     * space station.
     */
    public static double computeAngleFromZenith(Matrix r_SS, Matrix r_ES) {
        Matrix u_ES = r_ES.times(1 / Math.sqrt(r_ES.transpose().times(r_ES).get(0, 0)));
//        Matrix u_SS = r_SS.times(1 / Math.sqrt(r_SS.transpose().times(r_SS).get(0,0)));
//        double theta = Math.toDegrees(Math.acos(u_ES.transpose().times(u_SS).get(0,0)));
        Matrix r_SS_ES = r_SS.minus(r_ES);
        Matrix u_SS_ES = r_SS_ES.times(1 / Math.sqrt(r_SS_ES.transpose().times(r_SS_ES).get(0, 0)));

        return Math.toDegrees(Math.acos(u_ES.transpose().times(u_SS_ES).get(0, 0)));
    }
}
