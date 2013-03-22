/*
 * File: ResetPasswordAndSendEmailImpl.java

Purpose: Java class to get a random password from ResetPassword.java, update it in the database and send email using SendEmail.java
**********************************************************/
package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ArrayList;
import java.util.ResourceBundle;

import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.seventhdawn.gwt.rpc.context.server.RPCServerContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.account.UserItems;
import com.wcrl.web.cml.client.user.accountService.ResetPasswordAndSendEmailService;

public class ResetPasswordAndSendEmailImpl extends RemoteServiceServlet implements ResetPasswordAndSendEmailService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("EmailContent"); 
	
	public boolean resetAndSendEmail(ArrayList<Integer> userIds) 
	{		
    	boolean flag = true;
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{

			ClientContext ctx = (ClientContext) RPCServerContext.get();
			User currentUser = null;
			UserItems userItems = null;
			if(ctx != null)
			{
				currentUser = ctx.getCurrentUser();
				if(currentUser != null)
				{
					userItems = currentUser.getUserItems();
				}
			}	
			
	    	for(int i = 0; i < userIds.size(); i++)
			{
				int userId = userIds.get(i);
							    
			    User item = userItems.getUser(userId);
			    String primaryEmail = item.getPrimaryemail();
			    flag = resetAndEmail(userId, item.getUsername(), primaryEmail);
			    flag = flag & true;
			}
		}    		
		return flag;
	}
	
	public boolean resetAndEmail(int userId, String username, String primaryEmail)
	{
		//String password = "*****";
    	boolean flag = false;
    	
		/*DBConnection connection = new DBConnection();
    	CallableStatement cs = null;
    	
    	try 
    	{    		
    		connection.openConnection();
    		ResetPassword resetPassword = new ResetPassword();
    		password = resetPassword.generateRandomPassword();
    		
    		String pw_hash = BCrypt.hashpw(password, BCrypt.gensalt(12)); 
    		
    		cs = connection.getConnection().prepareCall("{ call EditPassword(?, ?) }");
    	    cs.setInt(1, userId);
    	    cs.setString(2, pw_hash);    	    
    	    cs.execute();
    	    flag = true;
    	    cs.close();
    	    connection.closeConnection();			
    	}
    	catch(SQLException e)
    	{
    		e.printStackTrace();
    	}*/   
    	String content = getEmailContent(username);
    	/*@SuppressWarnings("unused")
    	SendEmail email = new SendEmail(primaryEmail, content, "welcomesubject");*/
    	SendEmail email = new SendEmail();
    	email.callSendEmailScript(primaryEmail, content, "welcomesubject");
		return flag;
	}
	
	public int createUserDirectories(String username) 
	{
		 ResourceBundle scriptsPathConstants = ResourceBundle.getBundle("Scripts");
		 String path = scriptsPathConstants.getString("create_user_path").trim() + File.separator + scriptsPathConstants.getString("create_web_user").trim();
		 Log.info("User creation path: " + path);	   
		 int exitValue = -1;
	     try 
	     {
	    	 ProcessBuilder processBuilder = new ProcessBuilder();
	    	 processBuilder.command(path, username);
	    	 Process proc = processBuilder.start();	    
	    	 exitValue = proc.waitFor();    
	    	 Log.info("CreateUserDirectories after executing user creation script: " + path + " exitValue: " + exitValue);
	    	 Log.info("CreateUserDirectories after executing user creation script parameters: " + username);
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
		return exitValue;		
	}

	private String getEmailContent(String username) 
	{
		String str = constants.getString("msg1") + "\\n\\n";
		str = str + constants.getString("msg2") + "\\n";
		str = str + constants.getString("msg3") + "\\n\\n";
		str = str + constants.getString("msg4") + "\\n";
		str = str + "Username: " + username + "\\n\\n";
		str = str + constants.getString("msg5") + "\\n\\n";
		str = str + constants.getString("msg6") + "\\n\\n";
		str = str + constants.getString("msg7");		
		return str;
	}	     	    
}
