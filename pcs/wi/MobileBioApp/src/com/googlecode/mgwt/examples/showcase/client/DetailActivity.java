package com.googlecode.mgwt.examples.showcase.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.google.web.bindery.event.shared.EventBus;
import com.googlecode.mgwt.dom.client.event.tap.TapEvent;
import com.googlecode.mgwt.dom.client.event.tap.TapHandler;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.ServerGeneratedMessageEventService;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.service.ServerMessageGeneratorService;
import com.googlecode.mgwt.examples.showcase.client.event.ActionEvent;
import com.googlecode.mgwt.examples.showcase.client.event.ActionNames;
import com.googlecode.mgwt.mvp.client.MGWTAbstractActivity;
import com.googlecode.mgwt.ui.client.event.ShowMasterEvent;

public class DetailActivity extends MGWTAbstractActivity {

  private final DetailView detailView;
  private final String eventId;

  public DetailActivity(DetailView detailView, String eventId) {
    this.detailView = detailView;
    this.eventId = eventId;

  }

  @Override
  public void start(AcceptsOneWidget panel, final EventBus eventBus) {
    addHandlerRegistration(detailView.getMainButton().addTapHandler(new TapHandler() {

      @Override
      public void onTap(TapEvent event) {
        eventBus.fireEvent(new ShowMasterEvent(eventId));

      }
    }));

    addHandlerRegistration(detailView.getBackbutton().addTapHandler(new TapHandler() {

      @Override
      public void onTap(TapEvent event) {
    	  if(ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync != null)
		  {
    		  System.out.println("Stopping ServerGeneratedMessageEventService");
    		  ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync.stop(VoidAsyncCallback);
    		  ServerGeneratedMessageEventService.theServerMessageGeneratorServiceAsync = null;
		  }
    	  ActionEvent.fire(eventBus, ActionNames.BACK);
      }
      
      AsyncCallback<Void> VoidAsyncCallback = new AsyncCallback<Void>() {
    	  public void onFailure(Throwable aThrowable) {}
    	  public void onSuccess(Void aResult) {}
      };
    }));

  }

}
