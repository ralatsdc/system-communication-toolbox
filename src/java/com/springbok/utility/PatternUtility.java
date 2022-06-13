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
package com.springbok.utility;

import java.util.HashMap;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Defines methods for validating pattern input and output, and for comparing
 * patterns.
 */
public final class PatternUtility {

	public static final Logger logger = LogManager.getLogger(PatternUtility.class.getName());

	/**
	 * Validate input parameters.
	 * 
	 * @param key
	 *            Parameter name
	 * @param value_p
	 *            Parameter value
	 */
	public static void validate_input(String key, Object value_p) {
		validate_input(key, value_p, new HashMap<String, Object>());
	}

	/**
	 * Validate input parameters.
	 * 
	 * @param key
	 *            Parameter name
	 * @param value_p
	 *            Parameter value
	 * @param input
	 *            Parameter map
	 * 
	 * @return Parameter map
	 */
	public static Map<String, Object> validate_input(String key, Object value_p, Map<String, Object> input) {

		/* Required input parameters */
		double value_d;
		boolean value_b;
		switch (key) {
		case "GainMax":
			value_d = (Double) value_p;
			if (Double.isInfinite(value_d) || Double.isNaN(value_d)) {
				throw new IllegalArgumentException("GainMax must be a numeric scalar.");
			}
			if (value_d < 0.00e+0 || value_d > 7.00e+2) {
				throw new IllegalArgumentException("GainMax is out of limits [0:700]." + "APC_ERR_VAL_GAINMAX"
						+ "GainMax is out of limits [0:700].");
			}
			if (value_d < 0.00e+0 || value_d > 1.00e+2) {
				logger.warn("GainMax is out of limits [0:100].");
			}
			input.put(key, value_d);
			break;

		case "Beamlet":
			value_d = (Double) value_p;
			if (Double.isInfinite(value_d) || Double.isNaN(value_d)) {
				throw new IllegalArgumentException("Beamlet must be a numeric scalar.");
			}
			if (value_d < 1.00e-5 || value_d > 1.80e+2) {
				throw new IllegalArgumentException("Beamlet is out of limits [1e-5:180]." + "APC_ERR_VAL_BEAMLET"
						+ "Beamlet is out of limits [1e-5:180].");
			}
			if (value_d < 1.00e-3 || value_d > 1.80e+1) {
				logger.warn("Beamlet is out of limits [1e-3:18].");
			}
			input.put(key, value_d);
			break;

		case "Diameter":
			value_d = (Double) value_p;
			if (Double.isInfinite(value_d) || Double.isNaN(value_d)) {
				throw new IllegalArgumentException("Diameter must be a numeric scalar.");
			}
			if (value_d < 1.00e-5 || value_d > 1.00e+5) {
				throw new IllegalArgumentException("Diameter is out of limits [1e-5:1e+5]." + "APC_ERR_VAL_DIAMETER"
						+ "Diameter is out of limits [1e-5:1e+5].");
			}
			if (value_d < 1.00e-2 || value_d > 1.00e+2) {
				logger.warn("Diameter is out of limits [0.01:100].");
			}
			input.put(key, value_d);
			break;

		case "Frequency":
			value_d = (Double) value_p;
			if (Double.isInfinite(value_d) || Double.isNaN(value_d)) {
				throw new IllegalArgumentException("Frequency must be a numeric scalar.");
			}
			if (value_d < 1.00e-3 || value_d > 1.00e+10) {
				throw new IllegalArgumentException("Frequency is out of limits [1e-3:1e+10]." + "APC_ERR_VAL_FREQUENCY"
						+ "Frequency is out of limits [1e-3:1e+10].");
			}
			if (value_d < 1.00e+0 || value_d > 1.00e+6) {
				logger.warn("Frequency is out of limits [1:1e+6].");
			}
			input.put(key, value_d);
			break;

		case "Efficiency":
			value_d = (Double) value_p;
			if (Double.isInfinite(value_d) || Double.isNaN(value_d)) {
				throw new IllegalArgumentException("Efficiency must be a numeric scalar.");
			}
			if (value_d < 1.00e-5 || value_d > 1.00e+0) {
				throw new IllegalArgumentException("Efficiency is out of limits [1e-5:100]." + "APC_ERR_VAL_EFFICIENCY"
						+ "Efficiency is out of limits [1e-5:100].");
			}
			if (value_d < 1.00e-1 || value_d > 1.00e+0) {
				logger.warn("Efficiency is out of limits [0.1:100].");
			}
			input.put(key, value_d);
			break;

		case "Phi":
			value_d = (Double) value_p;
			if (Double.isInfinite(value_d) || Double.isNaN(value_d)) {
				throw new IllegalArgumentException("Phi must be a numeric vector (or scalar).");
			}
			if ((value_d < 0.00e+0) || (value_d > 1.80e+2)) {
				throw new IllegalArgumentException(
						"Phi is out of limits [0:180]." + "APC_ERR_VAL_PHI" + "Phi is out of limits [0:180].");
			}
			input.put(key, value_d);
			break;

		case "Phi0":
			value_d = (Double) value_p;
			if (Double.isInfinite(value_d) || Double.isNaN(value_d)) {
				throw new IllegalArgumentException("Phi0 must be a numeric scalar.");
			}
			if (value_d < 1.00e-5 || value_d > 1.80e+2) {
				throw new IllegalArgumentException(
						"Phi0 is out of limits [1e-5:180]." + "APC_ERR_VAL_PHI0" + "Phi0 is out of limits [1e-5:180].");
			}
			if (value_d < 1.00e-3 || value_d > 1.80e+2) {
				logger.warn("Phi0 is out of limits [1e-3:180].");
			}
			input.put(key, value_d);
			break;

		/* Optional input parameters */
		case "CoefA":
		case "CoefB":
		case "CoefC":
		case "CoefD":
		case "Phi1":
		case "Gmin":
			value_d = (Double) value_p;
			if (Double.isInfinite(value_d) || Double.isNaN(value_d)) {
				throw new IllegalArgumentException(key + " must be a numeric scalar.");
			}
			input.put(key, value_d);
			break;

		case "DoValidate":
			if (!(value_p instanceof Boolean)) {
				throw new IllegalArgumentException("DoValidate must be a logical scalar.");
			}
			value_b = (Boolean) value_p;
			input.put(key, value_b);
			break;

		default:
			logger.warn("Input parameter name not recognized (and ignored): %s.", key);
		}
		return input;
	}

	/**
	 * Validate output parameters.
	 * 
	 * @param G
	 *            Co-pol gain [dB]
	 * @param Gx
	 *            Cross-pol gain [dB]
	 * @param GainMax
	 *            Maximum antenna gain [dB]
	 */
	public static void validate_output(double G, double Gx, double GainMax) {
		if (G > GainMax) {
			throw new IllegalArgumentException(
					"G is greater than GainMax." + "APC_ERR_G_GT_GMAX" + "G is greater than GainMax.");
		}
		if (Gx > GainMax) {
			throw new IllegalArgumentException(
					"Gx is greater than GainMax." + "APC_ERR_GX_GT_GMAX" + "Gx is greater than GainMax.");
		}
		if (Gx > G) {
			logger.warn("Gx is greater than G.");
		}
		if (Gx == G) {
			logger.warn("Cross-polar gain is not calculated. Value is set to co-polar gain.");
		}
	}

	/**
	 * Validate each entry of an input options map.
	 * 
	 * @param options
	 *            A map of input options to validate
	 * 
	 * @return A validated map of input options
	 */
	static public Map<String, Object> validateOptions(Map options) {
		Map<String, Object> result = new HashMap<>();
		if (options == null) {
			options = result;
		}
		for (Object entry : options.entrySet()) {
			Map.Entry e = (Map.Entry) entry;
			Object key = e.getKey();
			String strKey;
			if (key instanceof String) {
				strKey = (String) key;
			} else {
				throw new IllegalArgumentException("Options keys must be String");
			}
			Object value = e.getValue();
			result = PatternUtility.validate_input(strKey, value, result);
		}

		/* Set input parameter defaults */
		if (!result.containsKey("DoValidate")) {
			result.put("DoValidate", false);
		}
		return result;
	}

	/*
	 * Note that utilities for comparing patterns are not necessary, since Java
	 * pattern classes have an implemented equals() method.
	 */
}
