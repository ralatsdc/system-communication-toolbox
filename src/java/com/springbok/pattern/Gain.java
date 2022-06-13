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

/**
 * Contains gain values.
 * 
 * @author raymondleclair
 */
public class Gain {

	/** Co-polar gain [dB] */
	public double G;
	/** Cross-polar gain [dB] */
	public double Gx;

	/**
	 * Construct an instance of class Gain with default values.
	 */
	public Gain() {
		this.G = 0.0;
		this.Gx = 0.0;
	}

	/**
	 * Constructs an instance of class Gain with specified values.
	 * 
	 * @param G
	 * @param Gx
	 */
	public Gain(double G, double Gx) {
		this.G = G;
		this.Gx = Gx;
	}
}
