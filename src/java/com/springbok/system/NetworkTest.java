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

import org.junit.Assert;
import org.junit.Test;


/**
 * Tests methods of Network class.
 */
public class NetworkTest {

    // A network
    private Network network;

//    function this = NetworkTest(logFId, testMode)
//    % Constructs a NetworkTest.
//    %
//            % Parameters
//    %   logFId - Log file identifier
//    %   testMode - Test mode, if 'interactive' then beeps and pauses
//
//    % Invoke the superclass constructor
//      if nargin == 0
//    superArgs = {};
//
//      else
//    superArgs{1} = logFId;
//    superArgs{2} = testMode;
//
//    end % if
//            this@TestUtility(superArgs{:});
//
//      % Compute derived properties
//      this.network = Network();
//
//    end % NetworkTest()

    /**
     * Tests Network method.
     */
    @Test
    public void test_Network() {
        network = new Network();
        Assert.assertNull(this.network.getEarthStation());
        Assert.assertNull(this.network.getSpaceStation());
        Assert.assertNull(this.network.getSpaceStationBeam());
        Assert.assertNull(this.network.getLosses());
        Assert.assertEquals("both", this.network.getType());
        Assert.assertTrue(this.network.isDoCheck());

        checkLink(new Link(), this.network.getUp_Link());
        checkLink(new Link(), this.network.getDn_Link());
    }

    private void checkLink(Link expected, Link actual) {
        Assert.assertEquals(expected.isDoCheck(), actual.isDoCheck());
        Assert.assertEquals(expected.getReceiveStation(), actual.getReceiveStation());
        Assert.assertEquals(expected.getTransmitStation(), actual.getTransmitStation());
        Assert.assertEquals(expected.getTransmitStationBeam(), actual.getTransmitStationBeam());
        Assert.assertEquals(expected.getLosses(), actual.getLosses());
    }
}
