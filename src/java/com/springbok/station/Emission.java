/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.station;

/**
 * Describes an emission.
 */
public class Emission {

    // Emission designator
    private String design_emi;

    // Maximum power density [dBW/Hz]
    private double pwr_ds_max;

    // Minimum power density [dBW/Hz]
    private double pwr_ds_min;

    // Center frequency [MHz]
    private double freq_mhz;

    // Required C/N [dB]
    private double c_to_n;

    // Power flux density [dBW/Hz/m2]
    private double pwr_flx_ds;

    public String getDesign_emi() {
        return design_emi;
    }

    public double getPwr_ds_max() {
        return pwr_ds_max;
    }

    public double getPwr_ds_min() {
        return pwr_ds_min;
    }

    public double getFreq_mhz() {
        return freq_mhz;
    }

    public double getC_to_n() {
        return c_to_n;
    }

    public double getPwr_flx_ds() {
        return pwr_flx_ds;
    }

    /**
     * Constructs an Emission.
     * @param design_emi Emission designator
     * @param pwr_ds_max Maximum power density [dBW/Hz]
     * @param pwr_ds_min Minimum power density [dBW/Hz]
     * @param freq_mhz Center frequency [MHz]
     * @param c_to_n Required C/N [dB]
     * @param pwr_flx_ds Power flux density [dBW/Hz/m2]
     */
    public Emission(String design_emi, double pwr_ds_max, double pwr_ds_min, double freq_mhz, double c_to_n, double pwr_flx_ds) {
        // Assign properties
        this.set_design_emi(design_emi);
        this.set_pwr_ds_max(pwr_ds_max);
        this.set_pwr_ds_min(pwr_ds_min);
        this.set_freq_mhz(freq_mhz);
        this.set_c_to_n(c_to_n);
        this.set_pwr_flx_ds(pwr_flx_ds);
    }

    /**
     * Copies an Emission.
     * @return A new Emission instance
     */
    public Emission copy() {
        return new Emission(this.design_emi, this.pwr_ds_max, this.pwr_ds_min,
                this.freq_mhz, this.c_to_n, this.pwr_flx_ds);
    }

    /**
     * Sets emission designator.
     * @param design_emi Emission designator
     */
    public void set_design_emi(String design_emi) {
        this.design_emi = design_emi;
    }

    /**
     * Sets maximum power density [dBW/Hz].
     * @param pwr_ds_max Maximum power density [dBW/Hz]
     */
    public void set_pwr_ds_max(double pwr_ds_max) {
        this.pwr_ds_max = pwr_ds_max;
    }

    /**
     * Sets minimum power density [dBW/Hz].
     * @param pwr_ds_min Minimum power density [dBW/Hz]
     */
    public void set_pwr_ds_min(double pwr_ds_min) {
        this.pwr_ds_min = pwr_ds_min;
    }

    /**
     * Sets center frequency [MHz].
     * @param freq_mhz Center frequency [MHz]
     */
    public void set_freq_mhz(double freq_mhz) {
        this.freq_mhz = freq_mhz;
    }

    /**
     * Sets required C/N [dB].
     * @param c_to_n Required C/N [dB]
     */
    public void set_c_to_n(double c_to_n) {
        this.c_to_n = c_to_n;
    }

    /**
     * Sets power flux density [dBW/Hz/m2].
     * @param pwr_flx_ds Power flux density [dBW/Hz/m2]
     */
    public void set_pwr_flx_ds(double pwr_flx_ds) {
        this.pwr_flx_ds = pwr_flx_ds;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(pwr_ds_max);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(pwr_ds_min);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(freq_mhz);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(c_to_n);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(pwr_flx_ds);
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
        if (!(obj instanceof Emission)) {
            return false;
        }
        Emission other = (Emission) obj;
        if (Double.doubleToLongBits(pwr_ds_max) != Double
                .doubleToLongBits(other.pwr_ds_max)) {
            return false;
        }
        if (Double.doubleToLongBits(pwr_ds_min) != Double
                .doubleToLongBits(other.pwr_ds_min)) {
            return false;
        }
        if (Double.doubleToLongBits(freq_mhz) != Double
                .doubleToLongBits(other.freq_mhz)) {
            return false;
        }
        if (Double.doubleToLongBits(c_to_n) != Double
                .doubleToLongBits(other.c_to_n)) {
            return false;
        }
        if (Double.doubleToLongBits(pwr_flx_ds) != Double
                .doubleToLongBits(other.pwr_flx_ds)) {
            return false;
        }

        return true;
    }
}