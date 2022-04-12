/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.system;

import java.util.Arrays;

/**
 * Describes a space station
 */
public class Performance {

    // Carrier power density [dBW/Hz]
    private double C;

    // Noise power density [dBW/Hz]
    private double N;

    // Interference power density for each network [dBW/Hz]
    private double[] i;

    // Interference power density total [dBW/Hz]
    private double I;

    // Equivalent power flux density for each network [dBW/m^2 in reference bandwidth]
    private double[] epfd;

    // Equivalent power flux density total [dBW/m^2 in reference bandwidth]
    private double EPFD;

    public double getC() {
        return C;
    }

    public double getN() {
        return N;
    }

    public double[] get_i() {
        return i;
    }

    public double getI() {
        return I;
    }

    public double[] getEpfd() {
        return epfd;
    }

    public double getEPFD() {
        return EPFD;
    }

    /**
     * Constructs a Performance.
     *
     * @param C    Carrier power density [dBW/Hz]
     * @param N    Noise power density [dBW/Hz]
     * @param i    Interference power density for each network [dBW/Hz]
     * @param I    Interference power density total [dBW/Hz]
     * @param epfd Equivalent power flux density for each network
     *             [dBW/m^2 in reference bandwidth]
     * @param EPFD Equivalent power flux density total [dBW/m^2 in
     *             reference bandwidth]
     */
    public Performance(double C, double N, double[] i, double I, double[] epfd, double EPFD) {
        // Assign properties
        this.set_C(C);
        this.set_N(N);
        this.set_i(i);
        this.set_I(I);
        this.set_EPFD(EPFD);
        this.set_epfd(epfd);
    }

    public Performance() {
    }

    /**
     * Copies a Performance.
     *
     * @return A new Performance instance
     */
    public Performance copy() {
        return new Performance(
                this.C, this.N, this.i.clone(), this.I, this.epfd.clone(), this.EPFD);
    }

    /**
     * Sets carrier power density [dBW/Hz].
     *
     * @param C Carrier power density [dBW/Hz]
     */
    public void set_C(double C) {
        this.C = C;
    }

    /**
     * Sets noise power density [dBW/Hz].
     *
     * @param N Noise power density [dBW/Hz]
     */
    public void set_N(double N) {
        this.N = N;
    }

    /**
     * Sets interference power density for each network [dBW/Hz].
     *
     * @param i Interference power density for each network [dBW/Hz]
     */
    public void set_i(double[] i) {
        this.i = i;
    }

    /**
     * Sets interference power density total [dBW/Hz].
     *
     * @param I Interference power density total [dBW/Hz]
     */
    public void set_I(double I) {
        this.I = I;
    }

    /**
     * Sets equivalent power flux density for each network [dBW/m^2
     * in reference bandwidth].
     *
     * @param EPFD Equivalent power flux density for each network
     *             [dBW/m^2 in reference bandwidth]
     */
    public void set_epfd(double[] epfd) {
        this.epfd = epfd;
    }

    /**
     * Sets equivalent power flux density total [dBW/m^2 in
     * reference bandwidth].
     *
     * @param EPFD Equivalent power flux density total [dBW/m^2 in
     *             reference bandwidth]
     */
    public void set_EPFD(double EPFD) {
        this.EPFD = EPFD;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(C);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(N);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(i));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(I);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(Arrays.hashCode(epfd));
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(EPFD);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        return result;
    }

    /* (non-Javadoc)
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
        if (!(obj instanceof Performance)) {
            return false;
        }
        Performance other = (Performance) obj;
        if (Double.doubleToLongBits(C) != Double
                .doubleToLongBits(other.C)) {
            return false;
        }
        if (Double.doubleToLongBits(N) != Double
                .doubleToLongBits(other.N)) {
            return false;
        }
        if (!Arrays.equals(i, other.i)) {
            return false;
        }
        if (Double.doubleToLongBits(I) != Double
                .doubleToLongBits(other.I)) {
            return false;
        }
        if (!Arrays.equals(epfd, other.epfd)) {
            return false;
        }
        return Double.doubleToLongBits(EPFD) == Double
                .doubleToLongBits(other.EPFD);
    }
}