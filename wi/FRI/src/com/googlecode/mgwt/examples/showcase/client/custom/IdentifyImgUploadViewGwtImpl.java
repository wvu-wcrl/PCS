package com.googlecode.mgwt.examples.showcase.client.custom;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.ui.FileUpload;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.FormPanel.SubmitCompleteEvent;
import com.google.gwt.user.client.ui.FormPanel.SubmitEvent;
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
	  
	  ctx = (ClientContext) RPCClientContext.get();	
	  String sessionID = Cookies.getCookie("sid");
	  Log.info("IdentifyImgUploadViewGwtImpl sessionID: " + sessionID + " ctx: " + RPCClientContext.get()); 
	  if(sessionID != null)
	  {
		  if(ctx != null)
		  {
			    //Set the current user context
			    currentUser = ctx.getCurrentUser();
			    identifyImg();
		  }
		  else
		  {
			  clientFactory.getPlaceController().goTo(new ElementsPlace());
		  }
	  }
	  else
	  {
		  clientFactory.getPlaceController().goTo(new ElementsPlace());
	  }
  }
  
  private void identifyImg() {
	  headerPanel.setLeftWidget(headerBackButton);
	  FlowPanel container = new FlowPanel();
	  final Image image=new Image("fly_wv.svg");
	  final Image image1=new Image("helmet_black_70_81.svg");
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
      
      lb1= new Label("OCULAR CLOUD-Using Cloud to Match Ocular Images");
 	  lb1.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
 	  lb1.setHorizontalAlignment(HasHorizontalAlignment.ALIGN_CENTER);
       HTML header = new HTML("Upload Two Images and Get the Matching Score");
 	  header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
 	  container.add(image);
 	  container.add(image1);
 	  container.add(lb1);
 	  container.add(new HTML("<br/><br/>"));
 	//  container.add(new HTML("<br/><br/>"));
 	  
 	  container.add(header);
	  
	  final Label lblWarning = new Label();
      
      WidgetList widgetList = new WidgetList();
      //WidgetList widgetList1 = new WidgetList();
      container.add(widgetList);
      //container.add(widgetList1);
      
      widgetList.add(lblWarning);
      //lblWarning.setText("222222222222222222222222");
      
      final FileUpload imgUpload = new FileUpload();
      imgUpload.setName("fileselect[]");
      
      final FileUpload imgUpload1 = new FileUpload();
      imgUpload1.setName("fileselect1[]");
      
      
      
      final FormPanel fPanel = new FormPanel();
      fPanel.reset();
  	  fPanel.setAction(GENERATEJOB_ACTION_URL);	
  	  fPanel.setEncoding(FormPanel.ENCODING_MULTIPART);
  	  fPanel.setMethod(FormPanel.METHOD_POST);
  	
  	  widgetList.add(fPanel);
  	  
  	  HorizontalPanel formContainerPanel = new HorizontalPanel();
  	  
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
  	  formContainerPanel.add(txtFilename);
  	  
  	
  	  
  	  
  	
  	  final TextBox txtOverwrite = new TextBox();
  	  txtOverwrite.setVisible(false);
  	  txtOverwrite.setName("overwrite");
  	  formContainerPanel.add(txtOverwrite);
  	
  	  formContainerPanel.add(imgUpload);
  	  
  	final TextBox txtFilename1 = new TextBox();
	  txtFilename1.setVisible(false);
	  txtFilename1.setName("dataFile1");
	  formContainerPanel.add(txtFilename1);
	  
  	formContainerPanel.add(imgUpload1);
  	 
  	  Button submitButton = new Button("Submit");
	  submitButton.addTapHandler(new TapHandler(){
		  public void onTap(TapEvent event) {
		
			  fPanel.submit();
		  }  
	  });
	  
	  widgetList.add(submitButton);
	  fPanel.add(formContainerPanel);
	  
	  fPanel.addSubmitHandler(new FormPanel.SubmitHandler() 
      {      	
		public void onSubmit(SubmitEvent event) {
			//txtProject.setValue("plbp");
			txtProject.setValue("IrisCloud");
			
			/* Change to make it dynamic */  
			String username = currentUser.getUsername();
			txtUsername.setValue(username);
			//txtUsername.setValue("abommaga");
			//txtTask.setValue("Identification");
			txtTask.setValue("Matching");
			txtOverwrite.setValue("1");
			
			
		//	if(imgUpload.getFilename().length() > 0)
    	
			if(imgUpload.getFilename().length() > 0 && imgUpload1.getFilename().length() > 0)
			{
				txtFilename.setValue(imgUpload.getFilename());
				txtFilename1.setValue(imgUpload1.getFilename());
				
				System.out.println("Submitting identification job");
			} 
			else
			{
				lblWarning.setText("");
				lblWarning.setText("Please upload an image.");
				event.cancel();
			}		
		}
      });
	  
	  fPanel.addSubmitCompleteHandler(new FormPanel.SubmitCompleteHandler() 
      {
		public void onSubmitComplete(SubmitCompleteEvent event) {
			String result = event.getResults();  
			System.out.println("Result: " + result);
			fPanel.reset();
			clientFactory.getPlaceController().goTo(new BCFunctionButtonPlace());
		}
      });
  }
  
}