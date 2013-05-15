/*
 * File: DataFilesDetails.java

Purpose: To display the DataFiles attributes and provide links to files.
**********************************************************/

package com.wcrl.web.cml.client.datafiles;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.client.ui.*;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.account.AdminPage;
import com.wcrl.web.cml.client.data.filesService.DeleteDataFilesService;
import com.wcrl.web.cml.client.data.filesService.DeleteDataFilesServiceAsync;
import com.wcrl.web.cml.client.data.filesService.GetDataFileDetailsService;
import com.wcrl.web.cml.client.data.filesService.GetDataFileDetailsServiceAsync;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.user.account.UserPage;

public class DataFileDetails extends Composite implements ClickHandler 
{
	private VerticalPanel panel;
	private VerticalPanel headerPanel;	
	private VerticalPanel detailsPanel;
	private VerticalPanel topPanel;
	private HorizontalPanel buttonPanel, fileDetailsPanel;
	private FlexTable table;	
	private Button btnDelete, btnSave, btnCancel;
	private Anchor hlBack;
	//private TextArea txtNotes;
	private HTML txtWarnings;
	private DataFileItem dataFileItem;
		
	private ClientContext ctx;
	private User currentUser;
	
	private int tabNumber;
	private int output;
	private String selectUser;
	private String selectProject;
	
	private String statusDirectory;

	public DataFileDetails(DataFileItem item, int start, int tabNumber, String selectUser, String selectProject) 
	{
		this.selectUser = selectUser;
		this.selectProject = selectProject;
		
		String sessionID = Cookies.getCookie("sid");
		if ( sessionID != null )
		{
			//this.start = start;
			//This is required to know if the request to view the File details came from the User view or Administrator view
			this.tabNumber = tabNumber;
			//Get and set the current user context
			ctx = (ClientContext) RPCClientContext.get();

			if (ctx != null) 
			{			
				currentUser = ctx.getCurrentUser();	
								
				fileDetailsPanel = new HorizontalPanel();
				panel = new VerticalPanel();
				fileDetailsPanel.add(panel);
				
				initWidget(fileDetailsPanel);
				GetDataFileDetailsServiceAsync service = GetDataFileDetailsService.Util.getInstance();
				service.getDataFileDetails(item, callback);
			} 
			else
			{
				Log.info("Ctx null FileDetails");
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
	
	AsyncCallback<DataFileItem> callback = new AsyncCallback<DataFileItem>() 
	{
		public void onFailure(Throwable caught) 
		{
			Window.alert(caught.getMessage());
		}
		
		public void onSuccess(DataFileItem item) 
		{
			System.out.println("In file details: " + item + " " + item.getFileName() + " statusDirectory: " + statusDirectory);			 
			dataFileItem = item;			
	        init();
			setFileValues(item);
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
		System.out.println("In file details init");
		if(currentUser != null)
		{			
			/*panel = new VerticalPanel();*/
			headerPanel = new VerticalPanel();
			detailsPanel = new VerticalPanel();
			topPanel = new VerticalPanel();
			buttonPanel = new HorizontalPanel();
			fileDetailsPanel = new HorizontalPanel();
			table = new FlexTable();	
			btnDelete = new Button("Delete");
			
			hlBack = new Anchor("<<back");
			
			hlBack.addClickHandler(this);
			
			btnSave = new Button("Save");
			btnCancel = new Button("Cancel");
						
			//txtNotes = new TextArea();
			txtWarnings = new HTML();

			table.setCellSpacing(5);
			
			table.setCellPadding(0);
			table.setWidth("100%");
			fileDetailsPanel.setSize("100%", "75%");
			/*txtNotes.setVisibleLines(5);
			txtNotes.setCharacterWidth(50);
			txtNotes.setEnabled(true);*/

			txtWarnings.setVisible(false);

			btnSave.addClickHandler(this);
			btnCancel.addClickHandler(this);
			btnSave.setEnabled(false);
			btnCancel.setEnabled(false);

			/*prevJobNotes = jobItem.getJobNotes();*/

			/*txtNotes.addKeyPressHandler(new KeyPressHandler() 
			{
				public void onKeyPress(KeyPressEvent arg0) 
				{
					btnSave.setEnabled(true);
					btnCancel.setEnabled(true);
					txtWarnings.setVisible(false);
				}
			});*/
						
			setTableRowWidget(0, 0, new HTML("<b>File Name:</b>&nbsp;&nbsp;&nbsp;"));			
			setTableRowWidget(1, 0, new HTML("<b>Project:</b>&nbsp;&nbsp;&nbsp;"));			
			setTableRowWidget(2, 0, new HTML("<b>Last modified:</b>&nbsp;&nbsp;&nbsp;"));
			
		
			/*VerticalPanel notesPanel = new VerticalPanel();
			HorizontalPanel notesButtonPanel = new HorizontalPanel();
			notesButtonPanel.add(btnSave);
			notesButtonPanel.add(btnCancel);
			notesPanel.add(txtNotes);
			notesPanel.add(notesButtonPanel);
			notesPanel.setVisible(false);
			table.setWidget(7, 1, notesPanel);
			table.getCellFormatter().setHorizontalAlignment(7, 1, HasHorizontalAlignment.ALIGN_LEFT);
			table.getCellFormatter().setVerticalAlignment(7, 1, HasVerticalAlignment.ALIGN_TOP);*/
					
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
			fileDetailsPanel.setCellHorizontalAlignment(panel, HasHorizontalAlignment.ALIGN_CENTER);			
			/*initWidget(jobDetailsPanel);*/

			setStyleName("mail-Detail");
			innerPanel.setStyleName("mail-DetailInner");		
		}		
	}
	
	private void setFileValues(DataFileItem fileItem)
	{
		System.out.println("In setting file values: " + fileItem);	
		setTableRowWidget(3, 0, new HTML("<b>File:</b>&nbsp;&nbsp;&nbsp;"));
		
		setTableRowText(0, 1, fileItem.getFileName());		
		setTableRowText(1, 1, fileItem.getProjectName());
		Date lastModifiedDate = new Date(fileItem.getLastModified());		
		setTableRowText(2, 1, lastModifiedDate.toString());
		displayDataFiles(fileItem);
	}	
	
	private void displayDataFiles(DataFileItem fileItem) 
	{		
		FlexTable filesTable = new FlexTable();
		filesTable.setCellSpacing(0);
		filesTable.setCellPadding(0);
		HTML file = new HTML("<a href = '" + fileItem.getPath() + "' target='_blank'>" + fileItem.getFileName() + "</a>");
		filesTable.setWidget(0, 0, file);
		System.out.println("Path: " + fileItem.getPath());
		filesTable.getCellFormatter().setHorizontalAlignment(0, 0, HasHorizontalAlignment.ALIGN_LEFT);
		filesTable.getCellFormatter().setVerticalAlignment(0, 0, HasVerticalAlignment.ALIGN_TOP);
		
		table.setWidget(3, 1, filesTable);
		table.getCellFormatter().setHorizontalAlignment(output, 1, HasHorizontalAlignment.ALIGN_LEFT);
		table.getCellFormatter().setVerticalAlignment(output, 1, HasVerticalAlignment.ALIGN_MIDDLE);
	}	

	public void onClick(ClickEvent event) 
	{
		Widget widget = (Widget) event.getSource();	
		//save the file notes
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
			//txtNotes.setText(prevJobNotes);
			btnSave.setEnabled(false);
			btnCancel.setEnabled(false);
		}
		//Delete the File
		if (widget == btnDelete) 
		{
			if(Window.confirm("Data file may be used by current running job(s). Are you sure to delete file?"))
			{
				ArrayList<DataFileItem> files = new ArrayList<DataFileItem>();
				files.add(dataFileItem);
				DeleteDataFilesServiceAsync service = DeleteDataFilesService.Util.getInstance();
				service.deleteDataFiles(files, 0, 0, false, 1, 1, deleteDataFilesCallback);
			}			
		}		
	
		//Take the control back to list of Files (depends upon the user)
		if (widget == hlBack) 
		{
			System.out.println("tabNumber: " + tabNumber + " user: " + selectUser + " project: " + selectProject);
			Log.info("tabNumber: " + tabNumber + " user: " + selectUser + " project: " + selectProject);
			RootPanel.get("content").clear();			
			if(tabNumber == 0)
			{
				tabNumber = 4;
				AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, statusDirectory, 0);
				RootPanel.get("content").add(adminPage);
			}
			else if(tabNumber == 1)
			{
				tabNumber = 1;
				UserPage userPage = new UserPage(tabNumber, selectUser, selectProject, statusDirectory);
				RootPanel.get("content").add(userPage);
			}
			else if(tabNumber == 2)
			{
				tabNumber = 5;
				AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, statusDirectory, 0);
				RootPanel.get("content").add(adminPage);
			}
		}
	}
	
		
	//After deleting file from database take the control the list of files
	AsyncCallback<List<DataFileItem>> deleteDataFilesCallback = new AsyncCallback<List<DataFileItem>>()
	{
		public void onFailure(Throwable caught) 
		{
			Log.info("FileDetails deleteDataFileCallback error: " + caught.toString());			
		}
		public void onSuccess(List<DataFileItem> result) 
		{			
			System.out.println("Delete: " + result + " Tab: " + tabNumber);
			if(result == null)
			{						
				RootPanel.get("content").clear();
				if(tabNumber == 0)
				{
					tabNumber = 4;
					AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, statusDirectory, 0);
					RootPanel.get("content").add(adminPage);
				}
				else if(tabNumber == 1)
				{
					tabNumber = 1;
					UserPage userPage = new UserPage(tabNumber, selectUser, selectProject, statusDirectory);
					RootPanel.get("content").add(userPage);
				}
				else if(tabNumber == 2)
				{
					tabNumber = 5;
					AdminPage adminPage = new AdminPage(tabNumber, selectUser, selectProject, statusDirectory, 0);
					RootPanel.get("content").add(adminPage);
				}
			}			
		}
	};	
	
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
	