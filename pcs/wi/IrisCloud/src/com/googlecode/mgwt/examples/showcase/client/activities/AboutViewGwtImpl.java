
package com.googlecode.mgwt.examples.showcase.client.activities;

import com.google.gwt.event.shared.HandlerRegistration;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.LayoutPanel;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
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
//import com.googlecode.mgwt.examples.showcase.client.acctmgmt.RPCClientContext;
//import com.googlecode.mgwt.examples.showcase.client.activities.UIPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.Upload.UploadImagesPlace;
//import com.googlecode.mgwt.examples.showcase.client.activities.elements.service.UserValidationService;
//import com.googlecode.mgwt.examples.showcase.client.activities.elements.service.UserValidationServiceAsync;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsPlace;
//import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;



public class AboutViewGwtImpl extends DetailViewGwtImpl implements AboutView {

  
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
  public ClientFactory clientFactory;
  private Label lblWarning = new Label();
  
  

  public AboutViewGwtImpl( ClientFactory clientFactory) {
	//  final ClientFactory clientFactory = null;
	  this.clientFactory=clientFactory;
	  displayLogin();
  }
	  
	  private void displayLogin()
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
   WidgetList widgetList = new WidgetList();
   widgetList.setRound(true);
   HTML header = new HTML("Login");
  // header.addStyleName(MGWTStyle.getTheme().getMGWTClientBundle().getListCss().listHeader());

    flexPanel.add(new HTML("WCRL"));
    flexPanel.add(new HTML("IRIS CLOUD"));
    flexPanel.add(new HTML("BUILT BY MATTHEW VALENTI FROM WEST VIRGINIA UNIVERSITY"));

    flexPanel.add(new HTML("Using Cloud to Match Iris Images"));

    flexPanel.add(new HTML("<br/><br/><a target='_blank' href='https://wcrl.csee.wvu.edu/wiki/Introduction'>WCRL.CSEE.WVU.EDU</a><br/><br/>"));

    

    
    loginPanel.add(new HTML("<br/><br/>"));
    
   
    loginPanel.add(new HTML("<br/><br/>"));
    loginPanel.add(widgetList);
  //  scrollPanel.setWidget(loginPanel);
    
 
    
   //widgetList.add(mainPanel);
   // loginPanel.add(mainPanel);
    widgetList.setHeader(new Label("Login"));
   
    widgetList.add(lblWarning);
    
    final MTextBox mTextBox = new MTextBox();
    mTextBox.setPlaceHolder("Username");
    widgetList.add(mTextBox);
    
    mTextBox.setText("");

    final MPasswordTextBox mPasswordTextBox = new MPasswordTextBox();
    mPasswordTextBox.setPlaceHolder("Password");
    widgetList.add(mPasswordTextBox);
    
    mPasswordTextBox.setText("");
            
    WidgetList widgetList1 = new WidgetList();
    widgetList1.setRound(true);
   // widgetList1.setSize("50", "50");
    
    Button loginButton = new Button("Sign in");
    Anchor forgotPassword = new Anchor("Forgot Password?");
        
    widgetList1.add(loginButton);
    widgetList1.add(forgotPassword);
    loginPanel.add(widgetList1);
    loginButton.setWidth("15");
  /*
	
	Button.setWidth("15");
	
	
	 
	   
	
	    widgetList.add(Button);
	
	//mainPanel.add(Button);*/
	
	loginButton.addTapHandler(new TapHandler() 
    {
		
        public void onTap(TapEvent event) {
        	String usernameRegex = "^[a-z][-a-z0-9_]*$";
			String passwordRegex = "^.*(?=.{8,})(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(^[a-zA-Z0-9@$=!:.#%]+$)";
        	//String regex = "^[A-Za-z@._][A-Za-z0-9._@]+";
        	String username = mTextBox.getValue().trim();
        	String password = mPasswordTextBox.getValue().trim();
      //  	Log.info("Username: " + username + " Password: " + password);
        	Window.alert("Username: " + username + " Password: " + password);
        //	System.out.println("Username: " + username + " Password: " + password);
        //	System.out.println((username.matches(usernameRegex))  + " " +  (password.matches(passwordRegex)));
        	if((username.matches(usernameRegex)) && (password.matches(passwordRegex)))
			{
        	//	RPCClientContext.set(null);
        	//	lblWarning.setText("Good Job");
        		clientFactory.getPlaceController().goTo(new UploadImagesPlace());
        		//UserValidationServiceAsync service = UserValidationService.Util.getInstance();			
				//service.validateUser(username, password, loginCallback);
			}
        	else
        	{
        		lblWarning.setText("");
     		    lblWarning.setText("Please enter valid username and password.");
        	}
        }                   
    });    
        
        	
        	//Window.alert("Welcome");
        	//clientFactory.getPlaceController().goTo(new UploadImagesPlace());
      //  }
        	             
  //  }) ;
	
	loginPanel.add(new HTML("<br/><br/>"));
    
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
