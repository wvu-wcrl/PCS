package com.googlecode.mgwt.examples.showcase.server.settings;

import java.sql.CallableStatement;
import java.sql.SQLException;

import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.googlecode.mgwt.examples.showcase.client.settings.service.ChangePasswordService;
import com.googlecode.mgwt.examples.showcase.server.db.BCrypt;
import com.googlecode.mgwt.examples.showcase.server.db.DBConnection;

public class ChangePasswordImpl extends RemoteServiceServlet implements ChangePasswordService 
{	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
		
	public String changePassword(int userId, String newPassword, String userEnteredCurrentPasswd, String currentPasswordHash)
	{
		String newPasswdHash = "";
		DBConnection connection;	
		CallableStatement cs;
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
				    cs.execute();          
				    Log.info("Query Executed.");	
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
	}
}
