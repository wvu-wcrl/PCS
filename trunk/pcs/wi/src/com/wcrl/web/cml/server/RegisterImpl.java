package com.wcrl.web.cml.server;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.Map;

import net.tanesha.recaptcha.ReCaptcha;
import net.tanesha.recaptcha.ReCaptchaFactory;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.loginService.RegisterService;


public class RegisterImpl extends RemoteServiceServlet implements RegisterService {
	/**
	 * 
	 */
	private static final long serialVersionUID = 4714556787128793670L;
		
	public int register(Map<String, String> formData, String challenge, String response) 
	{
		int flag = -100; 
		int value = -100;
		boolean verify = verifyChallenge(challenge, response);
		System.out.println("Challenge: " + challenge + " Response: " + response);
		if(verify) 
		{
			try 
			{
				String username = formData.get("userName").toString();
				String firstName = URLDecoder.decode(formData.get("firstName").toString(), "UTF-8").trim();
				String lastName = URLDecoder.decode(formData.get("lastName").toString(), "UTF-8").trim();
				String password = URLDecoder.decode(formData.get("passsword").toString(), "UTF-8").trim();
				/*String organization = URLDecoder.decode(formData.get("organization").toString(), "UTF-8").trim();
				String country = URLDecoder.decode(formData.get("country").toString(), "UTF-8").trim();
				String jobTitle = URLDecoder.decode(formData.get("jobTitle").toString(), "UTF-8").trim();*/
				String email = URLDecoder.decode(formData.get("email").toString(), "UTF-8").toLowerCase().trim();
				
				flag = registerUser(username, email, "User", 0, firstName, lastName, password, 0);
				/*AddUsersImpl addUsers = new AddUsersImpl();
				flag = addUsers.addUser(username, email, "User", 0, firstName, lastName, organization, country, jobTitle, 0);*/				
			} 
			catch (UnsupportedEncodingException e) 
			{
				e.printStackTrace();
			}			
		}
		System.out.println("verify: " + verify + " flag: " + flag);
		if(verify == true && flag  > 0) 
		{
			value = 0;
		}
		if(verify == true && flag  <= 0)
		{
			value = 1;
		}
		if(verify == false && flag  > 0)
		{
			value = 2;
		}
		if(verify == false && flag  <= 0)
		{
			value = 3;
		}
		System.out.println("Verify: " + verify + " flag: " + flag + " Value: " + value);
		return value;		 
	}
	
	public boolean verifyChallenge(String challenge, String response)
	{
		ReCaptcha r = ReCaptchaFactory.newReCaptcha("6LeoPwYAAAAAAEgl-99fWvVvzRQObu5UoTPoQtg1", "6LeoPwYAAAAAAKTZvk06wA2GyBzDDTQUs39Bh2qC", true);
		return r.checkAnswer(getThreadLocalRequest().getRemoteAddr().toString(), challenge, response).isValid();
	}
	
	public int registerUser(String username, String email, String usertype, int status, String firstName, String lastName, String password, int registrationCnt)
	{
		DBConnection connection = new DBConnection();
    	CallableStatement cs = null;    	 
    	int flag = -5;
    	connection.openConnection();
    	
    	if(registrationCnt == -1)
    	{
    		AddUsersImpl addUsers = new AddUsersImpl();
    		registrationCnt = addUsers.checkUser(email);
    		System.out.println("RegisterCnt: " + registrationCnt);
    	}
    	if(registrationCnt == 0)
    	{    		
    		String hash = BCrypt.hashpw(password, BCrypt.gensalt(12));
    		System.out.println("Password hash: " + hash);
    		double quota = 0.0;
    		try 
    		{
    			cs = connection.getConnection().prepareCall("{ call REGISTERUSER(?, ?, ?, ?, ?, ?, ?, ?, ?, ?) }");
    			cs.setString(1, username);
    			cs.setString(2, hash);
    			cs.setString(3, firstName);
    			cs.setString(4, lastName);
    			cs.setString(5, email);
    			cs.setString(6, usertype);
    			cs.setInt(7, status);
    			cs.setDouble(8, quota);
    			cs.setInt(9, 1); /* Newsletter: Set to receive by default. */
    			cs.registerOutParameter(10, java.sql.Types.INTEGER);
    			cs.execute();
    			flag = cs.getInt(10);			
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
}