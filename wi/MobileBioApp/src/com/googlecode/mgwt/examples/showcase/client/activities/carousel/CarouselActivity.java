/*
 * Copyright 2010 Daniel Kurka
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package com.googlecode.mgwt.examples.showcase.client.activities.carousel;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.googlecode.mgwt.examples.showcase.client.ClientFactory;
import com.googlecode.mgwt.examples.showcase.client.DetailActivity;

/**
 * @author Daniel Kurka
 * 
 */
public class CarouselActivity extends DetailActivity {

	private final ClientFactory clientFactory;

	public CarouselActivity(ClientFactory clientFactory) {
		super(clientFactory.getCarouselHorizontalView(), "nav");
		this.clientFactory = clientFactory;
	}

	@Override
	public void start(AcceptsOneWidget panel, EventBus eventBus) {
		super.start(panel, eventBus);
		final CarouselView view = clientFactory.getCarouselHorizontalView();

		view.getBackbuttonText().setText("UI");
		view.getMainButtonText().setText("Nav");
		view.getHeader().setText("Carousel");

		panel.setWidget(view);
	}

}
