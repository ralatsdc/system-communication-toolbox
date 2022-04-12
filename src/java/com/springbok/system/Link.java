/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.system;

import Jama.Matrix;
import com.celestrak.sgp4v.ObjectDecayed;
import com.springbok.station.Beam;
import com.springbok.station.EarthStation;
import com.springbok.station.SpaceStation;
import com.springbok.station.Station;
import com.springbok.twobody.Coordinates;
import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.MException;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * Describes a link between two stations.
 */
public class Link {

    protected static class Angle {
        //angle [deg]
        private double phi;
        //azm - Azimuth [deg]
        private double azm;
        //elv - Elevation [deg]
        private double elv;

        public Angle(double phi, double azm, double elv) {
            this.phi = phi;
            this.azm = azm;
            this.elv = elv;
        }

        public Angle() {
        }

        public double getPhi() {
            return phi;
        }

        public void setPhi(double phi) {
            this.phi = phi;
        }

        public double getAzimuth() {
            return azm;
        }

        public void setAzimuth(double azm) {
            this.azm = azm;
        }

        public double getElevation() {
            return elv;
        }

        public void setElevation(double elv) {
            this.elv = elv;
        }

    }


    // A transmit station
    private Station transmitStation;

    // A transmit station beam
    private Beam transmitStationBeam;

    // A receive station
    private Station receiveStation;

    // Propagation loss models to apply
    private Object[] losses;

    // Flag to check input arguments, or not
    private boolean doCheck;

    public Station getTransmitStation() {
        return transmitStation;
    }

    public Beam getTransmitStationBeam() {
        return transmitStationBeam;
    }

    public Station getReceiveStation() {
        return receiveStation;
    }

    public Object[] getLosses() {
        return losses;
    }

    public boolean isDoCheck() {
        return doCheck;
    }

    /**
     * Constructs a Link.
     *
     * @param transmitStation     A transmit station
     * @param transmitStationBeam A transmit station beam
     * @param receiveStation      A receive station
     * @param losses              Propagation loss models to apply
     * @param DoCheck             Flag for checking input values (default is 1)
     */

    public Link() {
        this.doCheck = true;
    }

    public Link(Station transmitStation, Beam transmitStationBeam, Station receiveStation, Object[] losses, Map options) {
        // Parse variable input arguments
        this.set_doCheck((boolean) options.getOrDefault("DoCheck", true));

        // Assign properties
        this.set_transmitStation(transmitStation);
        this.set_transmitStationBeam(transmitStationBeam);
        this.set_receiveStation(receiveStation);
        this.set_losses(losses);
    }

    /**
     * Copies a Link.
     *
     * @return A new Link instance
     */
    public Link copy() {
        Map options = new HashMap<String, Object>();
        options.put("DoCheck", doCheck);
        return new Link(
                this.transmitStation != null ? this.transmitStation.copy() : null,
                this.transmitStationBeam != null ? this.transmitStationBeam.copy() : null,
                this.receiveStation != null ? this.receiveStation.copy() : null,
                this.losses != null ? this.losses.clone() : null,
                options
        );
    }

    /**
     * Sets the transmit station.
     *
     * @param transmitStation A transmit station
     */
    public void set_transmitStation(Station transmitStation) {
        this.transmitStation = transmitStation;
    }

    /**
     * Sets the transmit station beam.
     *
     * @param transmitStationBeam A transmit station beam
     */
    public void set_transmitStationBeam(Beam transmitStationBeam) {
        if (this.doCheck) {
            if (
                    this.transmitStation instanceof EarthStation
                            && !((EarthStation) this.transmitStation).getBeam().equals(transmitStationBeam)
                            || this.transmitStation instanceof SpaceStation
                            && !Arrays.asList(((SpaceStation) this.transmitStation).getBeams()).contains(transmitStationBeam)
            ) {
                throw new MException("Springbok:IllegalArgumentException",
                        "Invalid transmit station beam");
            }
        }
        this.transmitStationBeam = transmitStationBeam;
    }

    /**
     * Sets the receive station.
     *
     * @param receiveStation A receive station
     */
    public void set_receiveStation(Station receiveStation) {
        this.receiveStation = receiveStation;
    }

    /**
     * Sets propagation loss models to apply
     *
     * @param losses Propagation loss models to apply
     */
    public void set_losses(Object[] losses) {
        this.losses = losses;
    }

    /**
     * Sets flag to check input arguments, or not.
     *
     * @param doCheck Flag to check input arguments, or not
     */
    public void set_doCheck(boolean doCheck) {
        this.doCheck = doCheck;

    }

    /**
     * Computes performance of the link in the presence of an
     * interfering system.
     *
     * @param dNm               Current date number
     * @param interferingSystem Interfering system
     * @param numSmpES          Factor of Earth stations to which a space station
     *                          was assigned
     * @param numSmpBm          Factor of Space station beams assigned
     *                          ref_bw - Reference bandwidth [kHz]
     * @param DoIS              Flag for computing up link performance in the
     *                          presence of inter-satellite interference (optional,
     *                          default is 0)
     * @return Link performance
     */


    public Performance computePerformance(ModJulianDate dNm, System interferingSystem, double numSmpES, double numSmpBm,
                                          double ref_bw, Map options) throws ObjectDecayed {
    /*    Performance performance;
        if (this.isEmpty()) {
            return new Performance();
        }

        // Parse variable input arguments
        boolean doIS = (boolean) options.getOrDefault("DoIS", false);

        // Assign wanted transmit and receive station, for clarity
        Station trnStn_w = this.transmitStation;
        Beam trnStnBm_w = this.transmitStationBeam;
        Station rcvStn_w = this.receiveStation;

        Matrix trnStn_w_r_ger;
        Matrix rcvStn_w_r_ger;
        // Assign positions for the wanted stations
        //TODO: Probably error in code. EarthStation class does not have public method compute_r_ger with param dNm
        if (trnStn_w instanceof SpaceStation) {
            trnStn_w_r_ger = ((SpaceStation) trnStn_w).getR_ger();
            rcvStn_w_r_ger = ((SpaceStation) rcvStn_w).compute_r_ger(dNm);
        } else {
            trnStn_w_r_ger = ((EarthStation) trnStn_w).compute_r_gei(dNm); //TODO: must be compute_r_ger
            rcvStn_w_r_ger = ((EarthStation) rcvStn_w).get_R_ger();
        }

        Station[] trnStns_i = new Station[]{};
        Beam[] trnStnsBms_i;
        Station[] rcvStns_i = new Station[]{};
        int idxVisSS, idxVisTx;
        int nNet = 0;
            // Assign visible interfering transmit and receive stations
        if (interferingSystem != null) {
            if (!doIS) {
                //  for consistency with wanted transmit station class
                if (trnStn_w instanceof EarthStation) {
                    trnStns_i = interferingSystem.get_assignedEarthStations();
                    trnStnsBms_i = interferingSystem.get_assignedEarthStationBeams();
                    rcvStns_i = interferingSystem.get_assignedSpaceStations();

                    // This is an up link, so assign interfering system Earth
                    // stations visible to this link space station
                    int[] arr = findIdxVisEStoSS(Arrays.copyOf(trnStns_i, trnStns_i.length, EarthStation[].class),
                            new SpaceStation[]{(SpaceStation) rcvStn_w}, dNm);
                    idxVisSS = arr[0];
                    idxVisTx = arr[1];
                } else {
                    trnStns_i = interferingSystem.get_assignedSpaceStations();
                    trnStnsBms_i = interferingSystem.get_assignedSpaceStationBeams();
                    rcvStns_i = interferingSystem.get_assignedEarthStations();

                    // This is a down link, so assign interfering system space
                    // stations visible to this link Earth station
                    int[] arr = findIdxVisEStoSS(new EarthStation[]{(EarthStation) rcvStn_w},
                            Arrays.copyOf(trnStns_i, trnStns_i.length, SpaceStation[].class), dNm);
                    idxVisSS = arr[0];
                    idxVisTx = arr[1];
                }
            } else {
                if (!(trnStn_w instanceof EarthStation)) {
                    throw new MException("Springbok:IllegalArgumentException",
                            "IS case only applicable for an uplink");
                }
                trnStns_i = interferingSystem.get_assignedSpaceStations();
                trnStnsBms_i = interferingSystem.get_assignedSpaceStationBeams();
                rcvStns_i = interferingSystem.get_assignedEarthStations();

                // This is an inter-satellite link, so assign interfering
                // system space stations visible to this link space station
                int[] arr = findIdxVisSStoSS(new Station[]{rcvStn_w}, trnStns_i, dNm);
                idxVisSS = arr[0];
                idxVisTx = arr[1];
            }
            // Select visible interfering transmit and receive stations
            trnStns_i = new Station[]{trnStns_i[idxVisSS]};
            trnStnsBms_i = new Beam[]{trnStnsBms_i[idxVisTx]};
            rcvStns_i = new Station[]{rcvStns_i[idxVisTx]};
            nNet = trnStns_i.length;
        }

        Matrix[] trnStns_i_r_ger = new Matrix[5];
        Matrix[] rcvStns_i_r_ger = new Matrix[5];

            // Assign positions for the interfering stations
        if (interferingSystem != null) {
            if (!doIS) {
                if (trnStn_w instanceof EarthStation) {
                    //  for consistency with wanted transmit station class
                    for (int iNet = 0; iNet <= nNet; iNet++) {
                        trnStns_i_r_ger[iNet] = ((EarthStation) trnStns_i[iNet]).get_R_ger();
                        rcvStns_i_r_ger[iNet] = ((EarthStation) rcvStns_i[iNet]).compute_r_gei(dNm);
                    }
                } else {
                    for (int iNet = 0; iNet <= nNet; iNet++) {
                        trnStns_i_r_ger[iNet] = ((SpaceStation) trnStns_i[iNet]).compute_r_ger(dNm);
                        rcvStns_i_r_ger[iNet] = ((SpaceStation) rcvStns_i[iNet]).getR_ger();
                    }
                }
            } else {
                for (int iNet = 0; iNet <= nNet; iNet++) {
                    //TODO: variables trnStns_i and rcvStns_i are Earth or Space stations?
                    trnStns_i_r_ger[iNet] = ((SpaceStation) trnStns_i[iNet]).compute_r_ger(dNm);
                    rcvStns_i_r_ger[iNet] = ((SpaceStation) rcvStns_i[iNet]).getR_ger();
                }
            }
        }

        // Assign frequency and propagation path length
        double f_w = trnStn_w.getEmission().getFreq_mhz();
        double d_w = computeDistance(trnStn_w_r_ger, rcvStn_w_r_ger);

        // Assign power density, transmit and receive gain, and
        // propagation path loss
        //TODO: uncomment when antenna will have pattern property
            if (trnStn_w.getTransmitAntenna().getPattern() instanceof SampledPattern) {
            phi_t_w = computeAngles(trnStn_w, trnStn_w_r_ger, rcvStn_w_r_ger);
            G_t_w_0 = trnStn_w.transmitAntenna.pattern.gain(
                    phi_t_w, 0, phi_t_w, trnStn_w.transmitAntenna.options {:});

      else
            G_t_w_0 = trnStn_w.transmitAntenna.pattern.gain(
                    0, trnStn_w.transmitAntenna.options {:});

            end         // if
            if isa(rcvStn_w.receiveAntenna.pattern, "SampledPattern")
            phi_r_w = Link.computeAngles(rcvStn_w, rcvStn_w_r_ger, trnStn_w_r_ger);
            G_r_w_0 = rcvStn_w.receiveAntenna.pattern.gain(
                    phi_r_w, 0, phi_r_w, rcvStn_w.receiveAntenna.options {:});

      else
            G_r_w_0 = rcvStn_w.receiveAntenna.pattern.gain(
                    0, rcvStn_w.receiveAntenna.options {:});

            end         // if
        double SL_w = 0;
        double PD_w = 0;
        if (trnStn_w.getEmission().getPwr_flx_ds() != 0) {
            SL_w = Propagation.computeSL(d_w);
            //PD_w = trnStn_w.emission.pwr_flx_ds - G_t_w_0 + SL_w;
        } else {
            PD_w = trnStn_w.getEmission().getPwr_ds_max();
        }

        double ML_w = 10 * Math.log10(trnStnBm_w.getDivisions());
        double DCL_w = 10 * Math.log10(100 / trnStnBm_w.getDutyCycle());
        double PL_w = Propagation.computeFSL(f_w, d_w);

        // Compute carrier power density
            C = PD_w - ML_w - DCL_w + G_t_w_0 - PL_w + G_r_w_0;

            // Assign receiver noise temperature
        double T_w = rcvStn_w.getReceiveAntenna().get_noise_t();

        // Compute noise power density
        double N = Propagation.k + 10 * Math.log10(T_w);

        // Consider each interfering network
        double[] i = new double[]{Double.NEGATIVE_INFINITY};
        double I = Double.NEGATIVE_INFINITY;
        double[] epfd = new double[]{Double.NEGATIVE_INFINITY};
        double EPFD = Double.NEGATIVE_INFINITY;

        if (interferingSystem != null) {
            i = SystemUtils.negativeInf(nNet);
            epfd = SystemUtils.negativeInf(nNet);
            for (int iNet = 0; iNet < nNet; iNet++) {
                // Assign frequency and propagation path length
                double f_i = trnStns_i[iNet].getEmission().getFreq_mhz();
                double d_i_i = computeDistance(trnStns_i_r_ger[iNet], rcvStns_i_r_ger[iNet]);
                double d_i_w = computeDistance(trnStns_i_r_ger[iNet], rcvStn_w_r_ger);

                // Assign power density, transmit and receive gain, and
                // propagation path and spreading loss
                    if isa(trnStns_i(iNet).transmitAntenna.pattern, "SampledPattern")
                            [phi_t_i, azm_r_w, elv_r_w] =Link.computeAngles(
                            trnStns_i(iNet), trnStns_i_r_ger {
                        iNet
                    },rcvStns_i_r_ger {
                        iNet
                    },rcvStn_w_r_ger);
                    G_t_i = trnStns_i(iNet).transmitAntenna.pattern.gain(
                            phi_t_i, azm_r_w, elv_r_w, trnStns_i(iNet).transmitAntenna.options {:});
            else
                    theta_t_i = Link.computeTheta(
                            trnStns_i_r_ger {
                        iNet
                    },rcvStns_i_r_ger {
                        iNet
                    },rcvStn_w_r_ger);
                    G_t_i = trnStns_i(iNet).transmitAntenna.pattern.gain(
                            theta_t_i, trnStns_i(iNet).transmitAntenna.options {:});

                    end         // if
                double SL_i_w = Propagation.computeSL(d_i_w);
                    if isa(rcvStn_w.receiveAntenna.pattern, "SampledPattern")
                            [phi_r_w, azm_t_i, elv_t_i] =Link.computeAngles(
                            rcvStn_w, rcvStn_w_r_ger, trnStn_w_r_ger, trnStns_i_r_ger {
                        iNet
                    });
                    G_r_w = rcvStn_w.receiveAntenna.pattern.gain(
                            phi_r_w, azm_t_i, elv_t_i, rcvStn_w.receiveAntenna.options {:});

          else
                    theta_r_w = Link.computeTheta(
                            rcvStn_w_r_ger, trnStn_w_r_ger, trnStns_i_r_ger {
                        iNet
                    });
                    G_r_w = rcvStn_w.receiveAntenna.pattern.gain(
                            theta_r_w, rcvStn_w.receiveAntenna.options {:});

                    end         // if
            }
        }

        if ~isempty(trnStns_i(iNet).emission.pwr_flx_ds)
        if isa(trnStns_i(iNet).transmitAntenna.pattern, "SampledPattern")
        G_t_i_0 = trnStns_i(iNet).transmitAntenna.pattern.gain(
                phi_t_i, 0, phi_t_i, trnStns_i(iNet).transmitAntenna.options {:});

            else
        G_t_i_0 = trnStns_i(iNet).transmitAntenna.pattern.gain(
                0, trnStns_i(iNet).transmitAntenna.options {:});

        end         // if
                SL_i_i = Propagation.computeSL(d_i_i);
        PD_i = trnStns_i(iNet).emission.pwr_flx_ds - G_t_i_0 + SL_i_i;

          else
        PD_i = trnStns_i(iNet).emission.pwr_ds_max;

        end         // if
                ML_i = 10 * log10(trnStnsBms_i(iNet).divisions);
        DCL_i = 10 * log10(100 / trnStnsBms_i(iNet).dutyCycle);
        PL_i = Propagation.computeFSL(f_i, d_i_w);

        // Compute interference power density
        i(iNet) = PD_i - ML_i - DCL_i + G_t_i - PL_i + G_r_w
                + 10 * log10(numSmpES * numSmpBm);         // Due to sampling
        I = 10 * log10(10 ^ (I / 10) + 10 ^ (i(iNet) / 10));

        // Compute equivalent power flux density
        epfd(iNet) = PD_i - ML_i - DCL_i + G_t_i - SL_i_w + G_r_w - G_r_w_0 + 10 * log10(ref_bw * 1000)
                + 10 * log10(numSmpES * numSmpBm);         // Due to sampling
        EPFD = 10 * log10(10 ^ (EPFD / 10) + 10 ^ (epfd(iNet) / 10));

        end         // for

                    end         // if

            // Assign carrier, noise, and interference power density
            performance = Performance(C, N, i, I, epfd, EPFD);

            end         // computePerformance(*/
        return null;
    }


    /**
     * Determines if Link properties are empty, or not.
     */
    public boolean isEmpty() {
        return this.transmitStation == null &&
                this.receiveStation == null &&
                this.losses == null;
    }

    /**
     * Computes distance between two stations.
     *
     * @param r_one First station position
     * @param r_two Second station position
     * @return Distance [km]
     */
    public double computeDistance(Matrix r_one, Matrix r_two) {
        if (r_one.getRowDimension() != 3 && r_one.getColumnDimension() != 1
                || r_two.getRowDimension() != 3 && r_two.getColumnDimension() != 1) {
            throw new MException("Springbok:IllegalArgumentException",
                    "Positions must be column vectors");
        }
        // Compute relative position vector
        Matrix r_two_one = r_two.minus(r_one);

        double matrixProduct = r_two_one.transpose().times(r_two_one).get(0, 0);
        // Compute distance
        double distance = Math.sqrt(matrixProduct) * EarthConstants.R_oplus;
        // [km] = [er] * [km/er]
        return distance;
    }

    /**
     * Computes the angle between two unit vectors pointing from a
     * reference station to two other stations
     *
     * @param r_ref Reference station position
     * @param r_one First station position
     * @param r_two Second station position
     * @return Angle between unit vectors [deg]
     */
    public double computeTheta(Matrix r_ref, Matrix r_one, Matrix r_two) {
        if (r_ref.getRowDimension() != 3 && r_ref.getColumnDimension() != 1
                || r_one.getRowDimension() != 3 && r_one.getColumnDimension() != 1
                || r_two.getRowDimension() != 3 && r_two.getColumnDimension() != 1) {
            throw new MException("Springbok:IllegalArgumentException",
                    "Positions must be column vectors");
        }

        // Compute relative position vectors
        Matrix r_one_ref = r_one.minus(r_ref);
        Matrix r_two_ref = r_two.minus(r_ref);

        // Compute unit vectors
        Matrix u_one_ref = r_one_ref.times(1 / Math.sqrt(r_one_ref.transpose().times(r_one_ref).get(0, 0)));
        Matrix u_two_ref = r_two_ref.times(1 / Math.sqrt(r_two_ref.transpose().times(r_two_ref).get(0, 0)));

        // Compute angle between
        double cos = u_one_ref.transpose().times(u_two_ref).get(0, 0);
        double acos;
        if (Double.compare(Math.floor(cos), 1) == 0) {
            acos = 0;
        } else if (Double.compare(Math.ceil(cos), -1) == 0) {
            acos = Math.PI;
        } else {
            acos = Math.acos(cos);
        }

        double theta = Math.toDegrees(acos);
        return theta;
    }

    /**
     * Computes the angles from boresight, defined by the reference
     * position, and the first and second position relative to the
     * reference position. As a result, the first angle from boresight
     * is the scan angle, and the second angle from boresight is the
     * elevation. Defines a local coordinate system with z axis aligned
     * with boresight, x axis such that the x-z axis contains the first
     * relative position vector, and y axis giving a right handed
     * system. Computes the azimuth (from the x axis) corresponding to
     * the second position.
     *
     * @param refStn Reference station
     * @param r_ref  Reference station position
     * @param r_one  First station position
     * @param r_two  Second station position
     * @return Elevation (corresponds to second position) [deg]
     */
    public Angle computeAngles(Station refStn, Matrix r_ref, Matrix... r_one_two) {
        if (r_one_two.length < 1 || r_one_two.length > 2) {
            throw new MException("Springbok:IllegalArgumentException",
                    "Two or threes position vectors are required");
        } else {
            boolean isValid = r_ref.getRowDimension() == 3 && r_ref.getColumnDimension() == 1
                    && r_one_two[0].getRowDimension() == 3 && r_one_two[0].getColumnDimension() == 1;
            if (r_one_two.length == 2) {
                isValid = isValid && r_one_two[1].getRowDimension() == 3 && r_one_two[1].getColumnDimension() == 1;
            }
            if (!isValid) {
                throw new MException("Springbok:IllegalArgumentException",
                        "Positions must be column vectors");
            }
        }

        Matrix r_one = r_one_two[0];

        // Compute first relative position vector
        Matrix r_one_ref = r_one.minus(r_ref);

        // Compute unit vectors
        Matrix u_ref = r_ref.times(1 / Math.sqrt(r_ref.transpose().times(r_ref).get(0, 0)));

        if (refStn instanceof SpaceStation) {
            // Space station antennas point toward the center of the
            // Earth
            u_ref = u_ref.uminus();
        }
        Matrix u_one_ref = r_one_ref.times(1 / Math.sqrt(r_one_ref.transpose().times(r_one_ref).get(0, 0)));

        // Compute scan angle (angle between boresight and first
        // position directions)
        double phi = Math.toDegrees(Math.acos(u_ref.transpose().times(u_one_ref).get(0, 0)));

        double azm = 0;
        double elv = 0;
        if (r_one_two.length == 2) {
            Matrix z_hat = u_ref;
            Matrix y_hat = new Matrix(3, 1);

            // Compute second relative position vector
            Matrix r_two = r_one_two[1];
            Matrix r_two_ref = r_two.minus(r_ref);

            // Compute unit vector
            Matrix u_two_ref = r_two_ref.times(1 / Math.sqrt(r_two_ref.transpose().times(r_two_ref).get(0, 0)));

            // Compute elevation (angle between scan and second position
            // directions)
            double s = u_one_ref.transpose().times(u_two_ref).get(0, 0);
            elv = Math.toDegrees(Math.acos(u_one_ref.transpose().times(u_two_ref).get(0, 0)));

            // Compute local coordinate system unit vectors
            if (Double.compare(u_one_ref.minus(z_hat).transpose().times(u_one_ref.minus(z_hat)).get(0, 0), 0) == 0) {
                // Reference and first relative position vectors are aligned
                y_hat.set(0, 0, 0);
                y_hat.set(1, 0, z_hat.get(2, 0));
                y_hat.set(2, 0, z_hat.get(1, 0));
            } else {
                y_hat = Coordinates.cross(z_hat, u_one_ref);
            }
            y_hat = y_hat.times(1 / Math.sqrt(y_hat.transpose().times(y_hat).get(0, 0)));
            Matrix x_hat = Coordinates.cross(y_hat, z_hat);

            // Compute azimuth (angle in the array plane between the
            // plane containing scan and boresight directions and plane
            // containing second position and boresight directions)
            double x_two_ref = u_two_ref.transpose().times(x_hat).get(0, 0);
            double y_two_ref = u_two_ref.transpose().times(y_hat).get(0, 0);

            azm = Math.atan2(y_two_ref, x_two_ref) * 180 / Math.PI;
        }

        return new Angle(phi, azm, elv);
    }

    /**
     * Finds index of each Earth station which is visible to at least
     * one space station, and conversely.
     *
     * @param earthStations Earth stations with which visibility is
     *                      determined
     * @param spaceStations Space stations with which visibility is
     *                      determined
     * @param dNm           Date number at which the position vectors occur
     */
    public Object[] findIdxVisEStoSS(EarthStation[] earthStations, SpaceStation[] spaceStations, ModJulianDate dNm) {
        int nSS = spaceStations.length;
        int nES = earthStations.length;

        int[][] idxVisES = new int[nSS][nES];
        int[][] idxVisSS = new int[nSS][nES];

        Matrix[] r_ger_SS = new Matrix[nSS];

        for (int iSS = 0; iSS < nSS; iSS++) {
            try {
                r_ger_SS[iSS] = spaceStations[iSS].compute_r_ger(dNm);
            } catch (ObjectDecayed objectDecayed) {
                objectDecayed.printStackTrace();
            }
            int[] tmpVisES = new int[nES];
            int[] tmpVisSS = new int[nES];

            for (int iES = 0; iES < nES; iES++) {
                Matrix r_ger_ES = earthStations[iES].get_R_ger();
                double theta = System.computeAngleFromZenith(r_ger_SS[iSS], r_ger_ES);

                if (theta < 90) {
                    tmpVisES[iES] = iES;
                    tmpVisSS[iES] = iSS;
                }
            }
            idxVisES[iSS] = tmpVisES;
            idxVisSS[iSS] = tmpVisSS;
        }

        idxVisES = SystemUtils.findUniqueBiggerThenZero(idxVisES);
        idxVisSS = SystemUtils.findUniqueBiggerThenZero(idxVisSS);

        idxVisES = SystemUtils.reshape(idxVisES, 1, idxVisES.length); //TODO: size could be wrong

        idxVisSS = SystemUtils.reshape(idxVisSS, 1, idxVisSS.length); //TODO: size could be wrong

        return new Object[]{idxVisES, idxVisSS, r_ger_SS};
    }

    /**
     * Finds index of each space station in the first array of space
     * stations which is visible to at least one space station in the
     * second array of space stations, and conversely.
     *
     * @param spaceStationsA First array space stations with which
     *                       visibility is determined
     * @param spaceStationsB Second array of space stations with which
     *                       visibility is determined
     * @param dNm            Date number at which the position vectors occur
     */
    public Object[] findIdxVisSStoSS(Station[] spaceStationsA, Station[] spaceStationsB, ModJulianDate dNm) {
        if (!(spaceStationsA instanceof SpaceStation[])) {
            throw new MException("Springbok:IllegalArgumentException",
                    "Input must be an array of class 'SpaceStation' instances");
        }

        if (!(spaceStationsB instanceof EarthStation[])) {
            throw new MException("Springbok:IllegalArgumentException",
                    "Input must be an array of class 'SpaceStation' instances");
        }

        int nSS_A = spaceStationsA.length;
        Matrix[] r_ger_SS_A = new Matrix[nSS_A];
        Matrix[] d_ger_SS_A = new Matrix[nSS_A];
        double[] alpha = new double[nSS_A];
        for (int iSS_A = 0; iSS_A < nSS_A; iSS_A++) {
            try {
                r_ger_SS_A[iSS_A] = ((SpaceStation) spaceStationsA[iSS_A]).compute_r_ger(dNm);
                d_ger_SS_A[iSS_A] = new Matrix(1, 1, Math.sqrt(r_ger_SS_A[iSS_A].transpose().times(r_ger_SS_A[iSS_A])
                        .get(0, 0)));
                alpha[iSS_A] = Math.toDegrees(Math.acos(1.0 / d_ger_SS_A[iSS_A].get(0, 0)));
            } catch (ObjectDecayed objectDecayed) {
                objectDecayed.printStackTrace();
            }
        }


        int nSS_B = spaceStationsB.length;
        Matrix[] r_ger_SS_B = new Matrix[nSS_B];
        Matrix[] d_ger_SS_B = new Matrix[nSS_B];
        double[] beta = new double[nSS_B];
        for (int iSS_B = 0; iSS_B < nSS_B; iSS_B++) {
            try {
                r_ger_SS_B[iSS_B] = ((SpaceStation) spaceStationsB[iSS_B]).compute_r_ger(dNm);
                d_ger_SS_B[iSS_B] = new Matrix(1, 1, Math.sqrt(r_ger_SS_B[iSS_B].transpose().times(r_ger_SS_B[iSS_B]).get(0, 0)));
                beta[iSS_B] = Math.toDegrees(Math.acos(1.0 / d_ger_SS_B[iSS_B].get(0, 0)));
            } catch (ObjectDecayed objectDecayed) {
                objectDecayed.printStackTrace();
            }

        }

        int[][] idxVisSS_A = new int[nSS_A][nSS_B];
        int[][] idxVisSS_B = new int[nSS_A][nSS_B];

        for (int iSS_A = 0; iSS_A < nSS_A; iSS_A++) {
            int[] tmpVisSS_A = new int[nSS_B];
            int[] tmpVisSS_B = new int[nSS_B];

            for (int iSS_B = 0; iSS_B < nSS_B; iSS_B++) {
                double theta = Math.toDegrees(Math.acos((r_ger_SS_A[iSS_A].arrayRightDivide(d_ger_SS_A[iSS_A])).transpose()
                        .times(r_ger_SS_B[iSS_B].arrayRightDivide(d_ger_SS_B[iSS_B])).get(0, 0)));
                if (theta < alpha[iSS_A] + beta[iSS_B]) {
                    tmpVisSS_A[iSS_B] = iSS_A;
                    tmpVisSS_B[iSS_B] = iSS_B;
                }
            }

            idxVisSS_A[iSS_A] = tmpVisSS_A;
            idxVisSS_B[iSS_A] = tmpVisSS_B;
        }

        idxVisSS_A = SystemUtils.findUniqueBiggerThenZero(idxVisSS_A);
        idxVisSS_B = SystemUtils.findUniqueBiggerThenZero(idxVisSS_B);

        idxVisSS_A = SystemUtils.reshape(idxVisSS_A, 1, idxVisSS_A.length);
        idxVisSS_B = SystemUtils.reshape(idxVisSS_B, 1, idxVisSS_B.length);

        return new Object[]{idxVisSS_A, idxVisSS_B, r_ger_SS_A, r_ger_SS_B};
    }


    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        if (transmitStation != null) {
            temp = Double.doubleToLongBits(transmitStation.hashCode());
            result = prime * result + (int) (temp ^ (temp >>> 32));
        }
        if (transmitStationBeam != null) {
            temp = Double.doubleToLongBits(transmitStationBeam.hashCode());
            result = prime * result + (int) (temp ^ (temp >>> 32));
        }
        if (receiveStation != null) {
            temp = Double.doubleToLongBits(receiveStation.hashCode());
            result = prime * result + (int) (temp ^ (temp >>> 32));
        }
        temp = Double.doubleToLongBits(Arrays.hashCode(losses));
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
        if (!(obj instanceof Link)) {
            return false;
        }
        Link other = (Link) obj;

        if (!transmitStation.equals(other.transmitStation)) {
            return false;
        }
        if (!transmitStationBeam.equals(other.transmitStationBeam)) {
            return false;
        }
        if (!receiveStation.equals(other.receiveStation)) {
            return false;
        }
        if (!Arrays.equals(losses, other.losses)) {
            return false;
        }
        return doCheck == other.doCheck;
    }
}