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

import java.io.Serializable;
import Jama.Matrix;

import com.springbok.antenna.Antenna;
import com.springbok.twobody.Coordinates;
import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.MException;

/**
 * Describes the position of a ground based sensor.
 * 
 * @author Raymond LeClair
 */
@SuppressWarnings("serial")
public class EarthStation extends Station implements Serializable {

	private Beam beam;
	/** Geodetic Latitude [rad] */
	protected double varphi;
	/** Longitude [rad] */
	protected double lambda;
	//Flag indicating whether to do multiplexing, or not
	private boolean doMultiplexing;
	// Date number at which the position vector occurs
    private ModJulianDate dNm;
    // Geocentric equatorial inertial position vector [er]
    private Matrix r_gei;

	/** Geocentric equatorial rotating position [er] */
	protected Matrix R_ger;

	/**
	 * Constructs an EarthStation.
	 *
	 * @param sensorId Identifier
	 * @param varphi Geodetic Latitude [rad]
	 * @param lambda Longitude [rad]
	 */
	public EarthStation(String sensorId, double varphi, double lambda) {

		// Fundamental values.
		super(sensorId);
		this.varphi = varphi;
		this.lambda = lambda;

		// Derived values.
		this.R_ger = compute_R_ger();
	}

	/**
	 * Constructs an EarthStation.
	 * 
	 * @param sensorId Identifier
	 * @param varphi Geodetic Latitude [rad]
	 * @param lambda Longitude [rad]
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
		this.R_ger = compute_R_ger();
	}

	public EarthStation() {
		super();
	}

	/**
	 * Sets geodetic latitude [rad].
	 * 
	 * @param varphi The geodetic latitude [rad]
	 */
	public void set_varphi(double varphi) {
		this.varphi = varphi;
		this.R_ger = compute_R_ger();
	}

	public Beam getBeam() {
		return beam;
	}

	public void set_beam(Beam beam) {
		if (beam.getMultiplicity() != 1) {
	        throw new MException("Springbok:IllegalArgumentException",
                    "An Earth station beam must have multiplicity one");
        }
		this.beam = beam;
	    this.beam.assign(this.doMultiplexing);
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
	 * 
	 */
	public void set_lambda(double lambda) {
		this.lambda = lambda;
		this.R_ger = compute_R_ger();
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
	 * Gets geocentric equatorial rotating position [er].
	 * 
	 * @return The geocentric equatorial rotating position [er]
	 */
	public Matrix get_R_ger() {
		return R_ger;
	}

	/**
	 * Computes geocentric equatorial inertial position vector (MG-2.50).
	 * 
	 * @param dNm MJD calendar date at which the position vector occurs
	 *
	 * @return equatorial inertial position vector [er]
	 */
	public Matrix r_gei(ModJulianDate dNm) {
		Matrix r_gei = Coordinates.ger2gei(R_ger, dNm);
		// System.out.println("r_gei"); r_gei.print(16, 8);
		return r_gei;
	}
	
	/**
	 * Computes the geocentric equatorial rotating position vector. (MG-5.83)
	 * 
	 * @return The geocentric equatorial rotating position [er]
	 */
	private Matrix compute_R_ger() {
		double N = 1.0 / (Math.sqrt(1 - EarthConstants.f * (2 - EarthConstants.f) * Math.pow(Math.sin(varphi), 2)));
		double h = 0.0;
		double[][] elements = { { (N + h) * Math.cos(varphi) * Math.cos(lambda) },
				{ (N + h) * Math.cos(varphi) * Math.sin(lambda) },
				{ (Math.pow(1.0 - EarthConstants.f, 2) * N + h) * Math.sin(varphi) } };
		Matrix R_ger = new Matrix(elements);
		// System.out.println("R_ger"); matrix.print(16, 8);
		return R_ger;
	}

	public EarthStation copy() {
	    EarthStation that = new EarthStation(this.getStationId(), this.getTransmitAntenna().copy(), this.getReceiveAntenna().copy(),
                this.getEmission().copy(), this.beam.copy(), this.varphi, this.lambda, this.doMultiplexing);
	    that.compute_r_gei(that.dNm);

	    return that;
    }

    public Matrix compute_r_gei(ModJulianDate dNm) {
        if (dNm != null && this.dNm != null && !dNm.equals(this.dNm)) {
            this.dNm = dNm;
            this.r_gei = Coordinates.ger2gei(this.R_ger, dNm);
        }

        return this.r_gei;
    }

    public void set_doMultiplexing(boolean value) {
		doMultiplexing = value;
	}

	public boolean doMultiplexing() {
		return this.doMultiplexing;
	}
}
