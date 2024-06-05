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

import com.springbok.pattern.SpacePattern;

/**
 * Describes a space station antenna.
 * TODO: Use a GIMS pattern
 *
 * @author raymondleclair
 */
public class SpaceStationAntenna extends Antenna {

    // Antenna pattern identifier
    private long pattern_id;
    // Antenna pattern
    private SpacePattern pattern;
    // Gain function options
    private Map options;

    /**
     * Constructs a space station antenna.
     *
     * @param name       Antenna name
     * @param gain       Antenna gain [dB]
     * @param pattern_id Antenna pattern identifier
     * @param pattern    Antenna pattern
     */
    public SpaceStationAntenna(String name, double gain, long pattern_id, SpacePattern pattern) {

        // Assign properties
        super(name, gain);
        this.set_pattern_id(pattern_id);
        this.set_pattern(pattern);
        this.set_options(null);
    }

    /**
     * Constructs an Space station antenna.
     *
     * @param name       Antenna name
     * @param gain       Antenna gain [dB]
     * @param pattern_id Antenna pattern identifier
     * @param pattern    Antenna pattern
     * @param options    Gain function options
     */
    public SpaceStationAntenna(String name, double gain, long pattern_id, SpacePattern pattern, Map options) {

        // Assign properties
        super(name, gain);
        this.set_pattern_id(pattern_id);
        this.set_pattern(pattern);
        this.set_options(options);
    }

    /**
     * Constructs a space station antenna.
     *
     * @param name       Antenna name
     * @param gain       Antenna gain [dB]
     * @param pattern_id Antenna pattern identifier
     * @param pattern    Antenna pattern
     * @param noise_t    Antenna noise temperature [K]
     */
    public SpaceStationAntenna(String name, double gain, long pattern_id, SpacePattern pattern, double noise_t) {

        // Assign properties
        super(name, gain, noise_t);
        set_pattern_id(pattern_id);
        set_pattern(pattern);
        set_options(null);
    }

    /**
     * Constructs an Space station antenna.
     *
     * @param name       Antenna name
     * @param gain       Antenna gain [dB]
     * @param pattern_id Antenna pattern identifier
     * @param pattern    Antenna pattern
     * @param noise_t    Antenna noise temperature [K]
     * @param options    Gain function options
     */
    public SpaceStationAntenna(String name, double gain, long pattern_id, SpacePattern pattern, double noise_t,
                               Map options) {

        // Assign properties
        super(name, gain, noise_t);
        this.set_pattern_id(pattern_id);
        this.set_pattern(pattern);
        this.set_options(options);
    }

    /**
     * Copies an Space station antenna.
     *
     * @return A new SpaceStation instance
     */
    public SpaceStationAntenna copy() {
        SpaceStationAntenna that = new SpaceStationAntenna(this.get_name(), this.get_gain(), this.get_pattern_id(), this.get_pattern().copy(), this.get_noise_t(), this.get_options());
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
        return pattern_id;
    }

    /**
     * Sets pattern
     *
     * @param pattern An Space antenna pattern
     */
    public void set_pattern(SpacePattern pattern) {
        this.pattern = pattern;
    }

    /**
     * Gets pattern
     *
     * @return An Space antenna pattern
     */
    public SpacePattern get_pattern() {
        return pattern;
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
        return options;
    }
}
