/*
 * File: ResetPassword.java

Purpose: Java class to generate a random Password
**********************************************************/
package com.googlecode.mgwt.examples.showcase.server.enroll;

import java.util.Random;

public class ResetPassword 
{
	StringBuffer sb;
	public String generateRandomPassword()
	{
		String PASSWORD_CHARS_LCASE  = "abcdefghijklmnopqrstuvwxyz";
	    String PASSWORD_CHARS_UCASE  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	    String PASSWORD_CHARS_NUMERIC = "0123456789";
	    String PASSWORD_CHARS_SPECIAL = "._@";
		final String charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@._";
		
		int length = 8; 
		Random rand = new Random(System.currentTimeMillis());
        sb = new StringBuffer();
        int pos = rand.nextInt(PASSWORD_CHARS_LCASE.length());
        sb.append(PASSWORD_CHARS_LCASE.charAt(pos));
        pos = rand.nextInt(PASSWORD_CHARS_UCASE.length());
        sb.append(PASSWORD_CHARS_UCASE.charAt(pos));
        pos = rand.nextInt(PASSWORD_CHARS_NUMERIC.length());
        sb.append(PASSWORD_CHARS_NUMERIC.charAt(pos));
        pos = rand.nextInt(PASSWORD_CHARS_SPECIAL.length());
        sb.append(PASSWORD_CHARS_SPECIAL.charAt(pos));
        for (int i = 4; i < length; i++) 
        {
            pos = rand.nextInt(charset.length());
            sb.append(charset.charAt(pos));
        }
        return sb.toString();	        		
	}
}
