/*
 * File: GetUsersImpl.java

Purpose: Java class to get list of registered users from the database.
**********************************************************/

package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.servlet.http.HttpSession;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.accountService.GetUsersService;

public class GetUsersImpl extends RemoteServiceServlet implements GetUsersService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
			
	public ArrayList<User> getUsers() 
	{
		ArrayList<User> usersList = new ArrayList<User>();
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			DBConnection connection = new DBConnection();
	    	try 
	    	{    		
				connection.openConnection();
				CallableStatement cs = connection.getConnection().prepareCall("{ call GETALLUSERS() }");
				boolean hasResults = cs.execute();
				
				if(hasResults)
				{
					ResultSet rs = cs.getResultSet();
					
					while(rs.next())
					{
						User user = new User();
						user.setUserId(rs.getInt("userId"));					
						user.setUsername(rs.getString("username"));
						user.setPassword(rs.getString("password"));
						user.setUsertype(rs.getString("usertype"));
						String firstName = rs.getString("firstName");
						String lastName = rs.getString("lastName");
						String country = rs.getString("country");
						String organization = rs.getString("organization");
						String jobTitle = rs.getString("jobTitle");
						if(firstName.length() == 0)
						{
							firstName = "";
						}
						if(lastName.length() == 0)
						{
							lastName = "";
						}
						if(country.length() == 0)
						{
							country = "";
						}
						if(organization.length() == 0)
						{
							organization = "";
						}
						if(jobTitle.length() == 0)
						{
							jobTitle = "";
						}
						user.setFirstName(firstName);
						user.setLastName(lastName);
						user.setPrimaryemail(rs.getString("PrimaryEmail"));
						user.setStatus(rs.getInt("status"));
						user.setCountry(country);
						user.setOrganization(organization);
						user.setJobTitle(jobTitle);
						user.setRuntime(rs.getDouble("RemainingUnits"));
						user.setTotalRuntime(rs.getDouble("TotalUnits"));
						usersList.add(user);
					}	
					rs.close();
				}
				cs.close();
				connection.closeConnection();
			}
	    	catch (SQLException e) 
	        {
	        	e.printStackTrace();
	        }  
		}    	      
    	return usersList;
    }     	    
}
