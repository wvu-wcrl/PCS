/*
 * File: UploadDataFile.java

Purpose: User interface to handle File upload requests.
**********************************************************/

package com.wcrl.web.cml.client.datafiles;

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
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FileUpload;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.google.gwt.user.client.ui.FormPanel.SubmitCompleteEvent;
import com.google.gwt.user.client.ui.FormPanel.SubmitEvent;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.data.filesService.GetSubscribedDataProjectListService;
import com.wcrl.web.cml.client.data.filesService.GetSubscribedDataProjectListServiceAsync;
import com.wcrl.web.cml.client.jobService.GetPreferredProjectService;
import com.wcrl.web.cml.client.jobService.GetPreferredProjectServiceAsync;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.projects.ProjectItem;
import com.wcrl.web.cml.client.projects.ProjectItems;

public class UploadDataFile extends Composite implements ClickHandler, ChangeHandler 
{
	private static String UPLOAD_ACTION_URL = GWT.getModuleBaseURL() + "uploadDataFile";
	private VerticalPanel vPanel = new VerticalPanel();
    private FormPanel form = new FormPanel();
    private FlexTable table = new FlexTable();
    private FileUpload upload = new FileUpload();
    //private FileUpload fileUpload = new FileUpload();
    //private TextBox tbName = new TextBox();
    private TextBox tbDescription = new TextBox();
    //private TextArea txtFileNotes = new TextArea();
    private HTML txtWarnings = new HTML();
    private HTML txtWarningDesc = new HTML();
    private TextBox txtLogin;
    private TextBox txtProject;
    private TextBox txtOverwrite;
    private ListBox lbProjects;
    private Button btnSubmit = new Button("Upload");
    private ClientContext userCtx;
    private User currentUser;
    private Anchor hlBack;
    private int tab;
    private static int cnt = 1;    
        
    public UploadDataFile(int tab) 
    {    
    	String sessionID = Cookies.getCookie("sid");
    	if ( sessionID != null )
    	{
        	this.tab = tab;
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
    
    public void setProjects()
	{		
		if(currentUser != null)
    	{
			cnt++;
			/*GetSubscribedProjectListServiceAsync service = GetSubscribedProjectListService.Util.getInstance();
    	  	service.getSubscribedProjectList(currentUser.getUserId(), projectListCallback);*/	  
			int userId = 0;
			if(tab == 4)
			{
				userId = currentUser.getUserId();
			}
			GetSubscribedDataProjectListServiceAsync service = GetSubscribedDataProjectListService.Util.getInstance();
    	  	service.getSubscribedDataProjectList(userId, projectListCallback);
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
	      	currentUser.setProjectItems(projectItems);
	      	userCtx.setCurrentUser(currentUser);
	      	GetPreferredProjectServiceAsync service = GetPreferredProjectService.Util.getInstance();
	      	service.getPreferredProject(currentUser.getUserId(), preferredProjectCallback);	      	
	      }
	  };
	  
	  AsyncCallback<HashMap<Integer, String>> preferredProjectCallback = new AsyncCallback<HashMap<Integer, String>>()
	  {
		  public void onFailure(Throwable caught)
		  {
			  Log.info("UploadDataFile preferredProjectCallback error: " + caught.toString());
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
					  Log.info("Upload data file: " + entry.getKey() + " " + entry.getValue());
				  }
				  userCtx.setCurrentUser(currentUser);				  
			  }
			  createComponent();
		  }
	  };

	private void createComponent() 
	{	
		hlBack = new Anchor("<<back");
		hlBack.addClickHandler(this);		
    	vPanel.add(hlBack);
    	ProjectItems projectItems = currentUser.getProjectItems();
    	if(projectItems.getProjectItemCount() == 0)
		{
			vPanel.add(new HTML("You are not subscribed to data file required projects."));
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
			//tbName.setWidth("300px");
			//tbDescription.setWidth("300px");
			//txtFileNotes.setHeight("75px");
			upload.setName("uploadFormElement");
			//fileUpload.setName("fileuploadFormElement");
			//tbName.setName("name");
			tbDescription.setName("description");
			//txtFileNotes.setName("notes");
			lbProjects.setName("projectDetails");
			btnSubmit.addClickHandler(this);
			txtWarnings.setStylePrimaryName("warnings");
			txtWarningDesc.setStylePrimaryName("warnings");
			//txtFileNotes.setCharacterWidth(50);
			//tbName.setMaxLength(50);
			//tbDescription.setMaxLength(255);
			//tbDescription.setText("");
			txtLogin = new TextBox();
			txtLogin.setName("user");
			txtLogin.setVisible(false);
			
			txtOverwrite = new TextBox();
			txtOverwrite.setName("overwrite");
			txtOverwrite.setVisible(false);
			
			txtProject = new TextBox();
			txtProject.setName("projectName");
			txtProject.setVisible(false);
			
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
					}
				}
				else
				{
					lbProjects.setItemSelected(0, true);
				}			
			}	
							
			table.setText(0, 0, "");
			table.setWidget(0, 1, txtWarnings);
			table.setText(1, 0, "");
	        table.setWidget(1, 1, txtWarningDesc);
	        //table.setWidget(2, 0, new HTML("<b>Data filename:</b>&nbsp;&nbsp;&nbsp;"));
			//table.setWidget(2, 1, tbName);
			table.setWidget(3, 0, new HTML("File:&nbsp;&nbsp;&nbsp;"));
			table.setWidget(3, 1, upload);
			//table.setWidget(4, 0, new HTML("<b>Description:</b>&nbsp;&nbsp;&nbsp;"));
			//table.setWidget(4, 1, fileUpload);
			table.setWidget(5, 0, new HTML("Project:&nbsp;&nbsp;&nbsp;"));
			table.setWidget(5, 1, lbProjects);
			//table.setWidget(6, 0, new HTML("<b>Notes:</b>&nbsp;&nbsp;&nbsp;"));
			//table.setWidget(6, 1, txtFileNotes);
			table.setWidget(7, 1, btnSubmit);
			table.setWidget(7, 2, txtLogin);
			table.setWidget(7, 3, txtProject);
			table.setWidget(7, 4, txtOverwrite);
			
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
	        		// This event is fired just before the form is submitted. We can
	        		// take this opportunity to perform validation. 
	        		String fileName1 = upload.getFilename().trim();
	        		//String fileName2 = fileUpload.getFilename().trim();
	        		//System.out.println("File1: " + fileName1);
	        		//if(fileName1.length() == 0 && tbName.getText().length() == 0)
	        		if(fileName1.length() == 0)
	        		{
	        			txtWarnings.setHTML("*Please upload a file.");
	        			//txtWarningDesc.setHTML("*Please enter the Job name.");
	        			event.cancel();
	        		}
	        		if(fileName1.length() == 0)
	        		{
	        			txtWarnings.setText("");
	        			txtWarningDesc.setText("");
	        			txtWarnings.setHTML("*Please upload a file.");
	        			event.cancel();
	        		}        		
	        		/*if((!(fileName1.length() == 0)) && tbName.getText().length() == 0)
	        		{
	        			txtWarnings.setText("");
	        			txtWarningDesc.setText("");
	        			txtWarnings.setHTML("*Please enter the Job name.");
	        			event.cancel();
	        		}*/        		        				
	        	}
	        });
	       
	        form.addSubmitCompleteHandler(new FormPanel.SubmitCompleteHandler() 
	        {
	            public void onSubmitComplete(SubmitCompleteEvent event) 
	            {
	            	//txtFileNotes.setText("");        
	            	txtWarningDesc.setText("");
	            	String sessionID = Cookies.getCookie("sid");
	            	if ( sessionID != null )
	            	{
	            		String result = event.getResults();  
		            	System.out.println("Upload data file Result: " + result);
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
		        				History.newItem("userFileList");
		        			}
		        			else
		        			{
		        				if(tab == 5)
		        				{

		        					History.newItem("adminFileList");
		        				}
		        				else
		        				{
		        					History.newItem("fileList");
		        				}				
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
				History.newItem("userFileList");
			}
			else
			{
				if(tab == 4)
				{

					History.newItem("fileList");
				}
				else
				{
					History.newItem("adminFileList");
				}				
			}
		}
	}	
	
	public void onChange(ChangeEvent event) 
	{
		Widget source = (Widget)event.getSource();
		if(source == lbProjects)
		{
			txtProject.setValue(lbProjects.getItemText(lbProjects.getSelectedIndex()));
		}				
	}
}