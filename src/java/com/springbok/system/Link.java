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
import com.springbok.pattern.Gain;
import com.springbok.station.Beam;
import com.springbok.station.EarthStation;
import com.springbok.station.SpaceStation;
import com.springbok.station.Station;
import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.MException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * Describes a link between two stations.
 */
public class Link {

    // A transmit station
    private Station transmitStation;
    // A transmit station beam
    private Beam transmitStationBeam;
    // A receive station
    private Station receiveStation;
    // Propagation loss models to apply
    private Object[] losses;
    // Flag to check input arguments, or not
    private boolean doCheck;

    /**
     * Constructs a Link.
     *
     * @param transmitStation     A transmit station
     * @param transmitStationBeam A transmit station beam
     * @param receiveStation      A receive station
     * @param losses              Propagation loss models to apply
     * @param options             TODO: complete
     */
    public Link(Station transmitStation, Beam transmitStationBeam, Station receiveStation, Object[] losses, Map options) {

        // Parse variable input arguments
        this.set_doCheck((boolean) options.getOrDefault("DoCheck", true));

        // Assign properties
        this.set_transmitStation(transmitStation);
        this.set_transmitStationBeam(transmitStationBeam);
        this.set_receiveStation(receiveStation);
        this.set_losses(losses);
    }

    /**
     * Constructs a Link.
     */
    public Link() {
        this.doCheck = true;
    }

    /**
     * Copies a Link.
     *
     * @return A new Link instance
     */
    public Link copy() {
        Map options = new HashMap<String, Object>();
        options.put("DoCheck", doCheck);
        return new Link(
                this.transmitStation != null ? this.transmitStation.copy() : null,
                this.transmitStationBeam != null ? this.transmitStationBeam.copy() : null,
                this.receiveStation != null ? this.receiveStation.copy() : null,
                this.losses != null ? this.losses.clone() : null,
                options
        );
    }

    /**
     * Sets the transmit station.
     *
     * @param transmitStation A transmit station
     */
    public void set_transmitStation(Station transmitStation) {
        this.transmitStation = transmitStation;
    }

    /**
     * Gets the transmit station.
     *
     * @return A transmit station
     */
    public Station get_transmitStation() {
        return this.transmitStation;
    }

    /**
     * Sets the transmit station beam.
     *
     * @param transmitStationBeam A transmit station beam
     */
    public void set_transmitStationBeam(Beam transmitStationBeam) {
        if (this.doCheck) {
            if (
                    this.transmitStation instanceof EarthStation
                            && !((EarthStation) this.transmitStation).get_beam().equals(transmitStationBeam)
                            || this.transmitStation instanceof SpaceStation
                            && !Arrays.asList(((SpaceStation) this.transmitStation).get_beams()).contains(transmitStationBeam)
            ) {
                throw new MException("Springbok:IllegalArgumentException",
                        "Invalid transmit station beam");
            }
        }
        this.transmitStationBeam = transmitStationBeam;
    }

    /**
     * Gets the transmit station beam.
     *
     * @return A transmit station beam
     */
    public Beam get_transmitStationBeam() {
        return this.transmitStationBeam;
    }

    /**
     * Sets the receive station.
     *
     * @param receiveStation A receive station
     */
    public void set_receiveStation(Station receiveStation) {
        this.receiveStation = receiveStation;
    }

    /**
     * Gets the receive station.
     *
     * @return A receive station
     */
    public Station get_receiveStation() {
        return this.receiveStation;
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
     * Gets propagation loss models to apply
     *
     * @return Propagation loss models to apply
     */
    public Object[] get_losses() {
        return this.losses;
    }

    /**
     * Sets flag to check input arguments, or not.
     *
     * @param doCheck Flag to check input arguments, or not
     */
    public void set_doCheck(boolean doCheck) {
        this.doCheck = doCheck;

    }

    /**
     * Gets flag to check input arguments, or not.
     *
     * @return Flag to check input arguments, or not
     */
    public boolean doCheck() {
        return doCheck;
    }

    /**
     * Computes performance of the link in the presence of an
     * interfering system.
     *
     * @param dNm               Current date number
     * @param interferingSystem Interfering system
     * @param options           Map of options containing:
     *                          DoIS  Flag for computing up link performance in the
     *                          presence of inter-satellite interference (default is 0)
     * @return Link performance
     */
    public Performance computePerformance(ModJulianDate dNm, System interferingSystem,
                                          double ref_bw, Map options) throws ObjectDecayed {
        if (this.isEmpty() || interferingSystem.isEmpty()) {
            return new Performance();
        }

        // Parse variable input arguments
        boolean doIS = (boolean) options.getOrDefault("DoIS", false);
        // TODO: Ask about polarization discrimination (PlDs)
        double PlDs = 0.0;

        // Assign wanted transmit and receive station, for clarity
        Station trnStn_w = this.transmitStation;
        Station rcvStn_w = this.receiveStation;
        Beam trnStnBm_w = this.transmitStationBeam;
        if (doIS && rcvStn_w instanceof EarthStation) {
            throw new IllegalArgumentException("The inter-satellite case requires the receive station to be a space station");
        }

        // Compute positions of wanted transmit and receive station
        Matrix trnStn_w_r_ger = trnStn_w.compute_r_ger(dNm);
        Matrix rcvStn_w_r_ger = rcvStn_w.compute_r_ger(dNm);

        // Assign interfering transmit and receive station, for clarity ...
        ArrayList<Station> trnStns_i = new ArrayList<Station>();
        ArrayList<Beam> trnStnsBms_i = new ArrayList<Beam>();
        ArrayList<Station> rcvStns_i = new ArrayList<Station>();
        ArrayList<Boolean> isVisible = new ArrayList<Boolean>();
        boolean isUpLink = false;
        if (doIS) {

            // ...for the IS case. Use a loop to auto cast.
            for (SpaceStation spaceStation : interferingSystem.get_assignedSpaceStations()) {
                SpaceStation trnStn_i = spaceStation;
                boolean isVis = Link.isVisSStoSS((SpaceStation) rcvStn_w, trnStn_i, dNm);
                if (isVis) {
                    trnStns_i.add(trnStn_i);
                }
                isVisible.add(isVis);
            }
            trnStnsBms_i = interferingSystem.get_assignedSpaceStationBeams();  // No cast required
            int iES = -1;
            for (EarthStation earthStation : interferingSystem.get_assignedEarthStations()) {
                if (isVisible.get(iES++)) {
                    rcvStns_i.add(earthStation);
                }
            }

        } else {

            if (trnStn_w instanceof EarthStation && rcvStn_w instanceof SpaceStation) {

                // ... for an up link. Use a loop to auto cast.
                isUpLink = true;
                for (EarthStation earthStation : interferingSystem.get_assignedEarthStations()) {
                    EarthStation trnStn_i = earthStation;
                    boolean isVis = Link.isVisEStoSS(trnStn_i, (SpaceStation) rcvStn_w, dNm);  // No cast required
                    if (isVis) {
                        trnStns_i.add(trnStn_i);
                    }
                    isVisible.add(isVis);
                }
                trnStnsBms_i = interferingSystem.get_assignedEarthStationBeams();
                int iSS = -1;
                for (SpaceStation spaceStation : interferingSystem.get_assignedSpaceStations()) {
                    if (isVisible.get(iSS++)) {
                        rcvStns_i.add(spaceStation);
                    }
                }

            } else {

                // ... for a down link. Use a loop to auto cast.
                isUpLink = false;
                for (SpaceStation spaceStation : interferingSystem.get_assignedSpaceStations()) {
                    SpaceStation trnStn_i = spaceStation;
                    boolean isVis = Link.isVisEStoSS((EarthStation) rcvStn_w, trnStn_i, dNm);
                    if (isVis) {
                        trnStns_i.add(trnStn_i);
                    }
                    isVisible.add(isVis);
                }
                trnStnsBms_i = interferingSystem.get_assignedSpaceStationBeams();
                int iES = -1;
                for (EarthStation earthStation : interferingSystem.get_assignedEarthStations()) {
                    if (isVisible.get(iES++)) {
                        rcvStns_i.add(earthStation);
                    }
                }
            }
        }

        // Compute positions of interfering transmit and receive stations
        int nInt = trnStns_i.size();
        Matrix[] trnStns_i_r_ger = new Matrix[nInt];
        Matrix[] rcvStns_i_r_ger = new Matrix[nInt];
        for (int iInt = 0; iInt < nInt; ++iInt) {
            trnStns_i_r_ger[iInt] = trnStns_i.get(iInt).compute_r_ger(dNm);
            rcvStns_i_r_ger[iInt] = rcvStns_i.get(iInt).compute_r_ger(dNm);
        }

        // Assign frequency and propagation path length
        double f_w = trnStn_w.get_emission().get_freq_mhz();
        double d_w = computeDistance(trnStn_w_r_ger, rcvStn_w_r_ger);

        // Assign power density, transmit and receive gain, and
        // propagation path loss
        Gain G_t_w_0 = trnStn_w.get_transmitAntenna().get_pattern().gain(
                0, trnStn_w.get_transmitAntenna().get_options());

        Gain G_r_w_0 = rcvStn_w.get_receiveAntenna().get_pattern().gain(
                0, rcvStn_w.get_receiveAntenna().get_options());

        double SL_w = 0;
        double PD_w = 0;
        if (trnStn_w.get_emission().get_pwr_flx_ds() != 0) {
            SL_w = Propagation.computeSL(d_w);
            PD_w = trnStn_w.get_emission().get_pwr_flx_ds() - G_t_w_0.G + SL_w;
        } else {
            PD_w = trnStn_w.get_emission().get_pwr_ds_max();
        }

        double ML_w = 10 * Math.log10(trnStnBm_w.get_divisions());
        double DCL_w = 10 * Math.log10(100 / trnStnBm_w.get_dutyCycle());
        double PL_w = Propagation.computeFSL(f_w, d_w);

        // Compute carrier power density
        double C = PD_w - ML_w - DCL_w + G_t_w_0.G - PL_w + G_r_w_0.G;

        // Assign receiver noise temperature
        double T_w = rcvStn_w.get_receiveAntenna().get_noise_t();

        // Compute noise power density
        double N = Propagation.k + 10 * Math.log10(T_w);

        // Consider each interfering network
        ArrayList<Double> i = new ArrayList<Double>(); // Negative_Infinity
        double I = Double.NEGATIVE_INFINITY;
        ArrayList<Double> epfd = new ArrayList<Double>(); // Negative_Infinity
        double EPFD = Double.NEGATIVE_INFINITY;
        for (int iInt = 0; iInt < nInt; ++iInt) {

            // Assign frequency and propagation path length
            double f_i = trnStns_i.get(iInt).get_emission().get_freq_mhz();
            double d_i_i = Link.computeDistance(trnStns_i_r_ger[iInt], rcvStns_i_r_ger[iInt]);
            double d_i_w = Link.computeDistance(trnStns_i_r_ger[iInt], rcvStn_w_r_ger);

            // Assign power density, transmit and receive gain, and propagation path and spreading loss
            double theta_t_i = Link.computeTheta(trnStns_i_r_ger[iInt], rcvStns_i_r_ger[iInt], rcvStn_w_r_ger);
            Gain G_t_i = trnStns_i.get(iInt).get_transmitAntenna().get_pattern().gain(theta_t_i, trnStns_i.get(iInt).get_transmitAntenna().get_options());
            double SL_i_w = Propagation.computeSL(d_i_w);
            double theta_r_w = Link.computeTheta(rcvStn_w_r_ger, trnStn_w_r_ger, trnStns_i_r_ger[iInt]);
            Gain G_r_w = rcvStn_w.get_receiveAntenna().get_pattern().gain(theta_r_w, rcvStn_w.get_receiveAntenna().get_options());
            double PwDn_i;
            if (trnStns_i.get(iInt).get_emission().get_pwr_flx_ds() != 0.0) {
                Gain G_t_i_0 = trnStns_i.get(iInt).get_transmitAntenna().get_pattern().gain(0, trnStns_i.get(iInt).get_transmitAntenna().get_options());
                double SL_i_i = Propagation.computeSL(d_i_i);
                PwDn_i = trnStns_i.get(iInt).get_emission().get_pwr_flx_ds() - G_t_i_0.G + SL_i_i;
            } else {
                PwDn_i = trnStns_i.get(iInt).get_emission().get_pwr_ds_max();
            }
            double ML_i = 10 * Math.log10(trnStnsBms_i.get(iInt).get_divisions());
            double DCL_i = 10 * Math.log10(100 / trnStnsBms_i.get(iInt).get_dutyCycle());
            double PL_i = Propagation.computeFSL(f_i, d_i_w);

            // Compute interference power density
            i.add(PwDn_i + G_t_i.G - PL_i + G_r_w.G - PlDs - ML_i - DCL_i);  // Including multiplexing and dutycycle
            I = 10 * Math.log10(Math.pow(10, I / 10) + Math.pow(10, i.get(iInt) / 10));

            // Compute equivalent power flux density
            epfd.add(PwDn_i + G_t_i.G - SL_i_w + G_r_w.G - PlDs - G_r_w_0.G + 10 * Math.log10(ref_bw * 1000) - ML_i - DCL_i);  // Including multiplexing and dutycycle
            EPFD = 10 * Math.log10(Math.pow(10, EPFD / 10) + Math.pow(10, epfd.get(iInt) / 10));
        }
        return new Performance(C, N, i, I, epfd, EPFD);
    }

    /**
     * Determines if Link properties are empty, or not.
     */
    public boolean isEmpty() {
        return this.transmitStation == null &&
                this.receiveStation == null &&
                this.losses == null;
    }

    /**
     * Computes distance between two stations.
     *
     * @param r_one First station position
     * @param r_two Second station position
     * @return Distance [km]
     */
    public static double computeDistance(Matrix r_one, Matrix r_two) {
        if (r_one.getRowDimension() != 3 && r_one.getColumnDimension() != 1
                || r_two.getRowDimension() != 3 && r_two.getColumnDimension() != 1) {
            throw new MException("Springbok:IllegalArgumentException",
                    "Positions must be column vectors");
        }
        // Compute relative position vector
        Matrix r_two_one = r_two.minus(r_one);

        double matrixProduct = r_two_one.transpose().times(r_two_one).get(0, 0);
        // Compute distance
        double distance = Math.sqrt(matrixProduct) * EarthConstants.R_oplus;
        // [km] = [er] * [km/er]
        return distance;
    }

    /**
     * Computes the angle between two unit vectors pointing from a
     * reference station to two other stations
     *
     * @param r_ref Reference station position
     * @param r_one First station position
     * @param r_two Second station position
     * @return Angle between unit vectors [deg]
     */
    public static double computeTheta(Matrix r_ref, Matrix r_one, Matrix r_two) {

        // Compute relative position vectors
        Matrix r_one_ref = r_one.minus(r_ref);
        Matrix r_two_ref = r_two.minus(r_ref);

        // Compute unit vectors
        Matrix u_one_ref = r_one_ref.times(1 / Math.sqrt(r_one_ref.transpose().times(r_one_ref).get(0, 0)));
        Matrix u_two_ref = r_two_ref.times(1 / Math.sqrt(r_two_ref.transpose().times(r_two_ref).get(0, 0)));

        // Compute angle between
        double cos = u_one_ref.transpose().times(u_two_ref).get(0, 0);
        double acos;
        if (Double.compare(Math.floor(cos), 1) == 0) {
            acos = 0;
        } else if (Double.compare(Math.ceil(cos), -1) == 0) {
            acos = Math.PI;
        } else {
            acos = Math.acos(cos);
        }

        double theta = Math.toDegrees(acos);
        return theta;
    }

    /**
     * Find if Earth station is visible to space station, and conversely.
     *
     * @param earthStation Earth station with which visibility is
     *                     determined
     * @param spaceStation Space station with which visibility is
     *                     determined
     * @param dNm          Date number at which the position vectors occur
     * @return boolean
     */
    public static boolean isVisEStoSS(EarthStation earthStation, SpaceStation spaceStation, ModJulianDate dNm) {

        Matrix r_ger_ES = earthStation.compute_r_ger(dNm);
        Matrix r_ger_SS = null;

        try {
            r_ger_SS = spaceStation.compute_r_ger(dNm);
        } catch (ObjectDecayed objectDecayed) {
            objectDecayed.printStackTrace();
        }

        double theta = System.computeAngleFromZenith(r_ger_SS, r_ger_ES);

        return theta < 90;
    }

    /**
     * Find if first space station is visible to second space station, and conversely.
     *
     * @param spaceStation_A First space station with which
     *                       visibility is determined
     * @param spaceStation_B Second space station with which
     *                       visibility is determined
     * @param dNm            Date number at which the position vectors occur
     */
    public static boolean isVisSStoSS(SpaceStation spaceStation_A, SpaceStation spaceStation_B, ModJulianDate dNm) {

        Matrix r_ger_SS_A = null;
        Matrix d_ger_SS_A = null;
        double alpha_A = 0.0;
        try {
            r_ger_SS_A = spaceStation_A.compute_r_ger(dNm);
            d_ger_SS_A = new Matrix(1, 1, Math.sqrt(r_ger_SS_A.transpose().times(r_ger_SS_A)
                    .get(0, 0)));
            alpha_A = Math.toDegrees(Math.acos(1.0 / d_ger_SS_A.get(0, 0)));
        } catch (ObjectDecayed objectDecayed) {
            objectDecayed.printStackTrace();
        }

        Matrix r_ger_SS_B = null;
        Matrix d_ger_SS_B = null;
        double alpha_B = 0.0;
        try {
            r_ger_SS_B = spaceStation_B.compute_r_ger(dNm);
            d_ger_SS_B = new Matrix(1, 1, Math.sqrt(r_ger_SS_B.transpose().times(r_ger_SS_B)
                    .get(0, 0)));
            alpha_B = Math.toDegrees(Math.acos(1.0 / d_ger_SS_B.get(0, 0)));
        } catch (ObjectDecayed objectDecayed) {
            objectDecayed.printStackTrace();
        }

        double theta = Math.toDegrees(Math.acos((r_ger_SS_A.arrayRightDivide(d_ger_SS_A)).transpose()
                .times(r_ger_SS_B.arrayRightDivide(d_ger_SS_B)).get(0, 0)));
        return theta < alpha_A + alpha_B;
    }


    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        if (transmitStation != null) {
            temp = Double.doubleToLongBits(transmitStation.hashCode());
            result = prime * result + (int) (temp ^ (temp >>> 32));
        }
        if (transmitStationBeam != null) {
            temp = Double.doubleToLongBits(transmitStationBeam.hashCode());
            result = prime * result + (int) (temp ^ (temp >>> 32));
        }
        if (receiveStation != null) {
            temp = Double.doubleToLongBits(receiveStation.hashCode());
            result = prime * result + (int) (temp ^ (temp >>> 32));
        }
        temp = Double.doubleToLongBits(Arrays.hashCode(losses));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        return result;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof Link)) {
            return false;
        }
        Link other = (Link) obj;

        if (!transmitStation.equals(other.transmitStation)) {
            return false;
        }
        if (!transmitStationBeam.equals(other.transmitStationBeam)) {
            return false;
        }
        if (!receiveStation.equals(other.receiveStation)) {
            return false;
        }
        if (!Arrays.equals(losses, other.losses)) {
            return false;
        }
        return doCheck == other.doCheck;
    }

    // TODO: Remove this inner class
    /**
     * Describes angles between two stations.
     */
    protected static class Angle {

        // Angle [deg]
        private double phi;
        // Azimuth [deg]
        private double azm;
        // Elevation [deg]
        private double elv;

        /**
         * Constructs an Angle.
         *
         * @param phi Angle
         * @param azm Azimuth
         * @param elv Elevation
         */
        public Angle(double phi, double azm, double elv) {
            this.phi = phi;
            this.azm = azm;
            this.elv = elv;
        }

        /**
         * Constructs an Angle.
         */
        public Angle() {
        }

        /**
         * Sets angle.
         *
         * @param phi Angle
         */
        public void set_phi(double phi) {
            this.phi = phi;
        }

        /**
         * Gets angle
         *
         * @return Angle
         */
        public double get_phi() {
            return this.phi;
        }

        /**
         * Sets azimuth.
         *
         * @param azm Azimuth
         */
        public void set_azimuth(double azm) {
            this.azm = azm;
        }

        /**
         * Gets azimuth
         *
         * @return Azimuth
         */
        public double get_azimuth() {
            return this.azm;
        }

        /**
         * Sets elevation.
         *
         * @param elv
         */
        public void set_elevation(double elv) {
            this.elv = elv;
        }

        /**
         * Gets elevation.
         *
         * @return Elevation
         */
        public double get_elevation() {
            return this.elv;
        }
    }
}
