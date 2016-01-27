package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ResourceBundle;
import java.util.Timer;
import java.util.TimerTask;

import com.wcrl.web.cml.client.jobService.ServerMessageGeneratorService;
import com.wcrl.web.cml.client.jobs.JobItem;
import com.wcrl.web.cml.client.jobs.ServerGeneratedMessageEvent;

import de.novanic.eventservice.client.event.Event;
import de.novanic.eventservice.service.RemoteEventServiceServlet;

public class ServerMessageGeneratorImpl extends RemoteEventServiceServlet implements ServerMessageGeneratorService
{
	private static final long serialVersionUID = 1L;
	private Timer myEventGeneratorTimer;
	private long updateDuration = 1000 * 60;
	private String rootPathForDownload;
    
	public synchronized void start(JobItem item)
    {
		rootPathForDownload = getServletContext().getRealPath(File.separator);
		ResourceBundle constants = ResourceBundle.getBundle("UpdateFrequency");
		String duration = constants.getString("jobUpdateDuration");
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
        if(myEventGeneratorTimer == null) 
        {
            myEventGeneratorTimer = new Timer();            
            myEventGeneratorTimer.schedule(new ServerMessageGeneratorTimerTask(item), 0, updateDuration);
        }
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
    		GetJobDetails jobDetails = new GetJobDetails();
    		jobItem = jobDetails.getDetails(jobItem, 2, rootPathForDownload);
    		//jobItem = jobDetails.getJobDetails(jobItem, 2);
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