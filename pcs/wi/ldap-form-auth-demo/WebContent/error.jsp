<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>


           <p>
                      Username and/or password not recognized.  Please try again.
                   </p>

                    <form method="POST" action='<%= response.encodeURL("j_security_check") %>' >
                <table cellpadding="2" border="0" cellspacing="0">
        	<tr>
                      <td align="right">Username:</td>
                            <td align="left"><input type="text" name="j_username" size="9"></td>
                                </tr>
                            <tr>
                          <td align="right">Password:</td>
                <td align="left"><input type="password" name="j_password" size="9"></td>
                                            </tr>
                                                 	<tr>
      <td align="right"><input type="submit" value="Log In"></td>
     <td align="left"><input type="reset"></td>
      </tr>
     </table>
     </form>


</body>
</html>