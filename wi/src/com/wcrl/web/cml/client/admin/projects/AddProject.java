/*
 * File: AddProject.java

Purpose: User interface class to add a new User/Group
Input fields: 
1. Company name
2. Username
3. Password
Optional Input fields:
1. Country
2. Email
**********************************************************/

package com.wcrl.web.cml.client.admin.projects;

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.projectService.AddProjectService;
import com.wcrl.web.cml.client.admin.projectService.AddProjectServiceAsync;
import com.wcrl.web.cml.client.login.Login;

public class AddProject extends Composite{
	
	private VerticalPanel vPanel = new VerticalPanel();
	private Label lblMsg = new Label();
	private FlexTable table;	
	private TextBox txtProject;
	private TextBox txtDirectoryPath;
	private ListBox lstDataFile;
	private TextArea txtDescription;	
		
	private Button btnClear;
	private Button btnSave;
	private ClientContext ctx;
	private User currentUser;	
	private Anchor hlBack;	
	
	public AddProject()
	{
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			ctx = (ClientContext) RPCClientContext.get();		
		    if(ctx != null)
		    {
		    	currentUser = ctx.getCurrentUser();
		    	if(currentUser.getUsername() != null)
		    	{
		    		createComponents();
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
	
	private void createComponents()
	{		
		hlBack = new Anchor("<<back");
		
		table = new FlexTable();
		btnSave = new Button("Save");
		btnClear = new Button("Clear");
				
		txtProject = new TextBox();
		txtDirectoryPath = new TextBox();
		lstDataFile = new ListBox();
		txtDescription = new TextArea();	
		
		lstDataFile.addItem("Not Required", "0");
		lstDataFile.addItem("Required", "1");
		lstDataFile.addItem("Possibly Required", "2");
		lstDataFile.setItemSelected(0, true);
		
		txtProject.setName("projectName");
		txtDescription.setName("description");
		txtDirectoryPath.setName("directoryPath");
		lstDataFile.setName("dataFile");
		table.setCellPadding(2);
		txtProject.setWidth("175px");
		txtDirectoryPath.setWidth("175px");
			
		table.setCellSpacing(5);
		vPanel.setWidth("100%");
				
		table.setText(0, 0, "Project Name:");
		table.setText(1, 0, "Description:");
		//table.setText(2, 0, "Directory path:");
		table.setText(3, 0, "Data file:");
				
		table.getCellFormatter().setHorizontalAlignment(0, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(0, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(1, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(2, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(2, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(3, 0, HasHorizontalAlignment.ALIGN_RIGHT);
	    table.getCellFormatter().setVerticalAlignment(3, 0, HasVerticalAlignment.ALIGN_MIDDLE);
	   	
		table.setWidget(0, 1, txtProject);
		table.setWidget(1, 1, txtDescription);
		//table.setWidget(2, 1, txtDirectoryPath);
		//table.setWidget(3, 1, chkDataFile);
		table.setWidget(3, 1, lstDataFile);
		
		table.getCellFormatter().setHorizontalAlignment(0, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(0, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(1, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(1, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(2, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(2, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	    table.getCellFormatter().setHorizontalAlignment(3, 1, HasHorizontalAlignment.ALIGN_LEFT);
	    table.getCellFormatter().setVerticalAlignment(3, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	   		   				
		lblMsg.addStyleName("warnings");								
		HorizontalPanel buttonPanel = new HorizontalPanel();		
		hlBack.addClickHandler(new ClickHandler()
		{
			public void onClick(ClickEvent event) 
			{
				History.newItem("projectList");
				/*RootPanel.get("content").clear();
				AdminPage adminPage = new AdminPage(5);
				RootPanel.get("content").add(adminPage);*/		
			}			
		});
									
		btnSave.addClickHandler(new ClickHandler()
		{
			public void onClick(ClickEvent event) 
			{				
				try
				{					
					Map<String, String> data = getDataAsMap();
					if(txtProject.getText().trim().length() <= 0)
					{
						lblMsg.setText("Please enter the project name.");
					}
					else
					{
						Set<Entry<String, String>> entrySet = data.entrySet();
						for(Entry<String, String> entry : entrySet)
						{
							System.out.println(entry.getKey() + " " + entry.getValue());
						}
						AddProjectServiceAsync service = AddProjectService.Util.getInstance();					
						service.addProject(data, addProjectCallback);
					}
				}
				catch(NumberFormatException exc)
				{
					exc.printStackTrace();
				}				
			}			
		});
		
		btnClear.addClickHandler(new ClickHandler()
		{
			public void onClick(ClickEvent event) 
			{
				lblMsg.setText("");			
				txtProject.setValue("");				
				txtDescription.setValue("");
				//chkDataFile.setValue(false);
				lstDataFile.setItemSelected(0, true);
				txtDirectoryPath.setValue("");
			}			
		});
		
		buttonPanel.add(btnSave);
		buttonPanel.add(btnClear);	
		table.setWidget(7, 1, buttonPanel);
			
		
		vPanel.add(lblMsg);
		vPanel.add(hlBack);
		vPanel.add(table);
		
		vPanel.setVerticalAlignment(VerticalPanel.ALIGN_TOP);
		vPanel.setHorizontalAlignment(HorizontalPanel.ALIGN_LEFT);
		vPanel.setSize("1000px", "500px");
		
		initWidget(vPanel);		
	}
	
	public Map<String, String> getDataAsMap()
	{		
		Map<String, String> data = new HashMap<String, String>();
		
		data.put(txtProject.getName(), txtProject.getText().trim());
		data.put(txtDescription.getName(), txtDescription.getText().trim());		
		data.put(txtDirectoryPath.getName(), txtDirectoryPath.getText().trim());
		String dataFileRequiredFlag = "";
		/*if(chkDataFile.getValue())
		{
			checked = "true";
		}
		data.put(chkDataFile.getName(), checked);*/
		dataFileRequiredFlag = lstDataFile.getValue(lstDataFile.getSelectedIndex());
		data.put(lstDataFile.getName(), dataFileRequiredFlag);
		
		return data;		
	}
		
	AsyncCallback<Integer> addProjectCallback = new AsyncCallback<Integer>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("AddProject addProjectCallback: " + caught.toString());
		}
		public void onSuccess(Integer result) 
		{			
			int projectAddeed = (Integer)result;
			if(projectAddeed == 1)
			{
				lblMsg.setText("Project already exists. Please enter a new project name.");
			}			
			else if(projectAddeed == 0)
			{
				lblMsg.setText("Project details saved.");								
				txtProject.setValue("");				
				txtDescription.setValue("");
				//chkDataFile.setValue(false);
				lstDataFile.setSelectedIndex(0);
				txtDirectoryPath.setValue("");
			}							
		}	
	};	
}