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
package com.springbok.antenna;

import java.util.Map;

import com.springbok.pattern.EarthPattern;

/**
 * Describes an Earth station antenna.
 * 
 * @author raymondleclair
 */
public class EarthStationAntenna extends Antenna {

	// Antenna pattern identifier
	private long pattern_id;

	// Antenna pattern
	private EarthPattern pattern;

	// Gain function options
	private Map options;

	/**
	 * Constructs an Earth station antenna.
	 *
	 * @param name Antenna name
	 * @param gain Antenna gain [dB]
	 * @param pattern_id Antenna pattern identifier
	 * @param pattern Antenna pattern
	 */
	public EarthStationAntenna(String name, double gain, long pattern_id, EarthPattern pattern) {

		// Assign properties
		super(name, gain);
		this.set_pattern_id(pattern_id);
		this.set_pattern(pattern);
		this.set_options(null);
	}

	/**
	 * Constructs an Earth station antenna.
	 *
	 * @param name Antenna name
	 * @param gain Antenna gain [dB]
	 * @param pattern_id Antenna pattern identifier
	 * @param pattern Antenna pattern
	 * @param options Gain function options
	 */
	public EarthStationAntenna(String name, double gain, long pattern_id, EarthPattern pattern, Map options) {

		// Assign properties
		super(name, gain);
		this.set_pattern_id(pattern_id);
		this.set_pattern(pattern);
		this.set_options(options);
	}

	/**
	 * Constructs an Earth station antenna.
	 *
	 * @param name Antenna name
	 * @param gain Antenna gain [dB]
	 * @param pattern_id Antenna pattern identifier
	 * @param pattern Antenna pattern
	 * @param noise_t Antenna noise temperature [K]
	 */
	public EarthStationAntenna(String name, double gain, long pattern_id, EarthPattern pattern, double noise_t) {

		// Assign properties
		super(name, gain, noise_t);
		this.set_pattern_id(pattern_id);
		this.set_pattern(pattern);
		this.set_options(null);
	}

	/**
	 * Constructs an Earth station antenna.
	 *
	 * @param name Antenna name
	 * @param gain Antenna gain [dB]
	 * @param pattern_id Antenna pattern identifier
	 * @param pattern Antenna pattern
	 * @param noise_t Antenna noise temperature [K]
	 * @param options Gain function options
	 */
	public EarthStationAntenna(String name, double gain, long pattern_id, EarthPattern pattern, double noise_t,
			Map options) {

		// Assign properties
		super(name, gain, noise_t);
		this.set_pattern_id(pattern_id);
		this.set_pattern(pattern);
		this.set_options(options);
	}

	/**
	 * Copies an Earth station antenna.
	 * 
	 * @return A new EarthStation instance
	 */
	public EarthStationAntenna copy() {
		EarthStationAntenna that = new EarthStationAntenna(this.get_name(), this.get_gain(), this.get_pattern_id(),
				this.pattern.copy(), this.get_noise_t());
		that.set_options(this.options);
		return that;
	}

	/**
	 * Sets antenna pattern identifier.
	 *
	 * @param pattern_id Antenna pattern identifier
	 */
	public void set_pattern_id(long pattern_id) {
		this.pattern_id = pattern_id;
	}

	/**
	 * Gets antenna pattern identifier.
	 *
	 * @return Antenna pattern identifier
	 */
	public long get_pattern_id() {
		return this.pattern_id;
	}

	/**
	 * Sets pattern
	 * 
	 * @param pattern An Earth antenna pattern
	 */
	public void set_pattern(EarthPattern pattern) {
		this.pattern = pattern;
	}

	/**
	 * Gets pattern
	 * 
	 * @return An Earth antenna pattern
	 */
	public EarthPattern get_pattern() {
		return this.pattern;
	}

	/**
	 * Sets options
	 * 
	 * @param options Gain function options
	 */
	public void set_options(Map options) {
		this.options = options;
	}

	/**
	 * Gets options
	 * 
	 * @return Gain function options
	 */
	public Map get_options() {
		return this.options;
	}
}
