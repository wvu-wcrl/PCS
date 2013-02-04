package com.wcrl.web.cml.server;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
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
				String organization = URLDecoder.decode(formData.get("organization").toString(), "UTF-8").trim();
				String country = URLDecoder.decode(formData.get("country").toString(), "UTF-8").trim();
				String jobTitle = URLDecoder.decode(formData.get("jobTitle").toString(), "UTF-8").trim();
				String email = URLDecoder.decode(formData.get("email").toString(), "UTF-8").toLowerCase().trim();
				AddUsersImpl addUsers = new AddUsersImpl();
				flag = addUsers.addUser(username, email, "User", 0, firstName, lastName, organization, country, jobTitle, -1);
			} 
			catch (UnsupportedEncodingException e) 
			{
				// TODO Auto-generated catch block
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
}