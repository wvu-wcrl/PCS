/*
 * File: JobDetails.java

Purpose: To display the job attributes and provide links to input and output files.
**********************************************************/

package com.wcrl.web.cml.client.jobs;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.client.ui.*;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.dom.client.KeyPressEvent;
import com.google.gwt.event.dom.client.KeyPressHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.account.AdminPage;
import com.wcrl.web.cml.client.jobService.ArchiveJobService;
import com.wcrl.web.cml.client.jobService.ArchiveJobServiceAsync;
import com.wcrl.web.cml.client.jobService.DeleteJobsService;
import com.wcrl.web.cml.client.jobService.DeleteJobsServiceAsync;
import com.wcrl.web.cml.client.jobService.GetJobDetailsService;
import com.wcrl.web.cml.client.jobService.GetJobDetailsServiceAsync;
import com.wcrl.web.cml.client.jobService.ResumeJobService;
import com.wcrl.web.cml.client.jobService.ResumeJobServiceAsync;
import com.wcrl.web.cml.client.jobService.ServerMessageGeneratorService;
import com.wcrl.web.cml.client.jobService.ServerMessageGeneratorServiceAsync;
import com.wcrl.web.cml.client.jobService.SuspendJobService;
import com.wcrl.web.cml.client.jobService.SuspendJobServiceAsync;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.user.account.UserPage;

import de.novanic.eventservice.client.event.Event;
import de.novanic.eventservice.client.event.RemoteEventService;
import de.novanic.eventservice.client.event.RemoteEventServiceFactory;
import de.novanic.eventservice.client.event.listener.RemoteEventListener;

public class JobDetails extends Composite implements ClickHandler 
{
	private VerticalPanel panel;
	private VerticalPanel headerPanel;	
	private VerticalPanel detailsPanel;
	private VerticalPanel topPanel;
	private HorizontalPanel buttonPanel, jobDetailsPanel;
	private FlexTable table;	
	private Button btnDelete, btnSave, btnCancel;
	private Button btnSuspend;
	private Button btnResume;
	private Button btnArchive;
	private Anchor hlBack;
	private TextArea txtNotes;
	private HTML txtWarnings;
	private JobItem jobItem;
		
	//private int start;
	private String prevJobNotes;
	private ClientContext ctx;
	private User currentUser;
	
	private int tabNumber;
	private int output;
	private int col;
	private String selectUser;
	private String selectProject;
	private ServerMessageGeneratorServiceAsync theServerMessageGeneratorServiceAsync;
	private String jobStatusDirectory;
	private String statusDirectory;

	public JobDetails(JobItem item, String statusDirectory, int start, int tabNumber, String selectUser, String selectProject) 
	{
		this.statusDirectory = statusDirectory;
		this.jobStatusDirectory = statusDirectory;
		this.selectUser = selectUser;
		this.selectProject = selectProject;
		
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			//this.start = start;
			//This is required to know if the request to view the Job details came from the User view or Administrator view
			this.tabNumber = tabNumber;
			//Get and set the current user context
			ctx = (ClientContext) RPCClientContext.get();

			if (ctx != null) 
			{			
				currentUser = ctx.getCurrentUser();	
								
				jobDetailsPanel = new HorizontalPanel();
				panel = new VerticalPanel();
				jobDetailsPanel.add(panel);				
				initWidget(jobDetailsPanel);
				
				GetJobDetailsServiceAsync service = GetJobDetailsService.Util.getInstance();
				//service.getJobDetails(item.getJobName(), item.getUsername(), item.getProjectName(), callback);
				service.getJobDetails(item, 1, callback);
			} 
			else
			{
				Log.info("Ctx null JobDetails JobDetails");
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
	
	/*private String getJobStatusDirectory(String status)
	{
		String jobStatusDirectory = null;
		ArrayList<String> directories = new ArrayList<String>();
		directories.add("Queued");
		directories.add("Running");				
		directories.add("Done");
		directories.add("Archive");
		directories.add("Suspended");
		directories.add("Failed");
		
		return jobStatusDirectory;
	}*/
	
	AsyncCallback<JobItem> callback = new AsyncCallback<JobItem>() 
	{
		public void onFailure(Throwable caught) 
		{
			Window.alert(caught.getMessage());
		}
		
		public void onSuccess(JobItem item) 
		{
			System.out.println("In job details: " + item + " " + item.getJobName() + " statusDirectory: " + statusDirectory);
			 
			jobItem = item;
			
			if(statusDirectory.equalsIgnoreCase("Queued") || statusDirectory.equalsIgnoreCase("Running") || statusDirectory.equalsIgnoreCase("Suspended"))
			{
				//starting the generation of Hello messages from the server
		        //ServerMessageGeneratorServiceAsync theServerMessageGeneratorServiceAsync = GWT.create(ServerMessageGeneratorService.class);
				theServerMessageGeneratorServiceAsync = GWT.create(ServerMessageGeneratorService.class);
		        theServerMessageGeneratorServiceAsync.start(item, VoidAsyncCallback);
				
				/* Logic for GWTEventService starts here */
		        //get the RemoteEventService for registration of RemoteEventListener instances
		        RemoteEventService theRemoteEventService = RemoteEventServiceFactory.getInstance().getRemoteEventService();
		        //add a listener to the SERVER_MESSAGE_DOMAIN
		        theRemoteEventService.addListener(ServerGeneratedMessageEvent.SERVER_MESSAGE_DOMAIN, new RemoteEventListener() {
		            public void apply(Event anEvent) {
		                if(anEvent instanceof ServerGeneratedMessageEvent) {
		                    ServerGeneratedMessageEvent theServerGeneratedMessageEvent = (ServerGeneratedMessageEvent)anEvent;
		                    setJobValues(theServerGeneratedMessageEvent.getMyServerGeneratedEvent());
		                }
		            }
		        });
			}
			
			
			//theServerMessageGeneratorServiceAsync = GWT.create(ServerMessageGeneratorService.class);
			/*//starting the generation of Hello messages from the server
	        theServerMessageGeneratorServiceAsync = GWT.create(ServerMessageGeneratorService.class);
	        theServerMessageGeneratorServiceAsync.start(item.getJobName(), item.getUsername(), item.getProjectName(), VoidAsyncCallback);
			
			 Logic for GWTEventService starts here 
	        //get the RemoteEventService for registration of RemoteEventListener instances
	        RemoteEventService theRemoteEventService = RemoteEventServiceFactory.getInstance().getRemoteEventService();
	        //add a listener to the SERVER_MESSAGE_DOMAIN
	        theRemoteEventService.addListener(ServerGeneratedMessageEvent.SERVER_MESSAGE_DOMAIN, new RemoteEventListener() {
	            public void apply(Event anEvent) {
	                if(anEvent instanceof ServerGeneratedMessageEvent) 
	                {
	                    ServerGeneratedMessageEvent theServerGeneratedMessageEvent = (ServerGeneratedMessageEvent)anEvent;
	                    jobItem = theServerGeneratedMessageEvent.getMyServerGeneratedEvent();
	                    setJobValues(theServerGeneratedMessageEvent.getMyServerGeneratedEvent());
	                    //txtNotes.setText(theServerGeneratedMessageEvent.getMyServerGeneratedEvent().getJobNotes());
	                }
	            }
	        });*/	
	        init();
			setJobValues(item);
		}
	};
	
	AsyncCallback<Void> VoidAsyncCallback = new AsyncCallback<Void>()
	{
		public void onFailure(Throwable aThrowable) {}

	    public void onSuccess(Void aResult) {}
	};
		

	//Initialize and set the components
	@SuppressWarnings("deprecation")
	private void init() 
	{
		System.out.println("In job details init");
		if(currentUser != null)
		{			
			/*panel = new VerticalPanel();*/
			headerPanel = new VerticalPanel();
			detailsPanel = new VerticalPanel();
			topPanel = new VerticalPanel();
			buttonPanel = new HorizontalPanel();
			jobDetailsPanel = new HorizontalPanel();
			table = new FlexTable();	
			btnDelete = new Button("Delete");
			btnSuspend = new Button("Suspend");
			btnArchive = new Button("Archive");
			btnResume = new Button("Resume");

			hlBack = new Anchor("<<back");
			
			hlBack.addClickHandler(this);
			
			btnSave = new Button("Save");
			btnCancel = new Button("Cancel");
						
			txtNotes = new TextArea();
			txtWarnings = new HTML();

			table.setCellSpacing(5);
			
			table.setCellPadding(0);
			table.setWidth("100%");
			jobDetailsPanel.setSize("100%", "75%");
			txtNotes.setVisibleLines(5);
			txtNotes.setCharacterWidth(50);
			txtNotes.setEnabled(true);

			txtWarnings.setVisible(false);

			btnSave.addClickHandler(this);
			btnCancel.addClickHandler(this);
			btnSuspend.addClickHandler(this);
			btnArchive.addClickHandler(this);
			btnResume.addClickHandler(this);
		
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(false);	
			btnArchive.setEnabled(false);

			btnSave.setEnabled(false);
			btnCancel.setEnabled(false);

			/*prevJobNotes = jobItem.getJobNotes();*/

			txtNotes.addKeyPressHandler(new KeyPressHandler() 
			{
				public void onKeyPress(KeyPressEvent arg0) 
				{
					btnSave.setEnabled(true);
					btnCancel.setEnabled(true);
					txtWarnings.setVisible(false);
				}
			});
						
			setTableRowWidget(0, 0, new HTML("<b>Job Name:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(1, 0, new HTML("<b>JobId:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(2, 0, new HTML("<b>Project:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(3, 0, new HTML("<b>Start time:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(4, 0, new HTML("<b>Last modified:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(5, 0, new HTML("<b>Stop time:</b>&nbsp;&nbsp;&nbsp;"));
			setTableRowWidget(6, 0, new HTML("<b>Process duration:</b>&nbsp;&nbsp;&nbsp;"));
			HTML notesLabel = new HTML("<b>Notes:</b>&nbsp;&nbsp;&nbsp;");
			notesLabel.setVisible(false);
			setTableRowWidget(7, 0, notesLabel);			
			setTableRowWidget(8, 0, new HTML("<b>Status:</b>&nbsp;&nbsp;&nbsp;"));
		
			VerticalPanel notesPanel = new VerticalPanel();
			HorizontalPanel notesButtonPanel = new HorizontalPanel();
			notesButtonPanel.add(btnSave);
			notesButtonPanel.add(btnCancel);
			notesPanel.add(txtNotes);
			notesPanel.add(notesButtonPanel);
			notesPanel.setVisible(false);
			table.setWidget(7, 1, notesPanel);
			table.getCellFormatter().setHorizontalAlignment(7, 1, HasHorizontalAlignment.ALIGN_LEFT);
			table.getCellFormatter().setVerticalAlignment(7, 1, HasVerticalAlignment.ALIGN_TOP);
					
			buttonPanel.add(btnDelete);
			buttonPanel.add(btnSuspend);
			buttonPanel.add(btnResume);
			buttonPanel.add(btnArchive);
			
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
			panel.add(table);
			/*System.out.println("In job details init check: " + table.getText(0, 0));*/
			innerPanel.setSize("100%", "100%");
			detailsPanel.setSize("100%", "100%");
			/*jobDetailsPanel.add(panel);*/
			jobDetailsPanel.setCellHorizontalAlignment(panel, HasHorizontalAlignment.ALIGN_CENTER);			
			/*initWidget(jobDetailsPanel);*/

			setStyleName("mail-Detail");
			innerPanel.setStyleName("mail-DetailInner");		
		}		
	}
	
	private void setJobValues(JobItem jobItem)
	{
		System.out.println("In setting job values: " + jobItem + " status: " + jobItem.getStatus());
		prevJobNotes = jobItem.getJobNotes();
		int cnt = 9;
		col = cnt;
		LinkedHashMap<String, String> itemData = jobItem.getColumns();
		
		if(itemData != null)
		{
			Set<Entry<String, String>> entrySet = itemData.entrySet();
			for(Entry<String, String> entry : entrySet)
			{
				String key = entry.getKey();
				setTableRowWidget(cnt, 0, new HTML("<b>" + key + ":</b>&nbsp;&nbsp;&nbsp;"));
				cnt++;
			}
		}
		
		/*input = cnt;*/
		output = cnt;
		setTableRowWidget(cnt, 0, new HTML("<b>File(s):</b>&nbsp;&nbsp;&nbsp;"));
		
		setTableRowText(0, 1, jobItem.getJobName());
		setTableRowText(1, 1, Integer.valueOf(jobItem.getJobId()).toString());
		System.out.println("In job details init check: " + table.getText(0, 0) + " " + table.getText(0, 1));			
		
		setTableRowText(2, 1, jobItem.getProjectName());
		Date lastModifiedDate = new Date(jobItem.getLastModified());
		setTableRowText(3, 1, jobItem.getStartTime());
		setTableRowText(4, 1, lastModifiedDate.toString());
		setTableRowText(5, 1, jobItem.getStopTime());
		String duration = "";
		if(jobItem.getProcessDuration() != null)
		{
			try
			{
				double pd = Double.parseDouble(jobItem.getProcessDuration());
				if(pd > 0)
				{
					duration = jobItem.getProcessDuration() + " seconds";
				}
			}
			catch(NumberFormatException e)
			{
				System.out.println("Process duration value not a number.");
				Log.info("Process duration value not a number.");
			}
			//duration = jobItem.getProcessDuration() + " seconds";
		}
		setTableRowText(6, 1, duration);
		
		txtNotes.setText(jobItem.getJobNotes());
		
		String statusStr = jobItem.getStatus();
						
		/*if((!statusStr.equalsIgnoreCase("Done")) || (!statusStr.equalsIgnoreCase("Failed")) || (!statusStr.equalsIgnoreCase("Suspended")) || (!statusStr.equalsIgnoreCase("Archive"))) 
		{
			btnSuspend.setEnabled(true);
		}
		else if(statusStr.equalsIgnoreCase("Suspended"))
		{
			btnResume.setEnabled(true);
		}*/
		
		//setButtonStatus(statusDirectory);
		setButtonStatus(jobStatusDirectory);
		/*if(statusStr.equalsIgnoreCase("Done"))
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(true);
		}
		else
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}
		
		if(statusStr.equalsIgnoreCase("Failed") || statusStr.equalsIgnoreCase("Archive"))
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}
		
		if(statusStr.equalsIgnoreCase("Queued") || statusStr.equalsIgnoreCase("Running"))
		{
			btnSuspend.setEnabled(true);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}
		if(statusStr.equalsIgnoreCase("Suspended"))
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(true);	
			btnArchive.setEnabled(false);
		}
		else
		{
			btnSuspend.setEnabled(true);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}*/
		
		setTableRowText(8, 1, statusStr);
		if(itemData != null)
		{
			int temp = col;
			Set<Entry<String, String>> entrySet = itemData.entrySet();
			for(Entry<String, String> entry : entrySet)
			{
				//String value = entry.getValue();
				String key = entry.getKey();
				HTML value = new HTML();
				value.setText(entry.getValue());
				//System.out.println("Getting data: " + key + " " + value);
				if(key.equalsIgnoreCase("Usage"))
				{
					value.setText(entry.getValue() + " seconds");
					setTableRowText(temp, 1, value);
				}
				else
				{
					setTableRowText(temp, 1, value);
				}
				
				temp++;
			}
		}
		
		if(jobItem.getOutputFiles().size() > 0)
		{
			/*if(jobItem.getLastModified() > 0)
			{
				displayOutputFiles();
			}*/
			//System.out.println("!!!!!!!!!!!!!!!!!!!!");
			displayOutputFiles(jobItem);
		}
	}	
	
	private void displayOutputFiles(JobItem jobItem) 
	{
		table.setWidget(output, 1, displayFiles(jobItem.getJobName(), jobItem.getOutputFiles()));			
		table.getCellFormatter().setHorizontalAlignment(output, 1, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(output, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	}
	
	private Widget displayFiles(final String fileName, final Map<Integer, String[]> files) 
	{
		final FlexTable filesTable = new FlexTable();
		filesTable.setCellSpacing(0);
		filesTable.setCellPadding(0);
				
		//System.out.println("Display files");
		List<Map.Entry<Integer, String[]>> list = new LinkedList<Map.Entry<Integer, String[]>>(files.entrySet());
    	
    	//Sort files by Filename
    	Collections.sort(list, new Comparator<Map.Entry<Integer, String[]>>() 
	    {
    		public int compare(Map.Entry<Integer, String[]> o1, Map.Entry<Integer, String[]> o2)
    		{
    			String[] a = (String[]) ((Map.Entry<Integer, String[]>) (o1)).getValue();
    			String[] b = (String[]) ((Map.Entry<Integer, String[]>) (o2)).getValue();
    			return a[0].compareTo(b[0]);
    		}
    	});
    	
    	/*
    	 * Add files to a table for display
    	 */
    	int i = 0;
    	for (Iterator<Entry<Integer, String[]>> it = list.iterator(); it.hasNext();)
		{
			Map.Entry<Integer, String[]> entry = (Map.Entry<Integer, String[]>)it.next();
			String[] fileData = entry.getValue();
			HTML file = new HTML("<a href = '" + fileData[1] + "' target='_blank'>" + fileData[0] + "</a>");
			filesTable.setWidget(i, 0, file);
			System.out.println("Path: " + fileData[1]);
			filesTable.getCellFormatter().setHorizontalAlignment(i, 0, HasHorizontalAlignment.ALIGN_LEFT);
			filesTable.getCellFormatter().setVerticalAlignment(i, 0, HasVerticalAlignment.ALIGN_TOP);
			i++;	    			
		}			
		return filesTable;
	}	

	public void onClick(ClickEvent event) 
	{
		Widget widget = (Widget) event.getSource();	
		//save the job notes
		if (widget == btnSave) 
		{
			/*prevJobNotes = txtNotes.getText().trim();
			btnSave.setEnabled(false);
			btnCancel.setEnabled(false);
			jobItem.setJobNotes(txtNotes.getText().trim());
			if(tabNumber == 0)
			{
				jobItems = currentUser.getUserJobItems();
				jobItems.updateJobItem(jobItem);
				currentUser.setUserJobItems(jobItems);
			}
			else if(tabNumber == 3)
			{
				jobItems = currentUser.getUsersJobItems();
				jobItems.updateJobItem(jobItem);
				currentUser.setUsersJobItems(jobItems);
			}
			else
			{
				jobItems = currentUser.getUserJobItems();
				jobItems.updateJobItem(jobItem);
				currentUser.setUserJobItems(jobItems);
			}
			ctx.setCurrentUser(currentUser);*/
			/*SaveJobNotesServiceAsync service = SaveJobNotesService.Util.getInstance();
			service.saveNotes(jobItem.getUserId(), jobID, txtNotes.getText().trim(), jobNotescallback);*/
		}
		if (widget == btnCancel) 
		{
			txtNotes.setText(prevJobNotes);
			btnSave.setEnabled(false);
			btnCancel.setEnabled(false);
		}
		//Delete the Job
		if (widget == btnDelete) 
		{
			if(theServerMessageGeneratorServiceAsync != null)
			{
				theServerMessageGeneratorServiceAsync.stop(stopAsyncCallback);
			}
			else
			{
				if(Window.confirm("Are you sure to delete the Job?"))
				{
					ArrayList<JobItem> jobs = new ArrayList<JobItem>();
					jobs.add(jobItem);
					DeleteJobsServiceAsync service = DeleteJobsService.Util.getInstance();
					service.deleteJobs(jobs, 0, 0, false, "", 1, 1, deleteJobCallback);
				}
			}			
		}
		if(widget == btnSuspend)
		{			
			/*ArrayList<JobItem> jobs = new ArrayList<JobItem>();
			jobs.add(jobItem);
			SuspendJobsServiceAsync service = SuspendJobsService.Util.getInstance();			
			service.suspendJobs(jobs, 0, 0, false, "", 1, suspendJobCallback);*/
			SuspendJobServiceAsync service = SuspendJobService.Util.getInstance();			
			service.suspendJob(jobItem, suspendJobCallback);
		}
		if(widget == btnResume)
		{
			ResumeJobServiceAsync service = ResumeJobService.Util.getInstance();			//	
			service.resumeJob(jobItem, resumeJobCallback);
		}
		if(widget == btnArchive)
		{			
			/*ArrayList<JobItem> jobs = new ArrayList<JobItem>();
			jobs.add(jobItem);
			SuspendJobsServiceAsync service = SuspendJobsService.Util.getInstance();			
			service.suspendJobs(jobs, 0, 0, false, "", 1, suspendJobCallback);*/
			ArchiveJobServiceAsync service = ArchiveJobService.Util.getInstance();			
			service.archiveJob(jobItem, archiveJobCallback);
		}
	
		//Take the control back to list of Jobs (depends upon the user)
		if (widget == hlBack) 
		{
			if(theServerMessageGeneratorServiceAsync != null)
			{
				theServerMessageGeneratorServiceAsync.stop(anAsyncCallback);
			}
			else
			{
				RootPanel.get("content").clear();
				System.out.println("tabNumber: " + tabNumber + " user: " + selectUser + " project: " + selectProject);
				Log.info("tabNumber: " + tabNumber + " user: " + selectUser + " project: " + selectProject);
				if(tabNumber == 0)
				{
					tabNumber = 0;
					AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, statusDirectory);
					RootPanel.get("content").add(adminPage);
				}
				else if(tabNumber == 1)
				{
					tabNumber = 0;
					UserPage userPage = new UserPage(tabNumber, selectUser, selectProject, statusDirectory);
					RootPanel.get("content").add(userPage);
				}
				else if(tabNumber == 2)
				{
					AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, statusDirectory);
					RootPanel.get("content").add(adminPage);
				}
			}
		}
	}
	
	AsyncCallback<Void> stopAsyncCallback = new AsyncCallback<Void>()
	{
		public void onFailure(Throwable aThrowable) {}

	    public void onSuccess(Void aResult) 
	    {
	    	if(Window.confirm("Are you sure to delete the Job?"))
			{
				ArrayList<JobItem> jobs = new ArrayList<JobItem>();
				jobs.add(jobItem);
				DeleteJobsServiceAsync service = DeleteJobsService.Util.getInstance();
				service.deleteJobs(jobs, 0, 0, false, "", 1, 1, deleteJobCallback);
			}
	    }
	};
	
	AsyncCallback<Void> anAsyncCallback = new AsyncCallback<Void>()
	{
		public void onFailure(Throwable aThrowable) {}

	    public void onSuccess(Void aResult) 
	    {
	    	RootPanel.get("content").clear();
			System.out.println("tabNumber: " + tabNumber + " user: " + selectUser + " project: " + selectProject);
			Log.info("tabNumber: " + tabNumber + " user: " + selectUser + " project: " + selectProject);
			if(tabNumber == 0)
			{
				tabNumber = 0;
				AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, statusDirectory);
				RootPanel.get("content").add(adminPage);
			}
			else if(tabNumber == 1)
			{
				tabNumber = 0;
				UserPage userPage = new UserPage(tabNumber, selectUser, selectProject, statusDirectory);
				RootPanel.get("content").add(userPage);
			}
			else if(tabNumber == 2)
			{
				AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, statusDirectory);
				RootPanel.get("content").add(adminPage);
			}
	    }
	};
	
	//After deleting job from database take the control the list of jobs
	AsyncCallback<List<JobItem>> deleteJobCallback = new AsyncCallback<List<JobItem>>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("JobDetails deleteJobCallback error: " + caught.toString());			
		}
		public void onSuccess(List<JobItem> result) 
		{			
			System.out.println("Delete: " + result + " Tab: " + tabNumber);
			if(result == null)
			{				
				/*JobList jobList = new JobList();
				if(tabNumber == 2)
				{
					jobList.refresh(0, start, tabNumber, "", jobItem.getProjectName(), jobItem.getStatus());
				}
				else
				{
					jobList.refresh(0, start, tabNumber, jobItem.getUsername(), jobItem.getProjectName(), jobItem.getStatus());
				}				
				RootPanel.get("content").clear();
				RootPanel.get("content").add(jobList);*/
				
				RootPanel.get("content").clear();
				if(tabNumber == 0)
				{
					tabNumber = 0;
					AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, statusDirectory);
					RootPanel.get("content").add(adminPage);
				}
				else if(tabNumber == 1)
				{
					tabNumber = 0;
					UserPage userPage = new UserPage(tabNumber, selectUser, selectProject, statusDirectory);
					RootPanel.get("content").add(userPage);
				}
				else if(tabNumber == 2)
				{
					AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, statusDirectory);
					RootPanel.get("content").add(adminPage);
				}
				
				/*if(currentUser.getUsertype().equalsIgnoreCase("user"))
				{
					UserPage userPage = new UserPage(tabNumber, selectUser, selectProject, jobItem.getStatus());
					RootPanel.get("content").add(userPage);
				}
				else
				{
					AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, jobItem.getStatus());
					RootPanel.get("content").add(adminPage);
				}*/
			}			
		}
	};	
	
	AsyncCallback<JobItem> suspendJobCallback = new AsyncCallback<JobItem>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("JobDetails suspendJobCallback error: " + caught.toString());			
		}
		public void onSuccess(JobItem item) 
		{		
			System.out.println("After suspension: " + item);
			if(item != null)
			{
				btnResume.setEnabled(true);
				btnSuspend.setEnabled(false);	
				jobItem = item;		
				System.out.println("After suspension Status: " + jobItem.getStatus());
				jobStatusDirectory = jobItem.getStatus();
				setJobValues(jobItem);
			}			
		}
	};
	
	AsyncCallback<JobItem> resumeJobCallback = new AsyncCallback<JobItem>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("JobDetails resumeJobCallback error: " + caught.toString());			
		}
		public void onSuccess(JobItem item) 
		{			
			System.out.println("After resume: " + item);
			if(item != null)
			{
				btnResume.setEnabled(false);
				btnSuspend.setEnabled(true);	
				jobItem = item;		
				System.out.println("After resume Status: " + jobItem.getStatus());
				jobStatusDirectory = jobItem.getStatus();
				setJobValues(jobItem);
			}			
		}
	};
	
	AsyncCallback<JobItem> archiveJobCallback = new AsyncCallback<JobItem>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("JobDetails archiveJobCallback error: " + caught.toString());			
		}
		public void onSuccess(JobItem item) 
		{		
			System.out.println("After archiving: " + item);
			if(item != null)
			{
				btnArchive.setEnabled(false);	
				jobItem = item;		
				System.out.println("After archive Status: " + jobItem.getStatus());
				setJobValues(jobItem);
			}			
		}
	};

	AsyncCallback<Integer> jobNotescallback = new AsyncCallback<Integer>() 
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("JobDetails jobNotescallback error" + caught.toString());
		}

		public void onSuccess(Integer flag) 
		{
			txtWarnings.setVisible(true);
			String msgText = "";
			if(flag == 1)
			{				
				msgText = "Job notes Saved.";
			}			
			else
			{
				msgText = "Error is saving Job notes.";
			}
			txtWarnings.setText(msgText);	
		}
	};

	private void setTableRowText(int row, int column, String text)
	{
		table.setText(row, column, text);
		table.getCellFormatter().setHorizontalAlignment(row, column, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(row, column, HasVerticalAlignment.ALIGN_TOP);
	}
	private void setTableRowText(int row, int column, HTML widget)
	{
		table.setWidget(row, column, widget);
		table.getCellFormatter().setHorizontalAlignment(row, column, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(row, column, HasVerticalAlignment.ALIGN_TOP);
	}
	private void setTableRowWidget(int row, int column, Widget widget)
	{
		table.setWidget(row, column, widget);
		table.getCellFormatter().setHorizontalAlignment(row, column, HasHorizontalAlignment.ALIGN_RIGHT);
		table.getCellFormatter().setVerticalAlignment(row, column, HasVerticalAlignment.ALIGN_TOP);		
	}
	
	private void setButtonStatus(String selectedStatus)
	{
		System.out.println("selectedStatus: " + selectedStatus);
		if(selectedStatus.equalsIgnoreCase("Suspended"))
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(true);		
			btnArchive.setEnabled(false);
		}
		/*else
		{
			btnSuspend.setEnabled(true);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}*/
		
		if(selectedStatus.equalsIgnoreCase("Done"))
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(true);
		}
		/*else
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}*/
		
		if(selectedStatus.equalsIgnoreCase("Failed") || selectedStatus.equalsIgnoreCase("Archive"))
		{
			btnSuspend.setEnabled(false);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}
		
		if(selectedStatus.equalsIgnoreCase("Queued") || selectedStatus.equalsIgnoreCase("Running"))
		{
			btnSuspend.setEnabled(true);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}
		
		/*if(!selectedStatus.equalsIgnoreCase("Queued") || !selectedStatus.equalsIgnoreCase("Running") || !selectedStatus.equalsIgnoreCase("Failed") || !selectedStatus.equalsIgnoreCase("Archive") || !selectedStatus.equalsIgnoreCase("Done") || !selectedStatus.equalsIgnoreCase("Suspended"))
		{
			btnSuspend.setEnabled(true);
			btnResume.setEnabled(false);
			btnArchive.setEnabled(false);
		}*/
		System.out.println("selectedStatus: " + selectedStatus + " suspend: " + btnSuspend.isEnabled() + " resume: " + btnResume.isEnabled() + " archive: " + btnArchive.isEnabled());
	}
}