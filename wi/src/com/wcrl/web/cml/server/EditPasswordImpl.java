/*
 * File: EditPasswordServiceImpl.java

Purpose: Java class to Update an user password in Database.
**********************************************************/

package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.SQLException;

import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.user.accountService.EditPasswordService;

public class EditPasswordImpl extends RemoteServiceServlet implements EditPasswordService 
{	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
		
	public String editPassword(int userId, String newPassword, String userEnteredCurrentPasswd, String currentPasswordHash)
	//public boolean editPassword(int userId, String newPassword, String userEnteredCurrentPasswd, String currentPasswordHash) 
	{
		String newPasswdHash = "";
		DBConnection connection;	
		CallableStatement cs;
		//boolean passwdChanged = false;
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			System.out.println("userEnteredCurrentPasswd: " + userEnteredCurrentPasswd + " currentPasswordHash: " + currentPasswordHash);
			if(BCrypt.checkpw(userEnteredCurrentPasswd, currentPasswordHash))
			{
				connection = new DBConnection();		
				try
				{
					newPasswdHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
					connection.openConnection();
					cs = connection.getConnection().prepareCall("{ call EditPassword(?, ?) }");
				    cs.setInt(1, userId);
				    cs.setString(2, newPasswdHash);
				    
				    Log.info("EditPassword for userId: " + userId + "New password: " +  newPassword);
				    cs.execute();          
				    
				    Log.info("Query Executed.");	
				    //passwdChanged = true;
				}
				catch(SQLException e)
				{
					e.printStackTrace();
				}
				finally
				{
					if(connection.isOpenConnection())
					{
						connection.closeConnection();
					}
				}
			}			
		}
		return newPasswdHash;
		//return passwdChanged;			
	}
}
