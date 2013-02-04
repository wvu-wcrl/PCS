/*
 * File: DBConnectionConstants.java

Purpose: Java class to get the Database parameter values.
**********************************************************/
package com.wcrl.web.cml.server;

import com.google.gwt.i18n.client.Constants;

public interface DBConnectionConstants extends Constants
{	
	String url();
	String servername();
	String databasename();
	String username();
	String password();
	String driverclassname();
	String portnumber();
}
