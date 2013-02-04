/*
 * File: ForgotPasswordServiceImpl.java

Purpose: Java class to reset, update an user password in the Database and send the reset password to the user.
**********************************************************/

package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.ResourceBundle;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.loginService.ForgotPasswordService;


public class ForgotPasswordImpl extends RemoteServiceServlet implements ForgotPasswordService {
	
	private static final long serialVersionUID = 5855609158212426678L;
	private DBConnection connection;
	private CallableStatement cs;
	private boolean hasResults;
	private boolean userExists;	
	private ResultSet rs;	
	private String primaryEmail;
	private String randomPassword;
	private int flag;
	private ResourceBundle constants = ResourceBundle.getBundle("PasswordEmailContent"); 
	
	public int sendEmail(Map<String, String> formData)
	{
		connection = new DBConnection();
		int userId = 0;
		try 
		{
			String username = formData.get("username");	
			String firstName = "";
			String lastName = "";
			Log.info("User: " + username);
			try
			{
				connection.openConnection();
				cs = connection.getConnection().prepareCall("{ call ValidateUser(?) }");
				cs.setString(1, username);
				
				hasResults = cs.execute();
				if(hasResults)
				{
					rs = cs.getResultSet();
										
					while(rs.next())
					{
						if(rs.getString("username").equals(username))
						{
							userId = rs.getInt("userId");
							primaryEmail = rs.getString("PrimaryEmail");
							firstName = rs.getString("firstName");
							lastName = rs.getString("lastName");
							userExists = true;
							break;
						}
					}
					rs.close();
				}
			    if(userExists)
			    {
			    	ResetPassword resetPassword = new ResetPassword();
			    	randomPassword = resetPassword.generateRandomPassword();			    	
					String hashedPassword = BCrypt.hashpw(randomPassword, BCrypt.gensalt(12));
					cs = connection.getConnection().prepareCall("{ call EditPassword(?, ?) }");
				    cs.setInt(1, userId);
				    cs.setString(2, hashedPassword);
				    cs.execute();
				    String content = getEmailContent(username, firstName, lastName, randomPassword);
				    Log.info("ForgotPasswordServiceImpl - Sending email to userId: " + userId);
				    //Call SendEmail java class to send PasswordReset Email
				    SendEmail email = new SendEmail();
			    	email.callSendEmailScript(primaryEmail, content, "passwordsubject");
				    flag = 1;
			    }			
			connection.closeConnection();
			}
			catch(SQLException e)
			{
				e.printStackTrace();
			}	
			finally
			{
				if(rs != null && (!rs.isClosed()))
				{
					rs.close();
				}
				if(connection.isOpenConnection())
				{
					connection.closeConnection();
				}
			}			
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}	
		return flag;
	}
	
	//Get the email message from EmailContent.properties file
	private String getEmailContent(String username, String firstName, String lastName, String password) 
	{
		String str = constants.getString("msg0") + " " + firstName + " " + lastName + ",";
		str = str + constants.getString("msg1");
		str = str + "\\n\\nUsername: " + username + "\\n";
		str = str + "Password: " + password + "\\n\\n";
		str = str + constants.getString("msg2");
		str = str + constants.getString("msg3");
		str = str + constants.getString("msg4");		
		return str;
	}	     
}

