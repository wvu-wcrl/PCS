/*
 * File: UserValidationServiceImpl.java

Purpose: Java class to validate a user login details.


The LDAP authentication implementation was created by modifying an official example
provided by Oracle located at
https://docs.oracle.com/javase/jndi/tutorial/ldap/security/src/BadPasswd.java
  Retrieved 10/2015
  Terry

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



/*
 *  imports required for LDAP authentication
 *  Terry 10/2015
*/
import javax.naming.*;
import javax.naming.directory.*;
import java.util.Hashtable;




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
    	//ResultSet rs = null;      
    	User currentUser = null;  
 
    	if(currentUser == null)
    	{    		
    		currentUser = new User(); 
    		// BConnection connection = new DBConnection();	 // Create object to connect to SQL database
    	    		   		
    		
    		
    		/* LDAP Authentication Implementation */
    		
    		// Set parameters required to authenticate using LDAP
    		//   LDAP server URI       ldap://wcrlCluster:389
    		//   Authentication type   simple
    		//   Security Principal    Full addess to user LDAP entry, e.g.
    		//                            "uid=tferrett,ou=People,dc=wcrl,dc=csee,dc=wvu,dc=edu"
    		//   Security Credentials  User's password
    		Hashtable env = new Hashtable(11);
    		env.put(Context.INITIAL_CONTEXT_FACTORY, 
    		    "com.sun.jndi.ldap.LdapCtxFactory");
    		env.put(Context.PROVIDER_URL, "ldap://wcrlCluster:389");
     		env.put(Context.SECURITY_AUTHENTICATION, "simple");
      		
     		// Construct WCRL LDAP user entry for requested user.
    		String principal = "uid=" + login + "," + "ou=People, dc=wcrl, dc=csee, dc=wvu, dc=edu";
    		env.put(Context.SECURITY_PRINCIPAL, principal);
    		env.put(Context.SECURITY_CREDENTIALS, passwd);
    	
    		    		
    		// The following try block connects to LDAP and attempts authentication.
    		try {
    		
    			DirContext ctx = new InitialDirContext(env);

    		    // If successful, create user object.
    		    //  These are placeholder values for testing authentication. Replace with 
    		    //  values from MySQL.
    			currentUser.setUserId(1);					
    			currentUser.setUsername(login);
    			currentUser.setPassword("password_hash");
    			currentUser.setUsertype("Admin");    								 								
    			currentUser.setEmail("terry@hello.com");
        			
    		    // Close the context when we're done
    		    ctx.close();
    
    		} catch (NamingException e) {
    		    e.printStackTrace();
    		}
    		
    		
    		
    		
    	}
    	return currentUser;
    }
    
    
    
    
}		
    		/*     		
    		try 
    		{	    			
    			try
    			{
    		    				connection.openConnection();   // open connection to database
    				CallableStatement cs = connection.getConnection().prepareCall("{ call ValidateUser(?) }");  // MySQL processing
    			    cs.setString(1, login);
    			    
    			    boolean hasResults = cs.execute(); 
    			    
    			    if(hasResults)  // execute if results returned
    				{
    			    	rs = cs.getResultSet();  // get results, loop over all results comparing username to login
    			    							 // if user matches, set properties - may need to maintain sql database with user params
    			    							 // for now possibly just skip it, 
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
    	*/	



/*

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
} */