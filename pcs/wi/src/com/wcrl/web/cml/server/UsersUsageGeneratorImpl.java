package com.wcrl.web.cml.server;

import java.io.File;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.ResourceBundle;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

import com.allen_sauer.gwt.log.client.Log;
import com.jmatio.io.MatFileReader;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLStructure;

//public class UsersUsageGeneratorServiceImpl extends RemoteEventServiceServlet implements UsersUsageGeneratorService
public class UsersUsageGeneratorImpl extends HttpServlet
{
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("UsersUsage");
	private String path = constants.getString("path"); 
	private String duration = constants.getString("updateDuration");
	private String dirName = constants.getString("dirName");
	private String fileName = constants.getString("fileName");
	private long updateDuration = 1000 * 60;
	private Timer myEventGeneratorTimer;
	private HashMap<String, Long> filesLastModified;
	
	public void init() throws ServletException 
	{
		start();
	}
    
    public synchronized void start() 
    {
    	filesLastModified = new HashMap<String, Long>();
    	try
    	{
    		double temp = Double.parseDouble(duration);
    		updateDuration = (long) (updateDuration * temp);
    		//long temp = Integer.parseInt(duration) ;
    		if(temp > 0)
    		{
    			//updateDuration = updateDuration * temp;
    			updateDuration = (long) (updateDuration * temp);
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
			File[] projectsList = rootPath.listFiles();
			//System.out.println("Rootpath: " + rootPath);
			if(projectsList != null) 
			{
				for (int i = 0; i < projectsList.length; i++)
				{
					File projectDirectory  = projectsList[i];
					String projectName = projectDirectory.getName();
					String temp_fileName = projectName + "_" + fileName;
					String filePath = projectDirectory.getPath() + File.separator + dirName + File.separator + temp_fileName;
					
					File file = new File(filePath);
					if(!filesLastModified.containsKey(projectName))
					{
						filesLastModified.put(projectName, (long) 0);
					}
					long lastModified = filesLastModified.get(projectName);
					//System.out.println("Checking project: " + projectName + " filePath: " + filePath + " Modified: " + file.lastModified() + " Previous modified: " + lastModified);
					//Log.info("Checking project: " + projectName + " filePath: " + filePath + " Modified: " + file.lastModified() + " Previous modified: " + lastModified);
					 
					if(file.lastModified() > lastModified)
					{
						filesLastModified.remove(projectName);
						filesLastModified.put(projectName, file.lastModified());
						System.out.println("Path: " + filePath + " Project: " + projectDirectory.getName());
						HashMap<String, Double> usersProcessDuration = getUsersUsage(filePath);
						updateUsersUsage(usersProcessDuration, projectName);
					}
				}
			}
        }
    }
    
    public HashMap<String, Double> getUsersUsage(String filePath)
	{				
		HashMap<String, Double> usersProcessDuration = new HashMap<String, Double>();
		MatFileReader matfilereader=null;
		try
		{
			matfilereader = new MatFileReader(filePath);
			MLStructure mlStructure = (MLStructure) matfilereader.getMLArray("UserUsage");
			Collection<MLArray> usersList = mlStructure.getAllFields();
			Iterator<MLArray> itr = null;
			itr = usersList.iterator();
			System.out.println("Count :" + usersList.size());
			int i = 1;
			double duration = 0;
			String userName = "";
			while(itr.hasNext())
			{
				MLArray value = itr.next();
				System.out.println("Content: " + value.contentToString());
				String[] tokens = value.contentToString().split("'");
				//System.out.println("tokens: " + tokens.length + " " + tokens[0] + " " + tokens[1] + " " + tokens[2]);
				if(i % 2 == 0)
				{							
					try
					{
						duration = Double.parseDouble(tokens[1]);
						//duration = Long.parseLong(tokens[1]);
						//duration = duration/60;								
					}
					catch(NumberFormatException e)
					{
						e.printStackTrace();
					}
					System.out.println("Key :" + userName + " Value: " + duration);
					usersProcessDuration.put(userName, duration);
				}
				else
				{
					userName = tokens[1];
				}
				i++;
			}
		}
		catch (Exception e)
		{
			System.out.println("error reading file: " + filePath);
			Log.info("Error in reading users usage file: "  + filePath);
			e.printStackTrace();
		}
		return usersProcessDuration;		
	}
    
    private DBConnection connection = new DBConnection();
	
	public void updateUsersUsage(HashMap<String, Double> usersProcessDuration, String projectName) 
	{
		try 
    	{    		
			connection.openConnection();
			Set<Entry<String, Double>> entrySet = usersProcessDuration.entrySet();
			for(Entry<String, Double> entry : entrySet)
			{
				String userName = entry.getKey();
				Double duration = entry.getValue();
				CallableStatement cs = connection.getConnection().prepareCall("{ call UPDATEUSERUSAGE(?, ?, ?) }");
				cs.setString(1, userName);
				cs.setDouble(2, duration);
				cs.setString(3, projectName);
				cs.execute();	
				cs.close();
			}		
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }
	}
}