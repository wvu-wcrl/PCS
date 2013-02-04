package com.wcrl.web.cml.server;

import java.io.File;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.ResourceBundle;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.projects.ProjectItem;
import com.wcrl.web.cml.client.projects.ProjectItems;

public class MonitorUsersUsageImpl extends HttpServlet
{
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("UsersUsage");
	private String duration = constants.getString("monitorDuration");
	private long monitorDuration = 1000 * 60;
	private Timer myEventGeneratorTimer;
	private UserProcessDurationUsage userUsage;

	private ResourceBundle pathConstants = ResourceBundle.getBundle("Paths");
	private String path = pathConstants.getString("path"); 
	private String projectConstant = pathConstants.getString("projects");
	
	public void init() throws ServletException 
	{
		start();
	}
    
    public synchronized void start() 
    {
    	try
    	{
    		long temp = Integer.parseInt(duration) ;
    		if(temp > 0)
    		{
    			monitorDuration = monitorDuration * temp;
    		}
    	}
    	catch(NumberFormatException e)
    	{
    		e.printStackTrace();
    	}
        if(myEventGeneratorTimer == null) 
        {
            myEventGeneratorTimer = new Timer();
            myEventGeneratorTimer.schedule(new ServerMessageGeneratorTimerTask(), 0, monitorDuration);            
        }
    }

    private class ServerMessageGeneratorTimerTask extends TimerTask
    {   
		public void run() 
		{			
			HashMap<Integer, User> users = getAllUsers();
			Set<Entry<Integer, User>> entrySet = users.entrySet();
			userUsage = new UserProcessDurationUsage();
			for(Entry<Integer, User> entry : entrySet)
			{
				int userId = entry.getKey();				
				double userProcessUsage = userUsage.getUserUsage(userId);
				User user = entry.getValue();
				String userName = user.getUsername();
				user.setUsedRuntime(userProcessUsage);
				double totalUserUnits = user.getTotalRuntime();
				ProjectItems userProjects = user.getProjectItems();
								
				if(userProcessUsage >= totalUserUnits)
				{
					for(int i = 0; i < userProjects.getProjectItemCount(); i++)
					{
						ProjectItem project = userProjects.getProjectItem(i);
						String projectName = project.getProjectName();
						
						String[] statusDirectory = new String[2];
						statusDirectory[0] = "JobIn";
						statusDirectory[1] = "JobRunning";	
						String rootPath = path + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
						
						for(int k = 0; k < 2; k++)
						{
							suspendJobs(statusDirectory[k], rootPath);
						}
					}
				}
				
				double remainingUsage = totalUserUnits - userProcessUsage;
				double remainPercent = (remainingUsage * 100)/totalUserUnits;
				if(remainPercent <= 20)
				{
					//sendEmail(user);
				}
			}
        }
    }
    
    public void sendEmail(User user)
    {
    	String content = getEmailContent(user.getFirstName(), user.getLastName());
    	/*@SuppressWarnings("unused")
		SendEmail email = new SendEmail(user.getPrimaryemail(), content, "runoutquotasubject");*/
    	SendEmail email = new SendEmail();
    	email.callSendEmailScript(user.getPrimaryemail(), content, "runoutquotasubject");
    }
    
    private String getEmailContent(String firstName, String lastName) 
	{
    	ResourceBundle constants = ResourceBundle.getBundle("AlertUserQuotaEmailContent");
		String str = constants.getString("msg0") + " " + firstName + " " + lastName + ",";
		str = str + constants.getString("msg1");
		str = str + constants.getString("msg2");
		str = str + constants.getString("msg3");				
		return str;
	}
    
    public HashMap<Integer, User> getAllUsers()
	{
    	HashMap<Integer, User> users = new HashMap<Integer, User>();
		try 
    	{    
			DBConnection connection = new DBConnection();	
			connection.openConnection();
			CallableStatement cs = connection.getConnection().prepareCall("{ call GETALLUSERS() }");					
			boolean usersExist = cs.execute();
			if(usersExist)
			{
				ResultSet rs = cs.getResultSet();
				while(rs.next())
				{
					User user = new User();
					int userId = rs.getInt("UserId");
					user.setUserId(userId);
					user.setUsertype(rs.getString("Usertype"));
					user.setUsername(rs.getString("Username"));
					user.setTotalRuntime(rs.getDouble("TotalUnits"));
					ProjectItems projectItems = new ProjectItems();
					
					CallableStatement projectsStmt = connection.getConnection().prepareCall("{ call GETUSERPROJECTS(?) }");
					projectsStmt.setInt(1, userId);
					if(projectsStmt.execute())
					{
						ResultSet projectsResultSet = projectsStmt.getResultSet();
						while(projectsResultSet.next())
						{
							ProjectItem project = new ProjectItem();
							project.setProjectId(projectsResultSet.getInt("ProjectId"));
							project.setProjectName(projectsResultSet.getString("ProjectName"));
							projectItems.addProjectItem(project);
						}						
					}
					projectsStmt.close();
					user.setProjectItems(projectItems);
					
					if(!users.containsKey(userId))
					{
						users.put(userId, user);
					}
				}
			}
			
			cs.close();	
			connection.closeConnection();
		}
    	catch (SQLException e) 
        {
        	e.printStackTrace();
        }
		return users;
	}
        
    public void suspendJobs(String statusDirectory, String rootPath)
	{	    	
		String dir = pathConstants.getString(statusDirectory);
		String path = rootPath + dir + File.separator;
		File filesRootPath = new File(path);
		File[] files = filesRootPath.listFiles();
		int fileCount = files.length;
		if(fileCount > 0)
		{
			for(int i = 0; i < fileCount; i++)
			{
				String fileName = files[i].getName();
				String filePath = rootPath + dir + File.separator + fileName;
				
				File jobFile = new File(filePath);
				boolean flag = jobFile.exists();
				if(flag)
				{
					// Move job file to Suspended directory
					String destinationPath = rootPath + pathConstants.getString("Suspend") + File.separator + fileName;
					System.out.println("To move File path: " + filePath);
					FileOperations fileOperations = new FileOperations();
					fileOperations.copyFile(filePath, destinationPath);
					fileOperations.removeFile(jobFile);		
				}				
			}			
		}
	}
}