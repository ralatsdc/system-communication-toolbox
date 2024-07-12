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
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.*;

import static com.springbok.system.SystemUtils.randperm;

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

    /**
     * Constructs a System.
     *
     * @param earthStations       An Earth station array
     * @param spaceStations       A space station array
     * @param losses              Propagation loss models to apply
     * @param dNm                 Current date number
     * @param options             Map of options containing:
     *                                TestAngleFromGsoArc Flag for avoiding GSO arc (default is 1)
     *                                AngleFromGsoArc     Angle for avoiding GSO arc [deg] (default is 10)
     *                                TestAngleFromZenith Flag for avoiding low passes (default is 1)
     *                                AngleFromZenith     Angle for avoiding low passes [deg] (default is 60)
     */
    public System(EarthStation[] earthStations, SpaceStation[] spaceStations, Object[] losses, ModJulianDate dNm, Map options) {

        // Assign properties
        this.set_earthStations(earthStations);
        this.set_spaceStations(spaceStations);
        this.set_losses(losses);
        this.dNm = dNm;  // Set on construction, or assignment only

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
        EarthStation[] earthStations = new EarthStation[nES];
        for (int iES = 0; iES < nES; iES++) {
            earthStations[iES] = this.earthStations[iES].copy();
        }

        int nSS = this.spaceStations.length;
        SpaceStation[] spaceStations = new SpaceStation[nSS];
        for (int iSS = 0; iSS < nSS; iSS++) {
            spaceStations[iSS] = this.spaceStations[iSS].copy();
        }

        Object[] losses = new Object[nES];
        int nLss = this.losses.length;
        for (int iLss = 0; iLss < nLss; iLss++) {
            losses[iLss] = this.losses[iLss];
        }

        ModJulianDate dNm = this.dNm.clone();

        Map options = new HashMap();
        options.put("testAngleFromGsoArc", this.testAngleFromGsoArc);
        options.put("testAngleFromZenith", this.testAngleFromZenith);

        System that = new System(earthStations, spaceStations, losses, dNm, options);

        that.set_theta_g(this.theta_g);
        that.set_theta_z(this.theta_z);
        that.set_metrics(this.metrics);

        int nNet = this.networks.length;
        Network[] networks = new Network[nNet];
        for (int iNet = 0; iNet < nNet; iNet++) {
            networks[iNet] = this.networks[iNet].copy();
        }

        that.set_networks(networks);
        that.set_idxNetES(this.idxNetES);
        that.set_idxNetSS(this.idxNetSS);

        return that;
    }

    /**
     * Sets the Earth stations.
     *
     * @param earthStations The Earth stations
     */
    public void set_earthStations(EarthStation[] earthStations) {
        this.earthStations = earthStations;
    }

    /**
     * Gets the Earth stations.
     *
     * @return The Earth stations
     */
    public EarthStation[] get_earthStations() {
        return this.earthStations;
    }

    /**
     * Sets the space stations.
     *
     * @param spaceStations The space stations
     */
    public void set_spaceStations(SpaceStation[] spaceStations) {
        this.spaceStations = spaceStations;
    }

    /**
     * Gets the space stations.
     *
     * @return The space stations
     */
    public SpaceStation[] get_spaceStations() {
        return this.spaceStations;
    }

    /**
     * Sets propagation loss models to apply.
     *
     * @param losses Propagation loss models to apply
     */
    public void set_losses(Object[] losses) {
        this.losses = losses;
    }

    /**
     * Gets propagation loss models to apply.
     *
     * @return Propagation loss models to apply
     */
    public Object[] get_losses() {
        return this.losses;
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
     * Gets Angle between space station position vector relative to
     * the Earth station and GSO arc.
     *
     * @return Angle between space station position vector
     *                relative to the Earth station and GSO arc
     */
    public double[][] get_theta_g() {
        return theta_g;
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
     * Gets Angle between space station position vector relative to
     * the Earth station and Earth station zenith direction.
     *
     * @return Angle between space station position vector
     *                relative to the Earth station and Earth station zenith
     *                direction
     */
    public double[][] get_theta_z() {
        return theta_z;
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
     * Gets metric used to select space station for each Earth
     * station.
     *
     * @return Metric used to select space station for each
     *                Earth station
     */
    public double[][] get_metrics() {
        return metrics;
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
     * Gets a network array.
     *
     * @return A network array
     */
    public Network[] get_networks() {
        return this.networks;
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
     * Gets index of each Earth station assigned to a network.
     *
     * @return Index of each Earth station assigned to a
     *                 network
     */
    public int[] get_idxNetES() {
        return idxNetES;
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
     * Gets index of each space station assigned to a network.
     *
     * @return Index of each space station assigned to a
     *                 network
     */
    public int[] get_idxNetSS() {
        return idxNetSS;
    }

    /**
     * Gets assigned Earth stations as a column vector.
     *
     * @return An array of Earth stations
     */
    public EarthStation[] get_assignedEarthStations() {
        EarthStation[] earthStations = new EarthStation[this.networks.length];
        for (int iNet = 0; iNet < this.networks.length; iNet++) {
            earthStations[iNet] = this.networks[iNet].get_earthStation();
        }
        return earthStations;
    }

    /**
     * Gets assigned Earth station beams as a column vector.
     *
     * @return An array of Earth station beams
     */
    public Beam[] get_assignedEarthStationBeams() {
        Beam[] earthStationBeams = new Beam[this.networks.length];
        for (int iNet = 0; iNet < this.networks.length; iNet++) {
            earthStationBeams[iNet] = this.networks[iNet].get_earthStationBeam();
        }
        return earthStationBeams;
    }

    /**
     * Gets assigned space stations as a column vector.
     *
     * @return An array of space stations
     */
    public SpaceStation[] get_assignedSpaceStations() {
        SpaceStation[] spaceStations = new SpaceStation[this.networks.length];
        for (int iNet = 0; iNet < this.networks.length; iNet++) {
            spaceStations[iNet] = this.networks[iNet].get_spaceStation();
        }
        return spaceStations;
    }

    /**
     * Gets assigned space station beams as a column vector.
     *
     * @return An array of space station beams
     */
    public Beam[] get_assignedSpaceStationBeams() {
        Beam[] spaceStationBeams = new Beam[this.networks.length];
        for (int iNet = 0; iNet < this.networks.length; iNet++) {
            spaceStationBeams[iNet] = this.networks[iNet].get_spaceStationBeam();
        }
        return spaceStationBeams;
    }

    /**
     * Establish a one-to-one correspondence between each Earth
     * station and a space station and beam.
     *
     * @param idxSelES Index of Earth stations selected for assignment
     * @param dNm      Date number of assignment
     * @param options  Map of options containing:
     *                     Method   Method for assigning space to Earth stations:
     *                         'MaxElv', 'MaxSep', 'MinSep', 'Random' (default is 'MaxElv')
     *                     DoCheck  Flag for checking input values (default is 1)
     * @return Beam assignment instance
     */
    public Assignment assignBeams(ArrayList<Integer> idxSelES, ModJulianDate dNm, Map options) {

        // Assign index of selected Earth stations
        int nES = earthStations.length;
        if (idxSelES.isEmpty()) {
            for (int iES = 0; iES < nES; iES++) {
                idxSelES.add(iES);
            }
        }
        int nSelES = idxSelES.size();

        // Assign index of all Space stations
        ArrayList<Integer> idxSelSS = new ArrayList<Integer>();
        int nSS = spaceStations.length;
        for (int iSS = 0; iSS < nSS; iSS++) {
            idxSelSS.add(iSS);
        }
        int nSelSS = idxSelSS.size();

        // Assign date number of assignement
        this.dNm = dNm;

        // Parse variable input arguments
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

        // Reset so that stations and beams can be assigned
        this.reset();

        // Initialize angles, metrics, networks, and their station
        // indexes. No networks are assured.
        this.theta_g = SystemUtils.getNanArray(nES, nSS);
        this.theta_z = SystemUtils.getNanArray(nES, nSS);
        this.metrics = SystemUtils.getNanArray(nES, nSS);
        this.networks = new Network[nES];
        this.idxNetES = new int[nES];
        this.idxNetSS = new int[nES];

        // Compute position of all space stations
        Matrix[] r_ger_SS = new Matrix[nSelSS];
        for (int iSelSS = 0; iSelSS < nSelSS; iSelSS++) {
            int iSS = idxSelSS.get(iSelSS);
            try {
                r_ger_SS[iSelSS] = this.spaceStations[iSS].compute_r_ger(dNm);
            } catch (ObjectDecayed objectDecayed) {
                objectDecayed.printStackTrace();
            }
        }

        // Consider each selected Earth station in order to assign a
        // space station and beam
        int[] idxEmpty = new int[]{};
        Matrix[] r_ger_ES = new Matrix[nSelES];
        for (int iSelES = 0; iSelES < nSelES; iSelES++) {
            int iES = idxSelES.get(iSelES);
            r_ger_ES[iSelES] = this.earthStations[iES].compute_r_ger(dNm);

            // Initialize local metrics, and indexes of assignable space
            // stations
            nSelSS = idxSelSS.size();
            double[] theta_g = SystemUtils.getNanArray(1, nSelSS)[0];
            double[] theta_z = SystemUtils.getNanArray(1, nSelSS)[0];
//            double[] metrics = SystemUtils.getNanArray(1, nSelSS)[0];
            ArrayList<Double> metrics = new ArrayList<Double>(nSelSS);

            // Consider each selected space station in order to find the space station by the specified method
            for (int iSelSS = 0; iSelSS < nSelSS; iSelSS++) {
                int iSS = idxSelSS.get(iSelSS);

                // Skip the current space station index if unavailable.
                if (!this.spaceStations[iSS].isAvailable()) {
                    continue;
                }

                // Compute angle between space station position vector
                // relative to the Earth station and GSO arc
                if (method_is_maxsep_or_minsep || this.testAngleFromGsoArc) {
                    theta_g[iSelSS] = computeAngleFromGsoArc(r_ger_SS[iSelSS], r_ger_ES[iSelSS]);
                    this.theta_g[iES][iSS] = theta_g[iSelSS];

                    // Skip the current space station if the current space
                    // and Earth station require the current Earth station
                    // to broadcast too directly toward the GSO arc
                    if (this.testAngleFromGsoArc && theta_g[iSelSS] < this.angleFromGsoArc) {
                        continue;
                    }

                    // Assign metric for selection
                    if (method_is_maxsep_or_minsep) {
                        metrics.set(iSelSS, theta_g[iSelSS]);
                    }
                }

                // Compute angle between space station position vector
                // relative to the Earth station and Earth station zenith
                // direction
                if (method_is_maxelv_or_random || this.testAngleFromZenith) {
                    theta_z[iSelSS] = computeAngleFromZenith(r_ger_SS[iSelSS], r_ger_ES[iSelSS]);
                    this.theta_z[iES][iSS] = theta_z[iSelSS];

                    // Skip the current space station if it is too near the
                    // current Earth station horizon
                    if (this.testAngleFromZenith && theta_z[iSelSS] > this.angleFromZenith) {
                        continue;
                    }

                    // Assign metric for selection
                    if (method_is_maxelv_or_random) {
                        metrics.set(iSelSS, theta_z[iSelSS]);
                    }
                }

                // Assign metric used to select the space station for the
                // current Earth station
                this.metrics[iES][iSS] = metrics.get(iSelSS);
            }

            // Select a space station to assign to the current Earth
            // station
            boolean zerosOnly = metrics.stream().allMatch(x -> x == 0);
            if (zerosOnly) {
                continue;  // Nothing to select
            }

            int iSS_sel;
            double metric_sel;
            switch (method) {
                case "minsep":
                    // Find the minimum angle between space station position
                    // vector relative to the Earth station and GSO arc
                case "maxelv":
                    // Find the minimum angle between space station position
                    // vector relative to the Earth station and Earth
                    // station zenith direction
                    metric_sel = Collections.min(metrics);
                    iSS_sel = idxSelSS.get(metrics.indexOf(metric_sel));
                    break;
                case "maxsep":
                    // Find the maximum angle between space station position
                    // vector relative to the Earth station and GSO arc
                    metric_sel = Collections.max(metrics);
                    iSS_sel = idxSelSS.get(metrics.indexOf(metric_sel));
                    break;
                case "random":
                    // Find valid indexes of assigned space stations then
                    // select one at random
                    iSS_sel = idxSelSS.get(new Random().nextInt(nSelSS));
                    break;
                default:
                    throw new MException("Springbok:IllegalArgumentException",
                            "The method for assigning beams must be " +
                                    "'maxelv', 'maxsep', 'minsep', or 'random'");
            }

            // Assign a space station to the current Earth station
            Beam beam = this.spaceStations[iSS_sel].assign(this.earthStations[iES].doMultiplexing());
            Map map = new HashMap();
            map.put("doCheck", doCheck);
            // TODO: Start here with Will: Understand assignment and number of SS
            this.networks[iSelES] = new Network(this.earthStations[iES],
                    this.spaceStations[iSS_sel], beam, this.losses, map);
            this.idxNetES[iSelES] = iES;
            this.idxNetSS[iSelES] = iSS_sel;

            // Eliminate the space station index and position from
            // further assignment, if unavailable. Note that the space
            // station array is not used in the Earth station loop.
//            if (!this.spaceStations[iSS_sel].isAvailable()) {
//                idxSelSS.set(iSS_sel, 0.0);
//                r_ger_SS[iSS_sel] = null;
//            }
//            idxEmpty = SystemUtils.findReverse(this.idxNetES);
        }

        // Eliminate empty networks
        // int[] idxEmpty = SystemUtils.findReverse(this.idxNetES);
        this.networks = SystemUtils.eliminateEmpty(this.networks, idxEmpty);
        this.idxNetES = SystemUtils.eliminateEmpty(this.idxNetES, idxEmpty);
        this.idxNetSS = SystemUtils.eliminateEmpty(this.idxNetSS, idxEmpty);

        // Consider each network
        int nNet = this.networks.length;
        boolean[] isAvailable_SS = new boolean[nNet];
        boolean[] isAvailable_SS_Bm = new boolean[nNet];
        boolean[] isMultiplexed_SS_Bm = new boolean[nNet];
        int[] divisions_SS_Bm = new int[nNet];
        double[] dutyCycle_ES_Bm = new double[nNet];

        for (int iNet = 0; iNet < nNet; iNet++) {
            // Compute duty cycle for the Earth station of each
            this.networks[iNet].get_earthStation().get_beam().set_dutyCycle(100.0
                    / this.networks[iNet].get_spaceStationBeam().get_divisions());

            // Collect assignement properties
            isAvailable_SS[iNet] = this.networks[iNet].get_spaceStation().isAvailable();
            isAvailable_SS_Bm[iNet] = this.networks[iNet].get_spaceStationBeam().isAvailable();
            isMultiplexed_SS_Bm[iNet] = this.networks[iNet].get_spaceStationBeam().isMultiplexed();
            divisions_SS_Bm[iNet] = this.networks[iNet].get_spaceStationBeam().get_divisions();
            dutyCycle_ES_Bm[iNet] = this.networks[iNet].get_earthStationBeam().get_dutyCycle();
        }

        // Check the number of networks
        if (nNet != idxSelES.length) {
            logger.warn("The number of networks and selected Earth stations are not equal");
        }

        // Create assignment, and set properties, for return
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
     * Reset derived properties of associated stations to initial
     * values.
     */
    public void reset() {

        int nSS = this.spaceStations.length;
        for (int iSS = 0; iSS < nSS; iSS++) {
            this.spaceStations[iSS].reset();
        }

        // No value to use to reset dNm
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
        Matrix r_SS_ES = r_SS.minus(r_ES);
        Matrix u_SS_ES = r_SS_ES.times(1 / Math.sqrt(r_SS_ES.transpose().times(r_SS_ES).get(0, 0)));
        return Math.toDegrees(Math.acos(u_ES.transpose().times(u_SS_ES).get(0, 0)));
    }

}