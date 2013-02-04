/*
 * File: SendEmail.java

Purpose: Java class to send an email.
From email address, password and subject of the email are received from EmailAddress.properties file.
**********************************************************/

package com.wcrl.web.cml.server;

import java.io.File;
import java.util.Date;
import java.util.ResourceBundle;

import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.Message.RecipientType;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import com.allen_sauer.gwt.log.client.Log;

public class SendEmail
{
	private ResourceBundle constants = ResourceBundle.getBundle("EmailAddress");
	
	/*public SendEmail(String to, String content, String subjectContext)
	{
		
	}*/
	
	public void sendEmailUsingJava(String to, String content, String subjectContext)
	{
		//int smtpPort = 465;
		//int smtpPort = 587;
		//String smtpHost = "smtp.gmail.com";
		//int smtpPort = 25;
		//String smtpHost = "exsmtp.wvu.edu";
		String subject = constants.getString(subjectContext);
		int smtpPort = Integer.parseInt(constants.getString("smtpPort"));
		String smtpHost = constants.getString("smtpHost");
		String urPassword = constants.getString("password");
		String from = constants.getString("emailaddress");
		//String content = contentText;
		// Create a mail session
		java.util.Properties props = new java.util.Properties();
		props = System.getProperties(); 
		props.put("mail.smtp.host", smtpHost);
		//props.put("mail.smtp.starttls.enable", "true");
		props.put("mail.smtps.auth", "true");
		SmtpAuthenticator authentication = new SmtpAuthenticator();
		//Session session = Session.getInstance(props, null);
		Session session = Session.getInstance(props, authentication);
		session.setDebug(true);
		// Construct the message
		try
		{
			MimeMessage msg = new MimeMessage(session);
			msg.setFrom(new InternetAddress(from));
			msg.setRecipient(RecipientType.TO, new InternetAddress(to));
			msg.setSubject(subject);
			msg.setText(content);
			msg.setSentDate(new Date());
			Transport tr = null;
			tr = session.getTransport("smtp");
			tr.connect(smtpHost,smtpPort,from, urPassword);
			tr.sendMessage(msg, msg.getAllRecipients());
		}
		catch(AddressException e)
		{
			System.out.println(e.getClass().getName() + ": " + e.getMessage());
			Log.info(e.getClass().getName() + ": " + e.getMessage());
			StackTraceElement[] trace = e.getStackTrace();
			for(int i = 0; i < trace.length; i++)
			{
				System.out.println("\t" + trace[i].toString());
				Log.info("\n\t" + trace[i].toString());
			}
			e.printStackTrace();	
		}
		catch(MessagingException e)
		{
			System.out.println(e.getClass().getName() + ": " + e.getMessage());
			Log.info(e.getClass().getName() + ": " + e.getMessage());
			StackTraceElement[] trace = e.getStackTrace();
			for(int i = 0; i < trace.length; i++)
			{
				System.out.println("\t" + trace[i].toString());
				Log.info("\n\t" + trace[i].toString());
			}
			e.printStackTrace();
		}
	}
	
	
	public void callSendEmailScript(String to, String content, String subjectContext) 
	{
		 String subject = constants.getString(subjectContext);
		 ResourceBundle scriptsPathConstants = ResourceBundle.getBundle("Scripts");
		 File wd = new File(scriptsPathConstants.getString("send_email_path"));
		 String scriptFileName = scriptsPathConstants.getString("send_project_email");
		 String path = wd + File.separator + scriptFileName;		 
		 System.out.println("Script Working Directory: " + path);
		 Log.info("Script Working Directory: " + path);	     
	     
	     try 
	     {
	    	 Log.info("Email argument: " + content);
	    	 System.out.println("Email argument: " + content);
	    	 ProcessBuilder processBuilder = new ProcessBuilder();
	    	 processBuilder.command(path, to, subject, content);
	    	 Process proc = processBuilder.start();
	    	/* String argument = path + scriptFileName + " \"" + to + "\" \"" + subject + "\" \"" + content + "\"";
	    	 Log.info("Email argument: " + argument);
	    	 System.out.println("Email argument: " + argument);*/
	    	 //proc = Runtime.getRuntime().exec(argument, null);
	    	 //proc = Runtime.getRuntime().exec(argument);
	    	 int exitValue = proc.waitFor();
	    	 Log.info("After executing script: " + path + " exitValue: " + exitValue);
	     }	
	     catch (InterruptedException e)
		 {
	    	 System.out.println(e.getClass().getName() + ": " + e.getMessage());
			 Log.info(e.getClass().getName() + ": " + e.getMessage());
			 StackTraceElement[] trace = e.getStackTrace();			
			 for(int i = 0; i < trace.length; i++)
			 {
				 System.out.println("\t" + trace[i].toString());
				 Log.info("\n\t" + trace[i].toString());
			 }
			 e.printStackTrace();
		 }
		 catch (Exception e)
		 {
			 System.out.println(e.getClass().getName() + ": " + e.getMessage());
			 Log.info(e.getClass().getName() + ": " + e.getMessage());
			 StackTraceElement[] trace = e.getStackTrace();			
			 for(int i = 0; i < trace.length; i++)
			 {
				 System.out.println("\t" + trace[i].toString());
				 Log.info("\n\t" + trace[i].toString());
			 }
			 e.printStackTrace();
		 }		
	}
}