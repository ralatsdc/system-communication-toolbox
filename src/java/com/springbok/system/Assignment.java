/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.system;


import com.springbok.twobody.ModJulianDate;

import java.util.Arrays;

/**
 * Encapsulates the result of a System beam assignment.
 */
public class Assignment {

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

    // Flag array indicating if the station is available, or not
    private boolean[] isAvailable_SS;

    // Flag array indicating if the beam is available, or not
    private boolean[] isAvailable_SS_Bm;

    // Flag array indicating if the beam is multiplexed, or not
    private boolean[] isMultiplexed_SS_Bm;

    // Number of divisions in use array
    private int[] divisions_SS_Bm;

    // Duty cycle array
    private double[] dutyCycle_ES_Bm;

    /**
     * Constructs an Assignment.
     *
     * @param dNm                 Current date number
     * @param theta_g             Angle between space station position vector
     *                            relative to the Earth station and GSO arc
     * @param theta_z             Angle between space station position vector
     *                            relative to the Earth station and Earth station zenith
     *                            direction
     * @param metrics             Metric used to select space station for each
     *                            Earth station
     * @param networks            A network array
     * @param idxNetES            Index of each Earth station assigned to a
     *                            network
     * @param idxNetSS            Index of each space station assigned to a
     *                            network
     * @param isAvailable_SS      Flag array indicating if the station is
     *                            available, or not
     * @param isAvailable_SS_Bm   Flag array indicating if the beam is
     *                            available, or not
     * @param isMultiplexed_SS_Bm Flag array indicating if the beam
     *                            is multiplexed, or not
     * @param divisions_SS_Bm     Number of divisions in use array
     * @param dutyCycle_ES_Bm     Duty cycle array
     */
    public Assignment(ModJulianDate dNm, double[][] theta_g, double[][] theta_z, double[][] metrics, Network[] networks,
                      int[] idxNetES, int[] idxNetSS, boolean[] isAvailable_SS, boolean[] isAvailable_SS_Bm,
                      boolean[] isMultiplexed_SS_Bm, int[] divisions_SS_Bm, double[] dutyCycle_ES_Bm) {

        // Assign properties
        this.set_dNm(dNm);
        this.set_theta_g(theta_g);
        this.set_theta_z(theta_z);
        this.set_metrics(metrics);
        this.set_networks(networks);
        this.set_idxNetES(idxNetES);
        this.set_idxNetSS(idxNetSS);
        this.set_isAvailable_SS(isAvailable_SS);
        this.set_isAvailable_SS_Bm(isAvailable_SS_Bm);
        this.set_isMultiplexed_SS_Bm(isMultiplexed_SS_Bm);
        this.set_divisions_SS_Bm(divisions_SS_Bm);
        this.set_dutyCycle_ES_Bm(dutyCycle_ES_Bm);
    }

    public ModJulianDate getdNm() {
        return dNm;
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

    public Network[] getNetworks() {
        return networks;
    }

    public int[] getIdxNetES() {
        return idxNetES;
    }

    public int[] getIdxNetSS() {
        return idxNetSS;
    }

    public boolean[] getIsAvailable_SS() {
        return isAvailable_SS;
    }

    public boolean[] getIsAvailable_SS_Bm() {
        return isAvailable_SS_Bm;
    }

    public boolean[] getIsMultiplexed_SS_Bm() {
        return isMultiplexed_SS_Bm;
    }

    public int[] getDivisions_SS_Bm() {
        return divisions_SS_Bm;
    }

    public double[] getDutyCycle_ES_Bm() {
        return dutyCycle_ES_Bm;
    }

    /**
     * Copies a Assignment.
     *
     * @return A new Assignment instance
     */
    public Assignment copy() {
        Assignment that = new Assignment(this.dNm, this.theta_g, this.theta_z,
                this.metrics, this.networks, this.idxNetES,
                this.idxNetSS, this.isAvailable_SS,
                this.isAvailable_SS_Bm, this.isMultiplexed_SS_Bm,
                this.divisions_SS_Bm, this.dutyCycle_ES_Bm);
        return that;
    }

    /**
     * Sets current date number.
     *
     * @param dNm Current date number
     */
    public void set_dNm(ModJulianDate dNm) {
        this.dNm = dNm;
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
     * Sets flag array indicating if the station is available, or
     * not.
     *
     * @param isAvailable_SS Flag array indicating if the station is
     *                       available, or not
     */
    public void set_isAvailable_SS(boolean[] isAvailable_SS) {
        this.isAvailable_SS = isAvailable_SS;
    }

    /**
     * Sets flag array indicating if the beam is available, or not.
     *
     * @param isAvailable_SS_Bm Flag array indicating if the beam is
     *                          available, or not
     */
    public void set_isAvailable_SS_Bm(boolean[] isAvailable_SS_Bm) {
        this.isAvailable_SS_Bm = isAvailable_SS_Bm;
    }

    /**
     * Sets flag array indicating if the beam is multiplexed, or
     * not.
     *
     * @param isMultiplexed_SS_Bm Flag array indicating if the beam is
     *                            multiplexed, or not
     */
    public void set_isMultiplexed_SS_Bm(boolean[] isMultiplexed_SS_Bm) {
        this.isMultiplexed_SS_Bm = isMultiplexed_SS_Bm;
    }

    /**
     * Sets number of divisions in use array.
     *
     * @param divisions_SS_Bm Number of divisions in use array
     */
    public void set_divisions_SS_Bm(int[] divisions_SS_Bm) {
        this.divisions_SS_Bm = divisions_SS_Bm;
    }

    /**
     * Sets duty cycle array.
     *
     * @param dutyCycle_ES_Bm Duty cycle array
     */
    public void set_dutyCycle_ES_Bm(double[] dutyCycle_ES_Bm) {
        this.dutyCycle_ES_Bm = dutyCycle_ES_Bm;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(dNm.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(theta_g));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(theta_z));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(metrics));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(networks));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(idxNetES));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(idxNetSS));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(divisions_SS_Bm));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(dutyCycle_ES_Bm));
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
        if (!(obj instanceof Assignment)) {
            return false;
        }
        Assignment other = (Assignment) obj;
        if (Double.doubleToLongBits(dNm.hashCode()) != Double
                .doubleToLongBits(other.dNm.hashCode())) {
            return false;
        }
        if (Double.doubleToLongBits(Arrays.hashCode(theta_g)) != Double
                .doubleToLongBits(Arrays.hashCode(other.theta_g))) {
            return false;
        }
        if (Double.doubleToLongBits(Arrays.hashCode(theta_z)) != Double
                .doubleToLongBits(Arrays.hashCode(other.theta_z))) {
            return false;
        }
        if (Double.doubleToLongBits(Arrays.hashCode(metrics)) != Double
                .doubleToLongBits(Arrays.hashCode(other.metrics))) {
            return false;
        }
        if (Double.doubleToLongBits(Arrays.hashCode(networks)) != Double
                .doubleToLongBits(Arrays.hashCode(other.networks))) {
            return false;
        }
        if (Double.doubleToLongBits(Arrays.hashCode(idxNetES)) != Double
                .doubleToLongBits(Arrays.hashCode(other.idxNetES))) {
            return false;
        }
        if (Double.doubleToLongBits(Arrays.hashCode(idxNetSS)) != Double
                .doubleToLongBits(Arrays.hashCode(other.idxNetSS))) {
            return false;
        }
        if (Double.doubleToLongBits(Arrays.hashCode(divisions_SS_Bm)) != Double
                .doubleToLongBits(Arrays.hashCode(other.divisions_SS_Bm))) {
            return false;
        }
        return Double.doubleToLongBits(Arrays.hashCode(dutyCycle_ES_Bm)) == Double
                .doubleToLongBits(Arrays.hashCode(other.dutyCycle_ES_Bm));
    }
}