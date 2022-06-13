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
package com.springbok.system;

import com.springbok.station.EarthStation;
import com.springbok.station.SpaceStation;
import com.springbok.twobody.ModJulianDate;
import com.springbok.utility.TimeUtility;

import java.util.HashMap;
import java.util.Map;

public class Gso_leo {
    public static System[] getSystems() {
        //Assign simulation constants
        double date2jd = TimeUtility.date2jd(2014, 10, 20, 19, 5, 0);
        ModJulianDate epoch_0 = new ModJulianDate(date2jd); // Epoch date number

        //Define the wanted system
        SpaceStation wantedSpaceStation = Gso_gso.getWntGsoSpaceSegment(epoch_0);
        EarthStation wantedEarthStation = Gso_gso.getWntGsoEarthSegment(wantedSpaceStation);

        Object[] losses = {};

        Map options = new HashMap();
        options.put("testAngleFromGsoArc", 0);
        System wantedSystem = new System(new EarthStation[]{wantedEarthStation}, new SpaceStation[]{wantedSpaceStation},
                losses, epoch_0, options);

        //Define the interfering system

        SpaceStation[] interferingSpaceStations = Gso_gso.getIntLeoSpaceSegment(epoch_0);
        EarthStation[] interferingEarthStations = Gso_gso.getIntLeoEarthSegment(wantedSpaceStation);

        System interferingSystem = new System(interferingEarthStations, interferingSpaceStations, losses, epoch_0, options);

        return new System[]{wantedSystem, interferingSystem};
    }

}
