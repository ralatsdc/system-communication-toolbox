/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved.*/
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
