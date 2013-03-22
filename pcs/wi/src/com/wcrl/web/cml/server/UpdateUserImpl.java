package com.wcrl.web.cml.server;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.ResourceBundle;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.accountService.UpdateUserService;

public class UpdateUserImpl extends RemoteServiceServlet implements UpdateUserService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private DBConnection connection = new DBConnection();
		
	public int updateUserStatus(int userId, int newStatus, int currentStatus, String username, String primaryEmail) 
	{
		int flag = -1;
		try 
    	{    		
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEUSERSTATUS(?, ?) }");
			cs.setInt(1, userId);
			cs.setInt(2, newStatus);
			flag = newStatus;
			cs.execute();	
			cs.close();
			
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }
    	
    	if(currentStatus == 0)
    	{
    		ResetPasswordAndSendEmailImpl sendEmail = new ResetPasswordAndSendEmailImpl();
    		sendEmail.createUserDirectories(username);
        	sendEmail.resetAndEmail(userId, username, primaryEmail);
    	}
    	
		return flag;  
	}
	
	public int updateNewsletterSubscription(int userId, int subscription)
	{
		int flag = -1;
		try 
    	{    		
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATENEWSLETTERSUBSCRIPTION(?, ?) }");
			cs.setInt(1, userId);
			cs.setInt(2, subscription);
			cs.execute();			
			flag = 0;
			cs.close();
			System.out.println("user: " + userId + " subscription :" + subscription);
			Log.info("subscription Flag:" + flag);
			
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }
		return flag;		
	}
	
	public int updateFirstName(int userId, String firstName) 
	{
		int flag = -1;
		try 
    	{    		
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEFIRSTNAME(?, ?) }");
			cs.setInt(1, userId);
			cs.setString(2, firstName);
			cs.execute();			
			flag = 0;
			cs.close();
			System.out.println("FirstName Flag:" + flag);
			Log.info("FirstName Flag:" + flag);
			
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }  
		return flag;	
	}
	
	public int updateLastName(int userId, String lastName) 
	{
		int flag = -1;
		try 
    	{    		
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATELASTNAME(?, ?) }");
			cs.setInt(1, userId);
			cs.setString(2, lastName);		
			cs.execute();			
			flag = 0;
			cs.close();
			System.out.println("Last Name Flag:" + flag);
			Log.info("Last Name Flag:" + flag);
			
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }  
		return flag;	
	}
	
	public int updateOrganization(int userId, String organization) 
	{
		int flag = -1;
		try 
    	{    		
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEORGANIZATION(?, ?) }");
			cs.setInt(1, userId);
			cs.setString(2, organization);
			cs.execute();			
			flag = 0;
			cs.close();
			System.out.println("Organization Flag:" + flag);
			Log.info("Organization Flag:" + flag);
			
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }  
		return flag;	
	}
	
	public int updateJobTitle(int userId, String jobTitle) 
	{
		int flag = -1;
		try 
    	{    		
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEJOBTITLE(?, ?) }");
			cs.setInt(1, userId);
			cs.setString(2, jobTitle);
			cs.execute();			
			flag = 0;
			cs.close();
			System.out.println("Job title Flag:" + flag);
			Log.info("Job title Flag:" + flag);
			
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }  
		return flag;	
	}
	
	public int updateCountry(int userId, String country) 
	{
		int flag = -1;
		try 
    	{    		
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATECOUNTRY(?, ?) }");
			cs.setInt(1, userId);
			cs.setString(2, country);
			cs.execute();			
			flag = 0;
			cs.close();
			System.out.println("Country Flag:" + flag);
			Log.info("Country Flag:" + flag);
			
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }  
		return flag;	
	}
	
	public double updateQuota(int userId, User user, double newQuota)
	{
		double totalQuota = 0;
		double usedQuota = 0;
		try 
    	{    		
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEUSERQUOTA(?, ?, ?, ?) }");
			cs.setInt(1, userId);
			cs.setDouble(2, newQuota);
			cs.registerOutParameter(3, java.sql.Types.DOUBLE);
			cs.registerOutParameter(4, java.sql.Types.DOUBLE);
			cs.execute();			
			totalQuota = cs.getDouble(3);
			usedQuota = cs.getDouble(4);
			cs.close();
			System.out.println("totalQuota: " + totalQuota);
			Log.info("totalQuota: " + totalQuota);
			
			connection.closeConnection();
			
			String content = getEmailContent(user.getFirstName(), user.getLastName(), newQuota, totalQuota, usedQuota);
			/*@SuppressWarnings("unused")
			SendEmail sendEmail = new SendEmail(user.getPrimaryemail(), content, "addquotasubject");*/
			SendEmail email = new SendEmail();
	    	email.callSendEmailScript(user.getPrimaryemail(), content, "addquotasubject");
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }
		return totalQuota;		
	}	
	
	private String getEmailContent(String firstName, String lastName, double newQuota, double totalQuota, double usedQuota) 
	{
		ResourceBundle constants = ResourceBundle.getBundle("UserQuotaEmailContent"); 
		String str = constants.getString("msg0") + " " + firstName + " " + lastName + ",";		
		str = str + constants.getString("msg1");
		str = str + " " + newQuota + " units ";
		str = str + constants.getString("msg2");
		str = str + constants.getString("msg3");
		str = str + " " + totalQuota + " units and your have " + (totalQuota - (usedQuota/60)) + " units remaining.\\n"; 
		str = str + constants.getString("msg4");
		str = str + constants.getString("msg5");		
		return str;
	}
}