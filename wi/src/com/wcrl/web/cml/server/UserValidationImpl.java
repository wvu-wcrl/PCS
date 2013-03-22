/*
 * File: UserValidationServiceImpl.java

Purpose: Java class to validate a user login details.
******************************************************/
package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.client.rpc.SerializableException;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.account.AuthenticationException;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.loginService.UserValidationService;

import org.apache.log4j.Logger;

@SuppressWarnings({ "serial", "deprecation" })
public class UserValidationImpl extends RemoteServiceServlet implements UserValidationService 
{		
	private static Logger logger = Logger.getLogger(UserValidationImpl.class);
		
	public User validateUserData(String userName, String password, boolean rememberMe)throws AuthenticationException, SerializableException 
	{    	
    	User userBean;

        try 
        {			
            userBean = ckLogin(userName, password, false); 
            /*if(rememberMe)
            {
            	createSession(userName);
            }*/
            createSession(userName);
            String sessionID = validateSession("Username");
            //System.out.println("Session value: "  + sessionID);
            Log.info("Session value: "  + sessionID);
            userBean.setSessionID(sessionID);
            return userBean;
        } 
        catch (Throwable exc) 
        {
            if (exc instanceof AuthenticationException)
				try 
            	{
					throw (AuthenticationException)exc;
				} 
            	catch (AuthenticationException e) 
            	{						
					e.printStackTrace();
				}
            throw new SerializableException(exc.getMessage());
        }        
    } // end of login
	
	private void createSession(String Username)
	{
		HttpServletRequest request = this.getThreadLocalRequest();
		HttpSession session = request.getSession();
		if (session.getAttribute("Username") == null)
		{
			session.setAttribute("Username", Username);
		}
	}
	
	public String validateSession(String username)
	{
		HttpServletRequest request = this.getThreadLocalRequest();
		HttpSession session = request.getSession();
		//System.out.println("Session on server side: " + session);
		//System.out.println("Session value on server side: " + session.getAttribute(username));
		//Log.info("ValidateSession: Session on server side: " + session);
		//Log.info("ValidateSession: Session value on server side: " + session.getAttribute(username));
		if (session.getAttribute(username) != null)
		{
			return (String) session.getAttribute(username);
		}
		else
		{
			return null;
		}
	}
	
	public boolean clearSession()
	{
		HttpServletRequest request = this.getThreadLocalRequest();
		HttpSession session = request.getSession();
		//System.out.println("Clearing session on server side: " + session);
		System.out.println("Clearing session value on server side: " + session.getAttribute("Username"));
		boolean sessionValue = false;
		if (session.getAttribute("Username") != null)
		{
			session.setAttribute("Username", null);
			sessionValue = true;
			System.out.println("After clearing session value on server side: " + session.getAttribute("Username"));
		}
		else
		{
			sessionValue = true;
		}
		return sessionValue;			
	}	
    
    public User ckLogin(String login, String passwd, boolean reVisit)
    {    	    	
    	User currentUser = null;
    	//double runtime = 0;
    	
    	//float totalRuntime = 0;
    	/*if(totalRuntimeVal.trim().length() > 0)
    	{
    		totalRuntime = Float.parseFloat(totalRuntimeVal);
    	}
    	System.out.println("Runtime: " + runtime + " Total runtime: " + totalRuntime);*/
    	
    	if(currentUser == null)
    	{    		
    		currentUser = validateUser(currentUser, login, reVisit, passwd);    		
    	}    	
    	return currentUser;	
    }    
    
    public User validateUser(User currentUser, String login, boolean reVisit, String passwd)
    {
    	DBConnection connection = new DBConnection();	
    	currentUser = new User();
    	ResultSet rs = null;
		try 
		{	    			
			try
			{
				connection.openConnection();
				CallableStatement cs = connection.getConnection().prepareCall("{ call ValidateUser(?) }");
			    cs.setString(1, login);
			    
			    boolean hasResults = cs.execute();
			    //System.out.println("HasResults: " + hasResults + " login: " + login);
			    if(hasResults)
				{
			    	rs = cs.getResultSet();
			    	//System.out.println("Resultset: " + rs.getFetchSize());
					while(rs.next())
					{
						String username = rs.getString("username");
						String pw_hash = rs.getString("password");
					
						//Log.info("Username: " + login + " " + username + " Password: " + passwd + " " + pw_hash);
						if(username.equals(login))
						{
							boolean valid = false;
							if(reVisit)
							{
								valid = true;
							}
							else
							{
								if (BCrypt.checkpw(passwd, pw_hash))
    							{
    								valid = true;
    							}
    							//System.out.println("Hash: " + valid + " " + BCrypt.checkpw(passwd, pw_hash));
							} 							
							//Log.info("UserValidation Hash: " + valid);
							if (valid)
							{
								currentUser.setUserId(rs.getInt("userId"));					
								currentUser.setUsername(username);
								currentUser.setPassword(pw_hash);
								currentUser.setUsertype(rs.getString("usertype"));
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
								currentUser.setFirstName(firstName);
								currentUser.setLastName(lastName);
								currentUser.setPrimaryemail(rs.getString("PrimaryEmail"));
								currentUser.setStatus(rs.getInt("status"));
								currentUser.setCountry(country);
								currentUser.setOrganization(organization);
								currentUser.setJobTitle(jobTitle);    	
								//currentUser.setRuntime(rs.getDouble("RemainingUnits"));
								currentUser.setRuntime(0);
								UserProcessDurationUsage userUsage = new UserProcessDurationUsage();
								double usedRuntime = userUsage.getUserUsage(currentUser.getUserId()) ;
								currentUser.setUsedRuntime(usedRuntime);
								currentUser.setTotalRuntime(rs.getDouble("TotalUnits"));
								currentUser.setNewsletter(rs.getInt("Newsletter"));
							    break;							
							}
						}
						//Log.info("Validate user: " + currentUser.getUsername());
					}
					rs.close();
				}
			    cs.close();
			    connection.closeConnection();   			  
			}
			catch(SQLException e)
			{
				logger.error(e);
				e.printStackTrace();    				
			}	
			finally
			{	
				try 
				{
					if(rs != null && (!rs.isClosed()))
					{
						rs.close();
					}
					if(connection.getConnection() != null)
					{
						connection.closeConnection();				
					}
				} 
				catch (SQLException e) 
				{			
					e.printStackTrace();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return currentUser;
    }
}