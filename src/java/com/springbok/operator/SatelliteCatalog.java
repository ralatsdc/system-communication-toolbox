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
package com.springbok.operator;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Formatter;
import java.util.Locale;
import java.util.zip.DataFormatException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.springbok.twobody.EarthConstants;
import com.springbok.twobody.ModJulianDate;

@SuppressWarnings("serial")
public class SatelliteCatalog implements Serializable {

	public static Logger logger = LogManager.getLogger(SatelliteCatalog.class.getName());

	/**
	 * Represents a two line element set.
	 * 
	 * @author Raymond LeClair.
	 */
	protected static class TwoLineElementSet implements Serializable {

		/** Line one of a two line element set. */
		public String lineOne;
		/** Line two of a two line element set. */
		public String lineTwo;
		/** Object Identification Number */
		public long objectId;
		/** Elset Classification */
		public String classification;
		/** International Designator */
		public String intlDesignator;
		/** Element Set Epoch */
		public ModJulianDate epoch;
		/** First Time Derivative of Mean Motion [NA] */
		public double nDot;
		/** Second Time Derivative of Mean Motion [NA] */
		public double nDotDot;
		/** B* Drag Term [NA] */
		public double bStar;
		/** Element Set Type */
		public long elSetType;
		/** Element Number */
		public long elementNum;
		/** Orbit Inclination [rad] */
		public double i;
		/** Right Ascension of Ascending Node [rad] */
		public double Omega;
		/** Eccentricity [-] */
		public double e;
		/** Argument of Perigee [rad] */
		public double omega;
		/** Mean Anomaly [rad] */
		public double M;
		/** Mean Motion [rad/s] */
		public double n;
		/** Semi-major axis [er] */
		public double a;
		/** Revolution Number at Epoch */
		public long revAtEpoch;

		/**
		 * Constructs a two line element set.
		 * 
		 * @param lineOne
		 *            Line one of a two line element set.
		 * @param lineTwo
		 *            Line two of a two line element set.
		 * @param objectId
		 *            Object Identification Number
		 * @param classification
		 *            Elset Classification
		 * @param intlDesignator
		 *            International Designator
		 * @param epoch
		 *            Element Set Epoch
		 * @param nDot
		 *            First Time Derivative of Mean Motion [NA]
		 * @param nDotDot
		 *            Second Time Derivative of Mean Motion [NA]
		 * @param bStar
		 *            B* Drag Term [NA]
		 * @param elSetType
		 *            Element Set Type
		 * @param elementNum
		 *            Element Number
		 * @param i
		 *            Orbit Inclination [rad]
		 * @param Omega
		 *            Right Ascension of Ascending Node [rad]
		 * @param e
		 *            Eccentricity [-]
		 * @param omega
		 *            Argument of Perigee [rad]
		 * @param M
		 *            Mean Anomaly [rad]
		 * @param n
		 *            Mean Motion [rad/s]
		 * @param a
		 *            Semi-major axis [er]
		 * @param revAtEpoch
		 *            Revolution Number at Epoch
		 */
		public TwoLineElementSet(String lineOne, String lineTwo, long objectId, String classification,
				String intlDesignator, ModJulianDate epoch, double nDot, double nDotDot, double bStar, long elSetType,
				long elementNum, double i, double Omega, double e, double omega, double M, double n, double a,
				long revAtEpoch) {
			this.lineOne = lineOne;
			this.lineTwo = lineTwo;
			this.objectId = objectId;
			this.classification = classification;
			this.intlDesignator = intlDesignator;
			this.epoch = epoch;
			this.nDot = nDot;
			this.nDotDot = nDotDot;
			this.bStar = bStar;
			this.elSetType = elSetType;
			this.elementNum = elementNum;
			this.i = i;
			this.Omega = Omega;
			this.e = e;
			this.omega = omega;
			this.M = M;
			this.n = n;
			this.a = a;
			this.revAtEpoch = revAtEpoch;
		}
	}

	/**
	 * Reads a file containing two line element sets downloaded from the Space
	 * Track site.
	 * 
	 * @param catDir
	 *            Directory containing catalog file
	 * @param catFNm
	 *            File containing two line element sets
	 * @return Array list containing two line element set parameters constructed
	 *         from the file
	 * @throws DataFormatException
	 * @throws IOException
	 * @throws NumberFormatException
	 */
	public static ArrayList<TwoLineElementSet> readCatalog(String catDir, String catFNm)
			throws NumberFormatException, IOException, DataFormatException {
		return readCatalog(catDir, catFNm, false);
	}

	/**
	 * Reads a file containing two line element sets downloaded from the Space
	 * Track site, or provided by NASA.
	 * 
	 * @param catDir
	 *            Directory containing catalog file
	 * @param catFNm
	 *            File containing two line element sets
	 * @param isNasaFormat
	 *            Two line element sets are in the NASA format
	 * @return Array list containing two line element set parameters constructed
	 *         from the file
	 * @throws DataFormatException
	 * @throws IOException
	 * @throws NumberFormatException
	 */
	public static ArrayList<TwoLineElementSet> readCatalog(String catDir, String catFNm, boolean isNasaFormat)
			throws NumberFormatException, IOException, DataFormatException {

		// Note that the file format conforms to the following:
		//
		// Line 1
		// Columns... Example.......... Description
		// ------------------------------------------------------------------------
		// 1......... 1................ Line Number
		// 3-7....... 25544............ Object Identification Number
		// 8......... U................ Elset Classification
		// 10-17..... 98067A........... International Designator
		// 19-32..... 04236.56031392... Element Set Epoch
		// 34-43..... .00020137........ First Time Derivative of Mean Motion
		// ...or, if NASA format:
		// 34-41..... 00000-0.......... area-to-mass (m^2/kg)
		// ............................ (decimal point assumed)
		// 45-52..... 00000-0.......... Second Time Derivative of Mean Motion
		// ............................ (decimal point assumed)
		// ...or, if NASA format:
		// 45-52..... 00000-0.......... radar cross section (m^2) at 10 cm
		// ............................ wavelength
		// ............................ (decimal point assumed)
		// 54-61..... 16538-3.......... B* Drag Term
		// 63........ 0................ Element Set Type
		// 65-68..... 513.............. Element Number
		// 69........ 5................ Checksum
		//
		// Line 2
		// Columns... Example.......... Description
		// ------------------------------------------------------------------------
		// 1......... 2................ Line Number
		// 3-7....... 25544............ Object Identification Number
		// 9-16...... 51.6335.......... Orbit Inclination (degrees)
		// 18-25..... 344.7760......... Right Ascension of Ascending Node
		// ............................ (degrees)
		// 27-33..... 0007976.......... Eccentricity
		// ............................ (decimal point assumed)
		// 35-42..... 126.2523......... Argument of Perigee (degrees)
		// 44-51..... 325.9359......... Mean Anomaly (degrees)
		// 53-63..... 15.70406856...... Mean Motion (revolutions/day)
		// 64-68..... 32890............ Revolution Number at Epoch
		// 69........ 3................ Checksum

		ArrayList<TwoLineElementSet> catalog = new ArrayList<TwoLineElementSet>();

		BufferedReader in = null;
		try {
			String catFSp = catDir + File.separator + catFNm;
			File file = new File(catFSp);
			if (!file.isFile()) {
				String errMsg = "Catalog file \"" + catFSp + "\" does not exist.";
				throw new FileNotFoundException(errMsg);
			}
			in = new BufferedReader(new FileReader(catFSp));

			/* Read and two lines at a time. */

			String lineOne;
			String lineTwo;
			while ((lineOne = in.readLine()) != null) {
				lineTwo = in.readLine();

				// System.out.println(lineOne);
				// System.out.println(lineTwo);

				/* Parse both lines. */

				long objectId = Long.parseLong(lineOne.substring(1, 7).trim().replace("+", ""));
				// System.out.println(objectId);

				String classification = lineOne.substring(7, 8);
				// System.out.println(classification);

				String intlDesignator = lineOne.substring(9, 17);
				// System.out.println(intlDesignator);

				int year = fixedWindowYYtoYYYY(Integer.parseInt(lineOne.substring(18, 20).trim().replace("+", "")));
				// System.out.println(year);

				double day = Double.parseDouble(lineOne.substring(20, 32));
				// System.out.println(day);

				ModJulianDate epoch = ModJulianDate.convertDayOfYear(year, day);

				int mantissa;
				int exponent;
				@SuppressWarnings("unused")
				double aom;
				@SuppressWarnings("unused")
				double rcs;
				double nDot = 0.0;
				double nDotDot = 0.0;

				if (isNasaFormat) {

					// NASA format: T34,I6.5,T40,I2.1
					mantissa = Integer.parseInt(lineOne.substring(33, 39).trim().replace("+", "")) / 100000;
					// System.out.println(mantissa);
					exponent = Integer.parseInt(lineOne.substring(39, 41).trim().replace("+", ""));
					// System.out.println(exponent);
					aom = mantissa * Math.pow(10, exponent);
					// System.out.println(nDot);

					// NASA format: T45,I6.5,T51,I2.1
					mantissa = Integer.parseInt(lineOne.substring(44, 50).trim().replace("+", "")) / 100000;
					// System.out.println(mantissa);
					exponent = Integer.parseInt(lineOne.substring(50, 52).trim().replace("+", ""));
					// System.out.println(exponent);
					rcs = mantissa * Math.pow(10, exponent);
					// System.out.println(nDotDot);

					lineOne = lineOne.replace(lineOne.substring(33, 43), ".00000000 ");
					lineOne = lineOne.replace(lineOne.substring(44, 52), " 00000-0");
					if (lineOne.substring(59, 60).equals(" ")) {
						lineOne = lineOne.substring(0, 59) + "+" + lineOne.substring(60);
					}
					lineOne = lineOne.substring(0, 68) + checkSum(lineOne);
					lineTwo = lineTwo.substring(0, 68) + checkSum(lineTwo);

				} else {

					nDot = Double.parseDouble(lineOne.substring(33, 43));
					// System.out.println(nDot);

					mantissa = Integer.parseInt(lineOne.substring(44, 50).trim().replace("+", "")) / 100000;
					// System.out.println(mantissa);
					exponent = Integer.parseInt(lineOne.substring(50, 52).trim().replace("+", ""));
					// System.out.println(exponent);
					nDotDot = mantissa * Math.pow(10, exponent);
					// System.out.println(nDotDot);
				}

				mantissa = Integer.parseInt(lineOne.substring(53, 59).trim().replace("+", ""));
				// System.out.println(mantissa);
				exponent = Integer.parseInt(lineOne.substring(59, 61).trim().replace("+", ""));
				// System.out.println(exponent);
				double bStar = mantissa * Math.pow(10, exponent - 5);
				// System.out.println(bStar);

				long elSetType = Long.parseLong(lineOne.substring(62, 63).trim().replace("+", ""));
				// System.out.println(elSetType);

				long elementNum = Long.parseLong(lineOne.substring(64, 68).trim().replace("+", ""));
				// System.out.println(elementNum);

				if (!isNasaFormat && Long.parseLong(lineTwo.substring(1, 7).trim()) != objectId) {
					// throw new
					// DataFormatException("Line 1 and 2 object numbers
					// disagree.");
					logger.warn("Line 1 and 2 object numbers disagree.");
				}

				double i = Double.parseDouble(lineTwo.substring(8, 16));
				// System.out.println(i);

				double Omega = Double.parseDouble(lineTwo.substring(17, 25));
				// System.out.println(Omega);

				double e = Double.parseDouble(lineTwo.substring(26, 33)) * Math.pow(10, -7);
				// System.out.println(e);

				double omega = Double.parseDouble(lineTwo.substring(34, 42));
				// System.out.println(omega);

				double M = Double.parseDouble(lineTwo.substring(43, 51));
				// System.out.println(M);

				double n = Double.parseDouble(lineTwo.substring(52, 63));
				// System.out.println(n);

				long revAtEpoch = Long.parseLong(lineTwo.substring(63, 68).trim().replace("+", ""));
				// System.out.println(revAtEpoch);

				/* Compute semi-major axis. */

				n = n * (2 * Math.PI) * (1 / 86400.0);
				// [rad/s] = [rev/day] * [rad/rev] * [day/s]
				double a = Math.pow(EarthConstants.GM_oplus / Math.pow(n, 2), 1 / 3.0);
				// [km] = [ [km^3/s^2] / [rad/s]^2 ]^(1/3)

				// Convert units.

				a = a / EarthConstants.R_oplus;
				// [er] = [km] / [km/er]
				// e = e;
				// [-]
				i = i * (Math.PI / 180);
				// [rad]
				Omega = Omega * (Math.PI / 180);
				// [rad]
				omega = omega * (Math.PI / 180);
				// [rad]
				M = M * (Math.PI / 180);
				// [rad]

				/* Add the object to the catalog. */
				SatelliteCatalog.TwoLineElementSet tle = new SatelliteCatalog.TwoLineElementSet(lineOne, lineTwo, objectId, classification,
						intlDesignator, epoch, nDot, nDotDot, bStar, elSetType, elementNum, i, Omega, e, omega, M, n, a,
						revAtEpoch);

				catalog.add(tle);
			}
		} finally {
			if (in != null)
				in.close();
		}
		return catalog;
	}

	/**
	 * Writes file containing two line element sets.
	 * 
	 * @param catalog
	 *            Array list containing two line element set parameters
	 *            constructed from the file
	 * @param catDir
	 *            Directory containing catalog file
	 * @param catFNm
	 *            File containing two line element sets
	 * @throws IOException
	 */
	public static boolean writeCatalog(ArrayList<TwoLineElementSet> catalog, String catDir, String catFNm)
			throws IOException {

		// Note that the file format conforms to the following:
		//
		// Line 1
		// Columns... Example.......... Description
		// ------------------------------------------------------------------------
		// 1......... 1................ Line Number
		// 3-7....... 25544............ Object Identification Number
		// 8......... U................ Elset Classification
		// 10-17..... 98067A........... International Designator
		// 19-32..... 04236.56031392... Element Set Epoch
		// 34-43..... .00020137........ First Time Derivative of Mean Motion
		// ...or, if NASA format:
		// 34-41..... 00000-0.......... area-to-mass (m^2/kg)
		// ............................ (decimal point assumed)
		// 45-52..... 00000-0.......... Second Time Derivative of Mean Motion
		// ............................ (decimal point assumed)
		// ...or, if NASA format:
		// 45-52..... 00000-0.......... radar cross section (m^2) at 10 cm
		// ............................ wavelength
		// ............................ (decimal point assumed)
		// 54-61..... 16538-3.......... B* Drag Term
		// 63........ 0................ Element Set Type
		// 65-68..... 513.............. Element Number
		// 69........ 5................ Checksum
		//
		// Line 2
		// Columns... Example.......... Description
		// ------------------------------------------------------------------------
		// 1......... 2................ Line Number
		// 3-7....... 25544............ Object Identification Number
		// 9-16...... 51.6335.......... Orbit Inclination (degrees)
		// 18-25..... 344.7760......... Right Ascension of Ascending Node
		// ............................ (degrees)
		// 27-33..... 0007976.......... Eccentricity
		// ............................ (decimal point assumed)
		// 35-42..... 126.2523......... Argument of Perigee (degrees)
		// 44-51..... 325.9359......... Mean Anomaly (degrees)
		// 53-63..... 15.70406856...... Mean Motion (revolutions/day)
		// 64-68..... 32890............ Revolution Number at Epoch
		// 69........ 3................ Checksum

		// Open a file for output
		Charset charset = Charset.forName("UTF-8");
		Path file = Paths.get(catDir + File.separator + catFNm);
		BufferedWriter writer = null;
		try {
			writer = Files.newBufferedWriter(file, charset);
		} catch (IOException e) {
			logger.warn(e.getMessage());
			e.printStackTrace();
			System.exit(1);
		}
		StringBuilder sb = new StringBuilder();
		Formatter formatter = new Formatter(sb, Locale.US);

		// Consider each object
		String line_1;
		String line_2;
		int exponent;
		int mantissa;
		int checksum_1;
		int checksum_2;
		for (TwoLineElementSet tle : catalog) {

			// Print line one to a string
			line_1 = String.format("1 %05d%s %8s", tle.objectId, tle.classification, tle.intlDesignator);
			line_1 += String.format(" %02d%012.8f", fixedWindowYYYYtoYY(tle.epoch.getYear()), tle.epoch.getDayOfYear() + tle.epoch.getFraction());
			line_1 += String.format(" %+.8f", tle.nDot).replace("0.", ".").replace("+", " ");
			if (tle.nDotDot == 0.0) {
				exponent = 0;
				mantissa = 0;
			} else {
				exponent = (int) Math.floor(Math.log10(Math.abs(tle.nDotDot)));
				mantissa = (int) Math.round(tle.nDotDot / Math.pow(10, exponent - 4));
			}
			line_1 += String.format(" %+06d", mantissa).replace("+", " ");
			line_1 += String.format("%+2d", exponent).replace("+0", "-0");
			if (tle.bStar == 0.0) {
				exponent = 0;
				mantissa = 0;
			} else {
				exponent = (int) Math.floor(Math.log10(Math.abs(tle.bStar))) + 1;
				mantissa = (int) Math.round(tle.bStar / Math.pow(10, exponent - 5));
			}
			line_1 += String.format(" %+06d", mantissa).replace("+", " ");
			line_1 += String.format("%+2d", exponent).replace("+0", "-0");
			line_1 += String.format(" %1d %4d", tle.elSetType, tle.elementNum);

			// Compute line one check sum
			checksum_1 = checkSum(line_1);

			// Print line one to a file
			writer.write(String.format("%s%d\n", line_1, checksum_1));

			// Print line two to a string
			line_2 = String.format("2 %05d %08.4f %08.4f", tle.objectId, tle.i * (180.0 / Math.PI),
					tle.Omega * (180.0 / Math.PI));
			line_2 += String.format(" %07d", Math.round(tle.e * Math.pow(10, 7)));
			line_2 += String.format(" %08.4f %08.4f %11.8f%5d", tle.omega * (180.0 / Math.PI),
					tle.M * (180.0 / Math.PI), tle.n * 86400 / (2 * Math.PI), tle.revAtEpoch);
			// [rev/day] = [rad/s] * [s/day] * [rev/rad]

			// Compute line two check sum
			checksum_2 = checkSum(line_2);

			// Print line two to a file
			writer.write(String.format("%s%d\n", line_2, checksum_2));
		}

		// Close the file opened for output
		formatter.close();
		try {
			writer.close();
		} catch (IOException e) {
			logger.warn(e.getMessage());
			e.printStackTrace();
			System.exit(1);
		}
		return true;
	}

	/**
	 * Converts a two digit year to a four digit year.
	 * 
	 * @param YY
	 *            Two digit year
	 * @return Four digit year using a fixed window with pivot year 1970
	 */
	public static int fixedWindowYYtoYYYY(int YY) {
		int YYYY = 0;
		if (YY < 70) {
			YYYY = YY + 2000;
		} else if (70 <= YY && YY < 100) {
			YYYY = YY + 1900;
		} else {
			throw new IllegalArgumentException("Invalid two digit year.");
		}
		return YYYY;
	}

	/**
	 * Converts a four digit year to a two digit year.
	 * 
	 * @param YYYY
	 *            Four digit year
	 * @return Two digit year using a fixed window with pivot year 1970
	 */
	public static int fixedWindowYYYYtoYY(int YYYY) {
		int YY = 0;
		if (YYYY >= 2000) {
			YY = YYYY - 2000;
		} else if (1970 <= YYYY && YYYY < 2000) {
			YY = YYYY - 1900;
		} else {
			throw new IllegalArgumentException("Invalid four digit year.");
		}
		return YY;
	}

	/**
	 * This method computes the checksum of 1 card of a a 2-line elset. The
	 * first 68 characters are scanned and "summed" to get the checksum.
	 * 
	 * Taken from: sgp4v/SatElset.Java.
	 * 
	 * @return the int containing the checksum [0,9]
	 * @param card
	 *            the String containing the card image
	 */
	public static int checkSum(String card) {
		int checksum = 0;
		for (int i = 0; i < 68; i++) {
			switch (card.charAt(i)) {
			case '1':
				/* falls through */
			case '-':
				checksum++;
				break;
			case '2':
				checksum += 2;
				break;
			case '3':
				checksum += 3;
				break;
			case '4':
				checksum += 4;
				break;
			case '5':
				checksum += 5;
				break;
			case '6':
				checksum += 6;
				break;
			case '7':
				checksum += 7;
				break;
			case '8':
				checksum += 8;
				break;
			case '9':
				checksum += 9;
				break;
			default:
				break;
			}
		}
		return checksum % 10;
	}
}
