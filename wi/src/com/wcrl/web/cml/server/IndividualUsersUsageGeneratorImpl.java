package com.wcrl.web.cml.server;

import java.io.File;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.ResourceBundle;
import java.util.Timer;
import java.util.TimerTask;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

import com.jmatio.io.MatFileReader;
import com.jmatio.types.MLArray;

public class IndividualUsersUsageGeneratorImpl extends HttpServlet
{
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("UsersUsage");
	private String path = constants.getString("path1"); 
	private String duration = constants.getString("updateDuration");
	private String fileName = constants.getString("usageFileName");
	private String projects = constants.getString("projects");
	private long updateDuration = 1000 * 60;
	private Timer myEventGeneratorTimer;
	//private HashMap<String, Long> filesLastModified;
	
	public void init() throws ServletException 
	{
		start();
	}
    
    public synchronized void start() 
    {
    	//filesLastModified = new HashMap<String, Long>();
    	try
    	{
    		long temp = Integer.parseInt(duration) ;
    		if(temp > 0)
    		{
    			updateDuration = updateDuration * temp;
    		}
    	}
    	catch(NumberFormatException e)
    	{
    		e.printStackTrace();
    	}
        if(myEventGeneratorTimer == null) 
        {
            myEventGeneratorTimer = new Timer();
            myEventGeneratorTimer.schedule(new ServerMessageGeneratorTimerTask(), 0, updateDuration);            
        }
    }

    private class ServerMessageGeneratorTimerTask extends TimerTask
    {   
		public void run() 
		{			
			File rootPath = new File(path);
						
			if(rootPath.isDirectory()) 
			{
				File[] usersDirList = rootPath.listFiles();
				if(usersDirList != null) 
				{
					for(int i = 0; i < usersDirList.length; i++)
					{
						File userDirectory  = usersDirList[i];
						String filePath = userDirectory.getPath() + File.separator + projects + File.separator;
						File userProjectDirectoryRoot = new File(filePath);
						if(userProjectDirectoryRoot != null && userProjectDirectoryRoot.isDirectory())
						{
							File[] projectsList = userProjectDirectoryRoot.listFiles();
							for(int j = 0; j < projectsList.length; j++)
							{
								File projectDirectory  = projectsList[j];
								String projectFilePath = projectDirectory.getPath() + File.separator + fileName;	
								double projectProcessDuration = getUserProjectUsage(projectFilePath);
								updateUserProjectUsage(userDirectory.getName(), projectDirectory.getName(), projectProcessDuration);
							}
						}									  
					}
				}
			}			
        }
    }
    
    public double getUserProjectUsage(String filePath)
	{		
		MatFileReader matfilereader=null;
		double duration = 0;
		try
		{
			matfilereader = new MatFileReader(filePath);
			MLArray processDuration = matfilereader.getMLArray("TotalProcessDuration");
			System.out.println("processDuration: " + processDuration.contentToString());
			String[] tokens = processDuration.contentToString().split("=");
			duration = Double.parseDouble(tokens[1].trim());			
		}
		catch (Exception e)
		{
			System.out.println("error reading file");
			e.printStackTrace();
		}
		return duration;		
	}
    
    private DBConnection connection = new DBConnection();
	
	public void updateUserProjectUsage(String userName, String projectName, double duration) 
	{
		try 
    	{    		
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEUSERUSAGE(?, ?, ?) }");
			cs.setString(1, userName);
			cs.setDouble(2, duration);
			cs.setString(3, projectName);
			cs.execute();	
			cs.close();		
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }
	}
}