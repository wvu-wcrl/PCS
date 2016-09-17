package com.googlecode.mgwt.examples.showcase.client.custom;

import java.io.File;
import java.io.FileReader;

import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.SwingConstants;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dev.jjs.ast.JLabel;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.event.dom.client.ChangeEvent;
import com.google.gwt.event.dom.client.ChangeHandler;
//import org.json.JSONObject;
import com.google.gwt.json.client.JSONObject;
import com.google.gwt.json.client.JSONParser;
import com.google.gwt.json.client.JSONValue;
import com.google.gwt.json.client.JSONString;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.ChangeListener;
import com.google.gwt.user.client.ui.FileUpload;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.PopupPanel;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.FormPanel.SubmitCompleteEvent;
import com.google.gwt.user.client.ui.FormPanel.SubmitEvent;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.googlecode.mgwt.dom.client.event.tap.TapEvent;
import com.googlecode.mgwt.dom.client.event.tap.TapHandler;
import com.googlecode.mgwt.examples.showcase.client.ChromeWorkaround;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.ClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.RPCClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.User;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryPlace;
import com.googlecode.mgwt.ui.client.MGWT;
import com.googlecode.mgwt.ui.client.MGWTStyle;
import com.googlecode.mgwt.ui.client.widget.Button;
import com.googlecode.mgwt.ui.client.widget.WidgetList;



public class IdentifyImgUploadViewGwtImpl extends DetailViewGwtImpl implements IdentifyImgUploadView{

  private static String GENERATEJOB_ACTION_URL = GWT.getModuleBaseURL() + "gupld";
  private ClientContext ctx;
  private User currentUser;
  private ClientFactory clientFactory;
  
  public IdentifyImgUploadViewGwtImpl(ClientFactory clientFactory) {
	  System.out.println("In IdentifyImgUploadViewGwtImpl");
	  this.clientFactory = clientFactory;
	  
	//  ctx = (ClientContext) RPCClientContext.get();	
	//  String sessionID = Cookies.getCookie("sid");
	//  Log.info("IdentifyImgUploadViewGwtImpl sessionID: " + sessionID + " ctx: " + RPCClientContext.get()); 
	//  if(sessionID != null)
	 // {
		//  if(ctx != null)
		 // {
			    //Set the current user context
			//    currentUser = ctx.getCurrentUser();
			    identifyImg();
		  //}
		  //else
		  //{
		//	  clientFactory.getPlaceController().goTo(new ElementsPlace());
		 // }
	  //}
	  //else
	  //{
	//	  clientFactory.getPlaceController().goTo(new ElementsPlace());
	 // }
  }
  
  private void identifyImg() {
	  headerPanel.setLeftWidget(headerBackButton);
	  FlowPanel container = new FlowPanel();
	  final Image image=new Image("fly_wv.svg");
	  final Image image1=new Image("fly_wv.svg");
	//  final Image image2=new Image();
	  
	 
		  
	   image.addStyleName("Imagewv");
	   image1.addStyleName("Imagemsu");
	  final Label lb1;
	  
	  container.getElement().getStyle().setMarginTop(20, Unit.PX);

      scrollPanel.setScrollingEnabledX(false);
      scrollPanel.setWidget(container);    
      // workaround for android formfields jumping around when using
      // -webkit-transform
      scrollPanel.setUsePos(MGWT.getOsDetection().isAndroid());

      ChromeWorkaround.maybeUpdateScroller(scrollPanel);
      lb1= new Label("Advanced Image Processing Mid Term Project");
	  lb1.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
	  lb1.setHorizontalAlignment(HasHorizontalAlignment.ALIGN_CENTER);
      HTML header = new HTML("Select for Inter-Class or Intra-Class and get the Histogram");
	  header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
	  container.add(image);
	  container.add(image1);
	  container.add(lb1);
	  container.add(new HTML("<br/><br/>"));
	//  container.add(new HTML("<br/><br/>"));
	  
	  container.add(header);
	  
	  final Label lblWarning = new Label();
      
	  WidgetList widgetList = new WidgetList();
	  WidgetList widgetList1 = new WidgetList();
      
      //WidgetList widgetList1 = new WidgetList();
      container.add(widgetList);
      container.add(widgetList1);
      
      widgetList.add(lblWarning);
      //lblWarning.setText("222222222222222222222222");
      
      final FileUpload imgUpload = new FileUpload();
      imgUpload.setName("fileselect[]");
      
      final FileUpload imgUpload1 = new FileUpload();
      imgUpload1.setName("fileselect1[]");
      
      final ListBox lb = new ListBox();
      lb.addItem("Intra-Class");
      lb.addItem("Inter-Class");
      lb.setName("SelectionList");
      lb.setVisibleItemCount(1);
      lb.setSelectedIndex(0);
      
      final ListBox listbox = new ListBox();
      listbox.addItem("Select a Database ");
      listbox.addItem("1");
      listbox.addItem("2");
      listbox.addItem("3");
      listbox.addItem("4");
      listbox.addItem("5");
      listbox.addItem("6 ");
      listbox.addItem("7");
      listbox.addItem("8");
      listbox.addItem("9");
      listbox.addItem("10");
      listbox.addItem("11");
      listbox.addItem("12");
      listbox.addItem("13");
      listbox.addItem("14");
      listbox.addItem("15");

      
      listbox.setVisibleItemCount(1);
      listbox.setName("AlgorithmList");
    //  listbox.setVisible(false);
      
      final ListBox listbox1 = new ListBox();
      listbox1.addItem("Select the 2nd Database ");
      listbox1.addItem("1");
      listbox1.addItem("2");
      listbox1.addItem("3");
      listbox1.addItem("4");
      listbox1.addItem("5");
      listbox1.addItem("6 ");
      listbox1.addItem("7");
      listbox1.addItem("8");
      listbox1.addItem("9");
      listbox1.addItem("10");
      listbox1.addItem("11");
      listbox1.addItem("12");
      listbox1.addItem("13");
      listbox1.addItem("14");
      listbox1.addItem("15");

      
      listbox1.setVisibleItemCount(1);
      listbox1.setName("AlgorithmList1");
      listbox1.setVisible(false);
      
      final FormPanel fPanel = new FormPanel();
      fPanel.reset();
  	  fPanel.setAction(GENERATEJOB_ACTION_URL);	
  	  fPanel.setEncoding(FormPanel.ENCODING_MULTIPART);
  	  fPanel.setMethod(FormPanel.METHOD_POST);
  	
  	  widgetList.add(fPanel);
  	  VerticalPanel vPanel = new VerticalPanel();
  	  vPanel.setSpacing(15);
  	  
  	  HorizontalPanel formContainerPanel = new HorizontalPanel();
  	HorizontalPanel formContainerPanel1 = new HorizontalPanel();
  	HorizontalPanel formContainerPanel2 = new HorizontalPanel();
  	formContainerPanel1.setSpacing(15);
  //	formContainerPanel2.addStyleName("paddedHorizontalPanel");
  	  
  	  final TextBox txtProject = new TextBox();
  	  txtProject.setVisible(false);
  	  txtProject.setName("project");
  	  formContainerPanel.add(txtProject);
  	
  	  final TextBox txtUsername = new TextBox();
   	  txtUsername.setVisible(false);
  	  txtUsername.setName("user");
  	  formContainerPanel.add(txtUsername);
  	
  	  final TextBox txtTask = new TextBox();
  	  txtTask.setVisible(false);
  	  txtTask.setName("taskName");
  	  formContainerPanel.add(txtTask);
  	
  	  final TextBox txtFilename = new TextBox();
  	  txtFilename.setVisible(false);
  	  txtFilename.setName("dataFile");
  	//  formContainerPanel.add(txtFilename);
  	  
  /*	File dirPath = new File("/home/vtalreja/AIPData/");
  			if(dirPath != null && dirPath.isDirectory())
  			{
  				int count = dirPath.list().length;
  				//System.out.println("File count: " + count);
  				if(count > 0)
  				{					
  					String[] files = dirPath.list();
  					for(int i = 0; i < count; i++)
  					{
  						String fileName = files[i];
  						lb.addItem(fileName);
  					}
  				}
  			}*/
  	  
  	  
  	
  	  final TextBox txtOverwrite = new TextBox();
  	  txtOverwrite.setVisible(false);
  	  txtOverwrite.setName("overwrite");
  	  formContainerPanel.add(txtOverwrite);
  	
 // 	  formContainerPanel.add(imgUpload);
  	  
  	final TextBox txtFilename1 = new TextBox();
	  txtFilename1.setVisible(false);
	  txtFilename1.setName("dataFile1");
//	  formContainerPanel1.add(txtFilename1);
	  
  //	formContainerPanel1.add(imgUpload1);
  	formContainerPanel1.add(lb);
  	formContainerPanel1.add(listbox);
  	formContainerPanel1.add(listbox1);
  	
  //	ChangeHandler handler;
	lb.addChangeHandler(new ChangeHandler(){

		@Override
		public void onChange(ChangeEvent event) {
			int item=lb.getSelectedIndex();
			if (item==1)
			{
				listbox1.setVisible(true);
				listbox1.setSelectedIndex(0);
				listbox.setSelectedIndex(0);
			}
			else
			{
				listbox1.setVisible(false);
				listbox1.setSelectedIndex(0);
				listbox.setSelectedIndex(0);
			}
			
		}
		
	});
  	
  	
  
  	  Button submitButton = new Button("Submit");
	  submitButton.addTapHandler(new TapHandler(){
		  public void onTap(TapEvent event) {
		
			  fPanel.submit();
		  }  
	  });
	  
	  final Button viewButton = new Button("View Histogram");
	  viewButton.setVisible(false);
	  viewButton.addTapHandler(new TapHandler(){
		  public void onTap(TapEvent event) {
		
			  PopupPanel popup=new PopupPanel(true);
			//  popup.
		    //  popup.getElement().setAttribute("style","z-index:20");
			// popup.setWidget(new Label("How r u"));
		     popup.setWidget(new Image("Histogram.png"));
		     popup.setHeight("400px");
		 //     popup.setStyleName("popup-hint");
		    popup.center();
		      popup.show();
		  }  
	  });
	  
	  widgetList.add(submitButton);
	  widgetList1.add(viewButton);
	  
	  vPanel.add(formContainerPanel);
	 // vPanel.add(new HTML("<br/><br/>"));
	  vPanel.add(formContainerPanel1);
	  vPanel.add(formContainerPanel2);
	  fPanel.add(vPanel);
	 // fPanel.add(formContainerPanel);
	 // fPanel.add(formContainerPanel1);
	  
	  fPanel.addSubmitHandler(new FormPanel.SubmitHandler() 
      {      	
		public void onSubmit(SubmitEvent event) {
			//txtProject.setValue("plbp");
			txtProject.setValue("IrisCloud");
			
			/* Change to make it dynamic */  
		//	String username = currentUser.getUsername();
			txtUsername.setValue("vtalreja");
			//txtUsername.setValue("abommaga");
			//txtTask.setValue("Identification");
			txtTask.setValue("Matching");
			txtOverwrite.setValue("1");
			if (lb.isItemSelected(0))
			{
				if(listbox.isItemSelected(0))
				{
					lblWarning.setText("");
					lblWarning.setText("Please select a database for Intra Class Matching");
					event.cancel();
				}
			}
			else
			{
				if (listbox.isItemSelected(0)|| listbox1.isItemSelected(0))
				{
					lblWarning.setText("");
					lblWarning.setText("One or more Database has not been selected for Inter-Class Matching");
					event.cancel();
				}
			}
			
		//	if(imgUpload.getFilename().length() > 0)
    	
	/*		if(imgUpload.getFilename().length() > 0 && imgUpload1.getFilename().length() > 0)
			
				
				txtFilename.setValue(imgUpload.getFilename());
				txtFilename1.setValue(imgUpload1.getFilename());
				/*if (txtFilename.getValue()==txtFilename1.getValue())
				{
					int lastDot = txtFilename.getValue().lastIndexOf('.');
					if (lastDot ==-1)
					{
					 String s=txtFilename.getValue()+"_n";
					 txtFilename1.setValue(s);	
					}
					else
					{
					String s = txtFilename.getValue().substring(0,lastDot) + "_n" + txtFilename.getValue().substring(lastDot);
					txtFilename1.setValue(s);
					}
				}*/
				
			/*	System.out.println("Submitting identification job");
			} 
			else
			{
				lblWarning.setText("");
				lblWarning.setText("Please upload an image.");
				event.cancel();
			}	*/	
		}
      });
	  
	  fPanel.addSubmitCompleteHandler(new FormPanel.SubmitCompleteHandler() 
      {
		@SuppressWarnings("deprecation")
		public void onSubmitComplete(final SubmitCompleteEvent event) {
		//	Window.alert("Results are being computed . You will be redirected to Job History Page for Matching Score");
			String result = event.getResults(); 
		//	Window.alert("Results are being computed . You will be redirected to Job History Page for Matching Score");
			System.out.println("Result: " + result);
			viewButton.setVisible(true);
		//	JFrame frame = new JFrame();
  		   // Icon icon = new ImageIcon("androidBook.jpg");
  		   // Icon icon = new ImageIcon("a.png");
  		    //JLabel label1 = new JLabel("Full Name :", icon, JLabel.LEFT);
  		    //JLabel label = new JLabel("Image with Text", icon, SwingConstants.BOTTOM);
  		//  ImageIcon icon = new ImageIcon("yourFile.gif");
  		//JLabel label3 = new JLabel(
  		
  	   // JLabel label3 = new JLabel("Warning", icon, JLabel.CENTER);
  		//    frame.add(label3);
  		 //   frame.setDefaultCloseOperation
  		  //         (JFrame.EXIT_ON_CLOSE);
  		   // frame.pack();
  		//    frame.setVisible(true);
		/*try {
				//JSONValue response = JSONParser.parse(result);
				 
			    //  JSONObject value = response.isObject();
			      JSONObject response = (JSONObject) JSONParser.parse(result);
			      String fileId = (response).get("jobFileName").isString().stringValue();			     
			    //  lblWarning.setText(fileId);
			    //  Window.alert("Hi");
			      Window.alert(fileId);
			      fPanel.reset();
			      // use fileId
			    } catch (Exception exception) {
			      Window.alert("Error! " + exception.getMessage() + "; json: " + result);
			    }*/
		//	Window.alert("Results are being computed . You will be redirected to Job History Page for Matching Score. The top most job is the most recent one.");
	//	clientFactory.getPlaceController().goTo(new JobHistoryPlace());
		
		/*	Timer timer = new Timer()
			{

				@Override
				public void run() {
					//System.out.println("Result: " + result);
					//fPanel.reset();
					//clientFactory.getPlaceController().goTo(new BCFunctionButtonPlace());
					String result = event.getResults();  
					System.out.println("Result: " + result);
					try {
						JSONValue response = JSONParser.parse(result);
						 
					      JSONObject value = response.isObject();
					      String fileId = (value).get("jobFileName").isString().stringValue();			     
					    //  lblWarning.setText(fileId);
					    //  Window.alert("Hi");
					      Window.alert(fileId);
					      fPanel.reset();
					      // use fileId
					    } catch (Exception exception) {
					      Window.alert("Error! " + exception.getMessage() + "; json: " + result);
					  }
					
				}
				
			};*/
		//	timer.schedule(8000);
			//Window.alert(result);
		/*System.out.println("Result: " + result);
			fPanel.reset();
			clientFactory.getPlaceController().goTo(new BCFunctionButtonPlace());*/
		}
      });
  }

				
				
  
}