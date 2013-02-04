/**
 * 
 */
package com.wcrl.web.cml.server;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import com.allen_sauer.gwt.log.client.Log;

/**
 * @author Aruna Sri Bommagani
 *
 */
public class FileOperations 
{
	/*
	 * inputFile: Input file path
	 * outputFile: Output file path
	 */
	public void copyFile(String inputFile, String outputFile)
	{
		if(new File(inputFile).exists())
		{
			try
			{
				InputStream in = new FileInputStream(inputFile);
				OutputStream out = new FileOutputStream(outputFile);
				// Transfer bytes from in to out
				byte[] buf = new byte[1024];
				int length;
				while ((length = in.read(buf)) > 0)
				{
					out.write(buf, 0, length);
				}
				in.close();
				out.close();
				System.out.println(inputFile + " file copied to " + outputFile);
				Log.info(inputFile + " file copied.");
			}
			catch(IOException e) 
			{
				e.printStackTrace();
			}
		}		
	}
	
	public void removeFile(File file)
	{		
		if(file.exists())
		{
			System.out.println("Removing file: " + file.getPath());
			Log.info("Removing file: " + file.getPath());
			boolean success = file.delete();
			if (!success)
			{
				System.out.println("File not deleted");
			}
		}		
	}
}