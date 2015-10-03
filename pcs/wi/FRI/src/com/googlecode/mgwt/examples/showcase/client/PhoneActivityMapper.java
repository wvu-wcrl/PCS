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

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.place.shared.Place;
import com.googlecode.mgwt.examples.showcase.client.activities.animation.AnimationActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.animation.AnimationPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationDissolvePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationDoneActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationFadePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationFlipPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationPopPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlideDownPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlidePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlideUpPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSwapPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.button.ButtonActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.button.ButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.buttonbar.ButtonBarActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.buttonbar.ButtonBarPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.carousel.CarouselActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.carousel.CarouselPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.gcell.GroupedCellListActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.gcell.GroupedCellListPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.popup.PopupActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.popup.PopupPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.progressbar.ProgressBarActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.progressbar.ProgressBarPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.progressindicator.ProgressIndicatorActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.progressindicator.ProgressIndicatorPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.pulltorefresh.PullToRefreshActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.pulltorefresh.PullToRefreshPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.scrollwidget.ScrollWidgetActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.scrollwidget.ScrollWidgetPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.searchbox.SearchBoxActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.searchbox.SearchBoxPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.slider.SliderActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.slider.SliderPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.tabbar.TabBarActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.tabbar.TabBarPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadActivity;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.GenerateModelActivity;
import com.googlecode.mgwt.examples.showcase.client.custom.GenerateModelPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadActivity;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobDetailsActivity;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobDetailsPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryActivity;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryPlace;
import com.googlecode.mgwt.examples.showcase.client.places.HomePlace;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordActivity;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordPlace;

/**
 * @author Daniel Kurka
 * 
 */
public class PhoneActivityMapper implements ActivityMapper {

	private final ClientFactory clientFactory;

	public PhoneActivityMapper(ClientFactory clientFactory) {
		this.clientFactory = clientFactory;
	}

	@Override
	public Activity getActivity(Place place) {
		
		//System.out.println("PhoneActivityMapper: " + place.getClass());
		
		if (place instanceof HomePlace) {
			//return new ShowCaseListActivity(clientFactory);
			return new ElementsActivity(clientFactory);
		}

		/*if (place instanceof UIPlace) {
			return new UIActivity(clientFactory);
		}

		if (place instanceof AboutPlace) {
			return new AboutActivity(clientFactory);
		}*/

		if (place instanceof AnimationPlace) {
			return new AnimationActivity(clientFactory);
		}

		if (place instanceof ScrollWidgetPlace) {
			return new ScrollWidgetActivity(clientFactory);
		}

		if (place instanceof ElementsPlace) {
			return new ElementsActivity(clientFactory);
		}

		if (place instanceof FormsPlace) {
			return new FormsActivity(clientFactory);
		}

		if (place instanceof ButtonBarPlace) {
			return new ButtonBarActivity(clientFactory);
		}

		if (place instanceof SearchBoxPlace) {
			return new SearchBoxActivity(clientFactory);
		}

		if (place instanceof TabBarPlace) {
			return new TabBarActivity(clientFactory);
		}

		if (place instanceof ButtonPlace) {
			return new ButtonActivity(clientFactory);
		}
		
		if (place instanceof EnrollImgUploadPlace) {
			return new EnrollImgUploadActivity(clientFactory);
		}
		
		if (place instanceof JobHistoryPlace) {
			return new JobHistoryActivity(clientFactory);
		}
		
		if (place instanceof JobDetailsPlace) {
			return new JobDetailsActivity(clientFactory);
		}
		
		if (place instanceof IdentifyImgUploadPlace) {
			return new IdentifyImgUploadActivity(clientFactory);
		}
		
		if (place instanceof GenerateModelPlace) {
			return new GenerateModelActivity(clientFactory);
		}
		
		if (place instanceof BCFunctionButtonPlace) {
			return new BCFunctionButtonActivity(clientFactory);
		}
		
		if (place instanceof ChangePasswordPlace) {
			return new ChangePasswordActivity(clientFactory);
		}

		if (place instanceof PopupPlace) {
			return new PopupActivity(clientFactory);
		}

		if (place instanceof ProgressBarPlace) {
			return new ProgressBarActivity(clientFactory);
		}

		if (place instanceof ProgressIndicatorPlace) {
			return new ProgressIndicatorActivity(clientFactory);
		}

		if (place instanceof SliderPlace) {
			return new SliderActivity(clientFactory);
		}
		if (place instanceof PullToRefreshPlace) {
			return new PullToRefreshActivity(clientFactory);
		}

		if (place instanceof CarouselPlace) {
			return new CarouselActivity(clientFactory);
		}

		if (place instanceof GroupedCellListPlace) {
			return new GroupedCellListActivity(clientFactory);
		}

		if (place instanceof AnimationSlidePlace || place instanceof AnimationSlideUpPlace || place instanceof AnimationDissolvePlace || place instanceof AnimationFadePlace
				|| place instanceof AnimationFlipPlace || place instanceof AnimationPopPlace || place instanceof AnimationSwapPlace || place instanceof AnimationSwapPlace || place instanceof AnimationSlideDownPlace) {
			return new AnimationDoneActivity(clientFactory);
		}
		//System.out.println("PhoneActivityMapper done");
		//return new ShowCaseListActivity(clientFactory);
		return new ElementsActivity(clientFactory);
	}
}
