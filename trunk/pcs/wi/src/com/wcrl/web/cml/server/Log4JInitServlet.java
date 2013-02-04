package com.wcrl.web.cml.server;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;


public class Log4JInitServlet extends HttpServlet 
{
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger(Log4JInitServlet.class);
	 
	  public Logger getLogger() 
	  {
		return logger;
	  }

	public void init() throws ServletException 
	{
	    System.out.println("Log4JInitServlet init() starting.");
	    String log4jfile = getInitParameter("log4j-properties");
	    if (log4jfile != null) 
	    {
	      String propertiesFilename = getServletContext().getRealPath(log4jfile);
	      PropertyConfigurator.configure(propertiesFilename);
	      logger.info("logger configured.");	      
	    }
	    else
	    {
	      System.out.println("Error setting up logger.");
	      logger.debug("Error setting up logger.");
	      
	    }	      
	  }
	}