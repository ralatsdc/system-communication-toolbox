/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.antenna;

import com.springbok.pattern.SpacePattern;

import java.util.HashMap;
import java.util.Map;

/**
 * Describes a space station antenna.
 * TODO: Use a GIMS pattern
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
     * @param name Antenna name
     * @param gain Antenna gain [dB]
     * @param pattern_id Antenna pattern identifier
     * @param pattern Antenna pattern
     * @param noise_t Antenna noise temperature [K] (optional, default is NaN)
     */
    public SpaceStationAntenna(String name, double gain, long pattern_id, SpacePattern pattern, double noise_t) {
        super(name, gain, noise_t);

        set_pattern_id(pattern_id);
        set_pattern(pattern);
        set_options(new HashMap());
    }

    public SpaceStationAntenna(String name, double gain, long pattern_id, SpacePattern pattern) {
        this(name, gain, pattern_id, pattern, Double.NaN);
    }

    public long get_pattern_id() {
        return pattern_id;
    }

    public void set_pattern_id(long pattern_id) {
        this.pattern_id = pattern_id;
    }

    public SpacePattern get_pattern() {
        return pattern;
    }

    public void set_pattern(SpacePattern pattern) {
        this.pattern = pattern;
    }

    public Map get_options() {
        return options;
    }

    public void set_options(Map options) {
        this.options = options;
    }

    public SpaceStationAntenna copy() {
        SpaceStationAntenna that = new SpaceStationAntenna(
                get_name(),
                get_gain(),
                get_pattern_id(),
                get_pattern().copy(),
                get_noise_t()
        );
        that.set_options(get_options());
        return that;
    }
}