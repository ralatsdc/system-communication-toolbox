/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
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