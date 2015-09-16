package com.googlecode.mgwt.examples.showcase.client.activities.Upload;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.googlecode.mgwt.dom.client.event.tap.TapEvent;
import com.googlecode.mgwt.dom.client.event.tap.TapHandler;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailActivity;
import com.googlecode.mgwt.examples.showcase.client.DetailView;
import com.googlecode.mgwt.examples.showcase.client.activities.AboutPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsView;

public class UploadImagesActivity extends DetailActivity {
	
	private final ClientFactory clientFactory;

	public UploadImagesActivity(ClientFactory clientFactory) {
		super(clientFactory.getUploadImagesView(clientFactory), "nav");
		this.clientFactory = clientFactory;

	
	}
	
	@Override
	public void start(AcceptsOneWidget panel, EventBus eventBus) {
		super.start(panel, eventBus);
		UploadImagesView view = clientFactory.getUploadImagesView(clientFactory);
		
		addHandlerRegistration(view.getBackbutton().addTapHandler(new TapHandler() {

		      @Override
		      public void onTap(TapEvent event) {
		    	  clientFactory.getPlaceController().goTo(new AboutPlace());
		      }
		    }));
		
		panel.setWidget(view);
	}

}
