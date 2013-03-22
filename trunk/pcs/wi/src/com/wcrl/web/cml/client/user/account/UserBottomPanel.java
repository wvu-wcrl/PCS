/*
 * File: BottomPanel.java

Purpose: Class to display the footer: Copyrights (and other links)
**********************************************************/

package com.wcrl.web.cml.client.user.account;

import java.util.Date;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.seventhdawn.gwt.rpc.context.client.RPCClientContext;
import com.wcrl.web.cml.client.account.ClientContext;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.login.Login;
import com.wcrl.web.cml.client.loginService.UserValidationService;
import com.wcrl.web.cml.client.loginService.UserValidationServiceAsync;

/**
 * The bottom panel, which contains the 'copyright' message and various links.
 */
public class UserBottomPanel extends Composite implements ClickHandler 
{
  private HTML copyrightLink;
  private HTML termsLink;
  private HTML policyLink;
  private HorizontalPanel outer;
  private User currentUser;
  private VerticalPanel inner;
  //private HTML usage;
  private ClientContext ctx;
  private Timer usageTimer;
  private Label lblRuntime;
  
  @SuppressWarnings("deprecation")
  public UserBottomPanel() 
  {	  
	  outer = new HorizontalPanel();
	  initWidget(outer);   
	  ctx = (ClientContext) RPCClientContext.get();
	  if(ctx != null)
	  {
		  //Log.info("before....");
		  currentUser = ctx.getCurrentUser();
		  if(currentUser != null)
		  {			  
			  inner = new VerticalPanel();
			  
			  //usage = new HTML();
			  copyrightLink = new HTML();
			  termsLink = new HTML("Terms");
			  policyLink = new HTML("Privacy Policy");
			  lblRuntime = new Label();
			  outer.setHorizontalAlignment(HorizontalPanel.ALIGN_CENTER);
			  //inner.setHorizontalAlignment(HorizontalPanel.ALIGN_CENTER);
			  Date date = new Date();
			  int year = date.getYear() + 1900;
			  copyrightLink.setHTML("&copy;" + year + " WCRL");
			  
			  HorizontalPanel copyright = new HorizontalPanel();
			  copyright.setSpacing(4);
			  copyright.add(copyrightLink);
			  copyright.add(getSeparator());
			  copyright.add(termsLink);
			  copyright.add(getSeparator());
			  copyright.add(policyLink);
			  copyrightLink.setStyleName("footerfont");
			  policyLink.addStyleName("pagefooterlink");
			  termsLink.addStyleName("pagefooterlink");
			  policyLink.addStyleName("pagefooterhover");
			  termsLink.addStyleName("pagefooterhover");
			  
			  //outer.add(copyright);		  
			  
			  usageTimer = new Timer()
			  {
				  public void run()
				  {
					  ctx = (ClientContext) RPCClientContext.get();
					  if ( ctx != null )
					  {
						  UserValidationServiceAsync service = UserValidationService.Util.getInstance();			
						  service.ckLogin(currentUser.getUsername(), currentUser.getPassword(), true, ckLoginCallback);
					  }
					  else
					  {
						  usageTimer.cancel();
					  }
				  }
			  };
			  usageTimer.scheduleRepeating(1000*30*1);
			  setRuntime(currentUser);		  
			  lblRuntime.addStyleName("pagefooter");	
						  
			  inner.add(copyright);
			  //inner.add(usage);
			  inner.add(lblRuntime);
			  outer.add(inner);
			  //outer.setCellHorizontalAlignment(copyright, HorizontalPanel.ALIGN_CENTER);
			  outer.setCellHorizontalAlignment(inner, HorizontalPanel.ALIGN_CENTER);
			  termsLink.addClickHandler(this);
			  policyLink.addClickHandler(this);
			  
			  setStyleName("mail-TopPanel");
			  copyright.setStyleName("mail-TopPanelLinks");			  
		  }		  
	  }
	  else
	  {
		  Log.info("Ctx null UserBottomPanel");
		  @SuppressWarnings("unused")
		  Login login = new Login();
	  }	   
  }
  
  AsyncCallback<User> ckLoginCallback = new AsyncCallback<User>()
  {
	  public void onFailure(Throwable arg0)
	  {
		  Log.info("BottomPanel ckLoginCallback error: " + arg0.toString());
	  }
	  public void onSuccess(User user)
	  {
		  String sessionID = Cookies.getCookie("sid");
		  //System.out.println("Timestamp: " + new Date() + " session: " + sessionID);
		  if ( sessionID != null )
		  {
			  if(ctx != null)
			  {
				  currentUser = ctx.getCurrentUser();
				  currentUser.setUsedRuntime(user.getUsedRuntime());
				  currentUser.setTotalRuntime(user.getTotalRuntime());
				  ctx.setCurrentUser(currentUser);
				  setRuntime(currentUser);
			  }
		  }
		  else
		  {
			  usageTimer.cancel();
			  Login login = new Login();
			  login.displayLoginBox();
		  }
	  }
  	};
  	
  	/*private void setRuntime(User currentUser)
    {
  	  String runtimeVal = "0";
  	  double usedRuntime = currentUser.getUsedRuntime();
  	  double totalRuntime = currentUser.getTotalRuntime();
  	  
  	  if(usedRuntime != 0)
  	  {
  		  runtimeVal = Double.valueOf(usedRuntime).toString();
  	  }
  	  if(runtimeVal.length() > 5)
  	  {
  		  runtimeVal = runtimeVal.substring(0, 4);
  	  }
  	  //System.out.println("@@@@@@@@@Runtime: " + runtime);
  	  
  	  String totalRuntimeVal = "0";
  	  if(totalRuntime != 0)
  	  {
  		  totalRuntimeVal = Double.valueOf(totalRuntime).toString();
  	  }
  	  
  	  if(totalRuntimeVal.length() > 5)
  	  {
  		  totalRuntimeVal = totalRuntimeVal.substring(0, 4);
  	  }
  	  //System.out.println("@@@@@@@@@TotalRuntime: " + totalRuntime);
  	  double percentRuntime = 0;
  	  if(usedRuntime > 0)
  	  {
  		  percentRuntime = (usedRuntime * 100)/(totalRuntime);
  	  }
  	  String percentVal = "0";
  	  if(percentRuntime != 0)
  	  {
  		  percentVal = Double.valueOf(percentRuntime).toString();
  	  }
  	  percentVal = Double.valueOf(percentRuntime).toString();
  	  if(percentVal.length() > 5)
  	  {
  		  percentVal = percentVal.substring(0, 4);
  	  }	  
  	  //String runtimeStr = "You have used " + runtimeVal + " units of your " + totalRuntimeVal + " units of runtime (" + percentVal + "%).";
  	  String runtimeStr = "You are using " + runtimeVal + " credits (" + percentVal + "%) of your " + totalRuntimeVal + " credits.";
  	  
  	  lblRuntime.setText(runtimeStr);
  	  
    }*/
  	
  	private void setRuntime(User currentUser)
    {
  	  String runtimeVal = "0";
  	  double usedRuntime = currentUser.getUsedRuntime();
  	  double totalRuntime = currentUser.getTotalRuntime();
  	  
  	  if(usedRuntime > 0)
  	  {
  		  usedRuntime = usedRuntime/60; 
  		  runtimeVal = Double.valueOf(usedRuntime).toString();
  	  }
  	  //System.out.println("runtimeVal: " + runtimeVal + " ");
  	  int runtimeDecimalIndex = runtimeVal.indexOf(".");
  	  if(runtimeDecimalIndex != -1)
  	  {
  		  if(runtimeVal.length() >= (runtimeDecimalIndex+3))
  		  {
  			runtimeVal = runtimeVal.substring(0, (runtimeDecimalIndex+3));
  		  }
  		  else
  		  {
  			runtimeVal = runtimeVal.substring(0, (runtimeDecimalIndex+2));
  		  }  		
  	  }
  	  
  	  String totalRuntimeVal = "0";
  	  if(totalRuntime > 0)
  	  {
  		  totalRuntime = totalRuntime/60;
  		  totalRuntimeVal = Double.valueOf(totalRuntime).toString();
  	  }
  	  //System.out.println("totalRuntimeVal: " + totalRuntimeVal + " ");
  	  int totalRuntimeDecimalIndex = totalRuntimeVal.indexOf(".");
  	  if(totalRuntimeDecimalIndex != -1)
  	  {
  		  if(totalRuntimeVal.length() >= (totalRuntimeDecimalIndex+3))
  		  {
  			totalRuntimeVal = totalRuntimeVal.substring(0, (totalRuntimeDecimalIndex+3));
  		  }
  		  else
  		  {
  			totalRuntimeVal = totalRuntimeVal.substring(0, (totalRuntimeDecimalIndex+2));
  		  }
  		
  	  }
  	  
  	  double percentRuntime = 0;
  	  if(usedRuntime > 0)
  	  {
  		  percentRuntime = (usedRuntime * 100)/(totalRuntime);
  	  }
  	  
  	  String percentVal = "0";  	
  	  percentVal = Double.valueOf(percentRuntime).toString();
  	  int percentValIndex = percentVal.indexOf(".");
  	  //System.out.println("PercentVal: " + percentVal + " ");
  	  if(percentValIndex != -1)
  	  {
  		  if(percentVal.length() >= (percentValIndex+3))
  		  {
  			  percentVal = percentVal.substring(0, (percentValIndex+3));
  		  }
  		  else
  		  {
  			  percentVal = percentVal.substring(0, (percentValIndex+2));
  		  }  		
  	  }  	  
  	  
  	  //String runtimeStr = "You have used " + runtimeVal + " units of your " + totalRuntimeVal + " units of runtime (" + percentVal + "%).";
  	  String runtimeStr = "You are using " + runtimeVal + " credits (" + percentVal + "%) of your " + totalRuntimeVal + " credits.";
  	  
  	  lblRuntime.setText(runtimeStr);  	  
    }
  
  private Widget getSeparator() 
  {
		Label barLabel = new Label();
		barLabel.setText("-");
		barLabel.addStyleName("normalTextFont");
		return barLabel;
  }

  public void onClick(ClickEvent event) 
  {
    Object sender = event.getSource();
    if (sender == termsLink) 
    {
      //Window.alert("If this were implemented, you would be signed out now.");
    } 
    else if (sender == policyLink) 
    {
    	//Window.alert("If this were implemented, you would see Frontier policies.");    	
    }   
  }
}