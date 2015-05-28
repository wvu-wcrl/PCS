/*
 * File: UserPage.java

Purpose: Provide access to the user to the below functions:

**********************************************************/

package com.wcrl.web.cml.client.user.account;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.ui.*;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.datafiles.DataFileList;
import com.wcrl.web.cml.client.jobs.JobList;
import com.wcrl.web.cml.client.login.Login;

public class UserPage extends Composite implements SelectionHandler<Integer>
{		
	private ClientContext ctx;
	private User currentUser;	
	private VerticalPanel panel;
	private DecoratedTabPanel tPanel;
	private JobList jobList;	
	private DataFileList fileList;
	private int idx = -1;
	private String selectUser;
	private String selectProject;
	private String selectStatus;
				    			
	public UserPage(int selectedIndex, String selectUser, String selectProject, String selectStatus) 
	{	 
		this.selectUser = selectUser;
		this.selectProject = selectProject;
		this.selectStatus = selectStatus;
		
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{

			panel = new VerticalPanel();
			panel.setSize("100%", "100%");
			initWidget(panel);
			ctx = (ClientContext) RPCClientContext.get();			
		    if(ctx != null)
		    {
		       	currentUser = (User) ctx.getCurrentUser();
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
		tPanel = new DecoratedTabPanel();
   		tPanel.setSize("100%", "100%");
   		tPanel.setAnimationEnabled(true);   		
   		tPanel.addSelectionHandler(this);
   		
   		jobList = new JobList();   		  		
   		fileList = new DataFileList();
   	   		
	    panel.add(tPanel);
	    
	    if(selectedIndex == 0)
   		{	    	
	    	History.newItem("userJobList");	    
	    	jobList.refresh(-1, 0, 0, selectUser, selectProject, selectStatus);
   		}
	    else if(selectedIndex == 1)
   		{	    	
	    	History.newItem("userFileList");	    
	    	fileList.refresh(-1, 0, 1, selectUser, selectProject);
   		}
   			   	       
	    tPanel.add(jobList, "Jobs");
	    tPanel.add(fileList, "Data files");
	    idx = selectedIndex;
	    
	    tPanel.selectTab(idx);	    
	}
	
	public void onSelection(SelectionEvent<Integer> event)
	{
		int index = event.getSelectedItem();
		
		Log.info("Tab selected: " + index + " " + index + " selectUser: " + selectUser + " selectProject: " + selectProject + " selectStatus: " + selectStatus);
		
		if(index == 0)
		{	
			if(!(idx == index))
			{
				Log.info("Calling userjoblist");
				History.newItem("userJobList");		
				jobList = new JobList();
				jobList.refresh(-1, 0, index, selectUser, selectProject, selectStatus);
				tPanel.remove(index);
				tPanel.insert(jobList, "Jobs", index);
				idx = index;
				tPanel.selectTab(index);				
			}			
		}	
		if(index == 1)
		{	
			if(!(idx == index))
			{
				Log.info("Calling userfilelist");
				History.newItem("userFilelist");		
				fileList = new DataFileList();
				fileList.refresh(-1, 0, index, selectUser, selectProject);
				tPanel.remove(index);
				tPanel.insert(fileList, "Data files", index);
				idx = index;
				tPanel.selectTab(index);				
			}			
		}
	}
}