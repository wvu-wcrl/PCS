package com.wcrl.web.cml.server;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.Map;

import javax.servlet.http.HttpSession;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.projectService.AddProjectService;

public class AddProjectImpl extends RemoteServiceServlet implements AddProjectService {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
			
	public int addProject(Map<String, String> formData) 
	{
		int flag = -1;
		HttpSession session = this.getThreadLocalRequest().getSession();
		if (session.getAttribute("Username") != null)
		{
			String projectName = null;
	    	String description = null;
	    	String path = null;
	    	int dataFile = 0;
	    	//System.out.println("flag:" + flag);
	    	DBConnection connection = new DBConnection();
	    	try 
	    	{   
	    		projectName = URLDecoder.decode(formData.get("projectName").toString(), "UTF-8");
	    		description = URLDecoder.decode(formData.get("description").toString(), "UTF-8");
	    		path = URLDecoder.decode(formData.get("directoryPath").toString(), "UTF-8");
	    		String temp = URLDecoder.decode(formData.get("dataFile").toString(), "UTF-8");
	    		/*if(temp.equalsIgnoreCase("true"))
	    		{
	    			dataFile = 1;
	    		}*/
	    		try
	    		{
	    			dataFile = Integer.parseInt(temp);
	    		}
	    		catch(NumberFormatException e)
	    		{
	    			e.printStackTrace();
	    		}
	    	    		
				connection.openConnection();
				
				CallableStatement cs = connection.getConnection().prepareCall("{ call AddProject(?, ?, ?, ?, ?) }");
				cs.setString(1, projectName);
				cs.setString(2, description);
				cs.setString(3, path);
				cs.setInt(4, dataFile);
				cs.registerOutParameter(5, java.sql.Types.INTEGER);
				cs.execute();
				flag = cs.getInt(5);
				cs.close();
				//System.out.println("Flag: " + flag + " Group:" + group);
				connection.closeConnection();			
			} 
	    	catch (UnsupportedEncodingException e) 
	    	{
				e.printStackTrace();
			}
	    	catch (SQLException e) 
	        {
	        	e.printStackTrace();
	        }
		}    	       
    	return flag;
    }     	    
}