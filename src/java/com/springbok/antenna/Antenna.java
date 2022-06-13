/* Copyright (C) 2022 Springbok LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
package com.springbok.antenna;

/**
 * Describes a space or an Earth station antenna.
 * 
 * @author raymondleclair
 */
public class Antenna {

	/** Antenna name */
	private String name;
	/** Antenna gain [dB] */
	private double gain;
	/** Antenna noise temperature [K] */
	private double noise_t;

	/**
	 * Constructs an Antenna.
	 * 
	 * @param name Antenna name
	 * @param gain Antenna gain [dB]
	 */
	public Antenna(String name, double gain) {

		// Assign properties
		this.set_name(name);
		this.set_gain(gain);
		this.set_noise_t(Double.NaN);
	}

	/**
	 * Constructs an Antenna.
	 * 
	 * @param name Antenna name
	 * @param gain Antenna gain [dB]
	 * @param noise_t Antenna noise temperature [K]
	 */
	public Antenna(String name, double gain, double noise_t) {

		// Assign properties
		this.set_name(name);
		this.set_gain(gain);
		this.set_noise_t(noise_t);
	}

	/**
	 * Copies an Antenna.
	 *
	 * 
	 * @return A new Antenna instance
	 */
	public Antenna copy() {
		return new Antenna(this.name, this.gain, this.noise_t);
	}

	/**
	 * Sets antenna name.
	 * 
	 * @param name Antenna name
	 */
	public void set_name(String name) {
		this.name = name;
	}

	/**
	 * Gets antenna name.
	 * 
	 * @return Antenna name
	 */
	public String get_name() {
		return this.name;
	}

	/**
	 * Sets antenna gain [dB].
	 *
	 * @param gain Antenna gain [dB]
	 */
	public void set_gain(double gain) {
		this.gain = gain;
	}

	/**
	 * Gets antenna gain [dB].
	 * 
	 * @return Antenna gain [dB]
	 */
	public double get_gain() {
		return this.gain;
	}

	/**
	 * Sets antenna noise temperature [K].
	 * 
	 * @param noise_t Antenna noise temperature [K]
	 */
	public void set_noise_t(double noise_t) {
		this.noise_t = noise_t;
	}

	/**
	 * Gets antenna noise temperature [K].
	 * 
	 * @return Antenna noise temperature [K]
	 */
	public double get_noise_t() {
		return this.noise_t;
	}

	// TODO: Add antenna pattern gain function that accepts optional arguments
}
