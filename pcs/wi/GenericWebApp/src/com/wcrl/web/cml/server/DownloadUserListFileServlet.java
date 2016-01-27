package com.wcrl.web.cml.server;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class DownloadUserListFileServlet extends HttpServlet
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public DownloadUserListFileServlet()
	{
		super();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		String path  = getServletContext().getRealPath(File.separator);
		String fileName  = path + "Users.xls";
		File tempFile = new File(fileName);
		
		response.setHeader("Content-Length", String.valueOf(tempFile.length()));
		response.setHeader("Content-Disposition", "attachment; filename=\"" + tempFile.getName() + "\"");

		InputStream input = new BufferedInputStream(new FileInputStream(tempFile), 1024 * 10);
		OutputStream output = new BufferedOutputStream(response.getOutputStream(), 1024 * 10);

		byte[] buffer = new byte[1024 * 10];
		int length;
		while ((length = input.read(buffer)) > 0) 
		{
		    output.write(buffer, 0, length);
		}

		output.flush();
		output.close();
		input.close();
		tempFile.delete();
	}   	    
}