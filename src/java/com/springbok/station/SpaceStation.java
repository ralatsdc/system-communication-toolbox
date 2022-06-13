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

import Jama.Matrix;
import com.celestrak.sgp4v.ObjectDecayed;
import com.springbok.antenna.Antenna;
import com.springbok.twobody.Coordinates;
import com.springbok.twobody.ModJulianDate;
import com.springbok.twobody.Orbit;

import java.util.Arrays;

/**
 * Describes a space station
 */
public class SpaceStation extends Station {

    // Beam array
    private Beam[] beams;

    // A satellite orbit
    private Orbit orbit;

    // Date number at which the inertial position vector occurs
    private ModJulianDate dNm_i;

    // Geocentric equatorial inertial position vector [er]
    private Matrix r_gei;

    // Date number at which the rotation position vector occurs
    private ModJulianDate dNm_r;

    // Geocentric equatorial rotating position vector [er]
    private Matrix r_ger;

    // Flag indicating if the station is available, or not
    private boolean isAvailable;

    public Beam[] getBeams() {
        return beams;
    }

    public Orbit getOrbit() {
        return orbit;
    }

    public ModJulianDate getdNm_i() {
        return dNm_i;
    }

    public Matrix getR_gei() {
        return r_gei;
    }

    public ModJulianDate getdNm_r() {
        return dNm_r;
    }

    public Matrix getR_ger() {
        return r_ger;
    }

    public boolean isAvailable() {
        return isAvailable;
    }

    /**
     * Constructs a SpaceStation.
     *
     * @param stationId Identifier for station
     * @param transmitAntenna Transmit antenna gain, and pattern
     * @param receiveAntenna Receive antenna gain, pattern, and noise temperature
     * @param emission Signal power, frequency, and requirement
     * @param beams Beam array
     * @param orbit A satellite orbit
     */
    public SpaceStation(String stationId, Antenna transmitAntenna, Antenna receiveAntenna, Emission emission, Beam[] beams,
                        Orbit orbit) {
        super(stationId, transmitAntenna, receiveAntenna, emission);

        // Assign properties
        this.set_transmitAntenna(transmitAntenna);
        this.set_receiveAntenna(receiveAntenna);
        this.set_beams(beams);
        this.set_orbit(orbit);

        // Derive properties
        this.isAvailable = true;
    }

    public SpaceStation(){
        super();
    }

    /**
     * Constructs a SpaceStation.
     *
     * @return A new SpaceStation instance
     */
    public SpaceStation copy() {
        Beam[] beams = new Beam[this.beams.length];
        for (int i = 0; i < this.beams.length; i++) {
            beams[i] = this.beams[i].copy();
        }
        SpaceStation that = new SpaceStation(this.getStationId(), this.getTransmitAntenna().copy(), this.getReceiveAntenna().copy(),
                this.getEmission().copy(), beams, this.orbit.copy());
        that.set_isAvailable(this.isAvailable);
        try {
            that.compute_r_ger(this.dNm_r);
        } catch (ObjectDecayed objectDecayed) {
            objectDecayed.printStackTrace();
        }
        return that;
    }

    /**
     * Sets beam array.
     *
     * @param beams Beam array
     */
    public void set_beams(Beam[] beams) {
        this.beams = beams;
    }

    /**
     * Set the satellite orbit
     *
     * @param orbit The satellite orbit
     */
    public void set_orbit(Orbit orbit) {
        this.orbit = orbit;
    }

    /**
     * Sets flag indicating if the station is available, or not.
     *
     * @param isAvailable Flag indicating if the station is available, or not
     */
    public void set_isAvailable(boolean isAvailable) {
        this.isAvailable = isAvailable;
    }

    /**
     * Assign this station by assigning the first available beam.
     *
     * @param doMultiplexing Flag indicating whether to do
     * @param multiplexing, or not
     *
     * @return The assigned beam, or an empty array, if no beam
     */
    public Beam assign(boolean doMultiplexing) {
        if (this.isAvailable) {
            // Consider each beam
            for (Beam beam : beams) {
                // Assign the first available beam
                boolean isAsigned = beam.assign(doMultiplexing);
                if (isAsigned) {
                    // This station remains available as long as it"s last
                    // beam remains available
                    this.isAvailable = beams[beams.length-1].isAvailable();
                    return beam;
                }
            }
        }
        return null;
    }

    /**
     * Computes geocentric equatorial inertial position vector.
     *
     * @param dNm Date number at which the position vector occurs
     *
     * @return Geocentric equatorial inertial position vector [er]
     */
    public Matrix compute_r_gei(ModJulianDate dNm) throws ObjectDecayed {
        if (!dNm.equals(this.dNm_i)) {
            this.dNm_i = dNm;
            this.r_gei = this.orbit.r_gei(dNm);
        }
        return this.r_gei;
    }

    /**
     * Computes the geocentric equatorial rotating position vector.
     *
     * @param dNm Date number at which the position vector occurs
     *
     * @return Geocentric equatorial rotating position vector [er]
     */
    public Matrix compute_r_ger(ModJulianDate dNm) throws ObjectDecayed {
        if (dNm != null && this.dNm_r != null && !dNm.equals(this.dNm_r)) {
            this.dNm_r = dNm;
            this.r_ger = Coordinates.gei2ger(this.compute_r_gei(dNm), dNm);
        }
        return this.r_ger;
    }

    /**
     * Reset derived properties of associated beams and this to
     * initial values.
     */
    public void reset() {
        for (Beam beam : beams) {
            beam.reset();
        }

        this.dNm_i = null;
        this.r_gei = null;
        this.dNm_r = null;
        this.r_ger = null;
        this.isAvailable = true;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(Arrays.hashCode(beams));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(orbit.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(dNm_i.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(r_gei.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(dNm_r.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(r_ger.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(isAvailable ? 1 : 0);
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
        if (!(obj instanceof SpaceStation)) {
            return false;
        }
        SpaceStation other = (SpaceStation) obj;
        if (!Arrays.equals(beams, other.beams)) {
            return false;
        }
        if (orbit.equals(other.orbit)) {
            return false;
        }
        if (dNm_i.equals(other.dNm_i)) {
            return false;
        }
        if (r_gei.equals(other.r_gei)) {
            return false;
        }
        if (dNm_r.equals(other.dNm_r)) {
            return false;
        }
        if (r_ger.equals(other.r_ger)) {
            return false;
        }
        if (isAvailable != other.isAvailable) {
            return false;
        }

        return true;
    }
}
