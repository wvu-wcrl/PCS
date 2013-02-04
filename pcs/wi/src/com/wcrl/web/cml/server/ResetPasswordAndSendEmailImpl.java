/*
 * File: ResetPasswordAndSendEmailImpl.java

Purpose: Java class to get a random password from ResetPassword.java, update it in the database and send email using SendEmail.java
**********************************************************/
package com.wcrl.web.cml.server;

import java.io.File;
import java.sql.CallableStatement;
import java.sql.SQLException;
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
		DBConnection connection = new DBConnection();
    	CallableStatement cs = null;
    	String password = null;
    	boolean flag = false;
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
    	}   
    	String content = getEmailContent(username, password);
    	/*@SuppressWarnings("unused")
    	SendEmail email = new SendEmail(primaryEmail, content, "welcomesubject");*/
    	SendEmail email = new SendEmail();
    	email.callSendEmailScript(primaryEmail, content, "welcomesubject");
		return flag;
	}
	
	public void createUserDirectories(String username) 
	{
		 //File wd = new File(File.separator + "home" + File.separator + "abommaga" + File.separator);
		 ResourceBundle scriptsPathConstants = ResourceBundle.getBundle("Scripts");
		 File wd = new File(scriptsPathConstants.getString("tasks"));
		 String path = wd + File.separator;
		 //System.out.println("Working Directory: " + path);
		 //Log.info("Working Directory: " + path);	     
	     @SuppressWarnings("unused")
	     Process proc = null;
	     try 
	     {
	    	 proc = Runtime.getRuntime().exec(path + scriptsPathConstants.getString("create_web_user") + " " + username, null);
	    	 //Log.info("After executing script." + path);
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

	private String getEmailContent(String username, String password) 
	{
		String str = constants.getString("msg1") + "\\n\\n";
		str = str + constants.getString("msg2") + "\\n";
		str = str + constants.getString("msg3") + "\\n\\n";
		str = str + constants.getString("msg4") + "\\n";
		str = str + "Username: " + username + "\\n";
		str = str + "Password: " + password + "\\n\\n";
		str = str + constants.getString("msg5") + "\\n\\n";
		str = str + constants.getString("msg6") + "\\n\\n";
		str = str + constants.getString("msg7");		
		return str;
	}	     	    
}
