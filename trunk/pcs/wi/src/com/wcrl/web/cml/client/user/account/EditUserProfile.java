/*
 * File: AddUsers.java

Purpose: To add the users - with Admin or User role to access the web application.
**********************************************************/

package com.wcrl.web.cml.client.user.account;

import java.util.ArrayList;
import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.CloseEvent;
import com.google.gwt.event.logical.shared.CloseHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.CheckBox;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.PopupPanel;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.account.UserItems;
import com.wcrl.web.cml.client.admin.accountService.SaveSubscribedProjectService;
import com.wcrl.web.cml.client.admin.accountService.SaveSubscribedProjectServiceAsync;
import com.wcrl.web.cml.client.admin.accountService.UnSubscribeUserProjectService;
import com.wcrl.web.cml.client.admin.accountService.UnSubscribeUserProjectServiceAsync;
import com.wcrl.web.cml.client.admin.accountService.UpdateUserService;
import com.wcrl.web.cml.client.admin.accountService.UpdateUserServiceAsync;
import com.wcrl.web.cml.client.jobService.GetSubscribedProjectListService;
import com.wcrl.web.cml.client.jobService.GetSubscribedProjectListServiceAsync;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.projectService.ProjectListService;
import com.wcrl.web.cml.client.projectService.ProjectListServiceAsync;
import com.wcrl.web.cml.client.projects.ProjectItem;
import com.wcrl.web.cml.client.projects.ProjectItems;
import com.wcrl.web.cml.client.user.accountService.EditEmailService;
import com.wcrl.web.cml.client.user.accountService.EditEmailServiceAsync;


public class EditUserProfile extends Composite implements ClickHandler
{
	private ClientContext ctx;
	private VerticalPanel vPanel;
	private FlexTable table;
	private Label lblMessage;
	private Button btnCreate;
	private ListBox lstUsertype;
	private ListBox lstProjects;
	private ListBox lstSelectedProjects;
	private Button btnAdd;
	private Button btnRemove;
	private User receivedUser;
	private ArrayList<ProjectItem> subscribedProjects;
	private ArrayList<ProjectItem> projectList;
	private Anchor hlBack;
	private HorizontalPanel statusPanel;
	private Label lblStatus;
	private Label lblOrganization;
	private Label lblJobTitle;
	private Label lblCountry;
	private Label lblEmail;
	private Label lblFirstName;
	private Label lblLastName;
	private CheckBox ckNewsletter;
	
	public EditUserProfile()
	{
		vPanel = new VerticalPanel();
		initWidget(vPanel);
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			//Get the current user context
			ctx = (ClientContext) RPCClientContext.get();
		    if(ctx != null)
		    {	    	
		    	receivedUser = ctx.getCurrentUser();
		       
		       	if(receivedUser != null)
		       	{	       		
		    		table = new FlexTable();	    		
		    		vPanel.setHorizontalAlignment(HorizontalPanel.ALIGN_LEFT);
		    	    vPanel.setVerticalAlignment(VerticalPanel.ALIGN_TOP);
		    	    setProjects();
		       	}
		    }
		}
		else
		{
			Login login = new Login();
			login.displayLoginBox();
		}			
	}
	
	public void setProjects()
	{		
		if(receivedUser != null)
    	{
			ProjectListServiceAsync service = ProjectListService.Util.getInstance();
    	  	service.getProjectList(projectListCallback);	    		
    	}
	}
    
    AsyncCallback<ArrayList<ProjectItem>> projectListCallback = new AsyncCallback<ArrayList<ProjectItem>>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("ProjectList projectListCallback error: " + caught.toString());
		}
		
		public void onSuccess(ArrayList<ProjectItem> items)
		{	    	
	      	ProjectItems projectItems = new ProjectItems();	      	
	      	projectItems.setItems(items);	      	
	      	receivedUser.setProjectItems(projectItems);
	      	ctx.setCurrentUser(receivedUser);
	      	GetSubscribedProjectListServiceAsync service = GetSubscribedProjectListService.Util.getInstance();
    	  	service.getSubscribedProjectList(receivedUser.getUserId(), subscribedProjectListCallback);	      	
	      }
	  };
	  
	  AsyncCallback<ArrayList<ProjectItem>> subscribedProjectListCallback = new AsyncCallback<ArrayList<ProjectItem>>()
		{
			public void onFailure(Throwable caught)
			{
				Log.info("ProjectList projectListCallback error: " + caught.toString());
			}
			
			public void onSuccess(ArrayList<ProjectItem> items)
			{	
				subscribedProjects = items;		      	
		      	createComponents();	      	
		      }
		  };
	
	//Create the display components
	private void createComponents()
	{
		Log.info("~~~~~In edituser components");
		//table.setWidth("100%");
		//vPanel.setSize("100%", "75%");
		lblMessage = new Label();
		btnCreate = new Button("Create");
		lstUsertype = new ListBox();
		lstUsertype.addItem("User");
		lstUsertype.addItem("Admin");
		hlBack = new Anchor("<<back");		
		hlBack.addClickHandler(this);
		
		lblFirstName = new Label();
		lblLastName = new Label();
		lblOrganization = new Label();
		lblJobTitle = new Label();
		lblCountry = new Label();
		lblEmail = new Label();
		ckNewsletter = new CheckBox();
		
		lblFirstName.addClickHandler(this);
		lblLastName.addClickHandler(this);
		lblOrganization.addClickHandler(this);
		lblJobTitle.addClickHandler(this);
		lblCountry.addClickHandler(this);
		lblEmail.addClickHandler(this);
		ckNewsletter.addClickHandler(this);
				
		btnAdd = new Button(">>");
		btnAdd.addClickHandler(this);
		btnRemove = new Button("<<");
		btnRemove.addClickHandler(this);
		
		VerticalPanel buttonPanel = new VerticalPanel();
		buttonPanel.add(btnAdd);
		buttonPanel.add(new HTML("<br>"));
		buttonPanel.add(btnRemove);
		
		lstProjects = new ListBox(true);
		lstProjects.setWidth("100px");
		lstProjects.setHeight("180px");
		
		lstSelectedProjects = new ListBox(true);
		lstSelectedProjects.setWidth("100px");
		lstSelectedProjects.setHeight("180px");
				
		ProjectItems projectItems = receivedUser.getProjectItems();
		//Log.info("Number of projects: " + projectItems.getProjectItemCount());
		for(int i = 0; i < projectItems.getProjectItemCount(); i++)
		{
			ProjectItem item = projectItems.getProjectItem(i);
			boolean boolValue = false;
			for(int j = 0; j < subscribedProjects.size(); j++)
			{
				ProjectItem subscribedItem = subscribedProjects.get(j);
				if(item.getProjectId() == subscribedItem.getProjectId())
				{
					boolValue = true;
					break;					
				}
				else
				{
					boolValue = false;					
				}
			}	
			if(boolValue)
			{
				lstSelectedProjects.addItem(item.getProjectName(), String.valueOf(item.getProjectId()));
				Log.info("Adding to subscribed projects: " + item.getProjectName());
			}
			else
			{
				lstProjects.addItem(item.getProjectName(), String.valueOf(item.getProjectId()));
				Log.info("Adding to projects: " + item.getProjectName());
			}
		}		
		Log.info("Completed adding");
		btnCreate.addClickHandler(this);
	
		lblMessage.setStyleName("warnings");
		
		vPanel.add(lblMessage);
		vPanel.add(table);
		
		table.getCellFormatter().setHorizontalAlignment(0, 0, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(0, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(1, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(1, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 2, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(1, 2, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 3, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(1, 3, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(2, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(2, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(2, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(2, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(3, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(3, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(3, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(3, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(4, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(4, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(4, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(4, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(4, 2, HasHorizontalAlignment.ALIGN_CENTER);
	    table.getCellFormatter().setVerticalAlignment(4, 2, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(4, 3, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(4, 3, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(5, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(5, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(5, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(5, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(6, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(6, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(6, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(6, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(7, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(7, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(7, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(7, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(8, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(8, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(8, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(8, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(9, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(9, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(9, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(9, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(10, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(10, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(10, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(10, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(11, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(11, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(11, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(11, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(11, 2, HasHorizontalAlignment.ALIGN_CENTER);
	    table.getCellFormatter().setVerticalAlignment(11, 2, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(11, 3, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(11, 3, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(12, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(12, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(12, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(12, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    
	    VerticalPanel backPanel = new VerticalPanel();
	    backPanel.add(hlBack);
	    backPanel.add(new HTML("<br><br>"));
	    
	    table.setWidget(0, 0, backPanel);
		table.setWidget(1, 0, new HTML("<b>User Id:</b>&nbsp;&nbsp;&nbsp;"));
		table.setText(1, 1, Integer.valueOf(receivedUser.getUserId()).toString());	
		table.setWidget(2, 0, new HTML("<b>Username:</b>&nbsp;&nbsp;&nbsp;"));
		table.setText(2, 1, receivedUser.getUsername());
		table.setWidget(3, 0, new HTML("<b>Usertype:</b>&nbsp;&nbsp;&nbsp;"));
		table.setText(3, 1, receivedUser.getUsertype());
		table.setWidget(4, 0, new HTML("<b>Status:</b>&nbsp;&nbsp;&nbsp;"));
		
		statusPanel = new HorizontalPanel();
		lblStatus = new Label();

		statusPanel.add(lblStatus);
		
		 int value = receivedUser.getStatus();
		 String status = "";
		 if(value == 1)   	  
		 {
			 status = "Approved";
		 }
		 else if(value == 0)
		 {
			 status = "Not approved";
		 }	 
		lblStatus.setText(status);
		
		if(receivedUser.getNewsletter() == 1)
		{
			ckNewsletter.setValue(true);
		}
		
		if(receivedUser.getFirstName().length() == 0)
		{
			lblFirstName.setText(receivedUser.getFirstName() + ".");
		}
		else
		{
			lblFirstName.setText(receivedUser.getFirstName());
		}
		if(receivedUser.getLastName().length() == 0)
		{
			lblLastName.setText(receivedUser.getLastName() + ".");
		}
		else
		{
			lblLastName.setText(receivedUser.getLastName());
		}
		if(receivedUser.getOrganization().length() == 0)
		{
			lblOrganization.setText(receivedUser.getOrganization() + ".");
		}
		else
		{
			lblOrganization.setText(receivedUser.getOrganization());
		}
		if(receivedUser.getJobTitle().length() == 0)
		{
			lblJobTitle.setText(receivedUser.getJobTitle() + ".");
		}
		else
		{
			lblJobTitle.setText(receivedUser.getJobTitle());
		}
		if(receivedUser.getCountry().length() == 0)
		{
			lblCountry.setText(receivedUser.getCountry() + ".");
		}
		else
		{
			lblCountry.setText(receivedUser.getCountry());
		}
		if(receivedUser.getPrimaryemail().length() == 0)
		{
			lblEmail.setText(receivedUser.getPrimaryemail() + ".");
		}
		else
		{
			lblEmail.setText(receivedUser.getPrimaryemail());
		}
		
		table.setWidget(4, 1, statusPanel);
		table.setWidget(5, 0, new HTML("<b>First Name:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(5, 1, lblFirstName);
		table.setWidget(6, 0, new HTML("<b>Last Name:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(6, 1, lblLastName);
		table.setWidget(7, 0, new HTML("<b>Email:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(7, 1, lblEmail);
		table.setWidget(8, 0, new HTML("<b>Organization:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(8, 1, lblOrganization);
		table.setWidget(9, 0, new HTML("<b>Professional Title:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(9, 1, lblJobTitle);
		table.setWidget(10, 0, new HTML("<b>Country:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(10, 1, lblCountry);
		
		
		VerticalPanel projectsPanel = new VerticalPanel();
		projectsPanel.add(new HTML("<br>"));
		projectsPanel.add(new Label("Projects"));
		//projectsPanel.add(new HTML("<br>"));
		projectsPanel.add(lstProjects);
					
		VerticalPanel subscribedProjectsPanel = new VerticalPanel();
		subscribedProjectsPanel.add(new HTML("<br>"));
		subscribedProjectsPanel.add(new Label("Subscribed Projects"));
		//subscribedProjectsPanel.add(new HTML("<br>"));
		subscribedProjectsPanel.add(lstSelectedProjects);
				
		if(receivedUser.getStatus() == 1)
		{
			table.setWidget(11, 0, new HTML("<b>Projects:</b>&nbsp;&nbsp;&nbsp;"));
			table.setWidget(11, 1, projectsPanel);
			table.setWidget(11, 2, buttonPanel);
			table.setWidget(11, 3, subscribedProjectsPanel);
		}
		table.setWidget(12, 0, new HTML("<b>Subscribe to Newsletters:</b>&nbsp;&nbsp;&nbsp;"));
		table.setWidget(12, 1, ckNewsletter);
	}

	
	public void onClick(ClickEvent event) 
	{
		Widget source = (Widget) event.getSource();
		/*if(source == btnAdd)
		{
			projectList = new ArrayList<ProjectItem>();
			for(int i = 0; i < lstProjects.getItemCount(); i++)
			{
				if(lstProjects.isItemSelected(i))
				{
					String project = lstProjects.getItemText(i);
					String value = lstProjects.getValue(i);
					Log.info("Project to subscribe: " + project);
					ProjectItem item = new ProjectItem();
					try
					{
						int projectId = Integer.parseInt(value);
						item.setProjectId(projectId);
						item.setProjectName(project);
						projectList.add(item);
						SaveSubscribedProjectServiceAsync service = SaveSubscribedProjectService.Util.getInstance();
			    	  	service.saveProject(projectId, receivedUser.getUserId(), 0, receivedUser.getUsername(), project, 1, addProjectCallback);
					}
					catch(NumberFormatException e)
					{
						e.printStackTrace();
					}					
				}
			}
		}*/
		if(source == btnAdd)
		{
			projectList = new ArrayList<ProjectItem>();
			for(int i = 0; i < lstProjects.getItemCount(); i++)
			{
				if(lstProjects.isItemSelected(i))
				{
					String project = lstProjects.getItemText(i);
					String value = lstProjects.getValue(i);
					Log.info("Project to subscribe: " + project);
					ProjectItem item = new ProjectItem();
					try
					{
						int projectId = Integer.parseInt(value);
						item.setProjectId(projectId);
						item.setProjectName(project);
						projectList.add(item);
					}
					catch(NumberFormatException e)
					{
						e.printStackTrace();
					}					
				}
			}
			int projCount = projectList.size();
			int k = 0;
			for(int i = 0; i < projCount; i++)
			{
				ProjectItem item = projectList.get(i);
				int projectId = item.getProjectId();
				String project = item.getProjectName();
				int preferredProject = 0;
				
				if(k == (projCount - 1))
				{
					preferredProject = 1;
				}
				System.out.println("Project: " + project + " project count: " + (projCount - 1) + " k: " + k + " preferredProject: " + preferredProject);
				SaveSubscribedProjectServiceAsync service = SaveSubscribedProjectService.Util.getInstance();
	    	  	service.saveProject(projectId, receivedUser.getUserId(), 0, receivedUser.getUsername(), project, preferredProject, addProjectCallback);
				k++;
			}
			
		}
		if(source == btnRemove)
		{
			projectList = new ArrayList<ProjectItem>();
			for(int i = 0; i < lstSelectedProjects.getItemCount(); i++)
			{
				if(lstSelectedProjects.isItemSelected(i))
				{
					String project = lstSelectedProjects.getItemText(i);
					String value = lstSelectedProjects.getValue(i);
					Log.info("Project to unsubscribe: " + project);
					ProjectItem item = new ProjectItem();
					try
					{
						int projectId = Integer.parseInt(value);
						item.setProjectId(projectId);
						item.setProjectName(project);
						projectList.add(item);
						UnSubscribeUserProjectServiceAsync service = UnSubscribeUserProjectService.Util.getInstance();
			    	  	service.unSubscribeProject(receivedUser.getUserId(), projectId, removeProjectCallback);
					}
					catch(NumberFormatException e)
					{
						e.printStackTrace();
					}					
				}
			}
		}
		if (source == hlBack) 
		{		
			if(History.getToken().length() == 0)
			{
				RootPanel.get("content").clear();
				AccountSettings accountSettings = new AccountSettings(0);
				RootPanel.get("content").add(accountSettings);
			}
			History.newItem("settings");
			/*RootPanel.get("content").clear();
			AccountSettings accountSettings = new AccountSettings();
			RootPanel.get("content").add(accountSettings);*/
		}
		if(source == ckNewsletter)
		{			
			boolean subscriptionValue = ckNewsletter.getValue();
			System.out.println("User: " + receivedUser.getUserId() + " subscriptionValue: " + subscriptionValue);
			if(subscriptionValue)
			{
				UpdateUserServiceAsync service = UpdateUserService.Util.getInstance();
				service.updateNewsletterSubscription(receivedUser.getUserId(), 1, updateUserNewsletterSubscriptionCallback);
			}
			else
			{
				UpdateUserServiceAsync service = UpdateUserService.Util.getInstance();
				service.updateNewsletterSubscription(receivedUser.getUserId(), 0, updateUserNewsletterSubscriptionCallback);
			}			
		}
		if(source == lblEmail)
		{
			final Label object = (Label)event.getSource();
			
			int x = object.getAbsoluteLeft();							
			int y = object.getAbsoluteTop();
			PopupPanel popup = new PopupPanel(true);
			popup.removeStyleName("gwt-PopupPanel");
			popup.removeStyleName("gwt-PopupPanel .popupContent");
													
			final TextBox txtBox = new TextBox();
			int width = lblEmail.getOffsetWidth() + 50;
			//System.out.println("Email width: " + width + " x: " + x + " y: " + y);
			//Log.info("email width: " + width);
			txtBox.setSize(Integer.valueOf(width).toString(), "20px");
			txtBox.setFocus(true);
			if(receivedUser.getPrimaryemail().length() != 0)
			{
				txtBox.setText(object.getText());
			}
			else
			{
				txtBox.setText("");
			}
						
			popup.add(txtBox);
			popup.setPopupPosition(x, y);
			popup.show();
			
			popup.addCloseHandler(new CloseHandler<PopupPanel>()
			{
				public void onClose(CloseEvent<PopupPanel> event)
				{
					String txtText = txtBox.getText().trim();
					if((txtText.length()) > 0 && (txtText.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$")))
					{
						object.setText(txtText);
						//Send a request to the server to save the email address in the database
						EditEmailServiceAsync service = EditEmailService.Util.getInstance();   		
			    		service.editEmail(receivedUser.getUserId(), txtText, editEmailCallback);
					}				
					else
					{
						lblMessage.setText("Please enter a valid email address");
					}
				}
			});
		}
		if(source == lblFirstName)
		{
			final Label object = (Label)event.getSource();
			
			int x = object.getAbsoluteLeft();							
			int y = object.getAbsoluteTop();
			PopupPanel popup = new PopupPanel(true);
			popup.removeStyleName("gwt-PopupPanel");
			popup.removeStyleName("gwt-PopupPanel .popupContent");
													
			final TextBox txtBox = new TextBox();
			int width = lblFirstName.getOffsetWidth() + 50;
			//System.out.println("Firstname width: " + width + " x: " + x + " y: " + y);
			//Log.info("Firstname width: " + width);
			txtBox.setSize(Integer.valueOf(width).toString(), "20px");
			txtBox.setFocus(true);
			if(receivedUser.getFirstName().length() != 0)
			{
				txtBox.setText(object.getText());
			}
			else
			{
				txtBox.setText("");
			}
						
			popup.add(txtBox);
			popup.setPopupPosition(x, y);
			popup.show();
			final UpdateUserServiceAsync service = UpdateUserService.Util.getInstance();
			
			popup.addCloseHandler(new CloseHandler<PopupPanel>()
			{
				public void onClose(CloseEvent<PopupPanel> event)
				{
					String txtText = null;
					if(txtBox.getText() == "")
					{
						txtText = object.getText();
					}
					else
					{
						txtText  = txtBox.getText().trim();									
						object.setText(txtText);
						//Long projectName = Long.parseLong(txtText);
						service.updateFirstName(receivedUser.getUserId(), txtText, updateUserFirstNameCallback);															
					}
				}
			});
		}
		if(source == lblLastName)
		{
			final Label object = (Label)event.getSource();
			
			int x = object.getAbsoluteLeft();							
			int y = object.getAbsoluteTop();
			PopupPanel popup = new PopupPanel(true);
			popup.removeStyleName("gwt-PopupPanel");
			popup.removeStyleName("gwt-PopupPanel .popupContent");
													
			final TextBox txtBox = new TextBox();
			int width = lblLastName.getOffsetWidth() + 50;
			//System.out.println("Lastname width: " + width + " x: " + x + " y: " + y);
			//Log.info("Lastname width: " + width);
			txtBox.setSize(Integer.valueOf(width).toString(), "20px");
			txtBox.setFocus(true);
			if(receivedUser.getLastName().length() != 0)
			{
				txtBox.setText(object.getText());
			}
			else
			{
				txtBox.setText("");
			}
						
			popup.add(txtBox);
			popup.setPopupPosition(x, y);
			popup.show();
			final UpdateUserServiceAsync service = UpdateUserService.Util.getInstance();
			
			popup.addCloseHandler(new CloseHandler<PopupPanel>()
			{
				public void onClose(CloseEvent<PopupPanel> event)
				{
					String txtText = null;
					if(txtBox.getText() == "")
					{
						txtText = object.getText();
					}
					else
					{
						txtText  = txtBox.getText().trim();									
						object.setText(txtText);
						//Long projectName = Long.parseLong(txtText);
						service.updateLastName(receivedUser.getUserId(), txtText, updateUserLastNameCallback);															
					}
				}
			});
		}
		if(source == lblOrganization)
		{
			final Label object = (Label)event.getSource();
			
			int x = object.getAbsoluteLeft();							
			int y = object.getAbsoluteTop();
			PopupPanel popup = new PopupPanel(true);
			popup.removeStyleName("gwt-PopupPanel");
			popup.removeStyleName("gwt-PopupPanel .popupContent");
													
			final TextBox txtBox = new TextBox();
			int width = lblOrganization.getOffsetWidth() + 50;
			//System.out.println("Org width: " + width + " x: " + x + " y: " + y);
			//Log.info("Org width: " + width);
			txtBox.setSize(Integer.valueOf(width).toString(), "20px");
			txtBox.setFocus(true);
			if(receivedUser.getOrganization().length() != 0)
			{
				txtBox.setText(object.getText());
			}
			else
			{
				txtBox.setText("");
			}
						
			popup.add(txtBox);
			popup.setPopupPosition(x, y);
			popup.show();
			final UpdateUserServiceAsync service = UpdateUserService.Util.getInstance();
			
			popup.addCloseHandler(new CloseHandler<PopupPanel>()
			{
				public void onClose(CloseEvent<PopupPanel> event)
				{
					String txtText = null;
					if(txtBox.getText() == "")
					{
						txtText = object.getText();
					}
					else
					{
						txtText  = txtBox.getText().trim();									
						object.setText(txtText);
						//Long projectName = Long.parseLong(txtText);
						service.updateOrganization(receivedUser.getUserId(), txtText, updateUserOrganizationCallback);															
					}
				}
			});
		}
		if(source == lblJobTitle)
		{
			final Label object = (Label)event.getSource();
			
			int x = object.getAbsoluteLeft();							
			int y = object.getAbsoluteTop();
			PopupPanel popup = new PopupPanel(true);
			popup.removeStyleName("gwt-PopupPanel");
			popup.removeStyleName("gwt-PopupPanel .popupContent");
													
			final TextBox txtBox = new TextBox();
			int width = lblJobTitle.getOffsetWidth() + 50;
			//System.out.println("Job title width: " + width + " x: " + x + " y: " + y);
			//Log.info("Job title width: " + width);
			txtBox.setSize(Integer.valueOf(width).toString(), "20px");
			txtBox.setFocus(true);
			if(receivedUser.getJobTitle().length() != 0)
			{
				txtBox.setText(object.getText());
			}
			else
			{
				txtBox.setText("");
			}
						
			popup.add(txtBox);
			popup.setPopupPosition(x, y);
			popup.show();
			final UpdateUserServiceAsync service = UpdateUserService.Util.getInstance();
			
			popup.addCloseHandler(new CloseHandler<PopupPanel>()
			{
				public void onClose(CloseEvent<PopupPanel> event)
				{
					String txtText = null;
					if(txtBox.getText() == "")
					{
						txtText = object.getText();
					}
					else
					{
						txtText  = txtBox.getText().trim();									
						object.setText(txtText);
						//Long projectName = Long.parseLong(txtText);
						service.updateJobTitle(receivedUser.getUserId(), txtText, updateUserJobTitleCallback);															
					}
				}
			});
		}
		if(source == lblCountry)
		{
			final Label object = (Label)event.getSource();
			
			int x = object.getAbsoluteLeft();							
			int y = object.getAbsoluteTop();
			PopupPanel popup = new PopupPanel(true);
			popup.removeStyleName("gwt-PopupPanel");
			popup.removeStyleName("gwt-PopupPanel .popupContent");
													
			final TextBox txtBox = new TextBox();
			int width = lblOrganization.getOffsetWidth() + 50;
			//System.out.println("Country width: " + width + " x: " + x + " y: " + y);
			//Log.info("Country width: " + width);
			txtBox.setSize(Integer.valueOf(width).toString(), "20px");
			txtBox.setFocus(true);
			if(receivedUser.getCountry().length() != 0)
			{
				txtBox.setText(object.getText());
			}
			else
			{
				txtBox.setText("");
			}
						
			popup.add(txtBox);
			popup.setPopupPosition(x, y);
			popup.show();
			final UpdateUserServiceAsync service = UpdateUserService.Util.getInstance();
			
			popup.addCloseHandler(new CloseHandler<PopupPanel>()
			{
				public void onClose(CloseEvent<PopupPanel> event)
				{
					String txtText = null;
					if(txtBox.getText() == "")
					{
						txtText = object.getText();
					}
					else
					{
						txtText  = txtBox.getText().trim();									
						object.setText(txtText);
						//Long projectName = Long.parseLong(txtText);
						service.updateCountry(receivedUser.getUserId(), txtText, updateUserCountryCallback);															
					}
				}
			});
		}
	}	
		
	//Callback from server - To set the list of users enrolled in the web application
	AsyncCallback<ArrayList<User>> usersCallback = new AsyncCallback<ArrayList<User>>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("AddUsers usersCallback error: " +  arg0.toString());				
		}		
		public void onSuccess(ArrayList<User> users)
		{			
			if(ctx != null)
			{
				User currentUser = ctx.getCurrentUser();
				if(users != null)
				{
					UserItems userItems = new UserItems();
					userItems.setUserItems(users);
					currentUser.setUserItems(userItems);
				}
			}			
		}
	};
	
	 AsyncCallback<Integer> updateUserStatusCallback = new AsyncCallback<Integer>()
	  {
		  public void onFailure(Throwable arg0)
		  {
			  System.out.print(arg0.toString());
			  Log.info("EditUserProfile updateUserStatusCallback: "+  arg0.toString());
		  }
		  public void onSuccess(Integer flag)
		  {
			  if(flag == 0)
			  {
				  lblStatus.setText("Approved");
				  lblMessage.setText("User approved.");				  
			  }
			  else
			  {				  
				  lblMessage.setText("Error in approving user. Please try again later.");
			  }
		  }
	  };
	
	AsyncCallback<Integer> addProjectCallback = new AsyncCallback<Integer>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("AddUsers addProjectCallback error: " +  arg0.toString());				
		}		
		public void onSuccess(Integer flag)
		{			
			if(flag != -1)
			{
				//User currentUser = ctx.getCurrentUser();
				Log.info("Projects to add: " + projectList.size() + " flag: " + flag);
				for(ProjectItem item : projectList)
				{
					boolean bool = false;
					int index = -1;
					String id = Integer.valueOf(item.getProjectId()).toString();
					
					for(int i = 0; i < lstProjects.getItemCount(); i++)
					{
						String projectId = lstProjects.getValue(i);
						if(projectId.equalsIgnoreCase(id) && (Integer.parseInt(id) == flag))
						{
							Log.info("Add ProjectId: " + projectId + " id: " + id + " flag: " + flag);
							bool = true;
							index = i;
							break;
						}			
						else
						{
							bool = false;
						}			
					}
					if(bool)
					{
						lstSelectedProjects.addItem(item.getProjectName(), id);
						lstProjects.removeItem(index);
					}
					Log.info("Added project: " + item.getProjectName());
				}				
			}			
		}
	};

	AsyncCallback<Integer> removeProjectCallback = new AsyncCallback<Integer>()
	{		
		public void onFailure(Throwable arg0) 
		{
			Log.info("EditUser removeProjectCallback error: " +  arg0.toString());				
		}		
		public void onSuccess(Integer flag)
		{			
			if(flag != -1)
			{
				//User currentUser = ctx.getCurrentUser();
				Log.info("Projects to remove: " + projectList.size() + " flag: " + flag);
				for(ProjectItem item : projectList)
				{
					boolean bool = false;
					int index = -1;
					String id = Integer.valueOf(item.getProjectId()).toString();
					
					for(int i = 0; i < lstSelectedProjects.getItemCount(); i++)
					{
						String projectId = lstSelectedProjects.getValue(i);
						if(projectId.equalsIgnoreCase(id) && (Integer.parseInt(id) == flag))
						{
							Log.info("Remove ProjectId: " + projectId + " id: " + id + " flag: " + flag);
							bool = true;
							index = i;
							break;
						}			
						else
						{
							bool = false;
						}
					}
					if(bool)
					{
						lstProjects.addItem(item.getProjectName(), id);
						lstSelectedProjects.removeItem(index);
					}
					Log.info("Removed project: " + item.getProjectName());
				}				
			}			
		}
	};
		
	AsyncCallback<Boolean> editEmailCallback = new AsyncCallback<Boolean>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("EditEmail editEmailCallback error: " + caught.toString());			
		}
		public void onSuccess(Boolean result) 
		{			
			boolean editEmail = result;
			lblMessage.setText("");
			if(editEmail)
			{
				//System.out.println("EditEmail: " + editEmail);
				if(ctx != null)
				{
					lblMessage.setText("Your email address is updated.");
					receivedUser.setPrimaryemail(lblEmail.getText());
					/*currentUser = ctx.getCurrentUser();
					if(currentUser != null)
					{
						currentUser.setPrimaryemail(lblEmail.getText());
						ctx.setCurrentUser(currentUser);					
					}*/										
				}				
			}	
		}	
	};
	
	AsyncCallback<Integer> updateUserFirstNameCallback = new AsyncCallback<Integer>()
	{
		public void onFailure(Throwable arg0)
		{
			System.out.print(arg0.toString());
			Log.info("EditUserProfile updateUserFirstNameCallback: "+  arg0.toString());
		}
		public void onSuccess(Integer flag)
		{
			lblMessage.setText("");
			if(flag == 0)
			{
				receivedUser.setFirstName(lblFirstName.getText());
				String firstName = receivedUser.getFirstName();
				if(firstName.length() == 0)
				{
					lblFirstName.setText(receivedUser.getFirstName() + ".");
				}
				else
				{
					lblFirstName.setText(receivedUser.getFirstName());
					lblMessage.setText("User first name is updated.");
				}
			}
			else
			{
				String firstName = receivedUser.getFirstName();
				if(firstName.length() == 0)
				{
					lblFirstName.setText(receivedUser.getFirstName() + ".");
				}
				else
				{
					lblFirstName.setText(receivedUser.getFirstName());
					lblMessage.setText("Error in the update of first name. Please try again later.");
				}
			}
		}
	};
	
	AsyncCallback<Integer> updateUserLastNameCallback = new AsyncCallback<Integer>()
	{
		public void onFailure(Throwable arg0)
		{
			System.out.print(arg0.toString());
			Log.info("EditUserProfile updateUserLastNameCallback: "+  arg0.toString());
		}
		public void onSuccess(Integer flag)
		{
			lblMessage.setText("");
			if(flag == 0)
			{
				receivedUser.setLastName(lblLastName.getText());
				String lastName = receivedUser.getLastName();
				if(lastName.length() == 0)
				{
					lblLastName.setText(receivedUser.getLastName() + ".");
				}
				else
				{
					lblLastName.setText(receivedUser.getLastName());
					lblMessage.setText("User last name is updated.");
				}
			}
			else
			{
				String lastName = receivedUser.getLastName();
				if(lastName.length() == 0)
				{
					lblLastName.setText(receivedUser.getLastName() + ".");
				}
				else
				{
					lblLastName.setText(receivedUser.getLastName());
					lblMessage.setText("Error in the update of last name. Please try again later.");
				}
			}
		}
	};
	
	AsyncCallback<Integer> updateUserOrganizationCallback = new AsyncCallback<Integer>()
	{
		public void onFailure(Throwable arg0)
		{
			System.out.print(arg0.toString());
			Log.info("EditUserProfile updateUserOrganizationCallback: " + arg0.toString());
		}
		public void onSuccess(Integer flag)
		{
			lblMessage.setText("");
			if(flag == 0)
			{
				receivedUser.setOrganization(lblOrganization.getText());
				String organization = receivedUser.getOrganization();
				if(organization.length() == 0)
				{
					lblOrganization.setText(receivedUser.getOrganization() + ".");
				}
				else
				{
					lblOrganization.setText(receivedUser.getOrganization());
					lblMessage.setText("User organization title is updated.");
				}
			}
			else
			{
				String organization = receivedUser.getOrganization();
				if(organization.length() == 0)
				{
					lblOrganization.setText(receivedUser.getOrganization() + ".");
				}
				else
				{
					lblOrganization.setText(receivedUser.getOrganization());
					lblMessage.setText("Error in the update of organization. Please try again later.");
				}
			}
		}
	};
	
	AsyncCallback<Integer> updateUserJobTitleCallback = new AsyncCallback<Integer>()
	{
		public void onFailure(Throwable arg0)
		{
			System.out.print(arg0.toString());
			Log.info("EditUserProfile updateUserJobTitleCallback: "+ arg0.toString());
		}
		public void onSuccess(Integer flag)
		{
			lblMessage.setText("");
			if(flag == 0)
			{
				receivedUser.setJobTitle(lblJobTitle.getText());
				String jobTitle = receivedUser.getJobTitle();
				if(jobTitle.length() == 0)
				{
					lblJobTitle.setText(receivedUser.getJobTitle() + ".");
				}
				else
				{
					lblJobTitle.setText(receivedUser.getJobTitle());
					lblMessage.setText("User profesional title is updated.");
				}
			}
			else
			{
				String path = receivedUser.getJobTitle();
				if(path.length() == 0)
				{
					lblJobTitle.setText(receivedUser.getJobTitle() + ".");
				}
				else
				{
					lblJobTitle.setText(receivedUser.getJobTitle());
					lblMessage.setText("Error in the update of professional title. Please try again later.");
				}
			}
		}
	};
	
	AsyncCallback<Integer> updateUserCountryCallback = new AsyncCallback<Integer>()
	{
		public void onFailure(Throwable arg0)
		{
			System.out.print(arg0.toString());
			Log.info("EditUserProfile updateUserCountryCallback: " + arg0.toString());
		}
		public void onSuccess(Integer flag)
		{
			lblMessage.setText("");
			if(flag == 0)
			{
				receivedUser.setCountry(lblCountry.getText());
				String country = receivedUser.getCountry();
				if(country.length() == 0)
				{
					lblCountry.setText(receivedUser.getCountry() + ".");
				}
				else
				{
					lblCountry.setText(receivedUser.getCountry());
					lblMessage.setText("User country title is updated.");
				}
			}
			else
			{
				String country = receivedUser.getCountry();
				if(country.length() == 0)
				{
					lblCountry.setText(receivedUser.getCountry() + ".");
				}
				else
				{
					lblCountry.setText(receivedUser.getCountry());
					lblMessage.setText("Error in the update of country. Please try again later.");
				}
			}
		}
	};
	
	AsyncCallback<Integer> updateUserNewsletterSubscriptionCallback = new AsyncCallback<Integer>()
	{
		public void onFailure(Throwable arg0)
		{
			System.out.print(arg0.toString());
			Log.info("EditUserProfile updateUserNewsletterSubscriptionCallback: "+  arg0.toString());
		}
		public void onSuccess(Integer flag)
		{
			lblMessage.setText("");
			boolean newsletterValue = ckNewsletter.getValue();
			int newsletter = 0;
			if(newsletterValue)
			{
				newsletter = 1;
			}
			else
			{
				newsletter = 0;
			}
			int userNewsletter = receivedUser.getNewsletter();
			if(flag == 0)
			{								
				if(userNewsletter != newsletter)
				{
					lblMessage.setText("User newsletter subscription is updated.");
				}
				receivedUser.setNewsletter(newsletter);
			}
			else
			{
				lblMessage.setText("Error in the update of newsletter subscription. Please try again later.");
			}
		}
	};
}