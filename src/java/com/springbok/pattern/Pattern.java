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
