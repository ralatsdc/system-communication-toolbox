/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */

package com.springbok.pattern;

/**
 * Defines methods required to describe an ITU antenna pattern for space
 * transmitting and receiving.
 */
public interface SpacePattern extends Pattern {
	public SpacePattern copy();
}