package com.googlecode.mgwt.examples.showcase.server.enroll;

import java.util.ResourceBundle;

import javax.mail.Authenticator;
import javax.mail.PasswordAuthentication;

public class SmtpAuthenticator extends Authenticator 
{
	private ResourceBundle constants = ResourceBundle.getBundle("EmailAddress");
	
	public SmtpAuthenticator() 
	{

	    super();
	}
	
	public PasswordAuthentication getPasswordAuthentication() 
	{
		String password = constants.getString("password");
		String username = constants.getString("username");
	    if ((username != null) && (username.length() > 0) && (password != null) && (password.length   () > 0)) 
	    {
	        return new PasswordAuthentication(username, password);
	    }
	    return null;
	}
}