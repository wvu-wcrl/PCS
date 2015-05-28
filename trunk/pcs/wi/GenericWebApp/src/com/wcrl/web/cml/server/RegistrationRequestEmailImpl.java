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
	private ResourceBundle adminEmail = ResourceBundle.getBundle("RegistrationRequestAdminEmailContent");
	private ResourceBundle adminEmailAddress = ResourceBundle.getBundle("EmailAddress");
	
	public boolean sendEmail(String firstName, String lastName, String primaryEmail, String username) 
	{	
		String str = constants.getString("msg0") + " " + firstName + " " + lastName + ",";
		str = str + constants.getString("msg1");
		str = str + constants.getString("msg2");
		str = str + constants.getString("msg3") + username;
		str = str + constants.getString("msg4");
		str = str + constants.getString("msg5");
		str = str + constants.getString("msg6");
		str = str + constants.getString("msg7");
		/*@SuppressWarnings("unused")
		SendEmail email = new SendEmail(primaryEmail, str, "registrationsubject");*/
		SendEmail email = new SendEmail();
    	email.callSendEmailScript(primaryEmail, str, "registrationsubject");
    	
    	/* Send email to administrator */
    	String adminEmailContent = adminEmail.getString("msg0");
    	adminEmailContent = adminEmailContent + adminEmail.getString("msg1") + username;
    	adminEmailContent = adminEmailContent + adminEmail.getString("msg2");
    	adminEmailContent = adminEmailContent + adminEmail.getString("msg3");
    	String adminEmail = adminEmailAddress.getString("emailaddress");
    	email.callSendEmailScript(adminEmail, adminEmailContent, "registrationrequestsubject");
		return true;
	}     	    
}
