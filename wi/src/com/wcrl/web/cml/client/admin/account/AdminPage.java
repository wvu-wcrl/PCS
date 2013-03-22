/*
 * File: AdminPage.java

Purpose: Provide access to an Administrator to the below functions:
a. Add Job
b. Display the list the job specific to the Administrator
c. Add Users
d. Display Users list
e. Display the list of Jobs of all the users
**********************************************************/

package com.wcrl.web.cml.client.admin.account;

import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.ui.*;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.StaticClass;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.projects.ProjectList;
import com.wcrl.web.cml.client.datafiles.DataFileList;
import com.wcrl.web.cml.client.jobs.JobList;
import com.wcrl.web.cml.client.login.Login;

public class AdminPage extends Composite implements SelectionHandler<Integer>
{		
	private ClientContext ctx;
	private User currentUser;	
	private VerticalPanel panel;
	private DecoratedTabPanel tPanel;	
	private UserList userList;
	private JobList jobList;
	private JobList userJobList;	
	private ProjectList projectList;	
	private DataFileList userFileList;
	private DataFileList fileList;
	private int idx = -1;
	private String selectUser;
	private String selectProject;
	private String selectStatus;
	private ClusterStatus clusterStatus;
	
			    			
	public AdminPage(int selectedIndex, String selectUser, String selectProject, String selectStatus) 
	{		
		this.selectUser = selectUser;
		this.selectProject = selectProject;
		this.selectStatus = selectStatus;
		
		panel = new VerticalPanel();
		panel.setSize("100%", "100%");
		initWidget(panel);
		String sessionID = Cookies.getCookie("sid");
		if (sessionID != null)
		{
			ctx = (ClientContext) RPCClientContext.get();			
		    if(ctx != null)
		    {
		       	currentUser = ctx.getCurrentUser();
		       	if(currentUser != null)
		       	{
		       		initWidgets(selectedIndex);
		       	}
		    }
		    else
		    {
				Login login = new Login();
				login.displayLoginBox();
		    }
		}
		else
		{
			Login login = new Login();
			login.displayLoginBox();
		}		
	}
	
	private void initWidgets(int selectedIndex)
	{
		System.out.println("Selected index in Admin page: " + selectedIndex);
		tPanel = new DecoratedTabPanel();
   		tPanel.setSize("100%", "100%");
   		tPanel.setAnimationEnabled(true);
   		tPanel.addSelectionHandler(this);
   		   		
   		//Initialize the classes to be added as tabs in the page   		
   		userJobList = new JobList();
   		userList = new UserList();
   		jobList = new JobList();
   		projectList = new ProjectList(selectedIndex);
   		userFileList = new DataFileList();
   		fileList = new DataFileList();
   		clusterStatus = new ClusterStatus();
   		
   		if(selectedIndex == 0)
   		{
   			History.newItem("adminJobList");
   			userJobList.refresh(-1, 0, 0, selectUser, selectProject, selectStatus);
   		}
   		/*else if(selectedIndex == 1)
   		{
   			History.newItem("adminFileList");
   			userFileList.setUserFileList(1);
   		}*/
   		else if(selectedIndex == 1)
   		{
   			History.newItem("userList");
   			//userList = new UserList(2);
   			userList = new UserList();
   		}
   		else if(selectedIndex == 2)
   		{
   			History.newItem("jobList");
   			jobList.refresh(-1, 0, 2, selectUser, selectProject, selectStatus);
   		}   	
   		else if(selectedIndex == 3)
   		{
   			History.newItem("projectList");   
   			projectList.loadProjects();
   		}
   		else if(selectedIndex == 4)
   		{
   			History.newItem("fileList");
   			userFileList.refresh(-1, 0, 4, selectUser, selectProject);
   		}
   		else if(selectedIndex == 5)
   		{
   			History.newItem("adminFileList");
   			fileList.refresh(-1, 0, 5, selectUser, selectProject);
   		}
   		else if(selectedIndex == 6)
   		{
   			History.newItem("clusterStatus");
   			clusterStatus.createComponents();
   		}
   		
	    panel.add(tPanel);
	    
	    //Add the tabs to provide Administrative privileges to the user	    
	    tPanel.add(userJobList, "My Jobs");	    
	    tPanel.add(userList, "Users");
	    tPanel.add(jobList, "Jobs");	    
	    tPanel.add(projectList, "Projects");    
	    tPanel.add(userFileList, "My Data files");
	    tPanel.add(fileList, "Data files");
	    tPanel.add(clusterStatus, "Cluster Status");
	    
	    idx = selectedIndex;
	    tPanel.selectTab(selectedIndex);
	}
	
	//Handle the selection of tabs
	public void onSelection(SelectionEvent<Integer> event)
	{
		int index = event.getSelectedItem();
			
		if(index == 0)
		{
			if(!(idx == index))
			{
				StaticClass.stopJobListTimers();
				History.newItem("adminJobList");
				userJobList = new JobList();
				userJobList.refresh(-1, 0, index, selectUser, selectProject, selectStatus);
				/*userJobList.refresh(-1, 0, index, "", "", "");*/
				tPanel.remove(index);
				tPanel.insert(userJobList, "My Jobs", index);
				idx = index;
				tPanel.selectTab(index);
			}			
		}	
		if(index == 1)
		{	
			if(!(idx == index))
			{
				History.newItem("userList");
				userList = new UserList();
				tPanel.remove(index);
				tPanel.insert(userList, "Users", index);
				idx = index;
				tPanel.selectTab(index);
			}			
		}
		if(index == 2)
		{	
			if(!(idx == index))
			{
				History.newItem("jobList");
				jobList = new JobList();
				jobList.refresh(-1, 0, index, selectUser, selectProject, selectStatus);
				/*jobList.refresh(-1, 0, index, "", "", "");	*/			
				tPanel.remove(index);
				tPanel.insert(jobList, "Jobs", index);
				idx = index;
				tPanel.selectTab(index);
			}			
		}	
		if(index == 3)
		{	
			if(!(idx == index))
			{
				History.newItem("projectList");
				projectList = new ProjectList(index);
				projectList.loadProjects();
				tPanel.remove(index);
				tPanel.insert(projectList, "Projects", index);
				idx = index;
				tPanel.selectTab(index);
			}			
		}			
		if(index == 4)
		{	
			if(!(idx == index))
			{
				History.newItem("fileList");
				userFileList = new DataFileList();
				userFileList.refresh(-1, 0, index, selectUser, selectProject);
				tPanel.remove(index);
				tPanel.insert(userFileList, "My Data files", index);
				idx = index;
				tPanel.selectTab(index);				
			}			
		}
		if(index == 5)
		{	
			if(!(idx == index))
			{
				History.newItem("adminFileList");
				fileList = new DataFileList();
				fileList.refresh(-1, 0, index, selectUser, selectProject);
				tPanel.remove(index);
				tPanel.insert(fileList, "Data files", index);
				idx = index;
				tPanel.selectTab(index);
			}			
		}
		if(index == 6)
		{	
			if(!(idx == index))
			{
				History.newItem("clusterStatus");
				clusterStatus = new ClusterStatus();
				clusterStatus.createComponents();
				tPanel.remove(index);
				tPanel.insert(clusterStatus, "Cluster Status", index);
				idx = index;
				tPanel.selectTab(index);
			}			
		}
	}
}