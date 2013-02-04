/*
 * File: EditEmailServiceImpl.java

Purpose: Java class to Update an user email address in Database.
**********************************************************/

package com.wcrl.web.cml.server;

import java.sql.CallableStatement;

import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.user.accountService.EditEmailService;

public class EditEmailImpl extends RemoteServiceServlet implements EditEmailService {
	
	private static final long serialVersionUID = 341533776131091670L;
	private DBConnection connection;
	private CallableStatement cs;	
	private boolean editEmail;
	

	public boolean editEmail(int userId, String email) 
	{
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{

			try
			{
				connection = new DBConnection();
				connection.openConnection();
				
				cs = null;
				
				cs = connection.getConnection().prepareCall("{ call UpdateEmail(?, ?) }");
			    cs.setInt(1, userId);				
				cs.setString(2, email);
				cs.execute();			   
				Log.info("EditEmailImpl to userId: " + userId);
				cs.close();
				editEmail = true;
				
				connection.closeConnection();
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
		}		
		return editEmail;
	}
}
