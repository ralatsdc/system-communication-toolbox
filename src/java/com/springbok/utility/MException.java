/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.utility;

/**
 * Extends the MATLAB exception class which includes error and
 * warning messages.
 */
public class MException extends RuntimeException {
    public MException(
            String msg_ident,
            String msg_string
    ) {
        super(msg_ident + ": " + msg_string);
    }
}
