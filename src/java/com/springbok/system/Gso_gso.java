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

import Jama.Matrix;
import com.celestrak.sgp4v.ObjectDecayed;
import com.springbok.antenna.Antenna;
import com.springbok.antenna.EarthStationAntenna;
import com.springbok.antenna.SpaceStationAntenna;
import com.springbok.pattern.*;
import com.springbok.station.Beam;
import com.springbok.station.EarthStation;
import com.springbok.station.Emission;
import com.springbok.station.SpaceStation;
import com.springbok.twobody.Coordinates;
import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.KeplerianOrbit;
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.TimeUtility;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Gso_gso {
    public static SpaceStation getWntGsoSpaceSegment(ModJulianDate epoch_0) {
        // = Wanted system

        // == Space station

        // === Transmit pattern

        // Maximum antenna gain [dB]
        double GainMax = 38;
        // Cross-sectional half-power beamwidth, degrees
        double Phi0 = 4;

        // Transmit space pattern
        PatternSREC408V01 pattern = new PatternSREC408V01(Phi0);

        // === Transmit antenna

        // Antenna name
        String name = "GSO SS Tx";
        // Antenna gain
        double gain = GainMax;
        // Antenna pattern identifier
        long pattern_id = 1;

        // Transmit space station antenna
        SpaceStationAntenna transmitAntenna = new SpaceStationAntenna(name, gain, pattern_id, pattern);

        // Gain function options
        Map options = new HashMap<String, Object>();
        options.put("GainMax", GainMax);
        transmitAntenna.set_options(options);

        // === Emission

        // Emission designator
        String design_emi = "1K20G1D--";
        // Maximum power density
        double pwr_ds_max = -58.0;
        // Minimum power density
        double pwr_ds_min = Double.NaN;
        // Center frequency
        double freq_mhz = 11200;
        // Required C/N
        double c_to_n = Double.NaN;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, 0);

        // === Beam

        Beam beam = new Beam("WntGsoSpaceSegment", 1, 100);

        // === Receive pattern

        // Maximum antenna gain [dB]
        GainMax = 40;
        // Cross-sectional half-power beamwidth, degrees
        Phi0 = 4;

        // Receive space pattern
        pattern = new PatternSREC408V01(Phi0);

        // === Receive antenna

        // Antenna name
        name = "GSO SS Rx";
        // Antenna gain
        gain = GainMax;
        // Antenna noise temperature
        double noise_t = 1000;
        // Antenna pattern identifier
        pattern_id = 1;

        // Receive space station antenna
        SpaceStationAntenna receiveAntenna = new SpaceStationAntenna(name, gain, pattern_id, pattern, noise_t);

        // Gain function options
        options = new HashMap<String, Object>();
        options.put("GainMax", GainMax);
        receiveAntenna.set_options(options);

        // == Space station

        String stationId = "wanted";             // Identifier for station
        double a = EarthConstants.a_gso; // Semi-major axis [er]
        double e = 0.001;                // Eccentricity [-]
        double i = 0.01 * Math.PI / 180;      // Inclination [rad]
        double Omega = 0.0 * Math.PI / 180;       // Right ascension of the ascending node [rad]
        double omega = 0.0 * Math.PI / 180;       // Argument of perigee [rad]
        double M = 0.0 * Math.PI / 180;       // Mean anomaly [rad]
        ModJulianDate epoch = epoch_0;              // Epoch date number
        String method = "halley";             // Method to solve Kepler"s equation: "newton" or "halley"

        return new SpaceStation(stationId, transmitAntenna, receiveAntenna, emission, new Beam[]{beam},
                new KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method));
    }

    public static System getWntGsoSystem() throws ObjectDecayed {
        // == Simulation constants

        // Date near reference where Greenwich hour angle is zero
        double epoch_0 = TimeUtility.date2mjd(2000, 1, 1, 12, 0, 0.0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot;
        // [decimal day] = [decimal day] - [rad] / [rad / day]

        // = Wanted system

        // == Space station

        SpaceStation spaceStation = getWntGsoSpaceSegment(new ModJulianDate(epoch_0));

        // == Earth station

        Matrix lla = Coordinates.gei2lla(
                spaceStation.getOrbit().r_gei(spaceStation.getOrbit().getEpoch()), spaceStation.getOrbit().getEpoch());

        double varphi = 10.0 * Math.PI / 180; // Geodetic latitude [rad]
        double lambda = lla.get(1, 0);          // Longitude [rad]

        EarthStation earthStation = getWntGsoEarthSegment(varphi, lambda);

        // = Wanted system

        Object[] losses = new Object[0];

        Map options = new HashMap<String, Object>();
        options.put("TestAngleFromGsoArc", false);

        return new System(
                new EarthStation[]{earthStation},
                new SpaceStation[]{spaceStation},
                losses,
                new ModJulianDate(epoch_0),
                options
        );
    }

    public static EarthStation getWntGsoEarthSegment(double varphi, double lambda) {
        // = Wanted system

        // == Earth station

        // === Transmit pattern

        // Maximum antenna gain [dB]
        double GainMax = 50;
        // Antenna efficiency, fraction
        double Efficiency = 0.7;

        // Transmit Earth pattern
        EarthPattern pattern = new PatternEREC013V01(GainMax, Efficiency);

        // === Transmit antenna
        // Antenna name
        String name = "GSO ES Tx";
        // Antenna gain
        double gain = GainMax;
        // Antenna pattern identifier
        long pattern_id = 1;

        // Transmit Earth station antenna
        EarthStationAntenna transmitAntenna = new EarthStationAntenna(name, gain, pattern_id, pattern);

        // === Emission

        // Emission designator
        String design_emi = "1K20G1D--";
        // Maximum power density
        double pwr_ds_max = -42.0;
        // Minimum power density
        double pwr_ds_min = Double.NaN;
        // Center frequency
        double freq_mhz = 13000;
        // Required C/N
        double c_to_n = Double.NaN;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, 0);

        // === Beam

        Beam beam = new Beam("WntGsoEarthSegment", 1, 100);

        // === Receive pattern

        // Maximum antenna gain [dB]
        GainMax = Double.NaN;
        // Diameter of an earth antenna, m
        double Diameter = 1.2;
        // Frequency for which a gain is calculated, MHz
        double Frequency = 11200;

        // Receive Earth pattern
        pattern = new PatternERR_020V01(Diameter, Frequency);

        // === Receive antenna

        // Antenna name
        name = "GSO ES Rx";
        // Antenna gain
        gain = GainMax;
        // Antenna noise temperature
        double noise_t = 150;
        // Antenna pattern identifier
        pattern_id = 1;

        // Receive Earth station antenna
        EarthStationAntenna receiveAntenna = new EarthStationAntenna(name, gain, pattern_id, pattern, noise_t);

        // == Earth station

        // Identifier for station
        String stationId = "wanted";
        // Geodetic latitude [rad]
        // varphi
        // Longitude [rad]
        // lambda
        // Flag indicating whether to do multiplexing, or not
        boolean doMultiplexing = false;

        return new EarthStation(
                stationId, transmitAntenna, receiveAntenna, emission, beam,
                varphi, lambda, doMultiplexing);
    }

    public static SpaceStation getIntGsoSpaceSegment(ModJulianDate epoch_0) {
        // = Interfering system

        // == Space station

        // === Transmit pattern

        // Maximum antenna gain [dB]
        double GainMax = 38;
        // Cross-sectional half-power beamwidth, degrees
        double Phi0 = 4;

        // Transmit space pattern
        PatternSREC408V01 pattern = new PatternSREC408V01(Phi0);

        // === Transmit antenna

        // Antenna name
        String name = "RAMBOUILLET";
        // Antenna gain
        double gain = GainMax;
        // Antenna pattern identifier
        long pattern_id = 1;

        // Transmit space station antenna
        SpaceStationAntenna transmitAntenna = new SpaceStationAntenna(name, gain, pattern_id, pattern);

        // Gain function options
        Map options = new HashMap<String, Object>();
        options.put("GainMax", GainMax);

        transmitAntenna.set_options(options);

        // === Emission

        // Emission designator
        String design_emi = "1K20G1D--";
        // Maximum power density
        double pwr_ds_max = -58.0;
        // Minimum power density
        double pwr_ds_min = Double.NaN;
        // Center frequency
        double freq_mhz = 11200;
        // Required C/N
        double c_to_n = Double.NaN;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, 0);

        // === Beam

        Beam beam = new Beam("IntGsoSpaceSegment", 1, 100);

        // === Receive pattern

        // Maximum antenna gain [dB]
        GainMax = 40;
        // Cross-sectional half-power beamwidth, degrees
        Phi0 = 4;

        // Receive space pattern
        pattern = new PatternSREC408V01(Phi0);

        // === Receive antenna

        // Antenna name
        name = "RAMBOUILLET";
        // Antenna gain
        gain = GainMax;
        // Antenna noise temperature
        double noise_t = 1000;
        // Antenna pattern identifier
        pattern_id = 1;

        // Receive space station antenna
        SpaceStationAntenna receiveAntenna = new SpaceStationAntenna(name, gain, pattern_id, pattern, noise_t);

        // Gain function options
        options = new HashMap<String, Object>();
        options.put("GainMax", GainMax);
        receiveAntenna.set_options(options);

        // == Space station

        String stationId = "interfering";        // Identifier for station
        double a = EarthConstants.a_gso; // Semi-major axis [er]
        double e = 0.001;                // Eccentricity [-]
        double i = 0.01 * Math.PI / 180;      // Inclination [rad]
        double Omega = 5.0 * Math.PI / 180;       // Right ascension of the ascending node [rad]
        double omega = 0.0 * Math.PI / 180;       // Argument of perigee [rad]
        double M = 0.0 * Math.PI / 180;       // Mean anomaly [rad]
        ModJulianDate epoch = epoch_0;              // Epoch date number
        String method = "halley";             // Method to solve Kepler"s equation: "newton" or "halley"

        return new SpaceStation(
                stationId, transmitAntenna, receiveAntenna, emission, new Beam[]{beam},
                new KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method));
    }

    public static EarthStation getIntGsoEarthSegment(double varphi, double lambda) {
        // = Interfering system

        // == Earth station

        // === Transmit pattern

        // Maximum antenna gain [dB]
        double GainMax = 50;
        // Antenna efficiency, fraction
        double Efficiency = 0.7;

        // Transmit Earth pattern
        EarthPattern pattern = new PatternEREC013V01(GainMax, Efficiency);

        // === Transmit antenna

        // Antenna name
        String name = "RAMBOUILLET";
        // Antenna gain
        double gain = GainMax;
        // Antenna pattern identifier
        long pattern_id = 1;

        // Transmit Earth station antenna
        EarthStationAntenna transmitAntenna = new EarthStationAntenna(name, gain, pattern_id, pattern);

        // === Emission

        // Emission designator
        String design_emi = "1K20G1D--";
        // Maximum power density
        double pwr_ds_max = -42.0;
        // Minimum power density
        double pwr_ds_min = Double.NaN;
        // Center frequency
        double freq_mhz = 13000;
        // Required C/N
        double c_to_n = Double.NaN;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, 0);

        // === Beam

        Beam beam = new Beam("IntGsoEarthSegment", 1, 100);

        // === Receive pattern

        // Maximum antenna gain [dB]
        GainMax = Double.NEGATIVE_INFINITY;
        // Diameter of an earth antenna, m
        double Diameter = 1.2;
        // Frequency for which a gain is calculated, MHz
        double Frequency = 11200;

        // Receive Earth pattern
        pattern = new PatternERR_020V01(Diameter, Frequency);

        // === Receive antenna

        // Antenna name
        name = "RAMBOUILLET";
        // Antenna gain
        gain = GainMax;
        // Antenna noise temperature
        double noise_t = 150;
        // Antenna pattern identifier
        pattern_id = 1;

        // Receive Earth station antenna
        EarthStationAntenna receiveAntenna = new EarthStationAntenna(name, gain, pattern_id, pattern, noise_t);

        // == Earth station

        // Identifier for station
        String stationId = "interfering";
        // Geodetic latitude [rad]
        // varphi
        // Longitude [rad]
        // lambda
        // Flag indicating whether to do multiplexing, or not
        boolean doMultiplexing = false;

        return new EarthStation(
                stationId, transmitAntenna, receiveAntenna, emission, beam,
                varphi, lambda, doMultiplexing);
    }

    public static System getIntGsoSystem() throws ObjectDecayed {
        // == Simulation constants

        // Date near reference where Greenwich hour angle is zero

        double epoch_0 = TimeUtility.date2mjd(2000, 1, 1, 12, 0, 0.0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot;
        // [decimal day] = [decimal day] - [rad] / [rad / day]

        // = Interfering system

        // == Space station

        SpaceStation spaceStation = getIntGsoSpaceSegment(new ModJulianDate(epoch_0));

        // == Earth station

        Matrix lla = Coordinates.gei2lla(
                spaceStation.getOrbit().r_gei(
                        spaceStation.getOrbit().getEpoch()), spaceStation.getOrbit().getEpoch());

        double varphi = 20.0 * Math.PI / 180; // Geodetic latitude [rad]
        double lambda = lla.get(1, 0);          // Longitude [rad]

        EarthStation earthStation = getIntGsoEarthSegment(varphi, lambda);

        // = Interfering system

        Map options = new HashMap<String, Object>();
        options.put("TestAngleFromGsoArc", 0);

        Object[] losses = new Object[0];
        return new System(new EarthStation[]{earthStation}, new SpaceStation[]{spaceStation}, losses, new ModJulianDate(epoch_0), options);
    }

    public static EarthStation getWntGsoEarthSegment(SpaceStation spaceStation) {
        // = Wanted system
        // == Earth station
        // === Transmit pattern

        //Maximum antenna gain [dB]
        double GainMax = 50;

        //Antenna efficiency, fraction
        double Efficiency = 0.7;

        //Transmit Earth pattern
        EarthPattern pattern = new PatternEREC013V01(GainMax, Efficiency);

        //=== Transmit antenna

        //Antenna name
        String name = "GSO ES Tx";

        //Antenna gain
        double gain = GainMax;

        //Antenna pattern identifier
        int pattern_id = 1;

        //Transmit Earth station antenna
        EarthStationAntenna transmitAntenna = new EarthStationAntenna(name, gain, pattern_id, pattern);

        //Gain function options
        Map options = new HashMap();
        options.put("DoValidate", false);
        transmitAntenna.set_options(options);

        //===Emission
        //Emission designator
        String design_emi = "1K20G1D--";

        //Maximum power density
        double pwr_ds_max = -42.0;

        //Minimum power density
        double pwr_ds_min = Double.NaN;

        //Center frequency
        double freq_mhz = 13000;

        //Required C/N
        double c_to_n = Double.NaN;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, 0);

        // === Beam
        Beam beam = new Beam("WntGsoEarthSegment", 1, 100);

        //=== Receive pattern

        //Maximum antenna gain[dB]
        GainMax = Double.NaN;

        //Diameter of an earth antenna, m
        double Diameter = 1.2;
        //Frequency for which a gain is calculated, MHz
        double Frequency = 11200;

        //Receive Earth pattern
        pattern = new PatternERR_020V01(Diameter, Frequency);

        // === Receive antenna

        // Antenna name
        name = "GSO ES Rx";

        //Antenna gain
        gain = GainMax;

        //Antenna noise temperature
        double noise_t = 150;

        //Antenna pattern identifier
        pattern_id = 1;

        //Receive Earth station antenna
        EarthStationAntenna receiveAntenna = new EarthStationAntenna(name, gain, pattern_id, pattern, noise_t);

        // Gain function options
        receiveAntenna.set_options(options);

        // == Earth station
        Matrix lla = null;
        try {
            lla = Coordinates.gei2lla(spaceStation.getOrbit().r_gei(spaceStation.getOrbit().getEpoch()),
                    spaceStation.getOrbit().getEpoch());
        } catch (ObjectDecayed objectDecayed) {
            objectDecayed.printStackTrace();
        }

        String stationId = "wanted"; //Identifier for station
        double varphi = 0;
        //Geodetic latitude[rad]
        double lambda = lla.get(1, 0);   //Longitude[rad]
        boolean doMultiplexing = false;
        //Flag indicating whether to do multiplexing, or not
        return new EarthStation(stationId, transmitAntenna, receiveAntenna, emission, beam, varphi,
                lambda, doMultiplexing);
    }

    public static SpaceStation[] getIntLeoSpaceSegment(ModJulianDate epoch_0) {

        // = Interfering system
        // == Space stations
        // === Transmit pattern

        //Maximum antenna gain [dB]
        double GainMax = 27;
        //Cross-sectional half-power beamwidth, degrees
        double Phi0 = 6.9;

        //Transmit space pattern
        SpacePattern pattern = new PatternSREC408V01(Phi0);

        // === Transmit antenna
        // Antenna name
        String name = "NGSO SS Tx";
        //Antenna gain
        double gain = GainMax;
        //Antenna pattern identifier
        int pattern_id = 1;

        //Transmit space station antenna
        SpaceStationAntenna transmitAntenna = new SpaceStationAntenna(name, gain, pattern_id, pattern);

        //Gain function options
        Map options = new HashMap();
        options.put("GainMax", GainMax);
        options.put("DoValidate", false);
        transmitAntenna.set_options(options);

        //=== Emission

        //Emission designator
        String design_emi = "1K20G1D--";
        //Maximum power density
        double pwr_ds_max = -73;
        //Minimum power density
        double pwr_ds_min = Double.NaN;
        //Center frequency
        double freq_mhz = 11200;
        //Required C/N
        double c_to_n = Double.NaN;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, 0);

        //=== Receive pattern

        //Maximum antenna gain [dB]
        GainMax = 30;
        //Cross-sectional half-power beamwidth, degrees
        Phi0 = 5.3;

        //Receive space pattern
        pattern = new PatternSREC408V01(Phi0);

        //=== Receive antenna

        //Antenna name
        name = "NGSO SS Rx";
        //Antenna gain
        gain = GainMax;
        //Antenna noise temperature
        double noise_t = 600;
        //Antenna pattern identifier
        pattern_id = 1;

        //Receive space station antenna
        SpaceStationAntenna receiveAntenna = new SpaceStationAntenna(name, gain, pattern_id, pattern, noise_t);

        //Gain function options
        options.put("GainMax", GainMax);
        receiveAntenna.set_options(options);

        // == Space stations

        String stationId = "interfering"; //Identifier for station
        double a = 1 + 1500 / EarthConstants.R_oplus; //Semi-major axis [er]
        double e = 0.001; //Eccentricity[-]
        double i = 80.0 * Math.PI / 180; //Inclination[rad]
        double Omega = 30.0 * Math.PI / 180; //Right ascension of the ascending node[ rad]
        double omega = 60.0 * Math.PI / 180;//Argument of perigee[rad]
        double M = 130.0 * Math.PI / 180;//Mean anomaly[ rad]
        ModJulianDate epoch = epoch_0; //Epoch date number
        String method = "halley"; //Method to solve Kepler "s equation: " newton " or " halley

        int nBeams = 4;
        List<SpaceStation> spaceStations = new ArrayList<>();
        int d_Omega = 360 / 30;
        int d_M = 360 / 30;
        for (int delta_Omega = 0; delta_Omega < (360 - d_Omega) * (Math.PI / 180); delta_Omega += d_Omega) {
            for (int delta_M = 0; delta_M < (360 - d_M) * (Math.PI / 180); delta_M += d_M) {
                //=== Beam
                Beam[] beams = new Beam[nBeams];

                for (int iBeam = 0; iBeam < nBeams; iBeam++) {
                    beams[iBeam] = new Beam("IntLeoSpaceSegment", 1, 100);
                }
                // == Space stations

                spaceStations.add(new SpaceStation(stationId, transmitAntenna, receiveAntenna, emission, beams,
                        new KeplerianOrbit(a, e, i, Omega + delta_Omega, omega, M + delta_M, epoch, method)));
            }
        }
        return spaceStations.toArray(new SpaceStation[spaceStations.size()]);
    }

    public static EarthStation[] getIntLeoEarthSegment(SpaceStation spaceStation) {

        //= Interfering system
        //== Earth stations
        //=== Transmit pattern
        //Maximum antenna gain [dB]
        double GainMax = 54;
        //Antenna efficiency, fraction
        double Efficiency = 0.7;

        //Transmit Earth pattern
        EarthPattern pattern = new PatternEREC013V01(GainMax, Efficiency);

        //=== Transmit antenna
        //Antenna name
        String name = "NGSO ES Tx";
        //Antenna gain
        double gain = GainMax;
        //Antenna pattern identifier
        int pattern_id = 1;

        //Transmit Earth station antenna
        EarthStationAntenna transmitAntenna = new EarthStationAntenna(name, gain, pattern_id, pattern);

        //Gain function options
        Map options = new HashMap();
        options.put("DoValidate", false);
        transmitAntenna.set_options(options);

        // ===Emission
        // Emission designator
        String design_emi = "1K20G1D--";
        //Maximum power density
        double pwr_ds_max = -74;
        //Minimum power density
        double pwr_ds_min = Double.NaN;
        //Center frequency
        double freq_mhz = 13000;
        //Required C/N
        double c_to_n = Double.NaN;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, 0);

        // ===Receive pattern

        //Maximum antenna gain[dB]
        GainMax = 27;
        //Antenna efficiency, fraction
        Efficiency = 0.7;

        //Receive Earth pattern
        pattern = new PatternEREC013V01(GainMax, Efficiency);

        // ===Receive antenna

        //Antenna name
        name = "NGSO ES Rx";
        //Antenna gain
        gain = GainMax;
        //Antenna noise temperature
        double noise_t = 440;
        //Antenna pattern identifier
        pattern_id = 1;

        //Receive Earth station antenna
        EarthStationAntenna receiveAntenna = new EarthStationAntenna(name, gain, pattern_id, pattern, noise_t);

        //Gain function options
        receiveAntenna.set_options(options);

        // ==Earth stations

        //Contiguous United States bounding box
        // See:https:answers.yahoo.com/question/index?qid=20070729220301AA6Ct4s

        //Northernmost point
        //Northwest Angle, Minnesota (49°23 "4.1" N)
        // 
        //Southernmost point
        //Ballast Key, Florida (24°31′15″N)
        // 
        //Easternmost point
        //Sail Rock, just offshore of West Quoddy Head, Maine
        // (66°57 " W)
        // 
        //Westernmost point
        //Bodelteh Islands offshore from Cape Alava, Washington
        //(124°46 " W) 
        Matrix lla = null;
        try {
            lla = Coordinates.gei2lla(spaceStation.getOrbit().r_gei(spaceStation.getOrbit().getEpoch()),
                    spaceStation.getOrbit().getEpoch());
        } catch (ObjectDecayed objectDecayed) {
            objectDecayed.printStackTrace();
        }

        String stationId = "wanted"; //Identifier for station
        double varphi = 0;        //Geodetic latitude[ rad]
        double lambda = lla.get(1,0);   //Longitude[rad]
        boolean doMultiplexing = false;        //Flag indicating whether to do multiplexing, or not

        List<EarthStation> earthStations = new ArrayList<>();
        double d_angle = 12;
        for (int d_varphi = 0; d_varphi < (24 - d_angle) * (Math.PI / 180); d_varphi+=d_angle) {
            for (int d_lambda = 0; d_lambda < (60 - d_angle) * (Math.PI / 180); d_lambda++) {
                // == = Beam

                Beam beam = new Beam("IntLeoEarthSegment", 1, 100);

                // ==Earth stations
                earthStations.add(new EarthStation(stationId, transmitAntenna, receiveAntenna, emission, beam,
                        varphi + d_varphi, lambda + d_lambda, doMultiplexing));
            }
        }
        return earthStations.toArray(new EarthStation[earthStations.size()]);
    }
}
