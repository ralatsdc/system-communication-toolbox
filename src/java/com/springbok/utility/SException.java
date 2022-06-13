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
