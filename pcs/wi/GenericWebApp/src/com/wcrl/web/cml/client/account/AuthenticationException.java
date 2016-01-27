/*
 * File: UserAuthenticationException.java

Purpose: A customized Exception class used whenever a user authentication fails.
**********************************************************/

package com.wcrl.web.cml.client.account;

public class AuthenticationException extends Exception {
    
    /**
	 * 
	 */
	private static final long serialVersionUID = 8316843644919134861L;

	// for serialization purpose
    public AuthenticationException() {
        super();
    }
    
    public AuthenticationException(String message, Throwable cause) {
        super(message, cause);
    }
    
    public AuthenticationException(String message) {
        super(message);
    }
}
