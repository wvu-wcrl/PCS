package com.googlecode.mgwt.examples.showcase.client.activities.Upload;

import com.google.gwt.place.shared.Place;
import com.google.gwt.place.shared.PlaceTokenizer;

public class UploadImagesPlace extends Place {
	public static class UploadImagesPlaceTokenizer implements PlaceTokenizer<UploadImagesPlace> {

		@Override
		public UploadImagesPlace getPlace(String token) {
			return new UploadImagesPlace();
		}

		@Override
		public String getToken(UploadImagesPlace place) {
			return "";
		}

	}
	
	

}
