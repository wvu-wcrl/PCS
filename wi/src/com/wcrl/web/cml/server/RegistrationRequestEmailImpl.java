/*
 * File: ResetPasswordAndSendEmailImpl.java

Purpose: Java class to get a random password from ResetPassword.java, update it in the database and send email using SendEmail.java
**********************************************************/
package com.wcrl.web.cml.server;

import java.util.ResourceBundle;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.loginService.RegistrationRequestEmailService;

public class RegistrationRequestEmailImpl extends RemoteServiceServlet implements RegistrationRequestEmailService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("RegistrationEmailContent"); 
	
	public boolean sendEmail(String firstName, String lastName, String primaryEmail) 
	{	
		String str = constants.getString("msg0") + " " + firstName + " " + lastName + ",";
		str = str + constants.getString("msg1");
		str = str + constants.getString("msg2");
		str = str + constants.getString("msg3");
		str = str + constants.getString("msg4");
		str = str + constants.getString("msg5");
		/*@SuppressWarnings("unused")
		SendEmail email = new SendEmail(primaryEmail, str, "registrationsubject");*/
		SendEmail email = new SendEmail();
    	email.callSendEmailScript(primaryEmail, str, "registrationsubject");
		return true;
	}     	    
}
