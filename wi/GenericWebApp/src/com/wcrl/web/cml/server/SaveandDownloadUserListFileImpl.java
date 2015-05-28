package com.wcrl.web.cml.server;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.account.User;
import com.wcrl.web.cml.client.admin.accountService.SaveandDownloadUserListFileService;

public class SaveandDownloadUserListFileImpl extends RemoteServiceServlet implements SaveandDownloadUserListFileService
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
			
	public boolean saveandDownloadUserListFile(ArrayList<User> users) 
	{
		int count = users.size();
		HSSFWorkbook workbook = new HSSFWorkbook();
		HSSFSheet sheet1 = workbook.createSheet("Sheet1");
		if(count > 0)
		{			
			HSSFRow rowhead = sheet1.createRow((short)0);
			rowhead.createCell(0).setCellValue("#");
			rowhead.createCell(1).setCellValue("Username");
			rowhead.createCell(2).setCellValue("First name");
			rowhead.createCell(3).setCellValue("Last name");
			rowhead.createCell(4).setCellValue("Email");
			rowhead.createCell(5).setCellValue("Status");
		}
		for(int i = 0; i < count; i++)
		{
			User user = users.get(i);
			System.out.println("User: " + user.getUsername());
			int colNum = i+1;
			Row row = sheet1.createRow(colNum);
			Cell c1 = row.createCell(0);
			c1.setCellValue(colNum);
			Cell c2 = row.createCell(1);
			c2.setCellValue(user.getUsername());
			Cell c3 = row.createCell(2);
			c3.setCellValue(user.getFirstName());
			Cell c4 = row.createCell(3);
			c4.setCellValue(user.getLastName());
			Cell c5 = row.createCell(4);
			c5.setCellValue(user.getPrimaryemail());
			Cell c6 = row.createCell(5);
			int status = user.getStatus();
			String statusValue = "";
			if(status == 1)
			{
				statusValue = "Enabled";
			}
			else if(status == 0)
			{
				statusValue = "Not approved";
			}
			if(status == 2)
			{
				statusValue = "Disabled";
			}
			c6.setCellValue(statusValue);
		}
		boolean value = false;
		try 
		{
			String path  = getServletContext().getRealPath(File.separator);
			String fileName  = path + "Users.xls";
			File tempFile = new File(fileName);
		    FileOutputStream out = new FileOutputStream(tempFile);
		    workbook.write(out);
		    out.close();
		    value = true;
		    System.out.println("Userlist excel file written successfully..");
		    Log.info("Userlist excel file written successfully..");
		     
		} 
		catch (FileNotFoundException e) 
		{
		    e.printStackTrace();
		} 
		catch (IOException e) 
		{
		    e.printStackTrace();
		}
		return value;
    }     	    
}