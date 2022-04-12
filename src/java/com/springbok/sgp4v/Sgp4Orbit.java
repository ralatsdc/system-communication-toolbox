package com.springbok.sgp4v;

import java.io.Serializable;
import java.util.ArrayList;

import Jama.Matrix;
import com.celestrak.sgp4v.ObjectDecayed;
import com.celestrak.sgp4v.SatElset;
import com.celestrak.sgp4v.SatElsetException;
import com.celestrak.sgp4v.Sgp4Data;
import com.celestrak.sgp4v.Sgp4Unit;
import com.celestrak.sgp4v.ValueOutOfRangeException;

import com.springbok.center.OrbitDetermination;
import com.springbok.center.SatelliteCatalog;
import com.springbok.twobody.EstimatedOrbit;
import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.KeplerianOrbit;
import com.springbok.twobody.ModJulianDate;
import com.springbok.twobody.Orbit;

/**
 * Describes an orbit using S1S2 elements by computing position relative to the
 * Earth center using the SGP4 propagator.
 * 
 * @author Raymond LeClair
 */
@SuppressWarnings("serial")
public class Sgp4Orbit implements Orbit, EstimatedOrbit, Serializable {

	/** Line one of a two line element set */
	private String lineOne;
	/** Line two of a two line element set */
	private String lineTwo;

	/** Epoch MJD calendar date */
	private ModJulianDate epoch;
	/** Satellite element set */
	private SatElset satElset;

	/** The SGP4 procedures */
	private Sgp4Unit sgp4Unit;
	/** The SGP4 data */
	private Sgp4Data sgp4Data;

	// TODO: Remove
	// private static ModJulianDateConversions mjdConverter = new ModJulianDateConversions();
	// private static DayOfYearConversions doyConverter = new DayOfYearConversions();


	@Override
	public ModJulianDate getEpoch() {
		return epoch;
	}

	/**
	 * Constructs an Sgp4Orbit given two line elements as strings.
	 * 
	 * @param lineOne
	 *            Line one of a two line element set
	 * @param lineTwo
	 *            Line two of a two line element set
	 * @throws SatElsetException
	 */
	public Sgp4Orbit(String lineOne, String lineTwo) throws SatElsetException {

		// Fundamental values.

		this.lineOne = lineOne;
		this.lineTwo = lineTwo;

		// Derived values.

		// TODO: Consider re-epoching to remove sub-milliscond time inaccuracy.
		int year = SatelliteCatalog
				.fixedWindowYYtoYYYY(Integer.parseInt(lineOne.substring(18, 20).trim().replace("+", "")));
		double day = Double.parseDouble(lineOne.substring(20, 32));

		// TODO: Remove
		// DayOfYear doy = new DayOfYear(year, day);
		// Model for time in day of year format YYYYDDD.dddd.
		// YYYY is the 4 digit year.
		// DDD is the day of year (1 for January 1).
		// dddd is the fraction of the day (0.5 is noon).
		// this.epoch = (ModJulianDate) doyConverter.convertFrame(doy, TimeSystem.MJD);
		this.epoch = ModJulianDate.convertDayOfYear(year, day);

		this.satElset = new SatElset(this.lineOne, this.lineTwo);

		this.sgp4Unit = new Sgp4Unit(this.satElset);
		this.sgp4Data = new Sgp4Data(this.satElset.getSatID());
	}

	/**
	 * Constructs an Sgp4Orbit given an Sgp4Orbit.
	 * 
	 * @param sgp4Orbit
	 *            An Sgp4Orbit to copy
	 */
	public Sgp4Orbit(Sgp4Orbit sgp4Orb) {

		// Fundamental values.

		this.lineOne = sgp4Orb.lineOne;
		this.lineTwo = sgp4Orb.lineTwo;

		// Derived values.

		this.epoch = sgp4Orb.epoch;
		this.satElset = sgp4Orb.satElset;

		this.sgp4Unit = sgp4Orb.sgp4Unit;
		this.sgp4Data = sgp4Orb.sgp4Data;
	}

	public void updateElset(SatElset elset) throws SatElsetException {
		this.satElset = elset;
		this.sgp4Unit = new Sgp4Unit(this.satElset);
		this.sgp4Data = new Sgp4Data(this.satElset.getSatID());
	}

	/**
	 * Constructs an Sgp4Orbit given an object identifier and a KeplerianOrbit.
	 * 
	 * @param objId
	 *            Object identifier
	 * @param kepOrb
	 *            A KeplerianOrbit to copy
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public Sgp4Orbit(long objId, KeplerianOrbit kepOrb) throws SatElsetException, ValueOutOfRangeException {

		if (kepOrb == null) {

			// Fundamental values.

			this.lineOne = null;
			this.lineTwo = null;

			// Derived values.

			this.epoch = null;
			this.satElset = null;

			this.sgp4Unit = null;
			this.sgp4Data = null;

			return;
		}

		// Fundamental values.

		// 1 00005U 58002B 10017.42086366 -.00000172 00000-0 -22271-3 0 5540
		// 2 00005 034.2403 058.9952 1850003 165.4339 200.7887 10.83964730792358

		// Line 1
		// Columns... Example.......... Description
		// ------------------------------------------------------------------------
		// 1......... 1................ Line Number
		String iline = "1";
		// 3-7....... 25544............ Object Identification Number
		long num = objId;
		// 8......... U................ Elset Classification
		String chu = "U";
		// 10-17..... 98067A........... International Designator
		// Object international designator reformatted to display YYNNNPPP.
		// YY........ 2 digit year
		// NNN....... Launch number
		// PPP....... Piece identifier
		String chid = "YYNNNPPP";
		// 19-32..... 04236.56031392... Element Set Epoch
		// Epoch time of ephemeris in YYDDD.FFFFFFFF.
		// Set to 15001.00000000 for Debris_CAT2015.dat
		// Set to 30001.00000000 for Debris_CAT2030.dat
		ModJulianDate kepEpoch = kepOrb.get_epoch();
		// TODO: Remove
		// DayOfYear doy = (DayOfYear) mjdConverter.convertFrame(kepEpoch, TimeSystem.DOY);

		// Notes:
		// - months are 0-based.
		// - TLE days are 1-based.
		// - milliseconds from the new year is 0-based.

		// TODO: Remove
		// double epoch = SatelliteCatalog.fixedWindowYYYYtoYY(doy.getYear()) * 1000 + doy.getDOY() + kepEpoch.getFraction();
		double epoch = SatelliteCatalog.fixedWindowYYYYtoYY(kepEpoch.getYear()) * 1000 + kepEpoch.getDayOfYear() + kepEpoch.getFraction();
		// 34-43..... .00020137........ First Time Derivative of Mean Motion
		double nDot = 0.0;
		// 45-52..... 00000-0.......... Second Time Derivative of Mean Motion
		// ............................ (decimal point assumed)
		String nDotDot = " 00000-0";
		// 54-61..... 16538-3.......... B // Drag Term
		// Drag term, B*=0.5aomCdρo
		// Cd=2.2, ρo=2.461x10-5 x 6378.135 [kg*Re/m2]
		String bStar = " 00000-0";
		// 63........ 0................ Element Set Type
		String iephtype = "0";
		// 65-68..... 513.............. Element Number
		String ielemno = "0000";
		// 69........ 5................ Checksum
		String icksum = " ";

		this.lineOne = String.format("%1s %05d%1s %8s %014.8f %10s %8s %8s %s %4s%1s", iline, num, chu, chid, epoch,
				String.format("%10.8f", nDot).replaceAll("^0", ""), nDotDot, bStar, iephtype, ielemno, icksum);

		// Line 2
		// Columns... Example.......... Description
		// ------------------------------------------------------------------------
		// 1......... 2................ Line Number
		iline = "2";
		// 3-7....... 25544............ Object Identification Number
		num = objId;
		// 9-16...... 51.6335.......... Orbit Inclination (degrees)
		double xinc = kepOrb.get_i() * (180.0 / Math.PI);
		// 18-25..... 344.7760......... Right Ascension of Ascending Node
		// ............................ (degrees)
		double raan = kepOrb.get_Omega() * (180.0 / Math.PI);
		// 27-33..... 0007976.......... Eccentricity
		// ............................ (decimal point assumed)
		// eccentricity x 10+7
		long iecc = (long) (kepOrb.get_e() * 10e6);
		// 35-42..... 126.2523......... Argument of Perigee (degrees)
		double arg_peri = kepOrb.get_omega() * (180.0 / Math.PI);
		// 44-51..... 325.9359......... Mean Anomaly (degrees)
		double xmean_anom = kepOrb.get_M() * (180.0 / Math.PI);
		// 53-63..... 15.70406856...... Mean Motion (revolutions/day)
		double xmean_mot = kepOrb.get_n() * (86400 / (2 * Math.PI));
		// 64-68..... 32890............ Revolution Number at Epoch
		// set to 00000
		String iepochrev = "00000";
		// 69........ 3................ Checksum
		icksum = " ";

		this.lineTwo = String.format("%s %05d %08.4f %08.4f %07d %08.4f %08.4f %011.8f%5s%1s", iline, num, xinc, raan,
				iecc, arg_peri, xmean_anom, xmean_mot, iepochrev, icksum);

		// Derived values.

		this.epoch = kepOrb.get_epoch();
		this.satElset = new SatElset(this.lineOne, this.lineTwo);
		this.satElset.setSatID((int) objId);

		this.sgp4Unit = new Sgp4Unit(this.satElset);
		this.sgp4Data = new Sgp4Data(this.satElset.getSatID());
	}

	/**
	 * Constructs a null Ssgp4Orbit.
	 */
	public Sgp4Orbit() {

		// Fundamental values.

		this.lineOne = null;
		this.lineTwo = null;

		// Derived values.

		this.epoch = null;
		this.satElset = null;

		this.sgp4Unit = null;
		this.sgp4Data = null;
	}

	/**
	 * Computes mean motion.
	 * 
	 * @return Mean motion [rad/s]
	 */
	public double meanMotion() {
		double n = satElset.getMeanMotion() * ((2 * Math.PI) / 86400.0);
		// [rad/s] = [rev/day] * ([rad/rev] / [s/day])
		return n;
	}

	/**
	 * Computes orbital period.
	 * 
	 * @return Orbital period [s]
	 */
	public double orbitalPeriod() {
		/*
		 * return (2 * Math.PI) Math.sqrt(Math.pow(EarthConstants.R_oplus *
		 * this.get_a(), 3) / EarthConstants.GM_oplus);
		 */
		// [s/rev] = [rad/rev] * sqrt(([km] * [-])^3 / [km^3/s^2])
		return 86400 / satElset.getMeanMotion();
		// [s/rev] = [s/day] / [rev/day]
	}

	/**
	 * Computes geocentric equatorial intertial position vector.
	 * 
	 * @param dNm
	 *            MJD calendar date at which the position vector occurs
	 * @return Geocentric equatorial intertial position vector [er]
	 * @throws ObjectDecayed
	 */
	public Matrix r_gei(ModJulianDate dNm) throws ObjectDecayed {

		// TODO: Remove
		// DayOfYear doy = (DayOfYear) mjdConverter.convertFrame(dNm, TimeSystem.DOY);

		// Notes:
		// - months are 0-based.
		// - SGP4 expects 1-based days (same as TLE).
		// - milliseconds from the new year is 0-based.

		sgp4Data = sgp4Unit.runSgp4(dNm.getYear(), dNm.getDayOfYear() + dNm.getFraction());
		double[][] elements = { { sgp4Data.getX() }, { sgp4Data.getY() }, { sgp4Data.getZ() } };
		// [er]
		Matrix r_gei = new Matrix(elements);
		// System.out.println("r_gei"); r_gei.print(16, 8);
		return r_gei; // .timesEquals(1 / EarthConstants.R_oplus);
		// [er]
	}

	/**
	 * Computes geocentric equatorial intertial position and velocity vectors.
	 * 
	 * @param dNm
	 *            MJD calendar date at which the position vector occurs
	 * @return Geocentric equatorial intertial position and velocity vectors
	 *         [er] and [er/s]
	 * @throws ObjectDecayed
	 */
	public Matrix rv_gei(ModJulianDate dNm) throws ObjectDecayed {

		// TODO: Remove
		// DayOfYear doy = (DayOfYear) mjdConverter.convertFrame(dNm, TimeSystem.DOY);

		// Notes:
		// - months are 0-based.
		// - SGP4 expects 1-based days (same as TLE).
		// - milliseconds from the new year is 0-based.
		double vkmpersec = 7.436685316871e-2 / 60.0; // See Sgp4Unit.java line
														// 51
		sgp4Data = sgp4Unit.runSgp4(dNm.getYear(), dNm.getDayOfYear() + dNm.getFraction());
		double[][] elements = { { sgp4Data.getX() }, { sgp4Data.getY() }, { sgp4Data.getZ() },
				{ sgp4Data.getXdot() * vkmpersec }, { sgp4Data.getYdot() * vkmpersec },
				{ sgp4Data.getZdot() * vkmpersec } };
		// [er] and [er/s] = [er/min] * [min/sec]
		Matrix rv_gei = new Matrix(elements);
		// System.out.println("rv_gei"); rv_gei.print(16, 8);
		return rv_gei; // .timesEquals(1 / EarthConstants.R_oplus);
		// [er] and [er/s]
	}

	/**
	 * Sets semi-major axis [er].
	 * 
	 * @param a
	 *            Semi-major axis [er]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_a(double a) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {
		double n = Math.sqrt(EarthConstants.GM_oplus / Math.pow(EarthConstants.R_oplus * a, 3));
		// [rad/s] = [ [km^3/s^2] / [ [km/er] * [er] ]^3 ]^(1/2)
		satElset.setMeanMotion(n * (86400.0 / (2 * Math.PI)));
		// [rev/day] = [rad/s] * ([s/day] / [rad/rev])
		sgp4Unit = new Sgp4Unit(satElset);
		sgp4Data = new Sgp4Data(satElset.getSatID());
	}

	/**
	 * Gets semi-major axis [er].
	 * 
	 * @return Semi-major axis [er]
	 */
	public double get_a() {
		double n = satElset.getMeanMotion() * ((2 * Math.PI) / 86400.0);
		// [rad/s] = [rev/day] * ([rad/rev] / [s/day])
		double a = Math.pow(EarthConstants.GM_oplus / Math.pow(n, 2), 1.0 / 3.0) / EarthConstants.R_oplus;
		// [er] = [ [km^3/s^2] / [rad/s]^2 ]^(1/3) / [km/er]
		return a;
	}

	/**
	 * Sets eccentricity [-].
	 * 
	 * @param e
	 *            Eccentricity [-]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_e(double e) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {
		satElset.setEccentricity(e);
		sgp4Unit = new Sgp4Unit(satElset);
		sgp4Data = new Sgp4Data(satElset.getSatID());
	}

	/**
	 * Gets eccentricity [-].
	 * 
	 * @return Eccentricity [-]
	 */
	public double get_e() {
		return satElset.getEccentricity();
	}

	/**
	 * Sets inclination [rad].
	 * 
	 * @param i
	 *            Inclination [rad]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_i(double i) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {
		satElset.setInclination(i);
		sgp4Unit = new Sgp4Unit(satElset);
		sgp4Data = new Sgp4Data(satElset.getSatID());
	}

	/**
	 * Gets inclination [rad].
	 * 
	 * @return Inclination [rad]
	 */
	public double get_i() {
		return satElset.getInclination();
	}

	/**
	 * Sets right ascension of the ascending node [rad].
	 * 
	 * @param Omega
	 *            Right ascension of the ascending node [rad]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_Omega(double Omega) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {
		satElset.setRtAsc(Omega);
		sgp4Unit = new Sgp4Unit(satElset);
		sgp4Data = new Sgp4Data(satElset.getSatID());
	}

	/**
	 * Gets right ascension of the ascending node [rad].
	 * 
	 * @return Right ascension of the ascending node [rad]
	 */
	public double get_Omega() {
		return satElset.getRightAscension();
	}

	/**
	 * Sets argument of perigee [rad].
	 * 
	 * @param omega
	 *            Argument of perigee [rad]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_omega(double omega) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {
		satElset.setArgPerigee(omega);
		sgp4Unit = new Sgp4Unit(satElset);
		sgp4Data = new Sgp4Data(satElset.getSatID());
	}

	/**
	 * Gets argument of perigee [rad].
	 * 
	 * @return Argument of perigee [rad]
	 */
	public double get_omega() {
		return satElset.getArgPerigee();
	}

	/**
	 * Sets mean anomaly [rad].
	 * 
	 * @param M
	 *            Mean anomaly [rad]
	 * @throws ObjectDecayed
	 * @throws SatElsetException
	 * @throws ValueOutOfRangeException
	 */
	public void set_M(double M) throws ObjectDecayed, SatElsetException, ValueOutOfRangeException {
		satElset.setMeanAnom(M);
		sgp4Unit = new Sgp4Unit(satElset);
		sgp4Data = new Sgp4Data(satElset.getSatID());
	}

	/**
	 * Gets mean anomaly [rad].
	 * 
	 * @return Mean anomaly [rad]
	 */
	public double get_M() {
		return satElset.getMeanAnomaly();
	}

	/**
	 * Gets epoch MJD calendar date.
	 * 
	 * @return Epoch MJD calendar date
	 */
	public ModJulianDate get_epoch() {
		return epoch;
	}

	/**
	 * Gets the standard 2-line orbital element set for a satellite.
	 * 
	 * @return The standard 2-line orbital element set for a satellite
	 */
	public SatElset getElSet() {
		return satElset;
	}

	/**
	 * Gets the data associated with the calculation of satellite positions.
	 * 
	 * @return The data associated with the calculation of satellite positions
	 */
	public Sgp4Data getData() {
		return sgp4Data;
	}

	/**
	 * @param lineOne
	 *            the lineOne to set
	 */
	public void set_lineOne(String lineOne) {
		this.lineOne = lineOne;
	}

	/**
	 * @return the lineOne
	 */
	public String get_lineOne() {
		return lineOne;
	}

	/**
	 * @param lineTwo
	 *            the lineTwo to set
	 */
	public void set_lineTwo(String lineTwo) {
		this.lineTwo = lineTwo;
	}

	/**
	 * @return the lineTwo
	 */
	public String get_lineTwo() {
		return lineTwo;
	}

	/**
	 * Constructs an Sgp4Orbit given a KeplerianOrbit by using the elements
	 * directly.
	 * 
	 * @param objId
	 *            Object identifier
	 * @param kepOrb
	 *            The KeplerianOrbit
	 * 
	 * @return The Sgp4Orbit
	 */
	public static Sgp4Orbit getSgp4OrbitFromKeplerianOrbit(long objId, KeplerianOrbit kepOrb) {

		// Construct an Sgp4 orbit using the Keplerian elements
		try {
			return new Sgp4Orbit(objId, kepOrb);
		} catch (SatElsetException | ValueOutOfRangeException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}

	/**
	 * Constructs an Sgp4Orbit given a KeplerianOrbit by fitting an Sgp4 orbit
	 * the positions corresponding to the Keplerian orbit.
	 * 
	 * @param objId
	 *            Object identifier
	 * @param kepOrb
	 *            The KeplerianOrbit
	 * 
	 * @return The Sgp4Orbit
	 */
	public static Sgp4Orbit fitSgp4OrbitFromKeplerianOrbit(long objId, KeplerianOrbit kepOrb) {

		/*
		 * Compute geocentric equatorial inertial position throughout one period
		 * of the Keplerian orbit
		 */
		ArrayList<ModJulianDate> obs_dNm = new ArrayList<ModJulianDate>();
		ArrayList<Matrix> obs_gei = new ArrayList<Matrix>();
		double T = kepOrb.get_T() / 86400;
		// [d] = [s] / [s/d]
		for (double dNm = kepOrb.get_epoch().getAsDouble(); dNm - kepOrb.get_epoch().getAsDouble() < T; dNm += dNm
				+ T / 100) {
			ModJulianDate mjd = new ModJulianDate(dNm);
			obs_dNm.add(mjd);
			obs_gei.add(kepOrb.r_gei(mjd));
		}

		/*
		 * Construct a preliminary Sgp4 orbit using the Keplerian elements
		 */
		Sgp4Orbit sgp4OrbP = null;
		try {
			sgp4OrbP = new Sgp4Orbit(0, kepOrb);
		} catch (SatElsetException | ValueOutOfRangeException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		// Differentially correct the preliminary orbit
		try {
			OrbitDetermination.DeterminationResult orbRes = OrbitDetermination.docNumerical(sgp4OrbP,
					obs_dNm.toArray(new ModJulianDate[obs_dNm.size()]), obs_gei.toArray(new Matrix[obs_gei.size()]),
					"Levenberg-Marquardt");
		} catch (SatElsetException | ValueOutOfRangeException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return sgp4OrbP;
	}

	/**
	 * Performs a few simple tests.
	 * 
	 * @param args
	 *            Not required
	 */
	public static void main(String[] args) {
	}

	@Override
	public Orbit copy() {
		return new Sgp4Orbit(this);
	}
}
