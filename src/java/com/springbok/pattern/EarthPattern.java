/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

/**
 * Defines a type required to describe an ITU antenna pattern for Earth
 * transmitting and receiving.
 * 
 * @author raymondleclair
 */
public interface EarthPattern extends Pattern {

	/**
	 * Copies an EarthPattern.
	 * 
	 * @return A new EarthPattern
	 */
	public abstract EarthPattern copy();
}
