
package com.googlecode.mgwt.examples.showcase.client.activities.Upload;

import java.util.Date;

import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.event.shared.HandlerRegistration;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.FileUpload;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.LayoutPanel;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.FormPanel.SubmitCompleteEvent;
import com.google.gwt.user.client.ui.FormPanel.SubmitEvent;
import com.googlecode.mgwt.dom.client.event.tap.HasTapHandlers;
import com.googlecode.mgwt.dom.client.event.tap.TapEvent;
import com.googlecode.mgwt.dom.client.event.tap.TapHandler;
import com.googlecode.mgwt.examples.showcase.client.DetailViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.ui.client.MGWT;
import com.googlecode.mgwt.ui.client.MGWTStyle;
import com.googlecode.mgwt.ui.client.widget.button.Button;
import com.googlecode.mgwt.ui.client.widget.button.image.PreviousitemImageButton;
import com.googlecode.mgwt.ui.client.widget.header.HeaderPanel;
import com.googlecode.mgwt.ui.client.widget.header.HeaderTitle;
import com.googlecode.mgwt.ui.client.widget.panel.Panel;
import com.googlecode.mgwt.ui.client.widget.panel.flex.FixedSpacer;
import com.googlecode.mgwt.ui.client.widget.panel.flex.FlexPanel;
import com.googlecode.mgwt.ui.client.widget.panel.flex.FlexSpacer;
import com.googlecode.mgwt.ui.client.widget.panel.flex.FlexPropertyHelper.Alignment;
import com.googlecode.mgwt.ui.client.widget.panel.flex.FlexPropertyHelper.Orientation;
import com.googlecode.mgwt.ui.client.widget.panel.flex.IsFlexPanel;
import com.googlecode.mgwt.ui.client.widget.panel.flex.RootFlexPanel;
import com.googlecode.mgwt.ui.client.widget.panel.scroll.ScrollPanel;
import com.googlecode.mgwt.ui.client.widget.list.widgetlist.*;
import com.googlecode.mgwt.ui.client.widget.panel.flex.*;
import com.googlecode.mgwt.ui.client.widget.input.MPasswordTextBox;
import com.googlecode.mgwt.ui.client.widget.input.MTextBox;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.ClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.RPCClientContext;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.User;
//import com.googlecode.mgwt.examples.showcase.client.activities.UIPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.AboutPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.Upload.UploadImagesPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
//import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsPlace;
//import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;



public class UploadImagesViewGwtImpl extends DetailViewGwtImpl implements UploadImagesView {

  private static String GENERATEJOB_ACTION_URL = GWT.getModuleBaseURL() + "gupld";
  private Panel round;
  private Button button;
  private HeaderPanel headerPanel;
  private PreviousitemImageButton headerBackButton;
  private HeaderTitle headerTitle = new HeaderTitle();
  private VerticalPanel mainPanel = new VerticalPanel();
  private HorizontalPanel addPanel1 = new HorizontalPanel();
  private TextBox usernameTextBox = new TextBox();
  private Label usernameLabel = new Label();
  private HorizontalPanel addPanel2 = new HorizontalPanel();
  private TextBox passwordTextBox = new TextBox();
  private Label passwordLabel = new Label();
  private Button Button=new Button();
  private ClientFactory clientFactory;
  private Label lblWarning = new Label();
  private ClientContext ctx;
  private User currentUser;
  
  

  public UploadImagesViewGwtImpl(ClientFactory clientFactory) {
	  this.clientFactory = clientFactory;
	 /* ctx = (ClientContext) RPCClientContext.get();	
	  String sessionID = Cookies.getCookie("sid");
	  if(sessionID != null)
	  {
		  if(ctx != null)
		  {
			    //Set the current user context
			    currentUser = ctx.getCurrentUser(); */
			    UploadImages();
		/*  }
		  else
		  {
			  clientFactory.getPlaceController().goTo(new AboutPlace());
		  }
	  }
	  else
	  {
		  clientFactory.getPlaceController().goTo(new AboutPlace());
	  }*/
  }
	  
	 private void UploadImages()
	 {
	  
	  
    round = new Panel();
     headerPanel = new HeaderPanel();
    FlexPanel flexPanel = new FlexPanel();
    flexPanel.setOrientation(Orientation.VERTICAL);
    flexPanel.setAlignment(Alignment.CENTER);
    FlowPanel loginPanel=new FlowPanel();

    round.add(flexPanel);
    round.add(loginPanel);
   round.setRound(true);
  
  
   HTML header = new HTML("Login");
  // header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());

    flexPanel.add(new HTML("WCRL"));
    flexPanel.add(new HTML("IRIS CLOUD"));
    flexPanel.add(new HTML("BUILT BY MATTHEW VALENTI FROM WEST VIRGINIA UNIVERSITY"));

    flexPanel.add(new HTML("Using Cloud to Match Iris Images"));

    flexPanel.add(new HTML("<br/><br/><a target='_blank' href='https://wcrl.csee.wvu.edu/wiki/Introduction'>WCRL.CSEE.WVU.EDU</a><br/><br/>"));

    

    
    loginPanel.add(new HTML("<br/><br/>"));
    
   
    loginPanel.add(new HTML("<br/><br/>"));
  
	
	 FlowPanel container = new FlowPanel();
		container.getElement().getStyle().setMarginTop(20, Unit.PX);
		
	//	scrollPanel.setScrollingEnabledX(false);
	 //     scrollPanel.setWidget(container); 
	      
	  //    scrollPanel.setUsePos(MGWT.getOsDetection().isAndroid());
		  
		  HTML header1 = new HTML("Get the Matching Score") ;
		 // header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());
		  container.add(header1);
		  
		  final Label lblWarning = new Label();
           WidgetList widgetList = new WidgetList();
           widgetList.setRound(true);
		  
	      container.add(widgetList);
	      
	      
	      widgetList.add(lblWarning);
	      
	      final FileUpload imgUpload = new FileUpload();
	      imgUpload.setName("SelectIris1");
	      final FileUpload imgUpload1 = new FileUpload();
	      imgUpload1.setName("SelectIris2");
	      
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
	  	
	  	  final MTextBox txtFilename = new MTextBox();
	  	  txtFilename.setVisible(false);
	  	  txtFilename.setName("dataFile");
	  	  formContainerPanel.add(txtFilename);
	  	
	  	  final TextBox txtOverwrite = new TextBox();
	  	  txtOverwrite.setVisible(false);
	  	  txtOverwrite.setName("overwrite");
	  	  formContainerPanel.add(txtOverwrite);
	  	  
	  	formContainerPanel.add(imgUpload);
	  	
	 /* 	final MTextBox txtFilename1 = new MTextBox();
	  	  txtFilename1.setVisible(false);
	  	  txtFilename1.setName("dataFile1");
	  	  formContainerPanel.add(txtFilename1); */
	  	
	  	
	  	formContainerPanel.add(imgUpload1);
	  	 Button submitButton = new Button("Submit");
	 		  submitButton.addTapHandler(new TapHandler(){
	 			  public void onTap(TapEvent event) {
	 			
	 				  fPanel.submit();
	 			  }  
	 		  });
	 		  
	 		  widgetList.add(submitButton);
	 		  fPanel.add(formContainerPanel);
		  
		  
		  loginPanel.add(container);
		  
		  fPanel.addSubmitHandler(new FormPanel.SubmitHandler()
	      {      	
			public void onSubmit(SubmitEvent event) {
				txtProject.setValue("IrisCloud");
				
				/* Change to make it dynamic */  
			//	String username = currentUser.getUsername();
			//	txtUsername.setValue(username);
				txtUsername.setValue("vtalreja");
				txtTask.setValue("Iris Recognition");
				txtOverwrite.setValue("1");
	    	
				if(imgUpload.getFilename().length() > 0 && imgUpload1.getFilename().length() > 0)
				{
					txtFilename.setValue(imgUpload.getFilename());
				//	txtFilename1.setValue(imgUpload1.getFilename());
					//System.out.println("Submitting identification job");
					Window.alert("Submitting the Matching Job");
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
			//	String result = event.getResults();  
			//	System.out.println("Result: " + result);
				Window.alert("Submitted Job");
				fPanel.reset();
				//clientFactory.getPlaceController().goTo(new ElementsPlace());
			}
	      });
	
	
	
	
	
    
	loginPanel.add(headerPanel);
	    
	    headerBackButton = new PreviousitemImageButton();

		headerBackButton.setVisible(!MGWT.getOsDetection().isAndroid());

		headerPanel.add(headerBackButton);
		headerPanel.add(new FlexSpacer());
		headerPanel.add(headerTitle);
		headerPanel.add(new FlexSpacer());
		FixedSpacer fixedSpacer = new FixedSpacer();
	fixedSpacer.setVisible(!MGWT.getOsDetection().isAndroid());
	headerPanel.add(fixedSpacer);
	
	
	
    if (MGWT.getFormFactor().isPhone()) {
      button = new Button("back");

      flexPanel.add(button);
    }
    scrollPanel.setWidget(round);
    scrollPanel.setScrollingEnabledX(false);
  }
  
  @Override
	public HasTapHandlers getBackbutton() {
		return headerBackButton;
	}

 /* @Override
  public HasTapHandlers getBackbutton() {
    final HasTapHandlers superB = super.getBackbutton();
    return new HasTapHandlers() {

      @Override
      public HandlerRegistration addTapHandler(TapHandler handler) {
        HandlerRegistration hr = null;
        if (MGWT.getOsDetection().isPhone()) {
          hr= button.addTapHandler(handler);
        }
        final HandlerRegistration hr1 = hr;
        final HandlerRegistration hr2 = superB.addTapHandler(handler);
        return new HandlerRegistration() {

          @Override
          public void removeHandler() {
            if(hr1 != null){
              hr1.removeHandler();
            }
            hr2.removeHandler();
          }
        };
      }
    };
  }*/
}
