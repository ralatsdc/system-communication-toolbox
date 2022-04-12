/* Copyright (C) 2016 Springbok LLC <http://springbok.io/> All rights reserved. */
package com.springbok.utility;

/**
 * Extends the MATLAB exception class which includes error and
 * warning messages.
 */
public class SException extends RuntimeException {

    public int event_code;
    public String symbol;
    public String event_message;

    public SException(
            String msg_ident,
            String msg_string,
            int event_code,
            String symbol,
            String event_message
    ) {
        super(msg_ident + ": " + msg_string);
        this.event_code = event_code;
        this.symbol = symbol;
        this.event_message = event_message;
    }

    public SException(
            String msg_ident,
            String msg_string,
            int event_code
    ) {
        this(msg_ident, msg_string, event_code, "", "");
    }

    public SException(
            String msg_ident,
            String msg_string,
            String symbol
    ) {
        this(msg_ident, msg_string, 0, symbol, "");
    }

    public SException(
            String msg_ident,
            String msg_string,
            int event_code,
            String symbol
    ) {
        this(msg_ident, msg_string, event_code, symbol, "");
    }

    public SException(
            String msg_ident,
            String msg_string,
            String symbol,
            String event_message
    ) {
        this(msg_ident, msg_string, 0, symbol, event_message);
    }
}
