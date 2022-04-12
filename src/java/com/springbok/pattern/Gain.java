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
