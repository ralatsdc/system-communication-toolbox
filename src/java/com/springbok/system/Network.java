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

import com.springbok.station.Beam;
import com.springbok.station.EarthStation;
import com.springbok.station.SpaceStation;
import com.springbok.utility.MException;
import com.springbok.utility.SException;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * Describes a network of two stations, typically a space and an
 */
public class Network {

    // An Earth station
    private EarthStation earthStation;
    // A space station
    private SpaceStation spaceStation;
    // A space station beam
    private Beam spaceStationBeam;
    // Propagation loss models to apply
    private Object[] losses;

    // Link direction: 'up', 'down', or 'both' (the default)
    private String type;
    // Flag to check input arguments, or not (check by default)
    private boolean doCheck;
    // An Earth station beam
    private Beam earthStationBeam;
    // An up link
    private Link up_Link;
    // A down link
    private Link dn_Link;

    /**
     * Constructs a Network.
     */
    public Network() {
        this.type = "both";
        this.doCheck = true;
        this.up_Link = new Link();
        this.dn_Link = new Link();
    }

    /**
     * Constructs a Network.
     *
     * @param earthStation     An Earth station
     * @param spaceStation     A space station
     * @param spaceStationBeam A space station beam
     * @param losses           Propagation loss models to apply
     * TODO: Document options
     * @ param Type             Link direction: 'up', 'down', or 'both' (the
     *                         default)
     * @ param DoCheck          Flag for checking input values (default is 1)
     */
    public Network(EarthStation earthStation, SpaceStation spaceStation, Beam spaceStationBeam, Object[] losses, Map options) {
        // Parse variable input arguments
        this.set_type((String) options.getOrDefault("Type", "both"));
        this.set_doCheck((boolean) options.getOrDefault("DoCheck", true));

        // Assign properties
        this.set_earthStation(earthStation);
        this.set_spaceStation(spaceStation);
        this.set_spaceStationBeam(spaceStationBeam);
        this.set_losses(losses);

        // Derive properties
        this.up_Link = new Link();
        this.up_Link.set_doCheck(this.doCheck);
        this.dn_Link = new Link();
        this.dn_Link.set_doCheck(this.doCheck);
        this.set_links();
    }

    /**
     * Copies a Network.
     *
     * @return A new Network instance
     */
    public Network copy() {
        Network that;
        if (!this.isEmpty()) {
            Map options = new HashMap();
            options.put("type", this.type);
            options.put("doCheck", this.doCheck);
            that = new Network(this.earthStation.copy(), this.spaceStation.copy(),
                    this.spaceStationBeam.copy(), this.losses, options);
        } else {
            that = new Network();
        }
        return that;
    }

    /**
     * Sets the Earth station.
     *
     * @param earthStation The Earth station
     */
    public void set_earthStation(EarthStation earthStation) {
        this.earthStation = earthStation;
    }

    /**
     * Gets the Earth station.
     *
     * @return earthStation The Earth station
     */
    public EarthStation get_earthStation() {
        return this.earthStation;
    }

    /**
     * Gets the Earth station beam.
     *
     * @return The Earth station beam
     */
    public Beam get_earthStationBeam() {
        return this.earthStationBeam;
    }

    /**
     * Gets the up link.
     *
     * @return The up link
     */
    public Link get_up_Link() {
        return this.up_Link;
    }

    /**
     * Gets the down link.
     *
     * @return The down link
     */
    public Link get_dn_Link() {
        return this.dn_Link;
    }

    /**
     * Set the space station.
     *
     * @param spaceStation The space station
     */
    public void set_spaceStation(SpaceStation spaceStation) {
        this.spaceStation = spaceStation;
    }

    /**
     * Get the space station.
     *
     * @return The space station
     */
    public SpaceStation get_spaceStation() {
        return this.spaceStation;
    }

    /**
     * Sets space station beam.
     *
     * @param spaceStationBeam A space station beam
     */
    public void set_spaceStationBeam(Beam spaceStationBeam) {
        if (this.doCheck && !Arrays.asList(this.spaceStation.get_beams()).contains(spaceStationBeam)) {
            throw new MException("Springbok:IllegalArgumentException",
                    "The Beam must be a member of the space station beam array");
        }
        this.spaceStationBeam = spaceStationBeam;
    }

    /**
     * Get the space station beam.
     *
     * @return The space station beam
     */
    public Beam get_spaceStationBeam() {
        return this.spaceStationBeam;
    }

    /**
     * Sets propagation loss models to apply.
     *
     * @param losses Propagation loss models to apply
     */
    public void set_losses(Object[] losses) {
        this.losses = losses;
    }

    /**
     * Gets propagation loss models to apply.
     *
     * @return losses Propagation loss models to apply
     */
    public Object[] get_losses() {
        return this.losses;
    }

    /**
     * Sets link direction: 'up', 'down', or 'both' (the default).
     *
     * @param type Link direction: 'up', 'down', or 'both' (the
     *             default)
     */
    public void set_type(String type) {
        if (this.doCheck && !Arrays.asList("up", "down", "both").contains(type)) {
            throw new MException("Springbok:IllegalArgumentException",
                    "Input must be 'up', 'down', or 'both' (the default)");
        }
        this.type = type;
    }

    /**
     * Gets link direction: 'up', 'down', or 'both' (the default).
     *
     * @return the Link direction: 'up', 'down', or 'both' (the
     *             default)
     */
    public String get_type() {
        return this.type;
    }

    /**
     * Sets flag to check input arguments, or not.
     *
     * @param doCheck Flag to check input arguments, or not
     */
    public void set_doCheck(boolean doCheck) {
        this.doCheck = doCheck;
    }

    /**
     * Gets flag to check input arguments, or not.
     *
     * @return Flag to check input arguments, or not
     */
    public boolean doCheck() {
        return this.doCheck;
    }

    /**
     * Constructs links
     */
    public void set_links() {
        this.earthStationBeam = this.earthStation.get_beam();
        switch (this.type) {
            case "up":
                this.up_Link.set_transmitStation(this.earthStation);
                this.up_Link.set_transmitStationBeam(this.earthStationBeam);
                this.up_Link.set_receiveStation(this.spaceStation);
                this.up_Link.set_losses(this.losses);
                break;
            case "down":
                this.dn_Link.set_transmitStation(this.spaceStation);
                this.dn_Link.set_transmitStationBeam(this.spaceStationBeam);
                this.dn_Link.set_receiveStation(this.earthStation);
                this.dn_Link.set_losses(this.losses);
                break;
            case "both":
                this.up_Link.set_transmitStation(this.earthStation);
                this.up_Link.set_transmitStationBeam(this.earthStationBeam);
                this.up_Link.set_receiveStation(this.spaceStation);
                this.up_Link.set_losses(this.losses);
                this.dn_Link.set_transmitStation(this.spaceStation);
                this.dn_Link.set_transmitStationBeam(this.spaceStationBeam);
                this.dn_Link.set_receiveStation(this.earthStation);
                this.dn_Link.set_losses(this.losses);
                break;
            default:
                throw new SException("Springbok:InvalidInput", String.format("Link type %s invalid", type), 0);
        }
    }

    /**
     * Determines if Network properties are empty, or not.
     */
    public boolean isEmpty() {
        return this.earthStation == null &&
                this.spaceStation == null &&
                this.spaceStationBeam == null &&
                this.losses == null &&
                this.earthStationBeam == null &&
                this.up_Link.isEmpty() &&
                this.dn_Link.isEmpty();
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(earthStation.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(spaceStation.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(spaceStationBeam.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(losses));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(type.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(dn_Link.hashCode());
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(up_Link.hashCode());
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
        if (!(obj instanceof Network)) {
            return false;
        }
        Network other = (Network) obj;
        if ((earthStation != null && other.earthStation != null) && Double.doubleToLongBits(earthStation.hashCode()) != Double
                .doubleToLongBits(other.earthStation.hashCode())) {
            return false;
        }
        if ((spaceStation != null && other.spaceStation != null) && Double.doubleToLongBits(spaceStation.hashCode()) != Double
                .doubleToLongBits(other.spaceStation.hashCode())) {
            return false;
        }
        if ((spaceStationBeam != null && other.spaceStationBeam != null) && Double.doubleToLongBits(spaceStationBeam.hashCode()) != Double
                .doubleToLongBits(other.spaceStationBeam.hashCode())) {
            return false;
        }
        if (Double.doubleToLongBits(Arrays.hashCode(losses)) != Double
                .doubleToLongBits(Arrays.hashCode(other.losses))) {
            return false;
        }
        if (Double.doubleToLongBits(type.hashCode()) != Double
                .doubleToLongBits(other.type.hashCode())) {
            return false;
        }
        if ((dn_Link != null && other.dn_Link != null) && Double.doubleToLongBits(dn_Link.hashCode()) != Double
                .doubleToLongBits(other.dn_Link.hashCode())) {
            return false;
        }
        return (up_Link == null || other.up_Link == null) || Double.doubleToLongBits(up_Link.hashCode()) == Double
                .doubleToLongBits(other.up_Link.hashCode());

    }
}
