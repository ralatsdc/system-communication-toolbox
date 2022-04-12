package com.springbok.center;

import static org.junit.Assert.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.zip.DataFormatException;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.TestUtility;

public class SatelliteCatalogTest {

	// Directory containing catalog file
	private final String catDir_input = "dat/java/com/springbok/center";
	// File containing two line element sets
	private final String catFNm_input = "tles.txt";

	// Array list containing two line element set parameters constructed from
	// the file
	private ArrayList<SatelliteCatalog.TwoLineElementSet> catalog_input;

	@Before
	public void setUp() throws Exception {

		catalog_input = new ArrayList<SatelliteCatalog.TwoLineElementSet>();

		// this.doyConverter = new DayOfYearConversions();

		String lineOne = "1 00005U 58002B   14224.13195843 -.00000025  00000-0 -42007-4 0  2491";

		// Line 1
		// Columns... Example.......... Description
		// ------------------------------------------------------------------------
		// 3-7....... 25544............ Object Identification Number
		long objectId = 5;
		// 8......... U................ Elset Classification
		String classification = "U";
		// 10-17..... 98067A........... International Designator
		String intlDesignator = "58002B  ";
		// 19-32..... 04236.56031392... Element Set Epoch
		ModJulianDate epoch = ModJulianDate.convertDayOfYear(2014, 224.13195843);
		// 34-43..... .00020137........ First Time Derivative of Mean Motion
		double nDot = -.00000025;
		// 45-52..... 00000-0.......... Second Time Derivative of Mean Motion
		// ............................ (decimal point assumed)
		double nDotDot = 0.0;
		// 54-61..... 16538-3.......... B* Drag Term
		double bStar = -0.42007e-4;
		// 63........ 0................ Element Set Type
		long elSetType = 0;
		// 65-68..... 513.............. Element Number
		long elementNum = 249;
		// 69........ 5................ Checksum

		String lineTwo = "2 00005 032.4486 331.6386 1848534 087.8835 292.2681 18.04384562973062";

		// Line 2
		// Columns... Example.......... Description
		// ------------------------------------------------------------------------
		// 9-16...... 51.6335.......... Orbit Inclination (degrees)
		double i = 032.4486 * Math.PI / 180.0;
		// 18-25..... 344.7760......... Right Ascension of Ascending Node
		// ............................ (degrees)
		double Omega = 331.6386 * Math.PI / 180.0;
		// 27-33..... 0007976.......... Eccentricity
		// ............................ (decimal point assumed)
		double e = 0.1848534;
		// 35-42..... 126.2523......... Argument of Perigee (degrees)
		double omega = 87.8835 * Math.PI / 180.0;
		// 44-51..... 325.9359......... Mean Anomaly (degrees)
		double M = 292.2681 * Math.PI / 180.0;
		// 53-63..... 15.70406856...... Mean Motion (revolutions/day)
		double n = 18.04384562 * 2.0 * Math.PI / 86400;
		double a = Math.pow(EarthConstants.GM_oplus / Math.pow(n, 2), 1.0 / 3.0) / EarthConstants.R_oplus;
		// 64-68..... 32890............ Revolution Number at Epoch
		long revAtEpoch = 97306;
		// 69........ 3................ Checksum

		SatelliteCatalog.TwoLineElementSet tle = new SatelliteCatalog.TwoLineElementSet(lineOne, lineTwo, objectId, classification, intlDesignator, epoch,
				nDot, nDotDot, bStar, elSetType, elementNum, i, Omega, e, omega, M, n, a, revAtEpoch);

		this.catalog_input.add(tle);

		lineOne = "1 40114U 14047F   14228.17412853 -.00000069  00000-0  00000-0 0    69";

		// Line 1
		// Columns... Example.......... Description
		// ------------------------------------------------------------------------
		// 3-7....... 25544............ Object Identification Number
		objectId = 40114;
		// 8......... U................ Elset Classification
		classification = "U";
		// 10-17..... 98067A........... International Designator
		intlDesignator = "14047F  ";
		// 19-32..... 04236.56031392... Element Set Epoch
		epoch = ModJulianDate.convertDayOfYear(2014, 228.17412853);
		// 34-43..... .00020137........ First Time Derivative of Mean Motion
		nDot = -.00000069;
		// 45-52..... 00000-0.......... Second Time Derivative of Mean Motion
		// ............................ (decimal point assumed)
		nDotDot = 0.0;
		// 54-61..... 16538-3.......... B* Drag Term
		bStar = 0.0;
		// 63........ 0................ Element Set Type
		elSetType = 0;
		// 65-68..... 513.............. Element Number
		elementNum = 6;
		// 69........ 5................ Checksum

		lineTwo = "2 40114 064.3596 351.0056 0140909 028.2938 338.7343 16.39284109    93";

		// Line 2
		// Columns... Example.......... Description
		// ------------------------------------------------------------------------
		// 9-16...... 51.6335.......... Orbit Inclination (degrees)
		i = 64.3596 * Math.PI / 180.0;
		// 18-25..... 344.7760......... Right Ascension of Ascending Node
		// ............................ (degrees)
		Omega = 351.0056 * Math.PI / 180.0;
		// 27-33..... 0007976.......... Eccentricity
		// ............................ (decimal point assumed)
		e = 0.0140909;
		// 35-42..... 126.2523......... Argument of Perigee (degrees)
		omega = 28.2938 * Math.PI / 180.0;
		// 44-51..... 325.9359......... Mean Anomaly (degrees)
		M = 338.7343 * Math.PI / 180.0;
		// 53-63..... 15.70406856...... Mean Motion (revolutions/day)
		n = 16.39284109 * 2.0 * Math.PI / 86400;
		a = Math.pow(EarthConstants.GM_oplus / Math.pow(n, 2), 1.0 / 3.0) / EarthConstants.R_oplus;
		// 64-68..... 32890............ Revolution Number at Epoch
		revAtEpoch = 9;
		// 69........ 3................ Checksum

		SatelliteCatalog.TwoLineElementSet tle2 = new SatelliteCatalog.TwoLineElementSet(lineOne, lineTwo, objectId, classification, intlDesignator, epoch, nDot, nDotDot,
				bStar, elSetType, elementNum, i, Omega, e, omega, M, n, a, revAtEpoch);

		this.catalog_input.add(tle2);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	// Tests readCatalog method. Note that readCatalog invoked private method
	// fixed_window, which is therefore tested implicitly.
	public void test_readCatalog() throws NumberFormatException, IOException, DataFormatException {

		ArrayList<SatelliteCatalog.TwoLineElementSet> catalog_expected = this.catalog_input;

		ArrayList<SatelliteCatalog.TwoLineElementSet> catalog_actual = SatelliteCatalog.readCatalog(this.catDir_input,
				this.catFNm_input);

		int iObj = 0;

		// String lineOne
		assertTrue(catalog_actual.get(iObj).lineOne.equals(catalog_expected.get(0).lineOne));
		// long objectId
		assertTrue(catalog_actual.get(iObj).objectId == catalog_expected.get(0).objectId);
		// String classification
		assertTrue(catalog_actual.get(iObj).classification.equals(catalog_expected.get(0).classification));
		// String intlDesignator
		assertTrue(catalog_actual.get(iObj).intlDesignator.equals(catalog_expected.get(0).intlDesignator));
		// ModJulianDate epoch
		assertTrue(catalog_actual.get(iObj).epoch.equals(catalog_expected.get(0).epoch));
		// double nDot
		assertTrue(catalog_actual.get(iObj).nDot == catalog_expected.get(0).nDot);
		// double nDotDot
		assertTrue(catalog_actual.get(iObj).nDotDot == catalog_expected.get(0).nDotDot);
		// double bStar
		assertTrue(catalog_actual.get(iObj).bStar == catalog_expected.get(0).bStar);
		// long elSetType
		assertTrue(catalog_actual.get(iObj).elSetType == catalog_expected.get(0).elSetType);
		// long elementNum
		assertTrue(catalog_actual.get(iObj).elementNum == catalog_expected.get(0).elementNum);

		// String lineTwo
		assertTrue(catalog_actual.get(iObj).lineTwo.equals(catalog_expected.get(0).lineTwo));
		// double i
		assertTrue(Math.abs(catalog_actual.get(iObj).i - catalog_expected.get(0).i) < TestUtility.HIGH_PRECISION);
		// double Omega
		assertTrue(
				Math.abs(catalog_actual.get(iObj).Omega - catalog_expected.get(0).Omega) < TestUtility.HIGH_PRECISION);
		// double e
		assertTrue(catalog_actual.get(iObj).e == catalog_expected.get(0).e);
		// double omega
		assertTrue(
				Math.abs(catalog_actual.get(iObj).omega - catalog_expected.get(0).omega) < TestUtility.HIGH_PRECISION);
		// double M
		assertTrue(Math.abs(catalog_actual.get(iObj).M - catalog_expected.get(0).M) < TestUtility.HIGH_PRECISION);
		// double n
		assertTrue(Math.abs(catalog_actual.get(iObj).n - catalog_expected.get(0).n) < TestUtility.HIGH_PRECISION);
		// double a
		assertTrue(Math.abs(catalog_actual.get(iObj).a - catalog_expected.get(0).a) < TestUtility.HIGH_PRECISION);
		// long revAtEpoch
		assertTrue(catalog_actual.get(iObj).revAtEpoch == catalog_expected.get(0).revAtEpoch);

		iObj = catalog_actual.size() - 1;

		// String lineOne
		assertTrue(catalog_actual.get(iObj).lineOne.equals(catalog_expected.get(1).lineOne));
		// long objectId
		assertTrue(catalog_actual.get(iObj).objectId == catalog_expected.get(1).objectId);
		// String classification
		assertTrue(catalog_actual.get(iObj).classification.equals(catalog_expected.get(1).classification));
		// String intlDesignator
		assertTrue(catalog_actual.get(iObj).intlDesignator.equals(catalog_expected.get(1).intlDesignator));
		// ModJulianDate epoch
		assertTrue(catalog_actual.get(iObj).epoch.equals(catalog_expected.get(1).epoch));
		// double nDot
		assertTrue(catalog_actual.get(iObj).nDot == catalog_expected.get(1).nDot);
		// double nDotDot
		assertTrue(catalog_actual.get(iObj).nDotDot == catalog_expected.get(1).nDotDot);
		// double bStar
		assertTrue(catalog_actual.get(iObj).bStar == catalog_expected.get(1).bStar);
		// long elSetType
		assertTrue(catalog_actual.get(iObj).elSetType == catalog_expected.get(1).elSetType);
		// long elementNum
		assertTrue(catalog_actual.get(iObj).elementNum == catalog_expected.get(1).elementNum);

		// String lineTwo
		assertTrue(catalog_actual.get(iObj).lineTwo.equals(catalog_expected.get(1).lineTwo));
		// double i
		assertTrue(Math.abs(catalog_actual.get(iObj).i - catalog_expected.get(1).i) < TestUtility.HIGH_PRECISION);
		// double Omega
		assertTrue(
				Math.abs(catalog_actual.get(iObj).Omega - catalog_expected.get(1).Omega) < TestUtility.HIGH_PRECISION);
		// double e
		assertTrue(catalog_actual.get(iObj).e == catalog_expected.get(1).e);
		// double omega
		assertTrue(
				Math.abs(catalog_actual.get(iObj).omega - catalog_expected.get(1).omega) < TestUtility.HIGH_PRECISION);
		// double M
		assertTrue(Math.abs(catalog_actual.get(iObj).M - catalog_expected.get(1).M) < TestUtility.HIGH_PRECISION);
		// double n
		assertTrue(Math.abs(catalog_actual.get(iObj).n - catalog_expected.get(1).n) < TestUtility.HIGH_PRECISION);
		// double a
		assertTrue(Math.abs(catalog_actual.get(iObj).a - catalog_expected.get(1).a) < TestUtility.HIGH_PRECISION);
		// long revAtEpoch
		assertTrue(catalog_actual.get(iObj).revAtEpoch == catalog_expected.get(1).revAtEpoch);
	}

	@Test
	// Tests writeCatalog method.
	public void test_writeCatalog()
			throws NumberFormatException, IOException, DataFormatException, InterruptedException {

		ArrayList<SatelliteCatalog.TwoLineElementSet> catalog_input = SatelliteCatalog.readCatalog(this.catDir_input, this.catFNm_input);

		String catFNm_output = this.catFNm_input.replace(".txt", ".dat");

		SatelliteCatalog.writeCatalog(catalog_input, this.catDir_input, catFNm_output);

		Runtime r = Runtime.getRuntime();
		Process p = r.exec(
				"diff " + this.catDir_input + "/" + this.catFNm_input + " " + this.catDir_input + "/" + catFNm_output);
		p.waitFor();
		BufferedReader b = new BufferedReader(new InputStreamReader(p.getInputStream()));
		String line = b.readLine();

		assertTrue(line == null);
	}
}
