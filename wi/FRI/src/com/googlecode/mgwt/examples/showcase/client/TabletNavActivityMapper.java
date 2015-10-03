package com.googlecode.mgwt.examples.showcase.client;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.activity.shared.ActivityMapper;
import com.google.gwt.place.shared.Place;
import com.googlecode.mgwt.examples.showcase.client.activities.animation.AnimationActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.animation.AnimationPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationCubePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationDissolvePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationFadePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationFlipPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationPopPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlideDownPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlidePlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSlideUpPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.animationdone.AnimationSwapPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.button.ButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.buttonbar.ButtonBarPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.carousel.CarouselPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsActivity;
import com.googlecode.mgwt.examples.showcase.client.activities.elements.ElementsPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.forms.FormsPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.gcell.GroupedCellListPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.popup.PopupPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.progressbar.ProgressBarPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.progressindicator.ProgressIndicatorPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.pulltorefresh.PullToRefreshPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.scrollwidget.ScrollWidgetPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.searchbox.SearchBoxPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.slider.SliderPlace;
import com.googlecode.mgwt.examples.showcase.client.activities.tabbar.TabBarPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.GenerateModelPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.IdentifyImgUploadPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobDetailsPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobHistoryPlace;
import com.googlecode.mgwt.examples.showcase.client.places.HomePlace;
import com.googlecode.mgwt.examples.showcase.client.settings.ChangePasswordPlace;

public class TabletNavActivityMapper implements ActivityMapper {

	private final ClientFactory clientFactory;

	public TabletNavActivityMapper(ClientFactory clientFactory) {
		this.clientFactory = clientFactory;
	}

	/*private UIActivity uiActivity;
	private ShowCaseListActivity showCaseListActivity;*/
	private ElementsActivity elementsActivity;
	private AnimationActivity animationActivity;

//	private Activity getUIActivity() {
//		if (uiActivity == null) {
//			uiActivity = new UIActivity(clientFactory);
//		}
//		return uiActivity;
//	}
//
//	private Activity getShowCaseListActivity() {
//		if (showCaseListActivity == null) {
//			showCaseListActivity = new ShowCaseListActivity(clientFactory);
//		}
//		return showCaseListActivity;
//	}
	
	private Activity getElementsActivity() {
		if (elementsActivity == null) {
			elementsActivity = new ElementsActivity(clientFactory);
		}
		return elementsActivity;
	}

	private Activity getAnimationActicity() {
		if (animationActivity == null) {
			animationActivity = new AnimationActivity(clientFactory);
		}
		return animationActivity;
	}

	@Override
	public Activity getActivity(Place place) {
		/*if (place instanceof HomePlace || place instanceof AboutPlace) {
			return getShowCaseListActivity();
		}*/
		
		if (place instanceof HomePlace) {
			return getElementsActivity();
		}

		if (place instanceof PullToRefreshPlace || place instanceof GroupedCellListPlace || place instanceof CarouselPlace || /*place instanceof UIPlace ||*/ place instanceof ScrollWidgetPlace
				|| place instanceof ElementsPlace || place instanceof FormsPlace || place instanceof ButtonBarPlace || place instanceof SearchBoxPlace || place instanceof TabBarPlace
				|| place instanceof ButtonPlace || place instanceof BCFunctionButtonPlace || place instanceof EnrollImgUploadPlace || place instanceof JobHistoryPlace || place instanceof JobDetailsPlace || place instanceof IdentifyImgUploadPlace || place instanceof GenerateModelPlace || place instanceof ChangePasswordPlace || place instanceof PopupPlace || place instanceof ProgressBarPlace || place instanceof SliderPlace || place instanceof ProgressIndicatorPlace) {
			//return getUIActivity();
			getElementsActivity();
		}

		if (place instanceof AnimationPlace) {
			return getAnimationActicity();
		}

		if (place instanceof AnimationSlidePlace || place instanceof AnimationSlideUpPlace || place instanceof AnimationDissolvePlace || place instanceof AnimationFadePlace
				|| place instanceof AnimationFlipPlace || place instanceof AnimationPopPlace || place instanceof AnimationSwapPlace || place instanceof AnimationCubePlace || place instanceof AnimationSlideDownPlace) {
			return getAnimationActicity();
		}
		//return new ShowCaseListActivity(clientFactory);
		
		return new ElementsActivity(clientFactory);
	}
}
