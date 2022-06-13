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
package com.springbok.station;

import com.springbok.utility.MException;

/**
 * Describes a space or an Earth station beam.
 */
public class Beam {

    // Beam name
    private String name;

    // Maximum number of divisions allowed
    private int multiplicity;

    // Duty cycle
    private double dutyCycle;

    // Flag indicating if the beam is available, or not
    private boolean isAvailable;

    // Flag indicating if the beam is multiplexed, or not
    private boolean isMultiplexed;

    // Number of divisions in use
    private int divisions;

    public String getName() {
        return name;
    }

    public int getMultiplicity() {
        return multiplicity;
    }

    public double getDutyCycle() {
        return dutyCycle;
    }

    public boolean isAvailable() {
        return isAvailable;
    }

    public boolean isMultiplexed() {
        return isMultiplexed;
    }

    public int getDivisions() {
        return divisions;
    }

    /**
     * Constructs a Beam.
     *
     * @param name Beam name
     * @param multiplicity Maximum number of divisions allowed
     * @param dutyCycle Duty cycle [%]
     */
    public Beam(String name, int multiplicity, double dutyCycle) {

        // Assign properties
        this.set_name(name);
        this.set_multiplicity(multiplicity);
        this.set_dutyCycle(dutyCycle);

        // Derive properties
        this.isAvailable = true;
        this.isMultiplexed = false;
        this.divisions = 0;
    }

    /**
     * Copies a Beam.
     *
     * @return A new Beam instance
     */
    public Beam copy() {
        return new Beam(this.name, this.multiplicity, this.dutyCycle);
    }

    /**
     * Sets beam name.
     *
     * @param name Beam name
     */
    public void set_name(String name) {
        this.name = name;
    }

    /**
     * Sets maximum number of divisions allowed.
     *
     * @param multiplicity Maximum number of divisions allowed
     */
    public void set_multiplicity(int multiplicity) {
        this.multiplicity = multiplicity;
    }

    /**
     * Sets duty cycle [%].
     *
     * @param dutyCycle Duty cycle [%]
     */
    public void set_dutyCycle(double dutyCycle) {
        if (dutyCycle < 0 || dutyCycle > 100) {
            throw new MException("Springbok:IllegalArgumentException",
                    "Duty cycle must be between 0 and 100");
        }
        this.dutyCycle = dutyCycle;
    }

    /**
     * Sets flag indicating if the beam is available, or not.
     *
     * @param isAvailable Flag indicating if the beam is available, or not
     */
    public void set_isAvailable(boolean isAvailable) {
        this.isAvailable = isAvailable;
    }

    /**
     * Sets flag indicating if the beam is multiplexed, or not.
     *
     * @param isMultiplexed Flag indicating if the beam is multiplexed or not
     */
    public void set_isMultiplexed(boolean isMultiplexed) {
        this.isMultiplexed = isMultiplexed;
    }

    /**
     * Sets number of divisions in use.
     *
     * @param divisions Number of divisions in use
     */
    public void set_divisions(int divisions) {
        if (divisions < 0) {
            throw new MException("Springbok:IllegalArgumentException",
                    "Divisions must be a non-negative integer");
        }
        this.divisions = divisions;
    }

    /**
     * Assign this beam, if available. On construction the beam is
     * available, and not multiplexed.  When the beam is first
     * assigned, the beam becomes unavailable if it is not multiplexed,
     * or, if it becomes multiplexed, the multiplicity is
     * one. Subsequently, when the beam is next assigned, the beam must
     * be multiplexed, and so it becomes unavailable if the divisions
     * equal the multiplicity.
     *
     * @param doMultiplexing Flag indicating whether to do multiplexing, or not
     *
     * @return Flag indicating whether the beam was assigned, or not.
     */
    public boolean assign(boolean doMultiplexing) {
        if (!this.isAvailable) {

            return false;

        } else if (this.divisions == 0) {

            // Available, and never assigned
            this.divisions = this.divisions + 1;
            if (!doMultiplexing) {

                // Not multiplexed
                this.isAvailable = false;

            } else {

                // Multiplexed
                this.isMultiplexed = true;
                if (!(this.divisions < this.multiplicity)) {

                    // No divisions remaining
                    this.isAvailable = false;

                }
            }
            return true;
        } else {         // Available, assigned before, so must be multiplexed

            if (doMultiplexing != this.isMultiplexed) {

                // Multiplexing disagrees
                return false;

            } else {

                // Multiplexing agrees
                this.divisions = this.divisions + 1;
                if (!(this.divisions < this.multiplicity)) {

                    // No divisions remaining
                    this.isAvailable = false;

                }
                return true;
            }
        }
    }

    /**
     * Reset derived properties to initial values.
     */
    public void reset() {
        this.isAvailable = true;
        this.isMultiplexed = false;
        this.divisions = 0;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(multiplicity);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(dutyCycle);
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
        if (!(obj instanceof Beam)) {
            return false;
        }
        Beam other = (Beam) obj;
        if (!name.equals(other.name)) {
            return false;
        }
        if (Double.doubleToLongBits(multiplicity) != Double
                .doubleToLongBits(other.multiplicity)) {
            return false;
        }
        if (Double.doubleToLongBits(dutyCycle) != Double
                .doubleToLongBits(other.dutyCycle)) {
            return false;
        }
        return true;
    }
}
