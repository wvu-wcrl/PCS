/*
 * File: AddUsersImpl.java

Purpose: Java class to add users to the database.
**********************************************************/
package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Set;

import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.accountService.AddUsersService;

public class AddUsersImpl_ver1 extends RemoteServiceServlet implements AddUsersService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
			
	public ArrayList<String> addUsers(int status, String[] usernames, String usertype, HashMap<Integer, String> subscribedProjectsMap) 
	{
		//ArrayList to store the usernames that are not created (A Reason - Username might already exist in the database)
		ArrayList<String> errorUsersList = new ArrayList<String>();
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			Log.info("AddUsersImpl Number of users to create: " + usernames.length);
			Set<Entry<Integer, String>> projectSet = subscribedProjectsMap.entrySet();
			for(int i = 0; i < usernames.length; i++)
			{				
				if(usernames[i].trim().length() > 0)
				{				
					String username  = null;
					String email = null;
					
					String[] tokens = usernames[i].trim().split(",");
					if(tokens.length == 2)
					{
						username = tokens[0].trim();					
						email = tokens[1].trim();
						
						int userId = 0;
						String usernameRegex = "^[a-z][-a-z0-9_]*$";
						String emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
						if(username.matches(usernameRegex) && email.matches(emailRegex))
						{
							userId = checkUser(username);
							if(userId == 0)
							{
								UserAvailabilityImpl checkUserAvailability = new UserAvailabilityImpl();
								int userEmailCnt = checkUserAvailability.checkUserEmail(email);
								if(userEmailCnt == 0)
								{
									userId = addUser(username, email, usertype, 1, "", "", "", "", "", userId);
									if(userId > 0)
									{
										int userAdded = addLinuxUser(userId, username, email, projectSet);
										if(userAdded != 0)
										{
											errorUsersList.add(usernames[i].trim());
										}
									}
									else
									{
										errorUsersList.add(usernames[i].trim());
									}
								}
								else
								{
									errorUsersList.add(usernames[i].trim());
								}								
							}
							else
							{
								int receivedProjectId = addUserProjects(userId, username, projectSet);
								if(receivedProjectId == -1)
								{
									errorUsersList.add(usernames[i].trim());
								}
							}						
						}
						else
						{
							errorUsersList.add(usernames[i].trim());
						}
					}
					else
					{
						errorUsersList.add(usernames[i].trim());
					}
				}				
			}
		}			      
    	return errorUsersList;
    } 
	
	private int addLinuxUser(int userId, String username, String email, Set<Entry<Integer, String>> projectSet)
	{
		//For each user subscribe to the selected projects						
		ResetPasswordAndSendEmailImpl sendEmail = new ResetPasswordAndSendEmailImpl();
		int userDirAdded = sendEmail.createUserDirectories(username);
		if(userDirAdded == 0)
		{
			addUserProjects(userId, username, projectSet);
	    	sendEmail.resetAndEmail(userId, username, email);
		}
		return userDirAdded;		
	}
	
	private int addUserProjects(int userId, String username, Set<Entry<Integer, String>> projectSet)
	{
		int projCount = projectSet.size();
		int k = 0;
		int receivedProjectId = -1;
		for(Entry<Integer, String> project : projectSet)
		{
			int projectId = project.getKey();
			String projectName = project.getValue();
			SaveSubscribedProjectImpl addProject = new SaveSubscribedProjectImpl();
			
			if(k == (projCount - 1))
			{				
				/* Set the last subscribed project as the default preferred project */
				receivedProjectId = addProject.saveProject(projectId, userId, 0, username, projectName, 1);
			}
			else
			{
				addProject.saveProject(projectId, userId, 0, username, projectName, 0);
			}
			k++;
		}
		return receivedProjectId;
	}
	
	public int addUser(String username, String email, String usertype, int status, String firstName, String lastName, String organization, String country, String jobTitle, int userId)
	{
		DBConnection connection = new DBConnection();
    	CallableStatement cs = null; 
    	connection.openConnection();
    	ResetPassword resetPassword = new ResetPassword();
    	if(userId == 0)
    	{
    		String password = resetPassword.generateRandomPassword();
    		String hash = BCrypt.hashpw(password, BCrypt.gensalt(12));
    		try 
    		{
    			cs = connection.getConnection().prepareCall("{ call ADDUSER(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) }");
    			cs.setString(1, username);
    			cs.setString(2, hash);
    			cs.setString(3, firstName);
    			cs.setString(4, lastName);
    			cs.setString(5, email);
    			cs.setString(6, usertype);
    			cs.setInt(7, status);
    			cs.setString(8, country);
    			cs.setString(9, organization);
    			cs.setString(10, jobTitle);
    			cs.registerOutParameter(11, java.sql.Types.INTEGER);
    			cs.execute();
    			userId = cs.getInt(11);			
    			cs.execute();
    			cs.close();
    			connection.closeConnection();
    		} 
    		catch (SQLException e) 
    		{
    			e.printStackTrace();
    		}
    	}
    	else
    	{
    		userId = checkUser(username);
    	}    			
		return userId;		
	}
	
	public int checkUser(String username)
	{
		int userId = 0;
		UserAvailabilityImpl checkUsernameAvailability = new UserAvailabilityImpl();
		userId = checkUsernameAvailability.checkUserAvailability(username);
		return userId;
	}
}