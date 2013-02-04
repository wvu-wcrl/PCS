package com.wcrl.web.cml.server;

import java.io.File;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;
import com.allen_sauer.gwt.log.client.Log;

 public class UploadDataFileServlet extends HttpServlet {
      
	 private static final long serialVersionUID = -1660370413961174966L;
	 /*private Map<String, String> fileDetailsMap = new HashMap<String, String>();
	 private ArrayList<String> allowedFormats = new ArrayList<String>();
	 private String login;
	 private String project;
	 private String overwrite;*/
	 private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	 	 	 
	 public UploadDataFileServlet()
	 {
		 super();
	 }
   
     @SuppressWarnings("unchecked")
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {   		 
    	 HttpSession session = request.getSession();
    	 Map<String, String> fileDetailsMap = new HashMap<String, String>();
    	 ArrayList<String> allowedFormats = new ArrayList<String>();
    	 String login;
    	 String project;
    	 String overwrite;
    	 
    	 if (session.getAttribute("Username") != null)
    	 {
             
        	 response.setContentType("text/html");
        	 String path = constants.getString("path");           	 
        	
        	 // process only multipart requests
             if (ServletFileUpload.isMultipartContent(request)) 
             {            
                 FileItemFactory factory = new DiskFileItemFactory();
                 ServletFileUpload upload = new ServletFileUpload(factory);
                 
                 try 
                 {
                	 List<FileItem> items = upload.parseRequest(request);
                                    
                     for (FileItem item : items) 
                     { 
                    	 if (item.isFormField()) 
                         {
                    		 fileDetailsMap.put(item.getFieldName(), item.getString());                   	 
                         }
                     }
                     project = fileDetailsMap.get("projectName");
                     login = fileDetailsMap.get("user");
                     overwrite = fileDetailsMap.get("overwrite");
                     
                     allowedFormats = getDataFileExtensionsForProject(project);
                     
                     //System.out.println(" Items size:" + items.size() + " Login: " + login + " Project: " + project);
                     boolean fileFlag = true;  
                     String[] files = new String[2];
                     ArrayList<FileItem> fileItems = new ArrayList<FileItem>();
                    
                     int idx = 0;
                     for (FileItem item : items) 
                     {
                         // process only file upload - discard other form item types                	           	  
                         if (item.isFormField()) 
                         {                    	 
                        	 continue;
                         }      	                    
                                             
                         String fileName = item.getName();
                         files[idx] = fileName;
                         idx++;
                         fileItems.add(item);
                         
                         // get only the file name not whole path
                         if (fileName != null) 
                         {
                        	 fileName = FilenameUtils.getName(fileName);

                        	 Iterator<String> itr = allowedFormats.iterator();
                        	 boolean validFileExtension = false;
                        	 while(itr.hasNext())
                        	 {
                        		 String fileExtension = itr.next().toString();
                        		 if(fileName.endsWith(fileExtension))
                        		 {
    								 validFileExtension = true;								 
                        		 }
                        	 }
                        	 if(validFileExtension)
                    		 {
                    			//Creating file path to save the file                             
                                 fileFlag = true && fileFlag;
                    		 }
                    		 else
                    		 {
                    			 fileFlag = false;
                    			 String validFileTypes = "";
                    			 String msg = "2~Not a valid file format.";
                    			 int count = allowedFormats.size();
                    			 if(count > 0)
                    			 {
                    				 for(int i = 0; i < count; i++)
                    				 {
                    					 validFileTypes = validFileTypes + allowedFormats.get(i);
                    					 if(i == (count - 1))
                    					 {
                    						 validFileTypes = validFileTypes + "\"" + ".";
                    					 }
                    					 else
                    					 {
                    						 validFileTypes = validFileTypes + ", ";
                    					 }
                    				 }
                    				 msg = msg + " Please upload a file of following file types \"" + validFileTypes;
                    			 }                    			 
                    			 response.getWriter().print(msg);
                    		 }                        	
                         }                                         
                     }
                     if(fileFlag)
                     {
                    	 createNewFile(path, files[0], fileItems.get(0), login, project, overwrite, response);             	                 	 
                     }                 
                 } 
                 catch (Exception e) 
                 {
                     response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while creating the file : " + e.getMessage());
                 }           
             } 
             else 
             {
                 response.sendError(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE, "Request contents type is not supported by the servlet.");
             }  
    	 }       
     }    
        
     private void createNewFile(String dir, String fileName, FileItem item, String login, String project, String overwrite, HttpServletResponse response)
     {
    	 String currentDir = dir;     
    	 File checkDir = new File(currentDir);             
         boolean success1 = false;
     
         if(!checkDir.exists())
         {
        	 success1 = checkDir.mkdirs();
         }
         else
         {
        	 success1 = true;
         }         
         Log.info("~~~Creating directory structure to place file: " + checkDir + " success: " +  success1);
         System.out.println("~~~Creating directory structure to place file: " + checkDir + " success: " +  success1 + " dir: " + dir);
         /*if(success1)
         {
        	 checkDir.setWritable(true, false);
         }*/
    	 dir = dir + login + File.separator + constants.getString("projects") + File.separator + project + File.separator + constants.getString("Data");
         checkDir = new File(dir);             
         boolean success = false;
  
         if(!checkDir.exists())
         {
        	 success = checkDir.mkdirs();
         }
         else
         {
        	 success = true;
         }         
         Log.info("***Creating directory structure to place file: " + checkDir + " success: " +  success);
         System.out.println("***Creating directory structure to place file: " + checkDir + " success: " +  success);
         if(success)
         {
        	 System.out.println("______________________________________________________");
        	 //checkDir.setWritable(true, false);
             System.setProperty("user.dir", dir);
         
        	 File uploadedFile = new File(dir, fileName);
        	 boolean fileExists = false;

        	 String filePath = dir + File.separator + fileName;
    		 System.out.println("Checking file: " + filePath);
    		 Log.info("Checking file: " + filePath);
    		 File file = new File(filePath);
    		 if(file.exists())
    		 {
    			 fileExists = true;
    		 }   		 
    		 
        	 System.out.println("Checking fileExists: " + fileExists);
        	 Log.info("Checking fileExists: " + fileExists);
        	 
        	 try
        	 {
        		 if(fileExists)
            	 {
            		 if(!overwrite.equals("1"))
                	 {
            			 String msg = 0 + "~A data file with the name already exists in the repository. Do you want to overwrite?";
            			 response.getWriter().print(msg);
                	 }
                	 else
                	 {
                		 File removeFile = new File(filePath);
                		 removeFile.delete();        
                		 createFile(uploadedFile, item, response);  
                	 }            		 
            	 }
            	 else
            	 {
            		 createFile(uploadedFile, item, response);            		 
            	 }
        	 }
        	 catch (IOException e) 
             {		
            	 System.out.println(e.getClass().getName() + ": " + e.getMessage());
    			 Log.info(e.getClass().getName() + ": " + e.getMessage());
    			 StackTraceElement[] trace = e.getStackTrace();			
    			 for(int i = 0; i < trace.length; i++)
    			 {
    				 System.out.println("\t" + trace[i].toString());
    				 Log.info("\n\t" + trace[i].toString());
    			 }
    			 e.printStackTrace();
     		 }        	            
         }         
     }  
     
     public void createFile(File uploadedFile, FileItem item, HttpServletResponse response)
     {
    	 try
    	 {
    		 if (uploadedFile.createNewFile()) 
			 {
			     item.write(uploadedFile);
			     response.setStatus(HttpServletResponse.SC_CREATED);			     
			     response.flushBuffer();
			     String msg = 1 + "~Job created and queued for execution.";
					 
			     Log.info("Message: " + msg + " Absolute path: " + uploadedFile.getAbsolutePath() + " Path: " + uploadedFile.getPath());
			     /*Log.info("Absolute path: " + uploadedFile.getAbsolutePath() + " Path: " + uploadedFile.getPath());
			     //Associate the  directory and its contents if the Operating system is Linux/Unix
			     if(File.separator.equals("/"))
			     {
			    	 Runtime rt = Runtime.getRuntime();
			    	 
			    	 String path = uploadedFile.getPath();
			    	 String temp = "chown tomcat55:tomcatusers " + path;
			    	 System.out.println("command line cmd: " + temp);
			    	 Log.info("command line cmd: " + temp);
			    	 Process proc = rt.exec(temp);
			    	 Log.info("Process inputStream: " + proc.getInputStream().toString());
			    	 Log.info("Process outputStream: " + proc.getOutputStream());
			    	 Log.info("Process errorStream: " + proc.getErrorStream());
			    	 int exitVal = proc.waitFor();
			    	 Log.info("Ownership process exitValue: " + exitVal);
			    	 temp = "chmod 664 " + path;
			    	 System.out.println("command line cmd: " + temp);
			    	 proc = rt.exec(temp);
			    	 exitVal = proc.waitFor();
			    	 System.out.println("Process exitValue: " + exitVal);        			    	 
    	             Log.info("Permissions process exitValue: " + exitVal);
			     }*/    
			     response.getWriter().print(msg);
			 }
			 else
			 {
				//Code Added
				 String msg = 2 + "~Error in adding job. Please try again later.";
				 response.getWriter().print(msg);
			     //throw new IOException(msg);                        
			 }    		 
    	 }
    	 catch (InterruptedException e)
		 {
	    	 System.out.println(e.getClass().getName() + ": " + e.getMessage());
			 Log.info(e.getClass().getName() + ": " + e.getMessage());
			 StackTraceElement[] trace = e.getStackTrace();			
			 for(int i = 0; i < trace.length; i++)
			 {
				 System.out.println("\t" + trace[i].toString());
				 Log.info("\n\t" + trace[i].toString());
			 }
			 e.printStackTrace();
		 }
         catch (IOException e) 
         {		
        	 System.out.println(e.getClass().getName() + ": " + e.getMessage());
			 Log.info(e.getClass().getName() + ": " + e.getMessage());
			 StackTraceElement[] trace = e.getStackTrace();			
			 for(int i = 0; i < trace.length; i++)
			 {
				 System.out.println("\t" + trace[i].toString());
				 Log.info("\n\t" + trace[i].toString());
			 }
			 e.printStackTrace();
 		 } 
 		 catch (Exception e) 
 		 {			
 			System.out.println(e.getClass().getName() + ": " + e.getMessage());
 			Log.info(e.getClass().getName() + ": " + e.getMessage());
 			StackTraceElement[] trace = e.getStackTrace();			
 			for(int i = 0; i < trace.length; i++)
 			{
 				System.out.println("\t" + trace[i].toString());
 				Log.info("\n\t" + trace[i].toString());
 			}
 			e.printStackTrace();
 		 }
     }
     
     public ArrayList<String> getDataFileExtensionsForProject(String project)
     {
    	 ArrayList<String> allowedFormats = new ArrayList<String>();
    	 DBConnection connection = new DBConnection();
    	 ResultSet rs = null;
    	 
    	 try
    	 {
    		 connection.openConnection();
    		 CallableStatement cs = connection.getConnection().prepareCall("{ call GetDataFileExtensions(?) }");
    		 cs.setString(1, project);
    		 boolean hasResults = cs.execute();
    		 
    		 if(hasResults)
    		 {
    			 rs = cs.getResultSet();
    			 allowedFormats.clear();
    			 while(rs.next())
    			 {
    				 String fileType = rs.getString("FileExtension");
    				 allowedFormats.add(fileType);
    				 System.out.println("Allowed file types: " + fileType);
    			 }
    		 }
    		 rs.close();
    	 }
    	 catch(SQLException e)
    	 {
    		 e.printStackTrace();
    	 }
    	 finally
    	 {
    		 try
    		 {
    			 if(rs != null && !rs.isClosed())
    			 {
    				 rs.close();
    			 }
    			 if(connection.getConnection() != null)
    			 {
    				 connection.closeConnection();
    			 }
    		 }
    		 catch (SQLException e)
    		 {
    			 e.printStackTrace();
    		 }
    	 }
		return allowedFormats;
     }
}