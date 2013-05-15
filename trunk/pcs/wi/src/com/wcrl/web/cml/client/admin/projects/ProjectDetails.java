/*
 * File: JobDetails.java

Purpose: To display the job attributes and provide links to input and output files.
**********************************************************/

package com.wcrl.web.cml.client.admin.projects;

import java.util.Date;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.client.ui.*;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.CloseEvent;
import com.google.gwt.event.logical.shared.CloseHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.account.AdminPage;
import com.wcrl.web.cml.client.admin.projectService.DeleteProjectService;
import com.wcrl.web.cml.client.admin.projectService.DeleteProjectServiceAsync;
import com.wcrl.web.cml.client.admin.projectService.UpdateProjectService;
import com.wcrl.web.cml.client.admin.projectService.UpdateProjectServiceAsync;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.projects.ProjectItem;
import com.wcrl.web.cml.client.projects.ProjectItems;
import com.wcrl.web.cml.client.user.account.UserPage;

public class ProjectDetails extends Composite implements ClickHandler 
{
	private VerticalPanel panel;
	private VerticalPanel headerPanel;	
	private VerticalPanel detailsPanel;
	private VerticalPanel topPanel;
	private HorizontalPanel buttonPanel, projectDetailsPanel;
	private FlexTable table;	
	private Button btnDelete, btnSave, btnCancel;
	private Anchor hlBack;
	private HTML txtWarnings;
	private ProjectItem projectItem;	
	private int projectID;
	private ClientContext ctx;
	private User currentUser;
	private ProjectItems projectItems;
	private Label lblProjectName;
	private Label lblProjectDescription;
	private Label lblProjectPath;
	private Label lblMsg;
	private RadioButton rdDataFileRequired;
	private RadioButton rdDataFileNotRequired;
	private RadioButton rdDataFilePossiblyRequired;
	private int tabNumber;
	
	public ProjectDetails(int tabNumber, int id) 
	{
		this.tabNumber = tabNumber;
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			this.projectID = id;
			//Get and set the current user context
			ctx = (ClientContext) RPCClientContext.get();

			if (ctx != null) 
			{			
				projectDetailsPanel = new HorizontalPanel();
				panel = new VerticalPanel();
				projectDetailsPanel.add(panel);				
				initWidget(projectDetailsPanel);
				
				currentUser = ctx.getCurrentUser();		
				init();
			} 
			else
			{
				Log.info("Ctx null JobDetails");
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
		

	//Initialize and set the components
	@SuppressWarnings("deprecation")
	private void init() 
	{
		if(currentUser != null)
		{
			projectItems = currentUser.getProjectItems();
			this.projectItem = projectItems.getProjectItembyID(projectID);
			
			headerPanel = new VerticalPanel();
			detailsPanel = new VerticalPanel();
			topPanel = new VerticalPanel();
			buttonPanel = new HorizontalPanel();
			
			table = new FlexTable();	
			btnDelete = new Button("Delete");
			hlBack = new Anchor("<<back");
			lblProjectName = new Label();
			lblProjectDescription = new Label();
			lblProjectPath = new Label();
			lblMsg = new Label();
			lblMsg.addStyleName("warnings");
			
			rdDataFileRequired = new RadioButton("group", "Required");
			rdDataFileNotRequired = new RadioButton("group", "Not Required");
			rdDataFilePossiblyRequired = new RadioButton("group", "Possibly Required");
			VerticalPanel radioPanel = new VerticalPanel();
			radioPanel.add(rdDataFileRequired);
			radioPanel.add(rdDataFileNotRequired);
			radioPanel.add(rdDataFilePossiblyRequired);
			rdDataFileRequired.addClickHandler(this);
			rdDataFileNotRequired.addClickHandler(this);
			rdDataFilePossiblyRequired.addClickHandler(this);
			
			hlBack.addClickHandler(this);
			
			btnSave = new Button("Save");
			btnCancel = new Button("Cancel");
			txtWarnings = new HTML();

			Log.info("In project details ProjectID:" + projectID);

			table.setCellSpacing(5);
			
			table.setCellPadding(0);
			table.setWidth("100%");
			projectDetailsPanel.setSize("100%", "75%");
			
			txtWarnings.setVisible(false);

			btnSave.addClickHandler(this);
			btnCancel.addClickHandler(this);
			btnSave.setEnabled(false);
			btnCancel.setEnabled(false);

			setTableRowWidget(0, 0, new HTML("<b>Project Name:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(1, 0, new HTML("<b>Project Id:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(2, 0, new HTML("<b>Description:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(3, 0, new HTML("<b>Data File:</b>&nbsp;&nbsp;&nbsp;"));
			//setTableRowWidget(4, 0, new HTML("<b>Path:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(5, 0, new HTML("<b>Last Update:</b>&nbsp;&nbsp;&nbsp;"));			
						
			lblProjectName.setText(projectItem.getProjectName());
			String description = projectItem.getDescription();
			if(description != null)
			{
				if(description.length() == 0)
				{
					lblProjectDescription.setText(projectItem.getDescription() + ".");
				}
				else
				{
					lblProjectDescription.setText(projectItem.getDescription());
				}
			}
			
			
			String path = projectItem.getPath();
			if(path != null)
			{
				if(path.length() == 0)
				{
					lblProjectPath.setText(projectItem.getPath() + ".");
				}
				else
				{
					lblProjectPath.setText(projectItem.getPath());
				}				
			}
			if(projectItem.getDataFile().equalsIgnoreCase("Required"))
			{
				rdDataFileRequired.setValue(true);
				rdDataFileNotRequired.setValue(false);
				rdDataFilePossiblyRequired.setValue(false);
			}
			else if(projectItem.getDataFile().equalsIgnoreCase("Not Required"))
			{					
				rdDataFileRequired.setValue(false);
				rdDataFileNotRequired.setValue(true);
				rdDataFilePossiblyRequired.setValue(false);
			}
			else
			{
				rdDataFileRequired.setValue(false);
				rdDataFileNotRequired.setValue(false);
				rdDataFilePossiblyRequired.setValue(true);
			}
			
			
			//System.out.println("~~~~~~~~~~Path: " + projectItem.getPath().length() + " projectItem.getDataFile(): " + projectItem.getDataFile());
			//Log.info("~~~~~~~~~~Path: " + projectItem.getPath().length() + " projectItem.getDataFile(): " + projectItem.getDataFile());
			setTableRowWidgetValue(0, 1, lblProjectName);
			setTableRowText(1, 1, Integer.valueOf(projectItem.getProjectId()).toString());						
			setTableRowWidgetValue(2, 1, lblProjectDescription);
			setTableRowWidgetValue(3, 1, radioPanel);
			//setTableRowWidgetValue(4, 1, lblProjectPath);
			Date lastModifiedDate = new Date(projectItem.getLastUpdate());
			setTableRowText(5, 1, lastModifiedDate.toString());
			
			//lblProjectName.addClickHandler(this);
			lblProjectDescription.addClickHandler(this);
			lblProjectPath.addClickHandler(this);
						
			buttonPanel.add(btnDelete);
							
			HorizontalPanel outer = new HorizontalPanel();
		    HorizontalPanel inner = new HorizontalPanel();
		    HorizontalPanel hlPanel = new HorizontalPanel();
			hlPanel.add(hlBack);
			hlPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));

		    outer.setHorizontalAlignment(HorizontalPanel.ALIGN_RIGHT);
		    inner.setHorizontalAlignment(HorizontalPanel.ALIGN_RIGHT);
		    inner.setVerticalAlignment(VerticalPanel.ALIGN_MIDDLE);
		  	    
		    outer.add(hlPanel);
		    outer.setCellHorizontalAlignment(hlPanel, HorizontalPanel.ALIGN_LEFT);
		    outer.setCellVerticalAlignment(hlPanel, VerticalPanel.ALIGN_MIDDLE);

		    outer.add(inner);
		    inner.add(buttonPanel);
		    inner.add(new HTML("&nbsp;&nbsp;&nbsp;"));
		    inner.add(lblMsg);
					    
			btnDelete.addClickHandler(this);			

			detailsPanel.add(table);
			detailsPanel.add(new HTML("<br><br><br>"));
			
			headerPanel.setWidth("100%");
			
			topPanel.add(outer);
			topPanel.add(new HTML("<br>"));
			topPanel.add(headerPanel);

			DockPanel innerPanel = new DockPanel();
			innerPanel.add(detailsPanel, DockPanel.CENTER);
		
			innerPanel.setCellHeight(detailsPanel, "100%");
			panel.add(txtWarnings);
			txtWarnings.setStylePrimaryName("progressbar-text");
			txtWarnings.setStylePrimaryName("message");
			
			panel.add(topPanel);
			panel.add(innerPanel);
			innerPanel.setSize("100%", "100%");
			
			detailsPanel.setSize("100%", "100%");
			//projectDetailsPanel.add(lblMsg);
			projectDetailsPanel.add(panel);
			projectDetailsPanel.setCellHorizontalAlignment(panel, HasHorizontalAlignment.ALIGN_CENTER);
			
			/*initWidget(projectDetailsPanel);*/

			setStyleName("mail-Detail");
			innerPanel.setStyleName("mail-DetailInner");		
		}		
	}

	public void onClick(ClickEvent event) 
	{
		Widget widget = (Widget) event.getSource();	
		
		//Delete the Job
		if (widget == btnDelete) 
		{
			if(Window.confirm("Are you sure to delete the Job?"))
			{
				DeleteProjectServiceAsync service = DeleteProjectService.Util.getInstance();
				service.deleteProject(projectItem.getProjectId(), deleteFileCallback);				
			}
		}
		//Take the control back to list of Jobs (depends upon the user)
		if (widget == hlBack) 
		{
			RootPanel.get("content").clear();
			//AdminPage adminPage = new AdminPage(5);
			AdminPage adminPage = new AdminPage(tabNumber, "", "", "", 0);
			RootPanel.get("content").add(adminPage);		
		}
		
		if(widget == rdDataFileRequired)
		{
			if(rdDataFileRequired.getValue())
			{
				UpdateProjectServiceAsync service = UpdateProjectService.Util.getInstance();
				service.updateDataFile(projectItem.getProjectId(), 1, updateProjectDataFileCallback);				
			}
		}
		
		if(widget == rdDataFileNotRequired)
		{
			if(rdDataFileNotRequired.getValue())
			{
				UpdateProjectServiceAsync service = UpdateProjectService.Util.getInstance();
				service.updateDataFile(projectItem.getProjectId(), 0, updateProjectDataFileCallback);
			}
		}
		
		if(widget == rdDataFilePossiblyRequired)
		{
			if(rdDataFilePossiblyRequired.getValue())
			{
				UpdateProjectServiceAsync service = UpdateProjectService.Util.getInstance();
				service.updateDataFile(projectItem.getProjectId(), 2, updateProjectDataFileCallback);
			}
		}
		
		if(widget == lblProjectName)
		{
			final Label object = (Label)event.getSource();
			int x = object.getAbsoluteLeft();							
			int y = object.getAbsoluteTop();
			PopupPanel popup = new PopupPanel(true);
			popup.removeStyleName("gwt-PopupPanel");
			popup.removeStyleName("gwt-PopupPanel .popupContent");
													
			final TextBox txtBox = new TextBox();
			int width = lblProjectName.getOffsetWidth() + 20;
			//System.out.println("Name width: " + width);
			//Log.info("Name width: " + width);
			txtBox.setSize(Integer.valueOf(width).toString(), "20px");
			
			txtBox.setFocus(true);
			txtBox.setText(object.getText());
			popup.add(txtBox);
			popup.setPopupPosition(x, y);
			popup.show();
			final UpdateProjectServiceAsync service = UpdateProjectService.Util.getInstance();
			
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
						service.updateProjectName(projectItem.getProjectId(), txtText, updateProjectNameCallback);															
					}
				}
			});
		}
		
		if(widget == lblProjectDescription)
		{
			final Label object = (Label)event.getSource();
			int x = object.getAbsoluteLeft();							
			int y = object.getAbsoluteTop();
			PopupPanel popup = new PopupPanel(true);
			popup.removeStyleName("gwt-PopupPanel");
			popup.removeStyleName("gwt-PopupPanel .popupContent");
													
			final TextBox txtBox = new TextBox();
			int width = lblProjectDescription.getOffsetWidth() + 50;
			//System.out.println("Description width: " + width);
			//Log.info("Description width: " + width);
			txtBox.setSize(Integer.valueOf(width).toString(), "20px");
			txtBox.setFocus(true);
			if(projectItem.getDescription().length() != 0)
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
			final UpdateProjectServiceAsync service = UpdateProjectService.Util.getInstance();
			
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
						service.updateProjectDescription(projectItem.getProjectId(), txtText, updateProjectDescriptionCallback);	
					}
				}
			});
		}
		
		if(widget == lblProjectPath)
		{
			final Label object = (Label)event.getSource();
			
			int x = object.getAbsoluteLeft();							
			int y = object.getAbsoluteTop();
			PopupPanel popup = new PopupPanel(true);
			popup.removeStyleName("gwt-PopupPanel");
			popup.removeStyleName("gwt-PopupPanel .popupContent");
													
			final TextBox txtBox = new TextBox();
			int width = lblProjectPath.getOffsetWidth() + 50;
			//System.out.println("Path width: " + width + " x: " + x + " y: " + y);
			//Log.info("Path width: " + width);
			txtBox.setSize(Integer.valueOf(width).toString(), "20px");
			txtBox.setFocus(true);
			if(projectItem.getPath().length() != 0)
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
			final UpdateProjectServiceAsync service = UpdateProjectService.Util.getInstance();
			
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
						service.updateProjectPath(projectItem.getProjectId(), txtText, updateProjectPathCallback);															
					}
				}
			});
		}
	}
	
	//After deleting job from database take the control the list of jobs
	AsyncCallback<Integer> deleteFileCallback = new AsyncCallback<Integer>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("ProjectDetails deleteFileCallback error: " + caught.toString());			
		}
		public void onSuccess(Integer receivedProjectId) 
		{			
			if(receivedProjectId != -1)
			{
				projectItems = currentUser.getProjectItems();
				projectItems.deleteProjectItem(receivedProjectId);							
				currentUser.setProjectItems(projectItems);
				ctx.setCurrentUser(currentUser);
				RootPanel.get("content").clear();
				if(currentUser.getUsertype().equalsIgnoreCase("user"))
				{
					//UserPage userPage = new UserPage(5);
					UserPage userPage = new UserPage(tabNumber, "", "", "");
					RootPanel.get("content").add(userPage);
				}
				else
				{
					//AdminPage adminPage = new AdminPage(2);
					AdminPage adminPage = new AdminPage(tabNumber, "", "", "", 0);
					RootPanel.get("content").add(adminPage);
				}				
			}			
		}
	};	
	
	AsyncCallback<int[]> updateProjectNameCallback = new AsyncCallback<int[]>()
	  {
		  public void onFailure(Throwable arg0)
		  {
			  System.out.print(arg0.toString());
			  Log.info("ProjectDetails updateProjectNameCallback: " + arg0.toString());
		  }
		  public void onSuccess(int[] flag)
		  {
			  lblMsg.setText("");
			  if(flag[0] == 0)
			  {
				  String projectName = projectItem.getProjectName();
				  String labelProjectName = lblProjectName.getText().trim();
				  if(!projectName.equalsIgnoreCase(labelProjectName))
				  {
					  projectItem.setProjectName(lblProjectName.getText());
					  lblMsg.setText("Project name is updated.");
				  }				  
			  }
			  else
			  {		
				  String projectName = projectItem.getProjectName();
				  String labelProjectName = lblProjectName.getText().trim();
				  if(!projectName.equalsIgnoreCase(labelProjectName))
				  {
					  lblProjectName.setText(projectItem.getProjectName());
					  lblMsg.setText("Project name already exists. Please choose another project name.");					  
				  } 			  				  
			  }
		  }
	  };
	  
	  AsyncCallback<int[]> updateProjectDescriptionCallback = new AsyncCallback<int[]>()
	  {
		  public void onFailure(Throwable arg0)
		  {
			  System.out.print(arg0.toString());
			  Log.info("ProjectDetails updateProjectDescriptionCallback: "+ arg0.toString());
		  }
		  public void onSuccess(int[] flag)
		  {
			  lblMsg.setText("");
			  if(flag[0] == 0)
			  {
				  projectItem.setDescription(lblProjectDescription.getText());
				  String description = projectItem.getDescription();
				  if(description.length() == 0)
				  {
					  lblProjectDescription.setText(projectItem.getDescription() + ".");
				  }
				  else
				  {
					  lblProjectDescription.setText(projectItem.getDescription());
					  lblMsg.setText("Project description is updated.");
				  }				  
			  }
			  else
			  {		
				  String description = projectItem.getDescription();
				  if(description.length() == 0)
				  {
					  lblProjectDescription.setText(projectItem.getDescription() + ".");
				  }
				  else
				  {
					  lblProjectDescription.setText(projectItem.getDescription());
					  lblMsg.setText("Error in the update of project description. Please try again later.");
				  }				  
			  }
		  }
	  };
	  
	  AsyncCallback<int[]> updateProjectPathCallback = new AsyncCallback<int[]>()
	  {
		  public void onFailure(Throwable arg0)
		  {
			  System.out.print(arg0.toString());
			  Log.info("ProjectDetails updateProjectPathCallback" + arg0.toString());
		  }
		  public void onSuccess(int[] flag)
		  {
			  lblMsg.setText("");
			  if(flag[0] == 0)
			  {
				  projectItem.setPath(lblProjectPath.getText());
				  String path = projectItem.getPath();
				  if(path.length() == 0)
				  {
					  lblProjectPath.setText(projectItem.getPath() + ".");
				  }
				  else
				  {
					  lblProjectPath.setText(projectItem.getPath());
					  lblMsg.setText("Project path is updated.");
				  }				  
			  }
			  else
			  {		
				  String path = projectItem.getPath();
				  if(path.length() == 0)
				  {
					  lblProjectPath.setText(projectItem.getPath() + ".");
				  }
				  else
				  {
					  lblProjectPath.setText(projectItem.getPath());
					  lblMsg.setText("Error in the update of project path. Please try again later.");
				  }				  
			  }
		  }
	  };
	  
	  AsyncCallback<int[]> updateProjectDataFileCallback = new AsyncCallback<int[]>()
	  {
		  public void onFailure(Throwable arg0)
		  {
			  System.out.print(arg0.toString());
			  Log.info("ProjectDetails updateProjectDataFileCallback: "+ arg0.toString());
		  }
		  public void onSuccess(int[] flag)
		  {
			  lblMsg.setText("");
			  String dataFile = "";
			  if(flag[0] == -1)
			  {				  
				  if(rdDataFileRequired.getValue())
				  {
					  dataFile = rdDataFileRequired.getText();
				  }
				  else if(rdDataFileNotRequired.getValue())
				  {
					  dataFile = rdDataFileNotRequired.getText();
				  }
				  else if(rdDataFilePossiblyRequired.getValue())
				  {
					  dataFile = rdDataFilePossiblyRequired.getText();
				  }				  
				  lblMsg.setText("Error in project update. Please try again later.");		
			  }
			  else
			  {
				  if(flag[0] == 0)
				  {
					  dataFile = rdDataFileNotRequired.getText();
				  }
				  else if(flag[0] == 1)
				  {
					  dataFile = rdDataFileRequired.getText();
				  }
				  else
				  {
					  dataFile = rdDataFilePossiblyRequired.getText();
				  }
			  }
			  projectItem.setDataFile(dataFile);
			  lblMsg.setText("Project data file requirement updated.");	
		  }
	  };

	private void setTableRowWidgetValue(int row, int column, Widget widget)
	{
		table.setWidget(row, column, widget);
		table.getCellFormatter().setHorizontalAlignment(row, column, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(row, column, HasVerticalAlignment.ALIGN_TOP);
	}
	private void setTableRowText(int row, int column, String text)
	{
		table.setText(row, column, text);
		table.getCellFormatter().setHorizontalAlignment(row, column, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(row, column, HasVerticalAlignment.ALIGN_TOP);
	}
	private void setTableRowWidget(int row, int column, Widget widget)
	{
		table.setWidget(row, column, widget);
		table.getCellFormatter().setHorizontalAlignment(row, column, HasHorizontalAlignment.ALIGN_RIGHT);
		table.getCellFormatter().setVerticalAlignment(row, column, HasVerticalAlignment.ALIGN_TOP);		
	}
}