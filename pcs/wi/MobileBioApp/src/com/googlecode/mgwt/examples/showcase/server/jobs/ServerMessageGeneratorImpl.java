package com.googlecode.mgwt.examples.showcase.server.jobs;

import java.io.File;
import java.util.Date;
import java.util.ResourceBundle;
import java.util.Timer;
import java.util.TimerTask;

import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobItem;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.ServerGeneratedMessageEvent;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.service.ServerMessageGeneratorService;

import de.novanic.eventservice.client.event.Event;
import de.novanic.eventservice.service.RemoteEventServiceServlet;

public class ServerMessageGeneratorImpl extends RemoteEventServiceServlet implements ServerMessageGeneratorService
{
	private static final long serialVersionUID = 1L;
	private Timer myEventGeneratorTimer;
	//private long updateDuration = 1000 * 10;
	//private String rootPathForDownload;
    
	public synchronized void start(JobItem item)
    {
		
		ResourceBundle constants = ResourceBundle.getBundle("UpdateFrequency");
		String duration = constants.getString("jobUpdateDuration");
		long updateDuration = 1000 * 10;
		try
    	{
    		long temp = Integer.parseInt(duration) ;
    		if(temp > 0)
    		{
    			updateDuration = updateDuration * temp;
    		}
    	}
    	catch(NumberFormatException e)
    	{
    		e.printStackTrace();
    	}
		System.out.println("***** Timer: " + myEventGeneratorTimer);
        if(myEventGeneratorTimer == null) 
        {
        	System.out.println("~~~~~ Starting timer with update duration: " + updateDuration);
            myEventGeneratorTimer = new Timer();    
            myEventGeneratorTimer.schedule(new ServerMessageGeneratorTimerTask(item), 0, updateDuration);
        }
        /*if(myEventGeneratorTimer != null) 
        {
        	stop();
        }
            myEventGeneratorTimer = new Timer();    
            myEventGeneratorTimer.schedule(new ServerMessageGeneratorTimerTask(item), 0, updateDuration);*/
        
    }
    
    public synchronized void stop() 
    {
        if(myEventGeneratorTimer != null) 
        {
            myEventGeneratorTimer.cancel();     
            myEventGeneratorTimer = null;
        }
    }

    private class ServerMessageGeneratorTimerTask extends TimerTask
    {   	
    	JobItem jobItem;
     	
    	public ServerMessageGeneratorTimerTask(JobItem item)
    	{
    		this.jobItem = item;
		}

		public void run() 
		{			
			System.out.println("***** Timer In run " + new Date() + " " + myEventGeneratorTimer);
			String rootPathForDownload = getServletContext().getRealPath(File.separator);
    		GetJobDetailsImpl jobDetails = new GetJobDetailsImpl();
    		jobItem = jobDetails.getDetails(jobItem, 2, rootPathForDownload);
    		String status = jobItem.getStatus();
    		if(status.equalsIgnoreCase("Done") || status.equalsIgnoreCase("Failed"))
    		{
    			myEventGeneratorTimer.cancel();
    		}
    		Event theEvent = new ServerGeneratedMessageEvent(jobItem);
            //add the event, so clients can receive it
            addEvent(ServerGeneratedMessageEvent.SERVER_MESSAGE_DOMAIN, theEvent);
        }
    }
}