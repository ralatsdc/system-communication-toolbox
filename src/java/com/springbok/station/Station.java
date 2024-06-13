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

import com.springbok.antenna.Antenna;

/**
 * Describes a space or Earth station.
 *
 * @author raymondleclair
 */
public class Station {

    // Identifier for station
    private String stationId;

    // Transmit antenna gain, and pattern
    private Antenna transmitAntenna;

    // Receive antenna gain, pattern, and noise temperature
    private Antenna receiveAntenna;

    // Signal power, frequency, and requirement
    private Emission emission;


    /**
     * Constructs a Station.
     *
     * @param stationId Identifier for station
     */
    public Station(String stationId) {

        // Assign properties
        this.set_stationId(stationId);
    }

    /**
     * Constructs a Station.
     *
     * @param stationId Identifier for station
     * @param transmitAntenna Transmit antenna gain, and pattern
     * @param receiveAntenna Receive antenna gain, pattern, and noise temperature
     * @param emission Signal power, frequency, and requirement
     */
    public Station(String stationId, Antenna transmitAntenna, Antenna receiveAntenna, Emission emission) {
        // Assign properties
        this.set_stationId(stationId);
        this.set_transmitAntenna(transmitAntenna);
        this.set_receiveAntenna(receiveAntenna);
        this.set_emission(emission);
    }

    /**
     * Constructs a Station.
     */
    public Station() {}


    /**
     * Sets the identifier station.
     *
     * @param stationId Identifier for station
     */
    public void set_stationId(String stationId) {
        this.stationId = stationId;
    }

    /**
     * Gets the stationId.
     *
     * @return Identifier for station
     */
    public String get_stationId() {
        return stationId;
    }

    /**
     * Sets the transmit antenna.
     *
     * @param transmitAntenna Transmit antenna
     */
    public void set_transmitAntenna(Antenna transmitAntenna) {
        //TODO: uncomment when antenna will have pattern property and getter for this
        //if (transmitAntenna.getPattern() instanceof TransmitPattern) {
        //    throw new MException("Springbok:IllegalArgumentException",
        //            "The transmit antenna must have an transmit pattern");
        //}
        this.transmitAntenna = transmitAntenna;
    }

    /**
     * Gets the transmit antenna.
     *
     * @return Transmit antenna
     */
    public Antenna get_transmitAntenna() {
        return transmitAntenna;
    }

    /**
     * Sets the receive antenna.
     *
     * @param receiveAntenna Receive antenna
     */
    public void set_receiveAntenna(Antenna receiveAntenna) {
        //TODO: uncomment when antenna will have pattern property and getter for this
        //if (receiveAntenna.getPattern()instanceof ReceivePattern) {
        //    throw new MException("Springbok:IllegalArgumentException",
        //            "The receive antenna must have an receive pattern");
        //}
        this.receiveAntenna = receiveAntenna;
    }

    /**
     * Gets the receive antenna.
     *
     * @return Receive antenna
     */
    public Antenna get_receiveAntenna() {
        return receiveAntenna;
    }

    /**
     * Sets the emission.
     *
     * @param emission Signal power, frequency, and requirement
     */
    public void set_emission(Emission emission) {
        this.emission = emission;
    }

    /**
     * Getter for emission.
     *
     * @return Signal power, frequency, and requirement
     */
    public Emission get_emission() {
        return emission;
    }

    /**
     * Copies a Station.
     *
     * @return A new Station instance
     */
    public Station copy() {
        return new Station(this.stationId, this.transmitAntenna.copy(),
                this.receiveAntenna.copy(),
                this.emission.copy());
    }

    /**
     * Returns a hash code value for the object.
     *
     * @return A hash code value for this object
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        if (this.emission != null && this.stationId != null
                && this.transmitAntenna != null && this.receiveAntenna != null) {
            temp = Double.doubleToLongBits(stationId.hashCode());
            result = prime * result + (int) (temp ^ (temp >>> 32));
            temp = Double.doubleToLongBits(transmitAntenna.hashCode());
            result = prime * result + (int) (temp ^ (temp >>> 32));
            temp = Double.doubleToLongBits(receiveAntenna.hashCode());
            result = prime * result + (int) (temp ^ (temp >>> 32));
            temp = Double.doubleToLongBits(emission.hashCode());
            result = prime * result + (int) (temp ^ (temp >>> 32));
        }
        return result;
    }

    /**
     * Indicates whether some other object is equal to this one.
     *
     * @param obj the reference object with which to compare
     *
     * @return true if this object is the same as the obj argument; false otherwise
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof Station)) {
            return false;
        }
        Station other = (Station) obj;
        if (Double.doubleToLongBits(stationId.hashCode()) != Double
                .doubleToLongBits(other.stationId.hashCode())) {
            return false;
        }
        if (Double.doubleToLongBits(transmitAntenna.hashCode()) != Double
                .doubleToLongBits(other.transmitAntenna.hashCode())) {
            return false;
        }
        if (Double.doubleToLongBits(receiveAntenna.hashCode()) != Double
                .doubleToLongBits(other.receiveAntenna.hashCode())) {
            return false;
        }
        if (Double.doubleToLongBits(emission.hashCode()) != Double
                .doubleToLongBits(other.emission.hashCode())) {
            return false;
        }
        return true;
    }
}
