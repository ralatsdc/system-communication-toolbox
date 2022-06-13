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
package com.springbok.pattern;

import com.springbok.utility.PatternUtility;

import java.util.Map;

/**
 * Describes the ITU antenna pattern SRR_406V01.
 */
public class PatternSRR_406V01 implements SpacePattern, TransmitPattern {

	/**
	 * Maximum antenna gain [dB]
	 */
	private double GainMax;

	/**
	 * Beamlet for fast roll-off space antennas [degrees]
	 */
	private double Beamlet;

	/**
	 * Cross-sectional half-power beamwidth [degrees]
	 */
	private double Phi0;

	/**
	 * Constructs a PatternSRR_406V01 given a cross-sectional half-power beamwidth and beamlet for fast roll-off space antennas.
	 *
	 * @param Beamlet Beamlet for fast roll-off space antennas [degrees]
	 * @param Phi0    Cross-sectional half-power beamwidth [degrees]
	 */
	public PatternSRR_406V01(double Beamlet, double Phi0) {
		/* Validate input parameters */
		PatternUtility.validate_input("Beamlet", Beamlet);
		PatternUtility.validate_input("Phi0", Phi0);

		/* Assign properties */
		this.Beamlet = Beamlet;
		this.Phi0 = Phi0;

		/* Compute derived properties */
		/* None */
	}

	/**
	 * Gets maximum antenna gain [dB].
	 *
	 * @return Maximum antenna gain [dB]
	 */
	public double getGainMax() {
		return GainMax;
	}

	/**
	 * Gets Beamlet for fast roll-off space antennas [degrees].
	 *
	 * @return Beamlet for fast roll-off space antennas [degrees]
	 */
	public double getBeamlet() {
		return Beamlet;
	}

	/**
	 * Gets Cross-sectional half-power beamwidth [degrees].
	 *
	 * @return Cross-sectional half-power beamwidth [degrees]
	 */
	public double getPhi0() {
		return Phi0;
	}

	/**
	 * Copies a PatternSRR_406V01 given a maximum antenna gain.
	 */
	public PatternSRR_406V01 copy() {
		return new PatternSRR_406V01(this.Beamlet, this.Phi0);
	}

	/**
	 * Appendix 30 (RR-2001) improved fast roll-off transmitting space station
	 * antenna pattern for Regions 1 and 3 (WRC-2000).
	 *
	 * @param Phi     Angle for which a gain is calculated [degrees]
	 * @param options Optional parameters (entered as key/value pairs)
	 * @return Co-polar and cross-polar gain [dB]
	 */
	public Gain gain(double Phi, Map options) {
		/* Validate input parameters */
		PatternUtility.validate_input("Phi", Phi);
		Map<String, Object> input = PatternUtility.validateOptions(options);

		/* Validate input options */
		options = PatternUtility.validateOptions(options);

		// TODO: Test constructor optional agruments
		GainMax = 0;
		boolean absolute_pattern = false;
		if (input.containsKey("GainMax")) {
			GainMax = (double) input.get("GainMax");
			absolute_pattern = true;

		}

		/* Implement pattern. */
		double eps = Math.ulp(1.0);
		double phi = Math.max(eps, Phi);

		double phi_over_phi0 = phi / Phi0;
		double x = 0.5 * (1 - Beamlet / Phi0);
		double phi1 = 1.45 / Phi0 * Beamlet + x;

		double delta_G1_0 = -12 * Math.pow(phi_over_phi0, 2);
		double delta_G1_1 = -12 * Math.pow((phi_over_phi0 - x) / (Beamlet / Phi0), 2);
		double delta_G1_2 = -25.3;
		double delta_G1_3 = -22 - 20 * Math.log10(phi_over_phi0);

		double delta_G1 = delta_G1_0 * (0 <= phi_over_phi0 && phi_over_phi0 <= 0.5 ? 1 : 0)
				+ delta_G1_1 * (0.5 < phi_over_phi0 && phi_over_phi0 <= phi1 ? 1 : 0)
				+ delta_G1_2 * (phi1 < phi_over_phi0 && phi_over_phi0 <= 1.45 ? 1 : 0)
				+ delta_G1_3 * (1.45 < phi_over_phi0 ? 1 : 0);

		double delta_G2_0 = -12 * Math.pow(phi_over_phi0, 2);
		double delta_G2_1 = -30;
		double delta_G2_2 = -17.5 - 25 * Math.log10(phi_over_phi0);

		double delta_G2 = delta_G2_0 * (0 <= phi_over_phi0 && phi_over_phi0 <= 1.58 ? 1 : 0)
				+ delta_G2_1 * (1.58 < phi_over_phi0 && phi_over_phi0 <= 3.16 ? 1 : 0)
				+ delta_G2_2 * (3.16 < phi_over_phi0 ? 1 : 0);

		double delta_G = Math.min(delta_G1, delta_G2);

		double G = GainMax + delta_G;

		double phix = Math.max(eps, Math.abs(phi_over_phi0 - 1));
		double Gx0 = GainMax - 40 - 40 * Math.log10(phix);
		double Gx1 = GainMax - 33;
		double Gx2 = GainMax - 40 - 40 * Math.log10(phix);

		double Gx = Gx0 * (0 <= phi_over_phi0 && phi_over_phi0 <= 0.33 ? 1 : 0)
				+ Gx1 * (0.33 < phi_over_phi0 && phi_over_phi0 <= 1.67 ? 1 : 0)
				+ Gx2 * (1.67 < phi_over_phi0 ? 1 : 0);

		/* Apply "flooring" for absolute gain pattern */
		if (absolute_pattern) {
			G = Math.max(0, G);
			Gx = Math.max(0, Gx);
		}
		/* Validate low level rules. */
		if (Phi0 < Beamlet) {
			PatternUtility.logger.warn("Phi0 is less than Beamlet.");
		}
		if (GainMax < 33 && absolute_pattern) {
			PatternUtility.logger.warn("GainMax is less than 33.");
		}
		/* Validate output parameters. */
		if ((boolean) options.get("DoValidate")) {
			PatternUtility.validate_output(G, Gx, GainMax);
		}
		return new Gain(G, Gx);
	}

	/*
	 * (non-Javadoc)
	 *
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		long temp;
		temp = Double.doubleToLongBits(Phi0);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(Beamlet);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(GainMax);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		return result;
	}

	/*
	 * (non-Javadoc)
	 *
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
		if (!(obj instanceof PatternSRR_406V01)) {
			return false;
		}
		PatternSRR_406V01 other = (PatternSRR_406V01) obj;
		if (Double.doubleToLongBits(Phi0) != Double.doubleToLongBits(other.Phi0)) {
			return false;
		}
		if (Double.doubleToLongBits(Beamlet) != Double.doubleToLongBits(other.Beamlet)) {
			return false;
		}
		if (Double.doubleToLongBits(GainMax) != Double.doubleToLongBits(other.GainMax)) {
			return false;
		}
		return true;
	}
}
