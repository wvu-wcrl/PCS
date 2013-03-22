/*
 * File: PersonalSettings.java

Purpose: Java class to handle user's Personal settings - Edit email and Change Password
**********************************************************/
package com.wcrl.web.cml.client.user.account;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;
import java.util.Map.Entry;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ChangeEvent;
import com.google.gwt.event.dom.client.ChangeHandler;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.accountService.SaveSubscribedProjectService;
import com.wcrl.web.cml.client.admin.accountService.SaveSubscribedProjectServiceAsync;
import com.wcrl.web.cml.client.jobService.GetPreferredProjectService;
import com.wcrl.web.cml.client.jobService.GetPreferredProjectServiceAsync;
import com.wcrl.web.cml.client.jobService.GetSubscribedProjectListService;
import com.wcrl.web.cml.client.jobService.GetSubscribedProjectListServiceAsync;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.projects.ProjectItem;
import com.wcrl.web.cml.client.projects.ProjectItems;

public class ProjectSettings extends Composite implements ClickHandler, ChangeHandler 
{
	private ClientContext ctx;
	private User user;
	private VerticalPanel panel;
	private FlexTable table;
	private Label msgLabel;
	private ListBox lbProjects;
	private Button btnSubmit;
	private String msgText;
	private String projectName;
	private int projectId;
	
	public ProjectSettings() 
	{		
		panel = new VerticalPanel();
		initWidget(panel);
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{

			ctx = (ClientContext) RPCClientContext.get();			
		    if(ctx != null)
		    {	    	
		       	user = ctx.getCurrentUser();		
				setProjects();
		    }
		}
		else
		{
			Login login = new Login();
			login.displayLoginBox();
		}
	}
		
	//Initialize and attach components
	private void getPersonalSettingsPanel()
	{			
		table = new FlexTable();
		lbProjects = new ListBox(false);
		msgLabel = new Label();
		btnSubmit = new Button("Save");
   		msgLabel.setStylePrimaryName("msg");
   		this.user = ctx.getCurrentUser();
   		Log.info("Preferred project is: " + user.getPreferredProject());
   		if(user.getPreferredProjectId() <= 0)
   		{
   			msgText = "You haven't selected your default project.";
   		}
   		else
   		{
   			msgText = "Your default project is " + user.getPreferredProject() + ".";
   		}
   		msgLabel.setText(msgText);
   		int temp = user.getPreferredProjectId();
   		//System.out.println("temp:" + temp);
   		//Log.info("temp:" + temp);
   		ProjectItems projectItems = user.getProjectItems();
   		lbProjects.addItem("--Select--", "0");
		for(int i = 0; i < projectItems.getProjectItemCount(); i++)
		{
			ProjectItem item = projectItems.getProjectItem(i);
			lbProjects.addItem(item.getProjectName(), String.valueOf(item.getProjectId()));	
			if(temp > 0)
			{
				if(temp == item.getProjectId())
				{
					lbProjects.setItemSelected(i+1, true);
				}
			}
			else
			{
				lbProjects.setItemSelected(0, true);
			}
		}
		   		
		FlexTable programTable = new FlexTable();
		
		table.setCellSpacing(10);
		table.setCellPadding(10);
		table.setWidget(0, 0, programTable);
				
		String lblProgram = "Default Project: ";
		programTable.setText(0, 0, lblProgram);
		programTable.setWidget(0, 1, lbProjects);
		programTable.setWidget(1, 1, btnSubmit);
		
		programTable.getCellFormatter().setVerticalAlignment(0, 0, HasVerticalAlignment.ALIGN_TOP);
		programTable.getCellFormatter().setHorizontalAlignment(0, 0, HasHorizontalAlignment.ALIGN_LEFT);
		programTable.getCellFormatter().setVerticalAlignment(0, 2, HasVerticalAlignment.ALIGN_TOP);
		programTable.getCellFormatter().setHorizontalAlignment(0, 2, HasHorizontalAlignment.ALIGN_LEFT);
		programTable.getCellFormatter().setVerticalAlignment(1, 2, HasVerticalAlignment.ALIGN_TOP);
		programTable.getCellFormatter().setHorizontalAlignment(1, 2, HasHorizontalAlignment.ALIGN_LEFT);
						
		panel.add(msgLabel);
		panel.add(table);
		
		lbProjects.addChangeHandler(this);
		btnSubmit.addClickHandler(this);
	}

	//Handle click events
	public void onClick(ClickEvent event) 
	{
		Widget source = (Widget) event.getSource();		
		if(source == btnSubmit)
		{					
			projectId = Integer.parseInt(lbProjects.getValue(lbProjects.getSelectedIndex()));
			projectName = lbProjects.getItemText(lbProjects.getSelectedIndex());
			if(projectId > 0)
			{
				SaveSubscribedProjectServiceAsync service = SaveSubscribedProjectService.Util.getInstance();			
	    	  	service.saveProject(projectId, user.getUserId(), 0, user.getUsername(), projectName, 1, saveSubscribedProjectCallback);
			}			
			else
			{
				msgText = "Please choose a project.";
				msgLabel.setText(msgText);
			}
		}		
	}

	public void onChange(ChangeEvent event) 
	{
		Widget source = (Widget)event.getSource();
		if(source == lbProjects)
		{
			int projectId = Integer.parseInt(lbProjects.getValue(lbProjects.getSelectedIndex()));		
			if(projectId > 0)
			{
				msgText = "You chose " + lbProjects.getItemText(lbProjects.getSelectedIndex()) + " project.";
			}
			else
			{
				msgText = "You haven't chose a project.";
			}			
			msgLabel.setText(msgText);
		}				
	}
	
	public void setProjects()
	{		
		if(user != null)
    	{
    		GetSubscribedProjectListServiceAsync service = GetSubscribedProjectListService.Util.getInstance();
    	  	service.getSubscribedProjectList(user.getUserId(), projectListCallback);	    		
    	}
	}
    
    AsyncCallback<ArrayList<ProjectItem>> projectListCallback = new AsyncCallback<ArrayList<ProjectItem>>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("ProjectSettings projectListCallback error: " + caught.toString());
		}
		
		public void onSuccess(ArrayList<ProjectItem> items)
		{	    
			Log.info("Received Subscribed list.");
	      	ProjectItems projectItems = new ProjectItems();	      	
	      	projectItems.setItems(items);	      	
	      	user.setProjectItems(projectItems);
	      	ctx.setCurrentUser(user);
	      	GetPreferredProjectServiceAsync service = GetPreferredProjectService.Util.getInstance();
	      	service.getPreferredProject(user.getUserId(), preferredProjectCallback);	      	
	      }
	  };
	  
	  AsyncCallback<HashMap<Integer, String>> preferredProjectCallback = new AsyncCallback<HashMap<Integer, String>>()
	  {
		  public void onFailure(Throwable caught)
		  {
			  Log.info("ProjectSettings preferredProjectCallback error: " + caught.toString());
		  }
		public void onSuccess(HashMap<Integer, String> project)
		  {
			  Log.info("Received preferred project size: " + project.size());
			  if(project.size() > 0)
			  {
				  Log.info("Received preferred project is not null.");
				  Set<Entry<Integer, String>> entrySet = project.entrySet();
				  for(Entry<Integer, String> entry : entrySet)
				  {
					  user.setPreferredProjectId(entry.getKey());
					  user.setPreferredProject(entry.getValue());
					  Log.info("ProjectSettings: " + entry.getKey() + " " + entry.getValue());
				  }				  				  
			  }
			  else
			  {
				  Log.info("Received preferred project is null.");
				  user.setPreferredProjectId(0);
				  user.setPreferredProject("");
			  }
			  ctx.setCurrentUser(user);
			  getPersonalSettingsPanel();
		  }
	  };
	  
	  AsyncCallback<Integer> saveSubscribedProjectCallback = new AsyncCallback<Integer>()
	  {
		  public void onFailure(Throwable caught)
		  {
			  Log.info("SaveSubscribedProjectCallback error: " + caught.toString());
		  }
		  
		  public void onSuccess(Integer flag)
		  {	    
			  if(flag != -1)
			  {
				  user.setPreferredProjectId(projectId);
				  user.setPreferredProject(projectName);
				  Log.info("Saved preferred project.");
				  ctx.setCurrentUser(user);	
				  msgText = user.getPreferredProject() + " is saved as your default project.";
				  msgLabel.setText(msgText);
			  }
			  else
			  {
				  msgText = "Error in saving the preferred project. Please try again later.";
				  msgLabel.setText(msgText);
			  }
		  }
	  };	  
}