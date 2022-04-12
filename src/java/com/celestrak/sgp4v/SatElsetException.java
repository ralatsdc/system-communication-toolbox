package com.celestrak.sgp4v;

/**
 * Exception for SatElset problems
 * 
 * @author Joe Coughlin
 *
 */
@SuppressWarnings("serial")
public class SatElsetException extends Exception {

	/**
	 * SatElsetException constructor
	 */
	public SatElsetException() {
		super();
	}

	/**
	 * SatElsetException constructor
	 * 
	 * @param s
	 */
	public SatElsetException(String s) {
		super(s);
	}

}
