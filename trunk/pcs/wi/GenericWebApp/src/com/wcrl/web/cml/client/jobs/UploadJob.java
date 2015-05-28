/*
 * File: UploadJob.java

Purpose: User interface to handle File upload requests.
**********************************************************/

package com.wcrl.web.cml.client.jobs;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Set;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ChangeEvent;
import com.google.gwt.event.dom.client.ChangeHandler;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.CheckBox;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FileUpload;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.google.gwt.user.client.ui.FormPanel.SubmitCompleteEvent;
import com.google.gwt.user.client.ui.FormPanel.SubmitEvent;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.jobService.GetPreferredProjectService;
import com.wcrl.web.cml.client.jobService.GetPreferredProjectServiceAsync;
import com.wcrl.web.cml.client.jobService.GetSubscribedProjectListService;
import com.wcrl.web.cml.client.jobService.GetSubscribedProjectListServiceAsync;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.projects.ProjectItem;
import com.wcrl.web.cml.client.projects.ProjectItems;

public class UploadJob extends Composite implements ClickHandler, ChangeHandler 
{
	private static String UPLOAD_ACTION_URL = GWT.getModuleBaseURL() + "uploadJobnDataFile";
	private VerticalPanel vPanel;	
	private VerticalPanel dataPanel;
    private FormPanel form;
    private FlexTable table;
    private FileUpload upload;
    private TextBox tbDescription;
    private TextArea txtFileNotes;
    private CheckBox ckDataFile;
	private FileUpload dataUpload;
	private HorizontalPanel dataFileUploadPanel;
    private HTML dtFile;
    private HTML txtWarnings;
    private HTML txtWarningDesc;
    private TextBox txtLogin;
    private TextBox txtProject;
    private TextBox txtOverwrite;
    private TextBox txtDataFileName;
    
    private ListBox lbProjects;
    private Button btnSubmit;
    private ClientContext userCtx;
    private User currentUser;
    private Anchor hlBack;
    private int tab;
    private static int cnt = 1;    
        
    public UploadJob(int tab) 
    {    
    	String sessionID = Cookies.getCookie("sid");
    	if ( sessionID != null )
    	{
        	this.tab = tab;
        	vPanel = new VerticalPanel();
        	initWidget(vPanel);
        	userCtx = (ClientContext) RPCClientContext.get();
        	if(userCtx != null)
        	{
        		currentUser = userCtx.getCurrentUser();
        		if(currentUser != null)
        		{
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
    
    private VerticalPanel getDataPanel()
    {    	
    	dataPanel.setSpacing(5);   	
    	dataFileUploadPanel.add(dataUpload);
    	
    	dataPanel.add(dataFileUploadPanel);
    	if(!ckDataFile.getValue())
    	{
    		dataPanel.setVisible(false);
    	}
    	System.out.println("Data panel checkbox: " + ckDataFile.getValue() + " datapanel visibility: " + dataPanel.isVisible());
		return dataPanel;    	
    }
    
    public void setProjects()
	{		
		if(currentUser != null)
    	{
			cnt++;
			int userId = 0;
			if(tab == 0)
			{
				userId = currentUser.getUserId();
			}
			GetSubscribedProjectListServiceAsync service = GetSubscribedProjectListService.Util.getInstance();
    	  	service.getSubscribedProjectList(userId, projectListCallback);	    		
    	}
	}
    
    /*private void setSelectionDataFileList()
    {
    	if(rdList.getValue())
		{
    		String user = currentUser.getUsername();
    		String project = lbProjects.getItemText(lbProjects.getSelectedIndex());
    		System.out.println("List - User: " + user + " Project: " + project);
			lbDataFiles.setEnabled(true);
			dataUpload.setEnabled(false);
			GetUserProjectDataFilesListServiceAsync service = GetUserProjectDataFilesListService.Util.getInstance();
    	  	service.userProjectDataFilesList(user, project, dataFilesCallback);
		}
		else
		{
			lbDataFiles.setEnabled(false);
			dataUpload.setEnabled(true);
		}
    }
    
    AsyncCallback<ArrayList<DataFileItem>> dataFilesCallback = new AsyncCallback<ArrayList<DataFileItem>>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("DataFilesCallback dataFilesCallback error: " + caught.toString());
		}
		
		public void onSuccess(ArrayList<DataFileItem> items)
		{
			lbDataFiles.clear();
			int count = 0;
			if(items != null)
			{
				count = items.size();
				if(count > 0)
				{
					for(int i = 0; i < count; i++)
					{
						DataFileItem item = items.get(i);
						String fileName = item.getFileName();
						lbDataFiles.addItem(fileName);
					}
					lbDataFiles.setSelectedIndex(0);
				}
				else
				{
					txtWarnings.setText("");
        			txtWarningDesc.setText("");
        			txtWarnings.setHTML("*Data files doesn't exist for the selected project. Please add a new data file.");
					lbDataFiles.setEnabled(false);
					
				}
			}
			System.out.println("After return file count: " + count);
		}
	};*/
    
    AsyncCallback<ArrayList<ProjectItem>> projectListCallback = new AsyncCallback<ArrayList<ProjectItem>>()
	{
		public void onFailure(Throwable caught)
		{
			Log.info("UploadJob projectList projectListCallback error: " + caught.toString());
		}
		
		public void onSuccess(ArrayList<ProjectItem> items)
		{	    	
	      	ProjectItems projectItems = new ProjectItems();	      	
	      	projectItems.setItems(items);	      	
	      	currentUser.setProjectItems(projectItems);
	      	userCtx.setCurrentUser(currentUser);
	      	System.out.println("Upload Job projectList: " + projectItems.getProjectItemCount());
	      	GetPreferredProjectServiceAsync service = GetPreferredProjectService.Util.getInstance();
	      	service.getPreferredProject(currentUser.getUserId(), preferredProjectCallback);	      	
	      }
	  };
	  
	  AsyncCallback<HashMap<Integer, String>> preferredProjectCallback = new AsyncCallback<HashMap<Integer, String>>()
	  {
		  public void onFailure(Throwable caught)
		  {
			  Log.info("UploadJob preferredProjectCallback error: " + caught.toString());
		  }
		  public void onSuccess(HashMap<Integer, String> project)
		  {
			  if(project != null)
			  {
				  Set<Entry<Integer, String>> entrySet = project.entrySet();
				  for(Entry<Integer, String> entry : entrySet)
				  {
					  currentUser.setPreferredProjectId(entry.getKey());
					  currentUser.setPreferredProject(entry.getValue());
					  Log.info("Upload Job: " + entry.getKey() + " " + entry.getValue());
				  }
				  userCtx.setCurrentUser(currentUser);				  
			  }
			  createComponent();
		  }
	  };

	private void createComponent() 
	{	
		dataPanel = new VerticalPanel();
		dataFileUploadPanel = new HorizontalPanel();
		form = new FormPanel();
	    table = new FlexTable();
	    upload = new FileUpload();
	    	        
	    tbDescription = new TextBox();
	    txtFileNotes = new TextArea();
	    ckDataFile = new CheckBox("Add data file");
	    txtWarnings = new HTML();
	    txtWarningDesc = new HTML();
	    btnSubmit = new Button("Upload & Run");
		hlBack = new Anchor("<<back");
		hlBack.addClickHandler(this);		
    	vPanel.add(hlBack);
    	dataUpload = new FileUpload();
    	
    	ProjectItems projectItems = currentUser.getProjectItems();
    	if(projectItems.getProjectItemCount() == 0)
		{
			vPanel.add(new HTML("You are not subscribed to any projects."));
		}
		else
		{
			vPanel.add(form);    
			lbProjects = new ListBox(false);
			lbProjects.addChangeHandler(this);
	    	vPanel.setSize("1000px", "500px");
			table.setCellSpacing(5);
			table.setCellPadding(0);
			table.setWidth("100%");
			txtFileNotes.setHeight("75px");
						
			ckDataFile.addClickHandler(this);			
			ckDataFile.setName("df");
			dataUpload.setName("dataUpload");			
			upload.setName("jobUpload");			
			tbDescription.setName("description");
			txtFileNotes.setName("notes");
			lbProjects.setName("projectDetails");
			btnSubmit.addClickHandler(this);
			txtWarnings.setStylePrimaryName("warnings");
			txtWarningDesc.setStylePrimaryName("warnings");
			txtFileNotes.setCharacterWidth(50);
			
			txtDataFileName = new TextBox();
			txtDataFileName.setName("dataFile");
		    txtDataFileName.setVisible(false);
			
			txtLogin = new TextBox();
			txtLogin.setName("user");
			txtLogin.setVisible(false);
			
			txtProject = new TextBox();
			txtProject.setName("projectName");
			txtProject.setVisible(false);
			
			txtOverwrite = new TextBox();
			txtOverwrite.setName("overwrite");
			txtOverwrite.setVisible(false);
			
			ckDataFile.setValue(false);
			ckDataFile.setEnabled(false);
			
			int projectId = currentUser.getPreferredProjectId();
					
			for(int i = 0; i < projectItems.getProjectItemCount(); i++)
			{
				ProjectItem item = projectItems.getProjectItem(i);
				lbProjects.addItem(item.getProjectName(), String.valueOf(item.getProjectId()));
				if(projectId > 0)
				{
					if(projectId == item.getProjectId())
					{
						lbProjects.setItemSelected(i, true);
						String dtFileRequired = item.getDataFile();
						if(dtFileRequired.equalsIgnoreCase("Possibly Required"))
						{
							ckDataFile.setValue(true);
							ckDataFile.setEnabled(true);			
						}
						if(dtFileRequired.equalsIgnoreCase("Required"))
						{
							ckDataFile.setValue(true);
							ckDataFile.setEnabled(true);			
						}
						if(dtFileRequired.equalsIgnoreCase("Not Required"))
						{
							ckDataFile.setValue(false);
							ckDataFile.setEnabled(false);
							ckDataFile.setVisible(false);
						}						
					}
					System.out.println("Project: " + item.getProjectName() + " ckDataFile: " + ckDataFile.getValue());
				}
				else
				{
					lbProjects.setItemSelected(0, true);
					String projectName = lbProjects.getItemText(0);
					if(projectName.equalsIgnoreCase(item.getProjectName()))
					{
						String dtFileRequired = item.getDataFile();
						if(dtFileRequired.equalsIgnoreCase("Possibly Required"))
						{
							ckDataFile.setValue(true);
							ckDataFile.setEnabled(true);			
						}
						if(dtFileRequired.equalsIgnoreCase("Required"))
						{
							ckDataFile.setValue(true);
							ckDataFile.setEnabled(true);			
						}
						if(dtFileRequired.equalsIgnoreCase("Not Required"))
						{
							ckDataFile.setValue(false);
							ckDataFile.setEnabled(false);
							ckDataFile.setVisible(false);
						}
					}					
				}			
			}	
							
			table.setText(0, 0, "");
			table.setWidget(0, 1, txtWarnings);
			table.setText(1, 0, "");
	        table.setWidget(1, 1, txtWarningDesc);
	        //table.setWidget(2, 0, new HTML("<b>Job Name:</b>&nbsp;&nbsp;&nbsp;"));
			//table.setWidget(2, 1, tbName);
			table.setWidget(3, 0, new HTML("Job file:&nbsp;&nbsp;&nbsp;"));
			table.setWidget(3, 1, upload);
			//table.setWidget(4, 0, new HTML("<b>Description:</b>&nbsp;&nbsp;&nbsp;"));
			//table.setWidget(4, 1, fileUpload);
			table.setWidget(5, 0, new HTML("Project:&nbsp;&nbsp;&nbsp;"));
			table.setWidget(5, 1, lbProjects);
			//table.setWidget(6, 0, new HTML("<b>Notes:</b>&nbsp;&nbsp;&nbsp;"));
			table.setWidget(6, 1, ckDataFile);
			dtFile = new HTML("Data file:&nbsp;&nbsp;&nbsp;");
			if(dataPanel.isVisible())
			{
				dtFile.setVisible(true);
			}
			else
			{
				dtFile.setVisible(false);
			}
			table.setWidget(7, 0, dtFile);
			table.setWidget(7, 1, getDataPanel());
			table.setWidget(8, 1, btnSubmit);
			table.setWidget(8, 2, txtLogin);
			table.setWidget(8, 3, txtProject);
			table.setWidget(8, 4, txtOverwrite);
			table.setWidget(8, 5, txtDataFileName);
			
			table.getCellFormatter().setHorizontalAlignment(0, 0, HasHorizontalAlignment.ALIGN_RIGHT);
			table.getCellFormatter().setVerticalAlignment(0, 0, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(1, 0, HasHorizontalAlignment.ALIGN_RIGHT);
			table.getCellFormatter().setVerticalAlignment(1, 0, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(2, 0, HasHorizontalAlignment.ALIGN_RIGHT);
			table.getCellFormatter().setVerticalAlignment(2, 0, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(3, 0, HasHorizontalAlignment.ALIGN_RIGHT);
			table.getCellFormatter().setVerticalAlignment(3, 0, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(4, 0, HasHorizontalAlignment.ALIGN_RIGHT);
			table.getCellFormatter().setVerticalAlignment(4, 0, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(5, 0, HasHorizontalAlignment.ALIGN_RIGHT);
			table.getCellFormatter().setVerticalAlignment(5, 0, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(6, 0, HasHorizontalAlignment.ALIGN_RIGHT);
			table.getCellFormatter().setVerticalAlignment(6, 0, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(7, 0, HasHorizontalAlignment.ALIGN_RIGHT);
			table.getCellFormatter().setVerticalAlignment(7, 0, HasVerticalAlignment.ALIGN_TOP);
			
			table.getCellFormatter().setHorizontalAlignment(0, 1, HasHorizontalAlignment.ALIGN_LEFT);
			table.getCellFormatter().setVerticalAlignment(0, 1, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(1, 1, HasHorizontalAlignment.ALIGN_LEFT);
			table.getCellFormatter().setVerticalAlignment(1, 1, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(2, 1, HasHorizontalAlignment.ALIGN_LEFT);
			table.getCellFormatter().setVerticalAlignment(2, 1, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(3, 1, HasHorizontalAlignment.ALIGN_LEFT);
			table.getCellFormatter().setVerticalAlignment(3, 1, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(4, 1, HasHorizontalAlignment.ALIGN_LEFT);
			table.getCellFormatter().setVerticalAlignment(4, 1, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(5, 1, HasHorizontalAlignment.ALIGN_LEFT);
			table.getCellFormatter().setVerticalAlignment(5, 1, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(6, 1, HasHorizontalAlignment.ALIGN_LEFT);
			table.getCellFormatter().setVerticalAlignment(6, 1, HasVerticalAlignment.ALIGN_TOP);
			table.getCellFormatter().setHorizontalAlignment(7, 1, HasHorizontalAlignment.ALIGN_LEFT);
			table.getCellFormatter().setVerticalAlignment(7, 1, HasVerticalAlignment.ALIGN_TOP);
			
			form.add(table);

	        form.setAction(UPLOAD_ACTION_URL);
	        form.setEncoding(FormPanel.ENCODING_MULTIPART);
	        form.setMethod(FormPanel.METHOD_POST);
			        
	        form.addSubmitHandler(new FormPanel.SubmitHandler() 
	        {
	        	public void onSubmit(SubmitEvent event) 
	        	{
	        		txtWarnings.setText("");
        			txtWarningDesc.setText("");
	        		// This event is fired just before the form is submitted to perform validation. 
	        		String fileName1 = upload.getFilename().trim();
	        		String dataFileName = "";
	        		String fileName = "";
	        		
	        		fileName = dataUpload.getFilename().trim();
	        		if(ckDataFile.getValue())
	        		{
	        			if(fileName.length() == 0)
	        			{
	        				txtWarnings.setText("");
		        			txtWarningDesc.setText("");
		        			txtWarnings.setHTML("*Please upload a data file.");
		        			event.cancel();
	        			}
	        			else
	        			{
	        				if(fileName.contains("&") || fileName.contains("/") || fileName.contains(">") || fileName.contains("<") || fileName.contains("|") || fileName.contains(":"))
	    	        		{
	    	        			txtWarnings.setText("");
	    	        			txtWarningDesc.setText("");
	    	        			txtWarnings.setHTML("*'&, / , > , <, | , :' are not valid characters in the filename. Please upload a file with valid file name.");
	    	        			event.cancel();
	    	        		}
	        				else
	        				{
	        					dataFileName = fileName;
	        				}	        				
	        			}
	        		}
	        		else
        			{
        				dataFileName = fileName;
        			}
        			
	        		txtDataFileName.setText(dataFileName);
	        		
	        		if(fileName1.length() == 0)
	        		{
	        			txtWarnings.setText("");
	        			txtWarningDesc.setText("");
	        			txtWarnings.setHTML("*Please upload a job file.");
	        			event.cancel();
	        		}
	        		if(fileName1.contains("&") || fileName1.contains("/") || fileName1.contains(">") || fileName1.contains("<") || fileName1.contains("|") || fileName1.contains(":"))
	        		{
	        			txtWarnings.setText("");
	        			txtWarningDesc.setText("");
	        			txtWarnings.setHTML("*'&, / , > , <, | , :' are not valid characters in the filename. Please upload a file with valid file name.");
	        			event.cancel();
	        		}
	        		
	        		System.out.println("Job: " + fileName1 + " ckDataFile: " + ckDataFile.getValue() + " dataFileName: " + dataFileName + " New: " + fileName);
	        		 
	        		//event.cancel();
	        	}
	        });
	       
	        form.addSubmitCompleteHandler(new FormPanel.SubmitCompleteHandler() 
	        {
	            public void onSubmitComplete(SubmitCompleteEvent event) 
	            {
	            	txtFileNotes.setText("");        
	            	txtWarningDesc.setText("");
	            	String sessionID = Cookies.getCookie("sid");
	            	if ( sessionID != null )
	            	{
	            		String result = event.getResults();  
		            	System.out.println("UploadJob Result: " + result);
		            	//Log.info("Result: " + result);
		            	String[] results = result.split("~");
		            	/*for(int i = 0; i < results.length; i++)
		            	{
		            		 System.out.println(results[i]);
		            		 try
		            		 {
		            			 jobId = Integer.parseInt(results[0]);
		            		 }
		            		 catch(NumberFormatException e)
		            		 {
		            			 e.printStackTrace();
		            		 }            		 
		            	}*/
		            	int id = -1;
		            	try
		            	{
		            		id = Integer.parseInt(results[0]);
		            	}
		            	catch(NumberFormatException e)
		            	{
		            		e.printStackTrace();
		            	}
		            	//Code modified
		            	if(id == 2)
		            	{
		            		txtWarnings.setHTML(results[1]);
		            	}
		            	else if(id == 0)
		            	{
		            		if(Window.confirm(results[1]))
		            		{
		            			if(currentUser != null)
		            			{
		            				txtLogin.setValue(currentUser.getUsername());
		            				txtProject.setValue(lbProjects.getItemText(lbProjects.getSelectedIndex()));
		            				txtOverwrite.setValue("1");
		            			    form.submit();
		            			}
		            		}
		            		//txtWarnings.setHTML(results[1]);
		            	}
		            	//Code modified
		            	//txtWarnings.setHTML(results[1]);
		            	
		            	else
		            	{
		            		if(currentUser.getUsertype().equalsIgnoreCase("user"))
		        			{				
		        				History.newItem("userJobList");
		        			}
		        			else
		        			{
		        				if(tab == 0)
		        				{

		        					History.newItem("adminJobList");
		        				}
		        				else
		        				{
		        					History.newItem("jobList");
		        				}				
		        				//AdminPage adminPage = new AdminPage(tab);
		        				//RootPanel.get("content").add(adminPage);
		        			}	
		            	}		            	
	            	}
	            	else
	            	{
	            		Login login = new Login();
	            		login.displayLoginBox();
	            	}
	            }
	        });
		}    			
	}
	
	public void onClick(ClickEvent event) 
	{
		Widget source = (Widget) event.getSource();
		if(source == btnSubmit)
		{
			if(currentUser != null)
			{
				txtLogin.setValue(currentUser.getUsername());
				txtProject.setValue(lbProjects.getItemText(lbProjects.getSelectedIndex()));
				txtOverwrite.setValue("0");
			    form.submit();
			}						
		}	
		if(source == hlBack)
		{
			if(currentUser.getUsertype().equalsIgnoreCase("user"))
			{				
				History.newItem("userJobList");
			}
			else
			{
				if(tab == 0)
				{

					History.newItem("adminJobList");
				}
				else
				{
					History.newItem("jobList");
				}				
				//AdminPage adminPage = new AdminPage(tab);
				//RootPanel.get("content").add(adminPage);
			}
			/*UserHistory userHistory = new UserHistory();
			userHistory.history();*/
		}
		if(source == ckDataFile)
		{
			if(ckDataFile.getValue())
			{
				dtFile.setVisible(true);
				dataPanel.setVisible(true);
			}
			else
			{
				dtFile.setVisible(false);
				dataPanel.setVisible(false);
			}
		}
	}	
	
	public void onChange(ChangeEvent event) 
	{
		Widget source = (Widget)event.getSource();
		if(source == lbProjects)
		{
			String selectedProject = lbProjects.getItemText(lbProjects.getSelectedIndex());
			txtProject.setValue(selectedProject);
			currentUser = userCtx.getCurrentUser();
			ProjectItems projectItems = currentUser.getProjectItems();
			ArrayList<ProjectItem> projectList = projectItems.getItems();
			int count = projectList.size();
			
			for(int i = 0; i < count; i++)
			{
				ProjectItem project = projectList.get(i);
				String projectName = project.getProjectName();
				System.out.println("ProjectName: " + projectName + " " + " required? " + project.getDataFile());
				if(selectedProject.equalsIgnoreCase(projectName))
				{
					if(project.getDataFile().equalsIgnoreCase("Possibly Required"))
					{			
						ckDataFile.setVisible(true);
						ckDataFile.setValue(true);
						ckDataFile.setEnabled(true);
						dataPanel.setVisible(true);
						dtFile.setVisible(true);
					}
					else if(project.getDataFile().equalsIgnoreCase("Required"))
					{
						ckDataFile.setVisible(true);
						ckDataFile.setValue(true);
						ckDataFile.setEnabled(true);
						dataPanel.setVisible(true);
						dtFile.setVisible(true);
					}
					if(project.getDataFile().equalsIgnoreCase("Not Required"))
					{
						ckDataFile.setValue(false);
						ckDataFile.setEnabled(false);
						ckDataFile.setVisible(false);
						dataPanel.setVisible(false);
						dtFile.setVisible(false);
					}
					break;
				}
			}			
		}				
	}
}