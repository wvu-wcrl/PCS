/*
 * File: FormatDate.java

Purpose: Java class to display Upload date of a Job in the required format.
Current Date : Upload time of Job
Current Month : Month Day
Previous year(s) : MM/dd/yyyy
**********************************************************/

package com.googlecode.mgwt.examples.showcase.client.custom;

import java.util.Date;

import com.google.gwt.i18n.client.DateTimeFormat;

public class FormatDate
{
	public DateTimeFormat formatDate(Date date)
	{	
		  DateTimeFormat fmt = null;	      
	      /*if(date.getYear() == new Date().getYear())
	      {
	    	  if(date.getDate() == new Date().getDate())
	    	  {
	    		  fmt = DateTimeFormat.getFormat("h:mm a");
	    	  }
	    	  else
	    	  {
	    		  fmt = DateTimeFormat.getFormat("MMM dd");	    		  
	    	  }
	      }
	      else
	      {
	    	  fmt = DateTimeFormat.getFormat("MM/dd/yyyy");
	      }*/
		  fmt = DateTimeFormat.getFormat("EEE., MMM dd, yyyy h:mm:ss a");
	      return fmt;
	 }
	
	public DateTimeFormat shortFormatDate(Date date)
	{	
		  DateTimeFormat fmt = null;	      
	      if(date.getYear() == new Date().getYear())
	      {
	    	  if(date.getDate() == new Date().getDate())
	    	  {
	    		  fmt = DateTimeFormat.getFormat("h:mm a");
	    	  }
	    	  else
	    	  {
	    		  fmt = DateTimeFormat.getFormat("MMM dd");	    		  
	    	  }
	      }
	      else
	      {
	    	  fmt = DateTimeFormat.getFormat("MM/dd/yyyy");
	      }
	      return fmt;
	 }
}
