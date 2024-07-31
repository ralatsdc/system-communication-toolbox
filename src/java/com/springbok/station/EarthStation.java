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
import com.springbok.antenna.Antenna;
import com.springbok.twobody.Coordinates;
import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.MException;

import java.io.Serializable;

/**
 * Describes the position of a ground based sensor.
 *
 * @author Raymond LeClair
 */
@SuppressWarnings("serial")
public class EarthStation extends Station implements Serializable {

    // Describes a space or an Earth station beam.
    private Beam beam;
    // Geodetic Latitude [rad]
    protected double varphi;
    // Longitude [rad]
    protected double lambda;
    // Flag indicating whether to do multiplexing, or not
    private boolean doMultiplexing;
    // Date number at which the position vector occurs
    private ModJulianDate dNm;
    // Geocentric equatorial inertial position vector [er]
    private Matrix r_gei;

    // Geocentric equatorial rotating position [er]
    protected Matrix r_ger;

    /**
     * Constructs an EarthStation.
     *
     * @param sensorId Identifier
     * @param varphi   Geodetic Latitude [rad]
     * @param lambda   Longitude [rad]
     */
    public EarthStation(String sensorId, double varphi, double lambda) {

        // Fundamental values.
        super(sensorId);
        this.varphi = varphi;
        this.lambda = lambda;

        // Derived values.
        this.r_ger = compute_r_ger(null);
    }

    /**
     * Constructs an EarthStation.
     *
     * @param sensorId Identifier
     * @param varphi   Geodetic Latitude [rad]
     * @param lambda   Longitude [rad]
     */
    public EarthStation(String sensorId, Antenna transmitAntenna, Antenna receiveAntenna, Emission emission,
                        Beam beam, double varphi, double lambda, boolean doMultiplexing) {
        // Fundamental values.
        super(sensorId, transmitAntenna.copy(), receiveAntenna.copy(), emission.copy());
        this.varphi = varphi;
        this.lambda = lambda;
        this.set_beam(beam);
        this.doMultiplexing = doMultiplexing;

        // Derived values.
        this.r_ger = compute_r_ger(null);
    }

    /**
     * Constructs an EarthStation.
     */
    public EarthStation() {
        super();
    }

    /**
     * Copies an EarthStation.
     *
     * @return A new EarthStation instance
     */
    public EarthStation copy() {
        EarthStation that = new EarthStation(this.get_stationId(), this.get_transmitAntenna().copy(), this.get_receiveAntenna().copy(),
                this.get_emission().copy(), this.beam.copy(), this.varphi, this.lambda, this.doMultiplexing);
        that.compute_r_gei(that.dNm);

        return that;
    }

    /**
     * Sets geodetic latitude [rad].
     *
     * @param varphi The geodetic latitude [rad]
     */
    public void set_varphi(double varphi) {
        this.varphi = varphi;
        this.r_ger = compute_r_ger(null);
    }

    /**
     * Gets geodetic latitude [rad].
     *
     * @return The geodetic latitude [rad]
     */
    public double get_varphi() {
        return varphi;
    }

    /**
     * Sets longitude [rad]
     *
     * @param lambda The longitude [rad]
     */
    public void set_lambda(double lambda) {
        this.lambda = lambda;
        this.r_ger = compute_r_ger(null);
    }

    /**
     * Gets longitude [rad]
     *
     * @return The longitude [rad]
     */
    public double get_lambda() {
        return lambda;
    }

    /**
     * Sets the Beam object for the Earth station.
     *
     * @param beam The Beam object to set
     * @throws MException if the multiplicity of the Beam object is not equal to 1
     */
    public void set_beam(Beam beam) {
        if (beam.get_multiplicity() != 1) {
            throw new MException("Springbok:IllegalArgumentException",
                    "An Earth station beam must have multiplicity one");
        }
        this.beam = beam;
        this.beam.assign(this.doMultiplexing);
    }

    /**
     * Gets the beam object.
     *
     * @return The beam object
     */
    public Beam get_beam() {
        return beam;
    }

    /**
     * Sets the flag indicating whether to perform multiplexing or not.
     *
     * @param bool Flag indicating if to perform multiplexing, or not
     */
    public void set_doMultiplexing(boolean bool) {
        doMultiplexing = bool;
    }

    /**
     * Checks if multiplexing is enabled.
     *
     * @return true if multiplexing is enabled, false otherwise.
     */
    public boolean doMultiplexing() {
        return this.doMultiplexing;
    }

    /**
     * Computes geocentric equatorial inertial position vector.
     *
     * @param dNm Date number at which the position vector occurs
     * @return Geocentric equatorial inertial position vector [er]
     */
    public Matrix compute_r_gei(ModJulianDate dNm) {
        if (dNm != null && this.dNm != null && !dNm.equals(this.dNm)) {
            this.dNm = dNm;
            this.r_gei = Coordinates.ger2gei(this.r_ger, dNm);
        }
        return this.r_gei;
    }

    /**
     * Computes the geocentric equatorial rotating position vector.
     *
     * @param dNm Date number at which the position vector occurs
     * @return Geocentric equatorial rotating position vector [er]
     */
    public Matrix compute_r_ger(ModJulianDate dNm) {
        if (this.r_ger == null) {
            double N = 1.0 / (Math.sqrt(1 - EarthConstants.f * (2 - EarthConstants.f) * Math.pow(Math.sin(varphi), 2)));
            double h = 0.0;
            double[][] elements = {{(N + h) * Math.cos(varphi) * Math.cos(lambda)},
                    {(N + h) * Math.cos(varphi) * Math.sin(lambda)},
                    {(Math.pow(1.0 - EarthConstants.f, 2) * N + h) * Math.sin(varphi)}};
            this.r_ger = new Matrix(elements);
        }
        return this.r_ger;
    }
}
