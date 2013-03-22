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

public class AddUsersImpl extends RemoteServiceServlet implements AddUsersService 
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
		System.out.println("# users: " + usernames.length);
		Log.info("# users: " + usernames.length);
		System.out.println("Session: " + session.getAttribute("Username"));
		Log.info("Session: " + session.getAttribute("Username"));
		if (session.getAttribute("Username") != null)
		{
			Log.info("AddUsersImpl Number of users to create: " + usernames.length);
			System.out.println("AddUsersImpl Number of users to create: " + usernames.length);
			Set<Entry<Integer, String>> projectSet = subscribedProjectsMap.entrySet();
			for(int i = 0; i < usernames.length; i++)
			{				
				int count = 1;
				int flag = -1;
				boolean bool = true;
				int registrationCnt = -1;
				
				if(usernames[i].trim().length() > 0)
				{				
					String username  = null;
					String email = null;
					
					username = usernames[i].trim();
			
					email = usernames[i].trim();
					String[] tokens = email.split("@");
					username = tokens[0].trim();
					
					Log.info("AddUsersImpl Adding user: " + username);
					System.out.println("AddUsersImpl Adding user: " + username);
					registrationCnt = checkUser(email);
					System.out.println("Registration count: " + registrationCnt);
					if(registrationCnt == 0)
					{
						while(bool)
						{						
							flag = addUser(username, email, usertype, 1, "", "", "", "", "", registrationCnt);						
							if(flag == 0)
							{
								int length = username.length();
								int code = username.charAt(length - 1);
								if(code >= 48 && code <= 57)
								{
									int num = Integer.valueOf(username.substring(length - 1));
									num++;
									username = username.substring(0, length - 1);
									username = username + num;
								}
								else
								{
									username = username + count;
									count++;
								}								
							}
							else
							{
								bool = false;
								break;
							}
						}
					}					
					else
					{
						// New code: Add new projects if username already exists
						int userId = checkUserId(username);
						int projCount = projectSet.size();
						int k = 0;
						for(Entry<Integer, String> project : projectSet)
						{
							int projectId = project.getKey();
							String projectName = project.getValue();
							SaveSubscribedProjectImpl addProject = new SaveSubscribedProjectImpl();
							if(k == (projCount - 1))
							{
								/* Set the last subscribed project as the default preferred project */
								//addProject.saveProject(projectId, flag, 1, username, projectName);								
								addProject.saveProject(projectId, userId, 0, username, projectName, 1);
							}
							else
							{
								//addProject.saveProject(projectId, flag, 0, username, projectName);
								addProject.saveProject(projectId, userId, 0, username, projectName, 0);
							}							
							k++;
						}
					}
					
					if(bool)
					{
						errorUsersList.add(username);
					}					
					else
					{
						//For each user subscribe to the selected projects						
						ResetPasswordAndSendEmailImpl sendEmail = new ResetPasswordAndSendEmailImpl();
						sendEmail.createUserDirectories(username);
						int projCount = projectSet.size();
						int k = 0;
						for(Entry<Integer, String> project : projectSet)
						{
							int projectId = project.getKey();
							String projectName = project.getValue();
							SaveSubscribedProjectImpl addProject = new SaveSubscribedProjectImpl();
							if(k == (projCount - 1))
							{
								/* Set the last subscribed project as the default preferred project */
								//addProject.saveProject(projectId, flag, 1, username, projectName);								
								addProject.saveProject(projectId, flag, 0, username, projectName, 1);
							}
							else
							{
								//addProject.saveProject(projectId, flag, 0, username, projectName);
								addProject.saveProject(projectId, flag, 0, username, projectName, 0);
							}							
							k++;
						}
				    	sendEmail.resetAndEmail(flag, username, email);
					}										
				}				
			}
		}			      
    	return errorUsersList;
    } 
	
	public int addUser(String username, String email, String usertype, int status, String firstName, String lastName, String organization, String country, String jobTitle, int registrationCnt)
	{
		DBConnection connection = new DBConnection();
    	CallableStatement cs = null;    	 
    	int flag = -5;
    	connection.openConnection();
    	ResetPassword resetPassword = new ResetPassword();
    	
    	if(registrationCnt == -1)
    	{
    		registrationCnt = checkUser(email);
    		System.out.println("RegisterCnt: " + registrationCnt);
    		Log.info("email:  " + email + " RegisterCnt: " + registrationCnt);
    	}
    	if(registrationCnt == 0)
    	{
    		String password = resetPassword.generateRandomPassword();
    		//String password = "@Admin123";
    		String hash = BCrypt.hashpw(password, BCrypt.gensalt(12));
    		System.out.println("Password hash: " + hash);
    		try 
    		{
    			cs = connection.getConnection().prepareCall("{ call ADDUSER(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) }");
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
    			cs.setInt(11, 1); /* Newsletter: Set to receive by default. */
    			cs.registerOutParameter(12, java.sql.Types.INTEGER);
    			cs.execute();
    			flag = cs.getInt(12);			
    			cs.execute();
    			cs.close();
    			connection.closeConnection();
    		} 
    		catch (SQLException e) 
    		{
    			e.printStackTrace();
    		}
    	}  			
		return flag;		
	}
	
	public int checkUser(String email)
	{
		int registrationCnt = -1;
		DBConnection connection = new DBConnection();
    	CallableStatement cs = null;
    	connection.openConnection();
		try 
		{
			cs = connection.getConnection().prepareCall("{ call VALIDATEUSEREMAIL(?, ?) }");
			cs.setString(1, email);
			cs.registerOutParameter(2, java.sql.Types.INTEGER);
			cs.execute();
			registrationCnt = cs.getInt(2);
		} 
		catch (SQLException e) 
		{
			e.printStackTrace();
		}		
		return registrationCnt;		
	}
	
	public int checkUserId(String username)
	{
		int userId = 0;
		UserAvailabilityImpl checkUsernameAvailability = new UserAvailabilityImpl();
		userId = checkUsernameAvailability.checkUserAvailability(username);
		return userId;
	}
}
