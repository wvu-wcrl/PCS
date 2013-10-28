/*
 * File: UserValidationServiceImpl.java

Purpose: Java class to validate a user login details.
******************************************************/
package com.googlecode.mgwt.examples.showcase.server.elements;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.client.rpc.SerializableException;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.AuthenticationException;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.User;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.service.UserValidationService;
import com.googlecode.mgwt.examples.showcase.server.db.BCrypt;
import com.googlecode.mgwt.examples.showcase.server.db.DBConnection;

import org.apache.log4j.Logger;

@SuppressWarnings({ "serial", "deprecation" })
public class UserValidationImpl extends RemoteServiceServlet implements UserValidationService 
{		
	private static Logger logger = Logger.getLogger(UserValidationImpl.class);
		
	public User validateUser(String userName, String password)throws AuthenticationException, SerializableException 
	{    	
    	User userBean;

        try 
        {			
            userBean = ckLogin(userName, password); 
            createSession(userName);
            String sessionID = validateSession("Username");
            System.out.println("Session value: "  + sessionID + " UserBean: " + userBean.getUsername());
            Log.info("Session value: "  + sessionID + " UserBean: " + userBean.getUsername());
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
	
	private void createSession(String username)
	{
		HttpServletRequest request = this.getThreadLocalRequest();
		HttpSession session = request.getSession();
		if (session.getAttribute("Username") == null)
		{
			session.setAttribute("Username", username);
		}
	}
	
	public String validateSession(String username)
	{
		HttpServletRequest request = this.getThreadLocalRequest();
		HttpSession session = request.getSession();
		System.out.println("Session on server side: " + session);
		System.out.println("Session value on server side: " + session.getAttribute(username));
		Log.info("Session on server side: " + session);
		Log.info("Session value on server side: " + session.getAttribute(username));
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
		boolean sessionValue = false;
		if (session.getAttribute("userName") != null)
		{
			session.setAttribute("Username", null);
			sessionValue = true;
		}
		else
		{
			sessionValue = true;
		}
		return sessionValue;			
	}	
    
    public User ckLogin(String login, String passwd)
    {    	
    	ResultSet rs = null;
    	User currentUser = null;
    	if(currentUser == null)
    	{    		
    		currentUser = new User();
    		DBConnection connection = new DBConnection();	
    		
    		try 
    		{	    			
    			try
    			{
    				connection.openConnection();
    				CallableStatement cs = connection.getConnection().prepareCall("{ call ValidateUser(?) }");
    			    cs.setString(1, login);
    			    
    			    boolean hasResults = cs.execute();
    			    if(hasResults)
    				{
    			    	rs = cs.getResultSet();
    					while(rs.next())
    					{
    						String username = rs.getString("username");
    						String pw_hash = rs.getString("password");
    					
    						if(username.equals(login))
    						{
    							if (BCrypt.checkpw(passwd, pw_hash))
    							{
    								currentUser.setUserId(rs.getInt("userId"));					
    								currentUser.setUsername(username);
    								//System.out.println("Password hash: " + pw_hash);
    								currentUser.setPassword(pw_hash);
    								currentUser.setUsertype(rs.getString("usertype"));    								 								
    								currentUser.setEmail(rs.getString("PrimaryEmail"));
    							    break;	
    							}	
    						}
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
    	}    	
    	return currentUser;	
    }
}