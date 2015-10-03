package com.googlecode.mgwt.examples.showcase.server.enroll;

import java.io.File;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.ResourceBundle;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import com.allen_sauer.gwt.log.client.Log;
import com.googlecode.mgwt.examples.showcase.server.db.BCrypt;
import com.googlecode.mgwt.examples.showcase.server.db.DBConnection;
import com.googlecode.mgwt.examples.showcase.server.elements.AddUserImpl;
import com.googlecode.mgwt.examples.showcase.server.job.MasterKeyImpl;
import com.jmatio.io.MatFileWriter;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLStructure;



public class EnrollmentServlet_Oct252013_BeforeCallingMatlabSciptsToAvoidSavingKey extends HttpServlet {

  private static final long serialVersionUID = 1L;
  protected static final String SESSION_FILES = "FILES";

  
  private Hashtable<String, String> receivedContentTypes = new Hashtable<String, String>();
  /**
   * Maintain a list with received files and their content types. 
   */
  private Hashtable<String, File> receivedFiles = new Hashtable<String, File>();
  private ResourceBundle constants = ResourceBundle.getBundle("Paths");
  private String dataPath = constants.getString("datapath");
  private HashMap<String, String> formItems = new HashMap<String, String>();


  /**
   * To save the received files in a custom place
   * and delete this items from session.  
   */
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	  
	String srvresponse = "";  
	String taskType = "";
	String passwordHash = "";
       
	System.out.println("In UploadServlet");
    if (ServletFileUpload.isMultipartContent(request)) 
    {            
        FileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        
		try {
			@SuppressWarnings("unchecked")
			List<FileItem> items = upload.parseRequest(request);
			for (FileItem item : items) 
	        {
	        	if (item.isFormField()) 
	        	{
	        		formItems.put(item.getFieldName(), item.getString());
	        		System.out.println("Item: " + item.getFieldName() + " Value: " + item.getString());
	        	}
	        	/* If enrolling for verification, create subject home directory and project directories */
	        	if(formItems.get("task") != null)
	        	{
	        		if(formItems.get("task").equals("verification"))
	        		{
	        			String username = formItems.get("username");
	        			String project = constants.getString("Project");
	        			int exitVal = createUserHomeDirectory(username);
	        			//if(exitVal == 1)
	        			//{
	        				AddUserImpl addUser = new AddUserImpl();
	        				int userId = addUser.checkUserAvailability(username);
	        				if(userId <= 0)
	        				{
	        					passwordHash = addUser.addUser(username, formItems.get("email"), "User");
	        					//System.out.println("Password: " + password);
	        					createProjectDirectories(username, project);
	        				}
	        			//}
	        		}
	        	}
        		
	        }
			taskType = formItems.get("task");
	    	System.out.println("# Items: " + items.size());
	    	Log.info("EnrollmentServlet # Items: " + items.size());
	    	
	        for (FileItem item : items) 
	        {
	        	if (item.isFormField()) 
	        	{
	        		continue;
	        	}
	        	else
	        	{        	
	        		String userPath = dataPath + constants.getString("datadir") + File.separator + formItems.get("username");
	        		System.out.println("EnrollmentServlet subjectPath: " + userPath);
	        		Log.info("EnrollmentServlet subjectPath: " + userPath);
	        		try {
	        			
	        			File userDataPath = new File(userPath);
	        			if(!userDataPath.exists())
	        			{
	        				userDataPath.mkdirs();
	        			}
	        			
	        	          File file = new File(userPath, item.getName());
	        	          System.out.println("EnrollmentServlet Writing " + file.getName());
	        	          Log.info("EnrollmentServlet Writing " + file.getName());
	        	          
	        	          item.write(file);
	        	          
	        	          /// Save a list with the received files
	        	          receivedFiles.put(item.getFieldName(), file);
	        	          receivedContentTypes.put(item.getFieldName(), item.getContentType());
	        	          
	        	          /// Send a customized message to the client.
	        	          srvresponse += "File saved as " + file.getAbsolutePath();
	        	          response.getWriter().print(srvresponse);
	        	        } 
	        	        catch (Exception e) 
	        	        {
	        	        	Log.info("EnrollmentServlet: " + e.getClass().getName() + ": " + e.getMessage());
	        				StackTraceElement[] trace = e.getStackTrace();			
	        				for(int i = 0; i < trace.length; i++)
	        				{
	        					System.out.println("\t" + trace[i].toString());
	        					Log.info("\n\t " + trace[i].toString());
	        				}
	        				e.printStackTrace();
	        	        }      
	        	}     	
	        }
	        String jobDir = "";
	        if(formItems.get("task").equals("identification"))
    		{
	        	MasterKeyImpl keyImpl = new MasterKeyImpl();
	        	passwordHash = keyImpl.getHashKey();
	        	jobDir = constants.getString("path") + formItems.get("admin") + File.separator + constants.getString("projects") + File.separator + formItems.get("project") + File.separator + constants.getString("JobIn");
    		}
	        else
	        {
	        	jobDir = constants.getString("path") + formItems.get("username") + File.separator + constants.getString("projects") + File.separator + formItems.get("project") + File.separator + constants.getString("JobIn");
	        }
	        
	        // Generate subject templates job file for verification
	        
	        SimpleDateFormat sdf = new SimpleDateFormat("ddMMyyyy-hhmmss");
	        String jobFileName = String.format(sdf.format( new Date() )) +  "_" + "Model" + ".mat";
            File jobFile  = new File(jobDir, jobFileName);
            boolean fileGenerated = generateVerificationModelJobFile(jobFile, passwordHash);
		} 
		catch (FileUploadException e) {			
			e.printStackTrace();
		}        
    }   
    /// Remove files from session because we have a copy of them
    removeSessionFileItems(request);  
  }
  
  private void removeSessionFileItems(HttpServletRequest request) {
	  @SuppressWarnings("unchecked")
	List<FileItem> sessionFiles = (List<FileItem>) request.getSession().getAttribute(SESSION_FILES);

	    if (sessionFiles != null) {
	      for (FileItem fileItem : sessionFiles) {
	        if (fileItem != null && !fileItem.isFormField()) {
	          fileItem.delete();
	        }
	      }
	    }
	    request.getSession().removeAttribute(SESSION_FILES);
  }
  
  public int createUserHomeDirectory(String username) {
		 ResourceBundle scriptsPathConstants = ResourceBundle.getBundle("Scripts");
		 String path = scriptsPathConstants.getString("create_user_path").trim() + File.separator + scriptsPathConstants.getString("create_web_user").trim();
		 System.out.println("User creation path: " + path);	   
		 int exitValue = -1;
	     try 
	     {
	    	 ProcessBuilder processBuilder = new ProcessBuilder();
	    	 processBuilder.command(path, username);
	    	 Process proc = processBuilder.start();	    
	    	 exitValue = proc.waitFor();    
	    	 System.out.println("CreateUserDirectories after executing user creation script: " + path + " exitValue: " + exitValue);
	    	 System.out.println("CreateUserDirectories after executing user creation script parameters: " + username);
	     }	    
		 catch (Exception e)
		 {
			 System.out.println(e.getClass().getName() + ": " + e.getMessage());
			 //Log.info(e.getClass().getName() + ": " + e.getMessage());
			 StackTraceElement[] trace = e.getStackTrace();			
			 for(int i = 0; i < trace.length; i++)
			 {
				 System.out.println("\t" + trace[i].toString());
				 //Log.info("\n\t" + trace[i].toString());
			 }
			 e.printStackTrace();
		 }
		return exitValue;		
	}
  
  public void createProjectDirectories(String username, String project) {
		 ResourceBundle scriptsPathConstants = ResourceBundle.getBundle("Scripts");
		 ResourceBundle pathConstants = ResourceBundle.getBundle("Paths");
		 String usersRootPath = pathConstants.getString("path");
		 
		 //File wd = new File(scriptsPathConstants.getString("project"));
		 String path = scriptsPathConstants.getString("project").trim() + File.separator + scriptsPathConstants.getString("create_proj").trim();
		 System.out.println("Working Directory of project script: " + path);
		 Log.info("Project creation script: " + path);	     
	   
	     try 
	     {
	    	 String homeDir = usersRootPath + username;
	    	 ProcessBuilder processBuilder = new ProcessBuilder();
	    	 processBuilder.command(path, homeDir, username, project);	 
	    	 Process proc = processBuilder.start();
	    	 int exitValue = proc.waitFor();    	 
	    	 Log.info("CreateProjectDirectories after executing project creation script: " + path + " exitValue: " + exitValue);
	    	 Log.info("CreateProjectDirectories after executing project creation script parameters: " + homeDir + ", " + username + ", " + project);
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
 
  public boolean resetAndEmail(int userId, String username, String primaryEmail)
  {
		String password = "*****";
		boolean flag = false;
  	
		DBConnection connection = new DBConnection();
		CallableStatement cs = null;
		
		try
		{    		
			connection.openConnection();
			ResetPassword resetPassword = new ResetPassword();
			password = resetPassword.generateRandomPassword();
  		
			String pw_hash = BCrypt.hashpw(password, BCrypt.gensalt(12)); 
  		
			cs = connection.getConnection().prepareCall("{ call EditPassword(?, ?) }");
			cs.setInt(1, userId);
			cs.setString(2, pw_hash);    	    
			cs.execute();
			flag = true;
			cs.close();
			connection.closeConnection();			
		}
		catch(SQLException e)
		{
			e.printStackTrace();
		}   
  	
		String content = getEmailContent(username, password);
		/*@SuppressWarnings("unused")
  		SendEmail email = new SendEmail(primaryEmail, content, "welcomesubject");*/
		SendEmail email = new SendEmail();
		email.callSendEmailScript(primaryEmail, content, "welcomesubject");
		return flag;
  }
  
  private String getEmailContent(String username, String password) 
  {
	  ResourceBundle constants = ResourceBundle.getBundle("EmailContent"); 
	  String str = constants.getString("msg1") + "\\n\\n";
	  str = str + constants.getString("msg2") + "\\n";
	  str = str + constants.getString("msg3") + "\\n\\n";
	  str = str + constants.getString("msg4") + "\\n";
	  str = str + "Username: " + username + "\\n";
	  str = str + "Password: " + password + "\\n\\n";
	  str = str + constants.getString("msg5") + "\\n\\n";
	  str = str + constants.getString("msg6") + "\\n\\n";
	  str = str + constants.getString("msg7");		
	  return str;
  }
  
  private boolean generateVerificationModelJobFile(File jobFile, String passwordHash)
  {
 	 System.out.println("In generateJobFile");
 	 boolean fileGenerated = false;
 	 try 
 	 {
 		 int[] dims = {1, 1};
			 
		 MLStructure mlParamStructure = new MLStructure("JobParam", dims);
		 MLStructure mlStateStructure = new MLStructure("JobState", dims);

		 String galleryPath = constants.getString("datapath") + constants.getString("datadir") + File.separator + formItems.get("username") + File.separator;
		 String saveModelPath = constants.getString("identificationModelPath"); 
		 String modelTask = "Identification";
 		 if(formItems.get("task").equals("verification"))
 		 {
 			 modelTask = "Verification";
 			 saveModelPath = constants.getString("path") + formItems.get("username") + File.separator + constants.getString("projects") + File.separator + formItems.get("project")  + File.separator + constants.getString("Data") + File.separator;
 			 MLChar modelPath = new MLChar("ModelPath", saveModelPath);
 			 mlParamStructure.setField("ModelPath", modelPath);
 		 }   
 		 String taskName = "Model";
 		 MLChar modelTaskValue = new MLChar("ModelTask", modelTask);
		 MLChar dataPath = new MLChar("DataPath", galleryPath);
		 MLChar key = new MLChar("Key", passwordHash);
		 MLChar taskTypeName = new MLChar("TaskType", taskName);
		 
		 mlParamStructure.setField("ModelTask", modelTaskValue);
		 mlParamStructure.setField("DataPath", dataPath);
		 mlParamStructure.setField("Key", key);  
		 mlParamStructure.setField("TaskType", taskTypeName);
 		 
 		 MatFileWriter fileWriter = new MatFileWriter();
 		 ArrayList<MLArray> list = new ArrayList<MLArray>();
 		 list.add(mlParamStructure);
 		 list.add(mlStateStructure);
			
		fileWriter.write(jobFile.getPath(), list);
		/*
		 * 1. Store job file to a temporary location, pass JobParam (without key) and JobState, and HashedKey separately
		 * 2. Run Matlab script to get RandomProjection
		 * 3. Save to file and move it to user JobIn directory
		 */
		
		fileGenerated = true;
 	 } 
 	 catch (IOException e) 
 	 {
 		 fileGenerated = false;
 		 e.printStackTrace();
 	 }
 	 return fileGenerated;		    	 
  }


}
