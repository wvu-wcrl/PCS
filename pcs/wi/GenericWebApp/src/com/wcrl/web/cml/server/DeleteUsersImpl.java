/*
 * File: DeleteUsersImpl.java

Purpose: Java class to Delete users from Database.
**********************************************************/
package com.wcrl.web.cml.server;

import java.io.File;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.ResourceBundle;
import java.util.Set;

import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.accountService.DeleteUsersService;

public class DeleteUsersImpl extends RemoteServiceServlet implements DeleteUsersService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
			
	public ArrayList<Integer> deleteUsers(HashMap<Integer, String> users) 
	{
		ArrayList<Integer> deletedUsersList = new ArrayList<Integer>();
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			
			Set<Entry<Integer, String>> entrySet = users.entrySet();
			
	    	DBConnection connection = new DBConnection();
	    	CallableStatement cs = null;
	    	try 
	    	{    		
				connection.openConnection();
				for(Entry<Integer, String> entry : entrySet)
				{										
					cs = connection.getConnection().prepareCall("{ call DELETEUSER(?, ?) }");
					int userId = entry.getKey();
					String username = entry.getValue();
					Log.info("DeleteUsersImpl: Deleting user: " + userId);
					cs.setInt(1, userId);
					cs.registerOutParameter(2, java.sql.Types.INTEGER);				
					cs.execute();
					int flag = cs.getInt(2);
					cs.close();
					if(flag == 0)
					{
						deletedUsersList.add(userId);
						deleteUserDirectories(username);
					}											
				}					
				connection.closeConnection();
			}
	    	catch (SQLException e) 
	        {
	        	e.printStackTrace();
	        }
		}        
    	return deletedUsersList;
    }   
	
	public int deleteUserDirectories(String username) 
	{
		 ResourceBundle scriptsPathConstants = ResourceBundle.getBundle("Scripts");
		 String path = scriptsPathConstants.getString("create_user_path").trim() + File.separator + scriptsPathConstants.getString("delete_web_user").trim();
		 Log.info("User deletion path: " + path);	   
		 int exitValue = -1;
	     try 
	     {
	    	 ProcessBuilder processBuilder = new ProcessBuilder();
	    	 processBuilder.command(path, username);
	    	 Process proc = processBuilder.start();	    
	    	 exitValue = proc.waitFor();    
	    	 Log.info("DeleteUserDirectories after executing user creation script: " + path + " exitValue: " + exitValue);
	    	 Log.info("DeleteUserDirectories after executing user creation script parameters: " + username);
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
}
