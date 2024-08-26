package com.springbok.system;

import Jama.Matrix;
import com.celestrak.sgp4v.ObjectDecayed;
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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import static com.springbok.utility.TimeUtility.date2mjd;
import static java.lang.Double.NaN;
import static java.lang.Double.NEGATIVE_INFINITY;

public class GsoGsoTestSetup {

    public static System getWntGsoSystem() throws ObjectDecayed {

        // = Simulation constants

        // Date near reference where Greenwich hour angle is zero
        ModJulianDate epoch_0 = new ModJulianDate(date2mjd(2000, 1, 1, 12, 0, 0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot);
        // [decimal day] = [decimal day] - [rad] / [rad / day]

        // = Wanted system

        // == Space station

        SpaceStation spaceStation = getWntGsoSpaceSegment(epoch_0);

        // == Earth station

        Matrix lla = Coordinates.gei2lla(spaceStation.get_orbit().r_gei(spaceStation.get_orbit().getEpoch()), spaceStation.get_orbit().getEpoch());

        double varphi = 10.0 * Math.PI / 180.0;  // Geodetic latitude [rad]
        double lambda = lla.get(0, 1);  // Longitude [rad]

        EarthStation earthStation = getWntGsoEarthSegment(varphi, lambda);

        // = Wanted system

        // An Earth station array
        ArrayList<EarthStation> earthStations = new ArrayList<EarthStation>();
        earthStations.add(earthStation);
        // A space station array
        ArrayList<SpaceStation> spaceStations = new ArrayList<SpaceStation>();
        spaceStations.add(spaceStation);
        // Propagation loss models to apply
        Object[] losses = null;
        // Current date number
        ModJulianDate dNm = epoch_0;
        // of options
        Map options = new HashMap();
        options.put("testAngleFromGsoArc", false);

        System system = new System(earthStations, spaceStations, losses, epoch_0, options);

        return system;
    }

    public static SpaceStation getWntGsoSpaceSegment(ModJulianDate epoch_0) {

        // = Wanted system

        // == Space station

        // === Transmit pattern

        // Maximum antenna gain [dB]
        double TransmitAntennaGainMax = 38.0;
        // Cross-sectional half-power beamwidth, degrees
        double TransmitAntennaPhi0 = 4.0;

        // Transmit space pattern
        SpacePattern transmitAntennaPattern = new PatternSREC408V01(TransmitAntennaPhi0);

        // === Transmit antenna

        // Antenna name
        String transmitAntennaName = "GSO SS Tx";
        // Antenna gain
        double transmitAntennaGain = TransmitAntennaGainMax;
        // Antenna pattern identifier
        long transmitAntennaPatternId = 1;

        // Transmit space station antenna
        SpaceStationAntenna transmitAntenna = new SpaceStationAntenna(transmitAntennaName, transmitAntennaGain, transmitAntennaPatternId, transmitAntennaPattern);

        // Gain function options
        Map transmitAntennaOptions = new HashMap();
        transmitAntennaOptions.put("GainMax", TransmitAntennaGainMax);
        transmitAntenna.set_options(transmitAntennaOptions);

        // === Emission

        // Emission designator
        String design_emi = "1K20G1D--";
        // Maximum power density
        double pwr_ds_max = -58.0;
        // Minimum power density
        double pwr_ds_min = NaN;
        // Center frequency
        double freq_mhz = 11200.0;
        // Required C/N
        double c_to_n = NaN;
        //  Power flux density [dBW/Hz/m2]
        double pwr_flx_ds = -40.0;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, pwr_flx_ds);

        // === Beam

        Beam[] beam = new Beam[]{new Beam("WntGsoSpaceSegment", 1, 100.0)};

        // === Receive pattern

        // Maximum antenna gain [dB]
        double ReceiveAntennaGainMax = 40.0;
        // Cross-sectional half-power beamwidth, degrees
        double ReceiveAntennaPhi0 = 4.0;

        // Receive space pattern
        SpacePattern receivePattern = new PatternSREC408V01(ReceiveAntennaPhi0);

        // === Receive antenna

        // Antenna name
        String receiveAntennaName = "GSO SS Rx";
        // Antenna gain
        double receiveAntennaGain = ReceiveAntennaGainMax;
        // Antenna noise temperature
        double noise_t = 1000.0;
        // Antenna pattern identifier
        long receiveAntennaPatternId = 1;

        // Receive space station antenna
        SpaceStationAntenna receiveAntenna = new SpaceStationAntenna(receiveAntennaName, receiveAntennaGain, receiveAntennaPatternId, receivePattern, noise_t);

        // Gain function options
        Map receiveAntennaOptions = new HashMap<>();
        receiveAntennaOptions.put("GainMax", ReceiveAntennaGainMax);
        receiveAntenna.set_options(receiveAntennaOptions);

        // == Space station

        String stationId = "wanted";  // Identifier for station
        double a = EarthConstants.a_gso;  // Semi-major axis [er]
        double e = 0.001;  // Eccentricity [-]
        double i = 0.01 * Math.PI / 180;  // Inclination [rad]
        double Omega = 0.0 * Math.PI / 180;  // Right ascension of the ascending node [rad]
        double omega = 0.0 * Math.PI / 180;  // Argument of perigee [rad]
        double M = 0.0 * Math.PI / 180;  // Mean anomaly [rad]
        ModJulianDate epoch = epoch_0;  // Epoch date number
        String method = "halley";  // Method to solve Kepler's equation: 'newton' or 'halley'

        SpaceStation spaceStation = new SpaceStation(stationId, transmitAntenna, receiveAntenna, emission, beam, new KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method));

        return spaceStation;
    }

    public static EarthStation getWntGsoEarthSegment(double varphi, double lambda) {

        // = Wanted system

        // == Earth station

        // === Transmit pattern

        // Maximum antenna gain [dB]
        double transmitAntennaGainMax = 50.0;
        // Antenna efficiency, fraction
        double transmitAntennaEfficiency = 0.7;

        // Transmit Earth pattern
        EarthPattern transmitAnetnnaPattern = new PatternEREC013V01(transmitAntennaGainMax, transmitAntennaEfficiency);

        // === Transmit antenna

        // Antenna name
        String transmitAntennaName = "GSO ES Tx";
        // Antenna gain
        double transmitAntennaGain = transmitAntennaGainMax;
        // Antenna pattern identifier
        long transmitAnetnnaPatternId = 1;

        // Transmit Earth station antenna
        EarthStationAntenna transmitAntenna = new EarthStationAntenna(transmitAntennaName, transmitAntennaGain, transmitAnetnnaPatternId, transmitAnetnnaPattern);

        // === Emission

        // Emission designator
        String design_emi = "1K20G1D--";
        // Maximum power density
        double pwr_ds_max = -42.0;
        // Minimum power density
        double pwr_ds_min = NaN;
        // Center frequency
        double freq_mhz = 13000.0;
        // Required C/N
        double c_to_n = NaN;
        //  Power flux density [dBW/Hz/m2]
        double pwr_flx_ds = -40.0;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, pwr_flx_ds);

        // === Beam

        Beam beam = new Beam("WntGsoEarthSegment", 1, 100.0);

        // === Receive pattern

        // Maximum antenna gain [dB]
        double receiveAntennaGainMax = NaN;
        // Diameter of an earth antenna, m
        double receiveAntennaDiameter = 1.2;
        // Frequency for which a gain is calculated, MHz
        double receiveAntennaFrequency = 11200.0;

        // Receive Earth pattern
        EarthPattern recieveAntennaPattern = new PatternERR_020V01(receiveAntennaDiameter, receiveAntennaFrequency);

        // === Receive antenna

        // Antenna name
        String receiveAntennaName = "GSO ES Rx";
        // Antenna gain
        double receiveAntennaGain = receiveAntennaGainMax;
        // Antenna noise temperature
        double noise_t = 150.0;
        // Antenna pattern identifier
        long receiveAntennaPatternId = 1;

        // Receive Earth station antenna
        EarthStationAntenna receiveAntenna = new EarthStationAntenna(receiveAntennaName, receiveAntennaGain, receiveAntennaPatternId, recieveAntennaPattern, noise_t);

        // == Earth station

        // Identifier for station
        String stationId = "wanted";
        // Geodetic latitude [rad]
        // varphi
        // Longitude [rad]
        // lambda
        // Flag indicating whether to do multiplexing, or not
        boolean doMultiplexing = false;

        EarthStation earthStation = new EarthStation(stationId, transmitAntenna, receiveAntenna, emission, beam, varphi, lambda, doMultiplexing);

        return earthStation;
    }

    public static System getIntGsoSystem() throws ObjectDecayed {

        // == Simulation constants

        // Date near reference where Greenwich hour angle is zero
        ModJulianDate epoch_0 = new ModJulianDate(date2mjd(2000, 1, 1, 12, 0, 0) - EarthConstants.Theta_0 / EarthConstants.Theta_dot);
        // [decimal day] = [decimal day] - [rad] / [rad / day]

        // = Interfering system

        // == Space station

        SpaceStation spaceStation = getIntGsoSpaceSegment(epoch_0);

        // == Earth station

        Matrix lla = Coordinates.gei2lla(spaceStation.get_orbit().r_gei(spaceStation.get_orbit().getEpoch()), spaceStation.get_orbit().getEpoch());

        double varphi = 20.0 * Math.PI / 180.0;  // Geodetic latitude [rad]
        double lambda = lla.get(0, 1);  // Longitude [rad]

        EarthStation earthStation = getIntGsoEarthSegment(varphi, lambda);

        // = Interfering system

        // An Earth station array
        ArrayList<EarthStation> earthStations = new ArrayList<EarthStation>();
        earthStations.add(earthStation);
        // A space station array
        ArrayList<SpaceStation> spaceStations = new ArrayList<SpaceStation>();
        spaceStations.add(spaceStation);
        // Propagation loss models to apply
        Object[] losses = null;
        // Current date number
        ModJulianDate dNm = epoch_0;
        // of options
        Map options = new HashMap();
        options.put("testAngleFromGsoArc", false);

        System system = new System(earthStations, spaceStations, losses, epoch_0, options);

        return system;
    }

    public static SpaceStation getIntGsoSpaceSegment(ModJulianDate epoch_0) {

        // = Interfering system

        // == Space station

        // === Transmit pattern

        // Maximum antenna gain [dB]
        double transmitAntennaGainMax = 38.0;
        // Cross-sectional half-power beamwidth, degrees
        double transmitAntennaPhi0 = 4.0;

        // Transmit space pattern
        SpacePattern transmitAntennaPattern = new PatternSREC408V01(transmitAntennaPhi0);

        // === Transmit antenna

        // Antenna name
        String transmitAntennaName = "RAMBOUILLET";
        // Antenna gain
        double transmitAntennaGain = transmitAntennaGainMax;
        // Antenna pattern identifier
        long transmitAntennaPatternId = 1;

        // Transmit space station antenna
        SpaceStationAntenna transmitAntenna = new SpaceStationAntenna(transmitAntennaName, transmitAntennaGain, transmitAntennaPatternId, transmitAntennaPattern);

        // Gain function options
        Map transmitAntennaOptions = new HashMap();
        transmitAntennaOptions.put("GainMax", transmitAntennaGainMax);
        transmitAntenna.set_options(transmitAntennaOptions);

        // === Emission

        // Emission designator
        String design_emi = "1K20G1D--";
        // Maximum power density
        double pwr_ds_max = -58.0;
        // Minimum power density
        double pwr_ds_min = NaN;
        // Center frequency
        double freq_mhz = 11200.0;
        // Required C/N
        double c_to_n = NaN;
        //  Power flux density [dBW/Hz/m2]
        double pwr_flx_ds = -40.0;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, pwr_flx_ds);

        // === Beam

        Beam[] beam = new Beam[]{new Beam("IntGsoSpaceSegment", 1, 100.0)};

        // === Receive pattern

        // Maximum antenna gain [dB]
        double receiveAntennaGainMax = 40.0;
        // Cross-sectional half-power beamwidth, degrees
        double receiveAntennaPhi0 = 4.0;

        // Receive space pattern
        SpacePattern receiveAntennaPattern = new PatternSREC408V01(receiveAntennaPhi0);

        // === Receive antenna

        // Antenna name
        String receiveAntennaName = "RAMBOUILLET";
        // Antenna gain
        double receiveAntennaGain = receiveAntennaGainMax;
        // Antenna noise temperature
        double noise_t = 1000.0;
        // Antenna pattern identifier
        long receiveAntennaPatternId = 1;

        // Receive space station antenna
        SpaceStationAntenna receiveAntenna = new SpaceStationAntenna(receiveAntennaName, receiveAntennaGain, receiveAntennaPatternId, receiveAntennaPattern, noise_t);

        // Gain function options
        Map receiveAntennaOptions = new HashMap();
        receiveAntennaOptions.put("GainMax", receiveAntennaGainMax);
        receiveAntenna.set_options(receiveAntennaOptions);

        // == Space station

        String stationId = "interfering";  // Identifier for station
        double a = EarthConstants.a_gso;  // Semi-major axis [er]
        double e = 0.001;  // Eccentricity [-]
        double i = 0.01 * Math.PI / 180.0;  // Inclination [rad]
        double Omega = 5.0 * Math.PI / 180.0;  // Right ascension of the ascending node [rad]
        double omega = 0.0 * Math.PI / 180.0;  // Argument of perigee [rad]
        double M = 0.0 * Math.PI / 180.0;  // Mean anomaly [rad]
        ModJulianDate epoch = epoch_0;  // Epoch date number
        String method = "halley";  // Method to solve Kepler's equation: 'newton' or 'halley'

        SpaceStation spaceStation = new SpaceStation(stationId, transmitAntenna, receiveAntenna, emission, beam, new KeplerianOrbit(a, e, i, Omega, omega, M, epoch, method));

        return spaceStation;
    }

    public static EarthStation getIntGsoEarthSegment(double varphi, double lambda) {

        // = Interfering system

        // == Earth station

        // === Transmit pattern

        // Maximum antenna gain [dB]
        double transmitAntennaGainMax = 50.0;
        // Antenna efficiency, fraction
        double transmitAntennaEfficiency = 0.7;

        // Transmit Earth pattern
        EarthPattern transmitAntennaPattern = new PatternEREC013V01(transmitAntennaGainMax, transmitAntennaEfficiency);

        // === Transmit antenna

        // Antenna name
        String transmitAntennaName = "RAMBOUILLET";
        // Antenna gain
        double transmitAntennaGain = transmitAntennaGainMax;
        // Antenna pattern identifier
        long transmitAntennaPatternId = 1;

        // Transmit Earth station antenna
        EarthStationAntenna transmitAntenna = new EarthStationAntenna(transmitAntennaName, transmitAntennaGain, transmitAntennaPatternId, transmitAntennaPattern);

        // === Emission

        // Emission designator
        String design_emi = "1K20G1D--";
        // Maximum power density
        double pwr_ds_max = -42.0;
        // Minimum power density
        double pwr_ds_min = NaN;
        // Center frequency
        double freq_mhz = 13000.0;
        // Required C/N
        double c_to_n = NaN;
        //  Power flux density [dBW/Hz/m2]
        double pwr_flx_ds = -40.0;

        Emission emission = new Emission(design_emi, pwr_ds_max, pwr_ds_min, freq_mhz, c_to_n, pwr_flx_ds);

        // === Beam

        Beam beam = new Beam("IntGsoEarthSegment", 1, 100.0);

        // === Receive pattern

        // Maximum antenna gain [dB]
        double receiveAntennaGainMax = NEGATIVE_INFINITY;
        // Diameter of an earth antenna, m
        double receiveAntennaDiameter = 1.2;
        // Frequency for which a gain is calculated, MHz
        double receiveAntennaFrequency = 11200.0;

        // Receive Earth pattern
        EarthPattern receiveAntennaPattern = new PatternERR_020V01(receiveAntennaDiameter, receiveAntennaFrequency);

        // === Receive antenna

        // Antenna name
        String receiveAntennaName = "RAMBOUILLET";
        // Antenna gain
        double gain = receiveAntennaGainMax;
        // Antenna noise temperature
        double noise_t = 150.0;
        // Antenna pattern identifier
        long receiveAntennaPatternId = 1;

        // Receive Earth station antenna
        EarthStationAntenna receiveAntenna = new EarthStationAntenna(receiveAntennaName, gain, receiveAntennaPatternId, receiveAntennaPattern, noise_t);

        // == Earth station

        // Identifier for station
        String stationId = "interfering";
        // Geodetic latitude [rad]
        // varphi
        // Longitude [rad]
        // lambda
        // Flag indicating whether to do multiplexing, or not
        boolean doMultiplexing = false;

        EarthStation earthStation = new EarthStation(stationId, transmitAntenna, receiveAntenna, emission, beam, varphi, lambda, doMultiplexing);

        return earthStation;
    }
}
