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

/**
 * Models propagation losses
 */

public class Propagation {

    // Speed of light [m/s]
    public static final double c = 299792458;
    //The Boltzmann constant [m^2 * kg] / [s^2 K]
    public static final double k = 10 * Math.log10(1.38064852e-23);

    /**
     * Computes free space loss.
     *
     * @param frequency Frequency [MHz]
     * @param distance  Distance [km]
     * @return Free space loss [dB]
     */
    public static double computeFSL(double frequency, double distance) {
        double lambda = c / (frequency * Math.pow(10, 6));
        return -20 * Math.log10(lambda / (4 * Math.PI * distance * Math.pow(10, 3)));
    }

    /**
     * Computes spreading loss.
     * <p>
     * distance - Distance [km]
     *
     * @param SL Spreading loss [dB/m^2]
     */
    public static double computeSL(double distance) {
        return 10 * Math.log10(4 * Math.PI * Math.pow((distance * 1000), 2));
    }

}
