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

/**
 * Manages a set of networks.
 */
public class System {

    public static Logger logger = LogManager.getLogger(System.class.getName());

    // An Earth station array
    private ArrayList<EarthStation> earthStations;
    // A space station array
    private ArrayList<SpaceStation> spaceStations;
    // Propagation loss models to apply
    private Object[] losses;

    // Flag for avoiding GSO arc
    private final boolean testAngleFromGsoArc;
    // Angle for avoiding GSO arc
    private final double angleFromGsoArc;
    // Flag for avoiding low passes
    private final boolean testAngleFromZenith;
    // Angle for avoiding low passes
    private final double angleFromZenith;

    // Current date number
    private ModJulianDate dNm;

    // A network array
    private ArrayList<Network> networks;

    /**
     * Constructs a System.
     *
     * @param earthStations An Earth station array
     * @param spaceStations A space station array
     * @param losses        Propagation loss models to apply
     * @param dNm           Current date number
     * @param options       Map of options containing:
     *                      TestAngleFromGsoArc Flag for avoiding GSO arc (default is 1)
     *                      AngleFromGsoArc     Angle for avoiding GSO arc [deg] (default is 10)
     *                      TestAngleFromZenith Flag for avoiding low passes (default is 1)
     *                      AngleFromZenith     Angle for avoiding low passes [deg] (default is 60)
     */
    public System(ArrayList<EarthStation> earthStations, ArrayList<SpaceStation> spaceStations, Object[] losses, ModJulianDate dNm, Map options) {

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
        this.networks = new ArrayList<Network>();
    }

    /**
     * Copies a System.
     *
     * @return A new System instance
     */
    public System copy() {


        ArrayList<EarthStation> earthStations = new ArrayList<EarthStation>();
        for (EarthStation earthstation : this.earthStations) {
            earthStations.add(earthstation.copy());
        }

        ArrayList<SpaceStation> spaceStations = new ArrayList<SpaceStation>();
        for (SpaceStation spacestation : this.spaceStations) {
            spaceStations.add(spacestation.copy());
        }

        Object[] losses = new Object[earthStations.size()];
        int nLss = this.losses.length;
        java.lang.System.arraycopy(this.losses, 0, losses, 0, nLss);

        ModJulianDate dNm = this.dNm.clone();

        Map options = new HashMap();
        options.put("testAngleFromGsoArc", this.testAngleFromGsoArc);
        options.put("testAngleFromZenith", this.testAngleFromZenith);

        System that = new System(earthStations, spaceStations, losses, dNm, options);

        ArrayList<Network> networks = new ArrayList<Network>();
        for (Network network : this.networks) {
            networks.add(network.copy());
        }

        that.set_networks(networks);

        return that;
    }

    /**
     * Determines if System properties are empty, or not.
     */
    public boolean isEmpty() {
        return this.earthStations.isEmpty() &&
                this.spaceStations.isEmpty() &&
                this.losses == null;
    }

    /**
     * Sets the Earth stations.
     *
     * @param earthStations The Earth stations
     */
    public void set_earthStations(ArrayList<EarthStation> earthStations) {
        this.earthStations = earthStations;
    }

    /**
     * Gets the Earth stations.
     *
     * @return The Earth stations
     */
    public ArrayList<EarthStation> get_earthStations() {
        return this.earthStations;
    }

    /**
     * Sets the space stations.
     *
     * @param spaceStations The space stations
     */
    public void set_spaceStations(ArrayList<SpaceStation> spaceStations) {
        this.spaceStations = spaceStations;
    }

    /**
     * Gets the space stations.
     *
     * @return The space stations
     */
    public ArrayList<SpaceStation> get_spaceStations() {
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
     * Sets a network array.
     *
     * @param networks A network array
     */
    public void set_networks(ArrayList networks) {
        this.networks = networks;
    }

    /**
     * Gets a network array.
     *
     * @return A network array
     */
    public ArrayList<Network> get_networks() {
        return this.networks;
    }

    /**
     * Gets assigned Earth stations as a column vector.
     *
     * @return An array of Earth stations
     */
    public ArrayList<EarthStation> get_assignedEarthStations() {
        ArrayList<EarthStation> earthStations = new ArrayList<EarthStation>();
        for (Network network : this.networks) {
            earthStations.add(network.get_earthStation());
        }
        return earthStations;
    }

    /**
     * Gets assigned Earth station beams as a column vector.
     *
     * @return An array of Earth station beams
     */
    public ArrayList<Beam> get_assignedEarthStationBeams() {
        ArrayList<Beam> earthStationBeams = new ArrayList<Beam>();
        for (Network network : this.networks) {
            earthStationBeams.add(network.get_earthStationBeam());
        }
        return earthStationBeams;
    }

    /**
     * Gets assigned space stations as a column vector.
     *
     * @return An array of space stations
     */
    public ArrayList<SpaceStation> get_assignedSpaceStations() {

        ArrayList<SpaceStation> spaceStations = new ArrayList<SpaceStation>();
        for (Network network : this.networks) {
            spaceStations.add(network.get_spaceStation());
        }
        return spaceStations;
    }

    /**
     * Gets assigned space station beams as a column vector.
     *
     * @return An array of space station beams
     */
    public ArrayList<Beam> get_assignedSpaceStationBeams() {
        ArrayList<Beam> spaceStationBeams = new ArrayList<Beam>();
        for (Network network : this.networks) {
            spaceStationBeams.add(network.get_spaceStationBeam());
        }
        return spaceStationBeams;
    }

    /**
     * Establish a one-to-one correspondence between each Earth
     * station and a space station and beam.
     *
     * @param earthStations Selected Earth stations in the system
     * @param dNm           Date number of assignment
     * @param options       Map of options containing:
     *                      Method   Method for assigning space to Earth stations:
     *                      'MaxElv', 'MaxSep', 'MinSep', 'Random' (default is 'MaxElv')
     *                      DoCheck  Flag for checking input values (default is 1)
     * @return Beam assignment instance
     */
    public Assignment assignBeams(ArrayList<EarthStation> earthStations, ModJulianDate dNm, Map options) throws NoSuchElementException {

        // Assign date number of assignment
        this.dNm = dNm;

        // Parse variable input arguments
        String method = ((String) options.getOrDefault("Method", "MaxElv")).toLowerCase();
        boolean doCheck = (boolean) options.getOrDefault("DoCheck", true);

        // Reset so that stations and beams can be assigned
        this.reset();

        // Initialize networks. No networks are assured.
        this.networks = new ArrayList<Network>();

        // Shallow copy ArrayList of space stations in system to allow modification of station list
        ArrayList<SpaceStation> spaceStations = (ArrayList<SpaceStation>) this.spaceStations.clone();

        // Consider each selected Earth station in order to assign a
        // space station and beam
        for (EarthStation earthStation : earthStations) {

            // Ensure Earth stations are in this system
            if (!this.earthStations.contains(earthStation)) {
                throw new NoSuchElementException();
            }

            // Initialize local metrics
            ArrayList<Double> metrics = new ArrayList<Double>();

            // Consider each selected space station in order to find the space station by the specified method
            int iSS = -1;
            for (SpaceStation spaceStation : spaceStations) {
                iSS++;
                double metric;
                switch (method) {
                    case "minsep":
                    case "maxelv":
                        metric = 90.0;
                        break;
                    case "maxsep":
                    case "random":
                        metric = 0.0;
                        break;
                    default:
                        throw new MException("Springbok:IllegalArgumentException",
                                "The method for assigning beams must be " +
                                        "'maxelv', 'maxsep', 'minsep', or 'random'");
                }
                metrics.add(metric);

                // Skip the current space station if unavailable.
                if (!spaceStation.isAvailable()) {
                    continue;
                }

                // Compute angle between space station position vector
                // relative to the Earth station and GSO arc
                if (method.equals("maxsep") || method.equals("minsep") || this.testAngleFromGsoArc) {
                    double theta_g = 0.0;
                    try {
                        theta_g = computeAngleFromGsoArc(spaceStation.compute_r_ger(dNm), earthStation.compute_r_ger(dNm));
                    } catch (ObjectDecayed objectDecayed) {
                        objectDecayed.printStackTrace();
                    }


                    // Skip the current space station if the current space
                    // and Earth station require the current Earth station
                    // to broadcast too directly toward the GSO arc
                    if (this.testAngleFromGsoArc && theta_g < this.angleFromGsoArc) {
                        continue;
                    }

                    // Assign metric for selection
                    if (method.equals("maxsep") || method.equals("minsep")) {
                        metrics.set(iSS, theta_g);
                    }
                }

                // Compute angle between space station position vector
                // relative to the Earth station and Earth station zenith
                // direction
                if (method.equals("maxelv") || method.equals("random") || this.testAngleFromZenith) {
                    double theta_z = 0.0;
                    try {
                        theta_z = computeAngleFromZenith(spaceStation.compute_r_ger(dNm), earthStation.compute_r_ger(dNm));
                    } catch (ObjectDecayed objectDecayed) {
                        objectDecayed.printStackTrace();
                    }

                    // Skip the current space station if it is too near the
                    // current Earth station horizon
                    if (this.testAngleFromZenith && theta_z > this.angleFromZenith) {
                        continue;
                    }

                    // Assign metric for selection
                    if (method.equals("maxelv") || method.equals("random")) {
                        metrics.set(iSS, theta_z);
                    }
                }
            }

            // Select a space station to assign to the current Earth
            // station
            int iSS_sel = 0;
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
                    iSS_sel = metrics.indexOf(metric_sel);
                    break;
                case "maxsep":
                    // Find the maximum angle between space station position
                    // vector relative to the Earth station and GSO arc
                    metric_sel = Collections.max(metrics);
                    iSS_sel = metrics.indexOf(metric_sel);
                    break;
                case "random":
                    // Find valid indexes of assigned space stations then
                    // select one at random
                    iSS_sel = new Random().nextInt(spaceStations.size());
                    break;
            }

            // Assign a space station to the current Earth station
            SpaceStation spaceStation = spaceStations.get(iSS_sel);
            Beam beam = spaceStation.assign(earthStation.doMultiplexing());
            Map map = new HashMap();
            map.put("doCheck", doCheck);
            this.networks.add(new Network(earthStation,
                    spaceStation, beam, this.losses, map));

            // Eliminate the space station from further assignment, if unavailable.
            if (!spaceStation.isAvailable()) {
                spaceStations.remove(iSS_sel);
            }
        }

        // Consider each network
        int nNet = this.networks.size();
        boolean[] isAvailable_SS = new boolean[nNet];
        boolean[] isAvailable_SS_Bm = new boolean[nNet];
        boolean[] isMultiplexed_SS_Bm = new boolean[nNet];
        int[] divisions_SS_Bm = new int[nNet];
        double[] dutyCycle_ES_Bm = new double[nNet];

        for (int iNet = 0; iNet < nNet; iNet++) {
            // Compute duty cycle for the Earth station of each
            this.networks.get(iNet).get_earthStation().get_beam().set_dutyCycle(100.0 / this.networks.get(iNet).get_spaceStationBeam().get_divisions());

            // Collect assignment properties
            isAvailable_SS[iNet] = this.networks.get(iNet).get_spaceStation().isAvailable();
            isAvailable_SS_Bm[iNet] = this.networks.get(iNet).get_spaceStationBeam().isAvailable();
            isMultiplexed_SS_Bm[iNet] = this.networks.get(iNet).get_spaceStationBeam().isMultiplexed();
            divisions_SS_Bm[iNet] = this.networks.get(iNet).get_spaceStationBeam().get_divisions();
            dutyCycle_ES_Bm[iNet] = this.networks.get(iNet).get_earthStationBeam().get_dutyCycle();
        }

        // Check the number of networks
        if (nNet != earthStations.size()) {
            logger.warn("The number of networks and selected Earth stations are not equal");
        }

        // Create assignment, and set properties, for return
        return new Assignment(dNm,
                this.networks,
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
     * @param ref_bw            Reference bandwidth [kHz]
     * @param options           Map of options containing:
     *                          DoIS  Flag for computing up link performance in the
     *                          presence of inter-satellite interference (default is 0)
     * @return Up link performance
     */
    public ArrayList<Performance> computeUpLinkPerformance(ModJulianDate dNm, System interferingSystem, double ref_bw, Map options) {
        // Compute up link performance
        ArrayList<Performance> performances = new ArrayList<Performance>();
        for (Network network : this.networks) {
            try {
                performances.add(network
                        .get_up_Link()
                        .computePerformance(dNm, interferingSystem, ref_bw, options));
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
     * @param ref_bw            Reference bandwidth [kHz]
     * @return Down link performance
     */
    public ArrayList<Performance> computeDownLinkPerformance(ModJulianDate dNm, System interferingSystem,
                                                             double ref_bw, Map options) {
        ArrayList<Performance> performances = new ArrayList<Performance>();
        for (Network network : this.networks) {
            try {
                performances.add(network
                        .get_dn_Link()
                        .computePerformance(dNm, interferingSystem, ref_bw, options));
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

        // TODO: Assignment needs a reference to system, which needs to be tested here

        // Set derived properties of this System instance
        this.dNm = assignment.get_dNm();
        this.networks = assignment.get_networks();

        // Consider each network
        int nNet = assignment.get_networks().size();
        for (int iNet = 0; iNet < nNet; iNet++) {
            // Set derived properties of the associated space station,
            // space station beam, and Earth station beam instances.
            this.networks.get(iNet).get_spaceStation().set_isAvailable(assignment.isAvailable_SS()[iNet]);
            this.networks.get(iNet).get_spaceStationBeam().set_isAvailable(assignment.isAvailable_SS_Bm()[iNet]);
            this.networks.get(iNet).get_spaceStationBeam().set_isMultiplexed(assignment.isMultiplexed_SS_Bm()[iNet]);
            this.networks.get(iNet).get_spaceStationBeam().set_divisions(assignment.get_divisions_SS_Bm()[iNet]);
            this.networks.get(iNet).get_earthStationBeam().set_dutyCycle(assignment.get_dutyCycle_ES_Bm()[iNet]);
        }

        // Consider each space station, assigned, or not, in order to
        // compute positions at the date number specified
        for (SpaceStation spaceStation : this.spaceStations) {
            try {
                spaceStation.compute_r_ger(this.dNm);
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
        for (SpaceStation spaceStation : this.spaceStations) {
            spaceStation.reset();
        }

        // No value to use to reset dNm
        this.networks = new ArrayList<Network>();
    }

    /**
     * Compute the (approximate) minimum angle between the line from
     * the current Earth station to the current space station, and a
     * line from the current Earth station to a point on the GSO
     * arc. Note that result always non-negative and <= 90.
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
     * space station. Note that result always non-negative and <= 90.
     */
    public static double computeAngleFromZenith(Matrix r_SS, Matrix r_ES) {
        Matrix u_ES = r_ES.times(1 / Math.sqrt(r_ES.transpose().times(r_ES).get(0, 0)));
        Matrix r_SS_ES = r_SS.minus(r_ES);
        Matrix u_SS_ES = r_SS_ES.times(1 / Math.sqrt(r_SS_ES.transpose().times(r_SS_ES).get(0, 0)));
        return Math.toDegrees(Math.acos(u_ES.transpose().times(u_SS_ES).get(0, 0)));
    }

}