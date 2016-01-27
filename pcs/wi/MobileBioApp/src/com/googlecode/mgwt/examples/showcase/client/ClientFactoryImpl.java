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
package com.googlecode.mgwt.examples.showcase.client;

import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceController;
import com.google.web.bindery.event.shared.EventBus;
import com.google.web.bindery.event.shared.SimpleEventBus;
import com.googlecode.mgwt.examples.showcase.client.activities.animation.AnimationView;
import com.googlecode.mgwt.examples.showcase.client.activities.animation.AnimationViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationDoneView;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationDoneViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.button.ButtonView;
import com.googlecode.mgwt.examples.showcase.client.activities.button.ButtonViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.buttonbar.ButtonBarView;
import com.googlecode.mgwt.examples.showcase.client.activities.buttonbar.ButtonBarViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.carousel.CarouselView;
import com.googlecode.mgwt.examples.showcase.client.activities.carousel.CarouselViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsView;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsViewImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsView;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.gcell.GroupedCellListGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.gcell.GroupedCellListView;
import com.googlecode.mgwt.examples.showcase.client.activities.popup.PopupView;
import com.googlecode.mgwt.examples.showcase.client.activities.popup.PopupViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.progressbar.ProgressBarView;
import com.googlecode.mgwt.examples.showcase.client.activities.progressbar.ProgressBarViewImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.progressindicator.ProgressIndicatorView;
import com.googlecode.mgwt.examples.showcase.client.activities.progressindicator.ProgressIndicatorViewImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.pulltorefresh.PullToRefreshDisplay;
import com.googlecode.mgwt.examples.showcase.client.activities.pulltorefresh.PullToRefreshDisplayGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.scrollwidget.ScrollWidgetView;
import com.googlecode.mgwt.examples.showcase.client.activities.scrollwidget.ScrollWidgetViewImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.searchbox.SearchBoxView;
import com.googlecode.mgwt.examples.showcase.client.activities.searchbox.SearchBoxViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.slider.SliderView;
import com.googlecode.mgwt.examples.showcase.client.activities.slider.SliderViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.activities.tabbar.TabBarView;
import com.googlecode.mgwt.examples.showcase.client.activities.tabbar.TabBarViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadView;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.custom.GenerateModelView;
import com.googlecode.mgwt.examples.showcase.client.custom.GenerateModelViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadView;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobDetailsView;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobDetailsViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryView;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.header.HeaderRightWidgetPanelView;
import com.googlecode.mgwt.examples.showcase.client.header.HeaderRightWidgetPanelViewGwtImpl;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordView;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordViewGwtImpl;

/**
 * @author Daniel Kurka
 * 
 */
public class ClientFactoryImpl implements ClientFactory {

	private EventBus eventBus;
	private PlaceController placeController;
	/*private ShowCaseListView homeViewImpl;
	private UIView uiView;
	private AboutView aboutView;*/
	private AnimationView animationView;
	private AnimationDoneView animationDoneView;
	private ScrollWidgetView scrollWidgetView;
	private ElementsView elementsView;
	private ButtonBarViewGwtImpl footerPanelView;
	private SearchBoxViewGwtImpl searchBoxViewGwtImpl;
	private TabBarView tabBarView;
	private ButtonView buttonView;
	private ButtonView bcFunctionbuttonView;
	private EnrollImgUploadView enrollImgUploadView;
	private JobHistoryView jobHistoryView;
	private JobDetailsView jobDetailsView;
	private GenerateModelView generateModelView;
	private ChangePasswordView changePasswordView;
	private HeaderRightWidgetPanelView headerRightWidgetPanelView;
	private IdentifyImgUploadView identifyImgUploadView;
	private PopupView popupView;
	private ProgressBarView progressBarView;

	private SliderView sliderView;
	private PullToRefreshDisplayGwtImpl pullToRefreshView;
	private ProgressIndicatorViewImpl progressIndicatorView;
	private FormsViewGwtImpl formsView;
	private CarouselView carouselView;
	private GroupedCellListGwtImpl groupedCellListView;

	public ClientFactoryImpl() {
		eventBus = new SimpleEventBus();

		placeController = new PlaceController(eventBus);

		//homeViewImpl = new ShowCaseListViewGwtImpl();
	}

	@Override
	/*public ShowCaseListView getHomeView() {
		if (homeViewImpl == null) {
			homeViewImpl = new ShowCaseListViewGwtImpl();
		}
		return homeViewImpl;
	}*/

	public EventBus getEventBus() {
		return eventBus;
	}

	@Override
	public PlaceController getPlaceController() {
		return placeController;
	}

	/*@Override
	public UIView getUIView() {
		if (uiView == null) {
			uiView = new UIViewImpl();
		}
		return uiView;
	}

	@Override
	public AboutView getAboutView() {
		if (aboutView == null) {
			aboutView = new AboutViewGwtImpl();
		}

		return aboutView;
	}*/

	@Override
	public AnimationView getAnimationView() {
		if (animationView == null) {
			animationView = new AnimationViewGwtImpl();
		}
		return animationView;
	}

	@Override
	public AnimationDoneView getAnimationDoneView() {
		if (animationDoneView == null) {
			animationDoneView = new AnimationDoneViewGwtImpl();
		}
		return animationDoneView;
	}

	@Override
	public ScrollWidgetView getScrollWidgetView() {
		if (scrollWidgetView == null) {
			scrollWidgetView = new ScrollWidgetViewImpl();
		}
		return scrollWidgetView;
	}

	@Override
	public ElementsView getElementsView(ClientFactory clientFactory) {
		//if (elementsView == null) {
			elementsView = new ElementsViewImpl(clientFactory);
		//}
		return elementsView;
	}

	@Override
	public ButtonBarView getButtonBarView() {
		if (footerPanelView == null) {
			footerPanelView = new ButtonBarViewGwtImpl();
		}
		return footerPanelView;
	}

	@Override
	public SearchBoxView getSearchBoxView() {
		if (searchBoxViewGwtImpl == null) {
			searchBoxViewGwtImpl = new SearchBoxViewGwtImpl();
		}
		return searchBoxViewGwtImpl;
	}

	@Override
	public TabBarView getTabBarView() {
		if (tabBarView == null) {
			tabBarView = new TabBarViewGwtImpl();
		}
		return tabBarView;
	}

	@Override
	public ButtonView getButtonView() {
		if (buttonView == null) {
			buttonView = new ButtonViewGwtImpl();
		}
		return buttonView;
	}
	
	public ButtonView getBcFunctionbuttonView(ClientFactory clientFactory) {
		//if (bcFunctionbuttonView == null) {
			bcFunctionbuttonView = new BCFunctionButtonViewGwtImpl(clientFactory);
		//}
		return bcFunctionbuttonView;
	}
	
	/*public void setBcFunctionbuttonView(ButtonView bcFunctionbuttonView) {
		this.bcFunctionbuttonView = bcFunctionbuttonView;
	}*/

	@Override
	public PopupView getPopupView() {
		if (popupView == null) {
			popupView = new PopupViewGwtImpl();
		}
		return popupView;
	}

	@Override
	public ProgressBarView getProgressBarView() {
		if (progressBarView == null) {
			progressBarView = new ProgressBarViewImpl();
		}
		return progressBarView;
	}

	@Override
	public SliderView getSliderView() {
		if (sliderView == null) {
			sliderView = new SliderViewGwtImpl();
		}
		return sliderView;
	}

	@Override
	public PullToRefreshDisplay getPullToRefreshDisplay() {
		if (pullToRefreshView == null) {
			pullToRefreshView = new PullToRefreshDisplayGwtImpl();
		}
		return pullToRefreshView;
	}

	@Override
	public ProgressIndicatorView getProgressIndicatorView() {
		if (progressIndicatorView == null) {
			progressIndicatorView = new ProgressIndicatorViewImpl();
		}
		return progressIndicatorView;
	}

	@Override
	public FormsView getFormsView() {
		if (formsView == null) {
			formsView = new FormsViewGwtImpl();
		}
		return formsView;
	}

	@Override
	public CarouselView getCarouselHorizontalView() {
		if (carouselView == null) {
			carouselView = new CarouselViewGwtImpl();
		}
		return carouselView;
	}

	@Override
	public GroupedCellListView getGroupedCellListView() {
		if (groupedCellListView == null) {
			groupedCellListView = new GroupedCellListGwtImpl();
		}
		return groupedCellListView;
	}

	@Override
	public EnrollImgUploadView getEnrollImgUploadView(ClientFactory clientFactory) {
		//if (enrollImgUploadView == null) {
			enrollImgUploadView = new EnrollImgUploadViewGwtImpl(clientFactory);
		//}
		return enrollImgUploadView;
	}
	
	@Override
	public JobHistoryView getJobHistoryView(ClientFactory clientFactory) {
		//if (jobHistoryView == null) {
			jobHistoryView = new JobHistoryViewGwtImpl(clientFactory);
		//}
		return jobHistoryView;
	}
	
	@Override
	public JobDetailsView getJobDetailsView(ClientFactory clientFactory) {
		//if (jobDetailsView == null) {
			jobDetailsView = new JobDetailsViewGwtImpl(clientFactory);
		//}
		return jobDetailsView;
	}

	@Override
	public IdentifyImgUploadView getIdentifyImgUploadView(ClientFactory clientFactory) {
		//if (identifyImgUploadView == null) {
			identifyImgUploadView = new IdentifyImgUploadViewGwtImpl(clientFactory);
		//}
		return identifyImgUploadView;
	}

	@Override
	public ChangePasswordView getChangePasswordView(ClientFactory clientFactory) {
		//if (changePasswordView == null) {
			changePasswordView = new ChangePasswordViewGwtImpl(clientFactory);
		//}
		return changePasswordView;
	}

	@Override
	public HeaderRightWidgetPanelView getHeaderRightWidgetPanelView(ClientFactory clientFactory) {
		if (headerRightWidgetPanelView == null) {
			headerRightWidgetPanelView = new HeaderRightWidgetPanelViewGwtImpl(clientFactory);
		}
		return headerRightWidgetPanelView;
	}

	@Override
	public GenerateModelView getGenerateModelView(ClientFactory clientFactory) {
		//if (generateModelView == null) {
			generateModelView = new GenerateModelViewGwtImpl(clientFactory);
		//}
		return generateModelView;
	}


}
