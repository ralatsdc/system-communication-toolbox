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


import com.springbok.twobody.ModJulianDate;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;

/**
 * Encapsulates the result of a System beam assignment.
 */
public class Assignment {

    // Current date number
    private ModJulianDate dNm;
    // A network array
    private ArrayList<Network> networks;
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
     * @param networks            A network array
     * @param isAvailable_SS      Flag array indicating if the station is
     *                            available, or not
     * @param isAvailable_SS_Bm   Flag array indicating if the beam is
     *                            available, or not
     * @param isMultiplexed_SS_Bm Flag array indicating if the beam
     *                            is multiplexed, or not
     * @param divisions_SS_Bm     Number of divisions in use array
     * @param dutyCycle_ES_Bm     Duty cycle array
     */
    public Assignment(ModJulianDate dNm, ArrayList<Network> networks,
                      boolean[] isAvailable_SS, boolean[] isAvailable_SS_Bm,
                      boolean[] isMultiplexed_SS_Bm, int[] divisions_SS_Bm, double[] dutyCycle_ES_Bm) {

        // Assign properties
        this.set_dNm(dNm);
        this.set_networks(networks);
        this.set_isAvailable_SS(isAvailable_SS);
        this.set_isAvailable_SS_Bm(isAvailable_SS_Bm);
        this.set_isMultiplexed_SS_Bm(isMultiplexed_SS_Bm);
        this.set_divisions_SS_Bm(divisions_SS_Bm);
        this.set_dutyCycle_ES_Bm(dutyCycle_ES_Bm);
    }

    /**
     * Copies a Assignment.
     *
     * @return A new Assignment instance
     */
    public Assignment copy() {
        ArrayList<Network> networks = new ArrayList<Network>();
        for (Network network : this.networks) {
            networks.add(network.copy());
        }
        Assignment that = new Assignment(this.dNm, networks, this.isAvailable_SS,
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
     * Gets current date number.
     *
     * @return Current date number
     */
    public ModJulianDate get_dNm() {
        return this.dNm;
    }

    /**
     * Sets a network array.
     *
     * @param networks A network array
     */
    public void set_networks(ArrayList<Network> networks) {
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
     * Gets flag array indicating if the station is available, or
     * not.
     *
     * @return Flag array indicating if the station is
     * available, or not
     */
    public boolean[] isAvailable_SS() {
        return this.isAvailable_SS;
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
     * Gets flag array indicating if the beam is available, or not.
     *
     * @return Flag array indicating if the beam is
     * available, or not
     */
    public boolean[] isAvailable_SS_Bm() {
        return this.isAvailable_SS_Bm;
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
     * Gets flag array indicating if the beam is multiplexed, or
     * not.
     *
     * @return Flag array indicating if the beam is
     * multiplexed, or not
     */
    public boolean[] isMultiplexed_SS_Bm() {
        return this.isMultiplexed_SS_Bm;
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
     * Gets number of divisions in use array.
     *
     * @return Number of divisions in use array
     */
    public int[] get_divisions_SS_Bm() {
        return this.divisions_SS_Bm;
    }

    /**
     * Sets duty cycle array.
     *
     * @param dutyCycle_ES_Bm Duty cycle array
     */
    public void set_dutyCycle_ES_Bm(double[] dutyCycle_ES_Bm) {
        this.dutyCycle_ES_Bm = dutyCycle_ES_Bm;
    }

    /**
     * Gets duty cycle array.
     *
     * @return Duty cycle array
     */
    public double[] get_dutyCycle_ES_Bm() {
        return this.dutyCycle_ES_Bm;
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
        temp = Double.doubleToLongBits(networks.hashCode());
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
        if (Double.doubleToLongBits(networks.hashCode()) != Double
                .doubleToLongBits(other.networks.hashCode())) {
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
