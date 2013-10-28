package com.googlecode.mgwt.examples.showcase.client;

import com.google.gwt.place.shared.Place;
import com.googlecode.mgwt.examples.showcase.client.activities.button.BCFunctionButtonPlace;
import com.googlecode.mgwt.examples.showcase.client.custom.EnrollImgUploadPlace;

public class Location1 {
	
	private Place place;
	private String header;
	
	public String getHeader(Place from)
	{
		header = "Home";
		
		if(from instanceof BCFunctionButtonPlace)
		{
			header = "Home";
		}
		if(from instanceof EnrollImgUploadPlace)
		{
			header = "Enroll";
		}
		return header;
	}
	
	public Place getPlace(String header)
	{
		if(header.equalsIgnoreCase("Home"))
		{
			place = new BCFunctionButtonPlace();
		}
		if(header.equalsIgnoreCase("Enroll"))
		{
			place = new EnrollImgUploadPlace();
		}
		return place;
	}

}