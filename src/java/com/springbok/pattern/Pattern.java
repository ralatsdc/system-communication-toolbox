/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

import java.util.Map;

/**
 * Defines methods required to describe an ITU antenna pattern.
 * 
 * @author raymondleclair
 */
public interface Pattern {

	/**
	 * Implements an ITU antenna pattern.
	 *
	 * @param phi
	 *            Angle for which a gain is calculated [degrees]
	 * @param options
	 *            Optional parameters as key/value pairs PlotFlag - Flag to indicate
	 *            plot, true or {false}
	 *
	 * @return Co-polar and cross-polar gain [dB]
	 */
	public abstract Gain gain(double phi, Map options);

	/**
	 * Copies a Pattern.
	 * 
	 * @return A new Pattern
	 */
	public abstract Pattern copy();

}
