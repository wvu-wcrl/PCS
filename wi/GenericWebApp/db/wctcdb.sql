CREATE DATABASE  IF NOT EXISTS `wctcdb` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `wctcdb`;
-- MySQL dump 10.13  Distrib 5.5.16, for Win32 (x86)
--
-- Host: localhost    Database: wctcdb
-- ------------------------------------------------------
-- Server version	5.5.11

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `userreg`
--

DROP TABLE IF EXISTS `userreg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userreg` (
  `UserId` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique Identifier',
  `UserName` varchar(150) NOT NULL COMMENT 'Name of the User - Login',
  `Password` varchar(255) NOT NULL COMMENT 'Min - 8 chars, Max - 32',
  `Usertype` varchar(32) NOT NULL DEFAULT 'USER' COMMENT 'Min - 8 chars, Max - 32',
  `FirstName` varchar(150) DEFAULT NULL COMMENT 'FirstName of the User',
  `LastName` varchar(150) DEFAULT NULL COMMENT 'LastName of the User',
  `PrimaryEmail` varchar(150) NOT NULL,
  `Country` varchar(255) NOT NULL,
  `Organization` varchar(255) NOT NULL,
  `JobTitle` varchar(255) NOT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `UpdatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `TotalUnits` double DEFAULT '6000',
  `RequestedUnits` double DEFAULT '0',
  `GrantedUnits` double DEFAULT '0',
  `RemainingUnits` double DEFAULT '100',
  `Status` int(11) NOT NULL DEFAULT '1',
  `LastLogin` timestamp NULL DEFAULT '0000-00-00 00:00:00',
  `Newsletter` int(11) DEFAULT '1',
  PRIMARY KEY (`UserId`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1 COMMENT='User preference table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `projectdatafileextension`
--

DROP TABLE IF EXISTS `projectdatafileextension`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projectdatafileextension` (
  `ProjectId` int(10) unsigned NOT NULL,
  `FileExtensionId` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ProjectId`,`FileExtensionId`),
  KEY `projectdatafileextension_fk_1` (`ProjectId`),
  KEY `projectdatafileextension_fk_2` (`FileExtensionId`),
  CONSTRAINT `projectdatafileextension_fk_1` FOREIGN KEY (`ProjectId`) REFERENCES `projects` (`ProjectId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `projectdatafileextension_fk_2` FOREIGN KEY (`FileExtensionId`) REFERENCES `fileextension` (`FileExtensionId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projects` (
  `ProjectId` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique Job Identifier',
  `ProjectName` varchar(255) NOT NULL,
  `CreatedOn` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Description` varchar(255) DEFAULT '',
  `UpdatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `LastModified` bigint(20) unsigned DEFAULT NULL,
  `DataFile` int(11) DEFAULT '0',
  `Path` varchar(255) DEFAULT '',
  PRIMARY KEY (`ProjectId`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fileextension`
--

DROP TABLE IF EXISTS `fileextension`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fileextension` (
  `FileExtensionId` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique Identifier',
  `FileExtension` varchar(10) DEFAULT NULL COMMENT 'Ex: ''.jpeg'', ''.mat''',
  `Description` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`FileExtensionId`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COMMENT='File extensions valid for the input data files.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobfileextensiontypes`
--

DROP TABLE IF EXISTS `jobfileextensiontypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobfileextensiontypes` (
  `JobFileExtensionTypeId` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique Identifier',
  `FileExtension` varchar(10) DEFAULT NULL COMMENT 'Ex: ''.jpeg'', ''.mat''',
  `Description` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`JobFileExtensionTypeId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='File extensions valid for the input files of the Jobs.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `projectjobfileextension`
--

DROP TABLE IF EXISTS `projectjobfileextension`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projectjobfileextension` (
  `ProjectId` int(10) unsigned NOT NULL,
  `FileExtensionId` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ProjectId`,`FileExtensionId`),
  KEY `projectjobfileextension_fk_1` (`ProjectId`),
  KEY `projectjobfileextension_fk_2` (`FileExtensionId`),
  CONSTRAINT `projectjobfileextension_fk_1` FOREIGN KEY (`ProjectId`) REFERENCES `projects` (`ProjectId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `projectjobfileextension_fk_2` FOREIGN KEY (`FileExtensionId`) REFERENCES `fileextension` (`FileExtensionId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `userprojects`
--

DROP TABLE IF EXISTS `userprojects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userprojects` (
  `ProjectId` int(10) unsigned NOT NULL,
  `UserId` bigint(20) unsigned NOT NULL,
  `CreatedOn` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `PreferredProject` int(11) DEFAULT NULL,
  `UsedUnits` double DEFAULT '0',
  PRIMARY KEY (`ProjectId`,`UserId`),
  KEY `userprojects_fk_1` (`UserId`),
  CONSTRAINT `userprojects_fk_1` FOREIGN KEY (`UserId`) REFERENCES `userreg` (`UserId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `userprojects_fk_2` FOREIGN KEY (`ProjectId`) REFERENCES `projects` (`ProjectId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'wctcdb'
--
/*!50003 DROP PROCEDURE IF EXISTS `ADDPROJECT` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `ADDPROJECT`(IN PROJECTNAME VARCHAR(255), IN DESCRIPTION VARCHAR(255), 
                                                        IN PATH VARCHAR(255),
                                                        IN DATAFILE INT(11),
                                                        OUT FLAG INT)
BEGIN
  DECLARE CNT INT;
  DECLARE PROJECTID INT;
  DECLARE FILEEXTENSIONID INT;
  SET CNT = 0;
  SET FLAG = -1;
  SET PROJECTID = 0;
  SET FILEEXTENSIONID =0;

  SELECT COUNT(PROJECTS.PROJECTID) INTO CNT
  FROM PROJECTS
  WHERE PROJECTS.PROJECTNAME = PROJECTNAME;

  IF (CNT = 0) THEN
    INSERT INTO PROJECTS(PROJECTNAME, DESCRIPTION, PATH, DATAFILE, CREATEDON, UPDATEDAT) VALUES(PROJECTNAME, DESCRIPTION, PATH, DATAFILE, NULL, NULL);
    
    SELECT PROJECTS.PROJECTID INTO PROJECTID
    FROM PROJECTS
    WHERE PROJECTS.PROJECTNAME = PROJECTNAME;
    
    SELECT FILEEXTENSION.FILEEXTENSIONID INTO FILEEXTENSIONID
    FROM FILEEXTENSION
    WHERE FILEEXTENSION.FILEEXTENSION = '.MAT';
    
    INSERT INTO PROJECTJOBFILEEXTENSION(PROJECTID, FILEEXTENSIONID) VALUES(PROJECTID, FILEEXTENSIONID);
    SET FLAG = 0;
  ELSE
    SET FLAG = 1;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ADDUSER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `ADDUSER`(IN USERNAME VARCHAR(150), IN PASSWORD VARCHAR(255), IN FIRSTNAME VARCHAR(150), IN LASTNAME VARCHAR(150), IN EMAIL VARCHAR(150), IN USERTYPE VARCHAR(32), IN STATUS INT, IN COUNTRY VARCHAR(255), IN ORGANIZATION VARCHAR(255), IN JOBTITLE VARCHAR(255), IN NEWSLETTER INT, OUT FLAG INT)
BEGIN
  DECLARE CNT INT;
  DECLARE USERID INT;
  SET CNT = 0;
  SET FLAG = -1;
  SET USERID = 0;

  SELECT COUNT(USERREG.USERID) INTO CNT
  FROM USERREG
  WHERE USERREG.USERNAME = USERNAME;

  IF (CNT = 0) THEN
    INSERT INTO USERREG(USERNAME, PASSWORD, FIRSTNAME, LASTNAME, USERTYPE, PRIMARYEMAIL, STATUS, COUNTRY, ORGANIZATION, JOBTITLE, CREATEDAT, UPDATEDAT, NEWSLETTER) VALUES(USERNAME, PASSWORD, FIRSTNAME, LASTNAME, USERTYPE, EMAIL, STATUS, COUNTRY, ORGANIZATION, JOBTITLE, NULL, NULL, NEWSLETTER);
    
    SELECT USERREG.USERID INTO FLAG
    FROM USERREG
    WHERE USERREG.USERNAME = USERNAME;
      
  ELSE
    SET FLAG = 0;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ADDUSERDATAFILE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `ADDUSERDATAFILE`(IN userid varchar(150),
                                                         IN name varchar(25),
                                                         IN notes BLOB,
                                                         IN createdon timestamp,
                                                         IN updatedat timestamp,                                                         
                                                         IN projectId INT)
BEGIN

  Insert into userprojectdatafiles(userid, name, projectId, createdon, updatedat, notes) values(userid, name, projectId, createdon, updatedat, notes);

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DELETEPROJECT` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `DELETEPROJECT`(IN PROJECT_ID INT, OUT FLAG INT)
BEGIN
SET FLAG = 0;
SELECT COUNT(PROJECTID) INTO FLAG FROM PROJECTS WHERE PROJECTID = PROJECT_ID;
IF (FLAG = 1) THEN
    DELETE FROM PROJECTS WHERE PROJECTID = PROJECT_ID;
    SET FLAG = 0;
ELSE 
    SET FLAG = -1;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DELETEUSER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `DELETEUSER`(IN USERID INT, OUT FLAG INT)
BEGIN

  DECLARE CNT INT;
  SET CNT = 0;
  SET FLAG = -1;

  SELECT COUNT(USERREG.USERID) INTO CNT
  FROM USERREG
  WHERE USERREG.USERID = USERID;

  IF (CNT > 0) THEN
     /*UPDATE USERREG SET USERREG.STATUS = 2 WHERE USERREG.USERID = USERID;*/
     DELETE FROM USERREG WHERE USERREG.USERID = USERID;
     SET FLAG = 0;
  ELSE
     SET FLAG = 1;
  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DISABLEUSER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `DISABLEUSER`(IN USERID INT, OUT FLAG INT)
BEGIN

  DECLARE CNT INT;
  SET CNT = 0;
  SET FLAG = -1;

  SELECT COUNT(USERREG.USERID) INTO CNT
  FROM USERREG
  WHERE USERREG.USERID = USERID;

  IF (CNT > 0) THEN
     UPDATE USERREG SET USERREG.STATUS = 2 WHERE USERREG.USERID = USERID;
     /*DELETE FROM USERREG WHERE USERREG.USERID = USERID;*/
     SET FLAG = 0;
  ELSE
     SET FLAG = 1;
  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `EDITPASSWORD` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `EDITPASSWORD`(IN USERID INT, IN PASSWORD varchar(255))
BEGIN
  UPDATE USERREG U SET U.PASSWORD = PASSWORD WHERE U.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GETALLUSERS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `GETALLUSERS`()
BEGIN
   SELECT * FROM USERREG U ORDER BY USERTYPE, USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GETDATAFILEEXTENSIONS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `GETDATAFILEEXTENSIONS`(IN PROJECT VARCHAR(255))
BEGIN
    DECLARE PROJECTID INT;
    SET PROJECTID = 0;
    
    SELECT PROJECTS.PROJECTID INTO PROJECTID
    FROM PROJECTS WHERE PROJECTS.PROJECTNAME = PROJECT;
    
    SELECT * FROM FILEEXTENSION 
    WHERE FILEEXTENSION.FILEEXTENSIONID IN(
        SELECT PROJECTDATAFILEEXTENSION.FILEEXTENSIONID FROM PROJECTDATAFILEEXTENSION 
        WHERE PROJECTDATAFILEEXTENSION.PROJECTID = PROJECTID
    );
   /*Select * from DataFileExtensionTypes;*/
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GETJOBFILEEXTENSIONS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `GETJOBFILEEXTENSIONS`(IN PROJECT VARCHAR(255))
BEGIN
    DECLARE PROJECTID INT;
    SET PROJECTID = 0;
    
    SELECT PROJECTS.PROJECTID INTO PROJECTID
    FROM PROJECTS WHERE PROJECTS.PROJECTNAME = PROJECT;
    
    SELECT * FROM FILEEXTENSION 
    WHERE FILEEXTENSION.FILEEXTENSIONID IN(
        SELECT PROJECTJOBFILEEXTENSION.FILEEXTENSIONID FROM PROJECTJOBFILEEXTENSION 
        WHERE PROJECTJOBFILEEXTENSION.PROJECTID = PROJECTID
    );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GETPREFERREDPROJECT` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `GETPREFERREDPROJECT`(IN USERID BIGINT(20))
BEGIN
  SELECT U.PROJECTID, P.PROJECTNAME, P.DESCRIPTION, U.PREFERREDPROJECT
  FROM PROJECTS P, USERPROJECTS U
  WHERE U.USERID = USERID 
  AND U.PREFERREDPROJECT = 1
  AND P.PROJECTID = U.PROJECTID   
  ORDER BY P.PROJECTID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GETPROJECTS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `GETPROJECTS`()
BEGIN
    SELECT * FROM PROJECTS;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GETUSERDATAPROJECTS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `GETUSERDATAPROJECTS`(IN USERID INT)
BEGIN
    IF (USERID = 0) THEN
        SELECT DISTINCT(U.PROJECTID), P.PROJECTNAME, P.DESCRIPTION
        FROM PROJECTS P, USERPROJECTS U
        WHERE P.DATAFILE <> 0
        AND P.PROJECTID = U.PROJECTID   
        ORDER BY P.PROJECTID;
    ELSE
        SELECT U.PROJECTID, P.PROJECTNAME, P.DESCRIPTION
        FROM PROJECTS P, USERPROJECTS U
        WHERE P.DATAFILE <> 0
        AND U.USERID = USERID 
        AND P.PROJECTID = U.PROJECTID   
        ORDER BY P.PROJECTID;        
    END IF;  
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GETUSERPROJECTS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `GETUSERPROJECTS`(IN USERID INT)
BEGIN

  IF (USERID > 0) THEN  
    SELECT U.PROJECTID, P.PROJECTNAME, P.DESCRIPTION, P.DATAFILE
    FROM PROJECTS P, USERPROJECTS U
    WHERE U.USERID = USERID 
    AND P.PROJECTID = U.PROJECTID   
    ORDER BY P.PROJECTID;
  ELSE
    SELECT DISTINCT(U.PROJECTID), P.PROJECTNAME, P.DESCRIPTION, P.DATAFILE
    FROM PROJECTS P, USERPROJECTS U
    WHERE P.PROJECTID = U.PROJECTID   
    ORDER BY P.PROJECTID;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GETUSERSTATUS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `GETUSERSTATUS`(IN USERID BIGINT(20), OUT USERSTATUS INT(11))
BEGIN
  SELECT USERREG.STATUS INTO USERSTATUS FROM USERREG WHERE USERREG.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `REGISTERUSER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `REGISTERUSER`(IN USERNAME VARCHAR(150), IN PASSWORD VARCHAR(255), IN FIRSTNAME VARCHAR(150), IN LASTNAME VARCHAR(150), IN EMAIL VARCHAR(150), IN USERTYPE VARCHAR(32), IN STATUS INT, IN TOTALUNITS DOUBLE, IN NEWSLETTER INT, OUT FLAG INT)
BEGIN
  DECLARE CNT INT;
  DECLARE USERID INT;
  SET CNT = 0;
  SET FLAG = -1;
  SET USERID = 0;

  SELECT COUNT(USERREG.USERID) INTO CNT
  FROM USERREG
  WHERE USERREG.USERNAME = USERNAME;

  IF (CNT = 0) THEN
    INSERT INTO USERREG(USERNAME, PASSWORD, FIRSTNAME, LASTNAME, USERTYPE, PRIMARYEMAIL, STATUS, COUNTRY, ORGANIZATION, JOBTITLE, CREATEDAT, UPDATEDAT, NEWSLETTER, TOTALUNITS) VALUES(USERNAME, PASSWORD, FIRSTNAME, LASTNAME, USERTYPE, EMAIL, STATUS, COUNTRY, ORGANIZATION, JOBTITLE, NULL, NULL, NEWSLETTER, TOTALUNITS);
    
    SELECT USERREG.USERID INTO FLAG
    FROM USERREG
    WHERE USERREG.USERNAME = USERNAME;
      
  ELSE
    SET FLAG = 0;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SAVEUSERPROJECT` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `SAVEUSERPROJECT`(IN USERID INT, IN PROJECTID INT, IN PREFERREDPROJECT INT)
BEGIN
  DECLARE CNT INT;
  DECLARE PREFERREDPRJCNT INT;
  SET CNT = 0;
  SET PREFERREDPRJCNT = 0;
  SELECT COUNT(PROJECTID) INTO CNT FROM USERPROJECTS U WHERE U.USERID = USERID AND U.PROJECTID = PROJECTID;
  IF(CNT = 0) THEN
    SELECT COUNT(PROJECTID) INTO PREFERREDPRJCNT FROM USERPROJECTS U WHERE U.USERID = USERID;
    IF(PREFERREDPRJCNT > 0 && PREFERREDPROJECT = 1) THEN
	UPDATE USERPROJECTS SET USERPROJECTS.PREFERREDPROJECT = 0 WHERE USERPROJECTS.USERID = USERID;
    END IF;
    
    INSERT INTO USERPROJECTS(USERID, PROJECTID, CREATEDON, PREFERREDPROJECT) VALUES(USERID, PROJECTID, NULL, PREFERREDPROJECT);
  ELSE 
    UPDATE USERPROJECTS SET USERPROJECTS.PREFERREDPROJECT = 0 WHERE USERPROJECTS.USERID = USERID;
    UPDATE USERPROJECTS SET USERPROJECTS.PREFERREDPROJECT = PREFERREDPROJECT WHERE USERPROJECTS.USERID = USERID AND USERPROJECTS.PROJECTID = PROJECTID;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UNSUBSCRIBEUSERPROJECT` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UNSUBSCRIBEUSERPROJECT`(IN USERID INT, IN PROJECTID INT)
BEGIN
  DECLARE CNT INT;
  SET CNT = 0;
  SELECT COUNT(PROJECTID) INTO CNT FROM USERPROJECTS U WHERE U.USERID = USERID AND U.PROJECTID = PROJECTID;
  IF(CNT = 1) THEN
    DELETE FROM USERPROJECTS WHERE USERPROJECTS.USERID = USERID AND USERPROJECTS.PROJECTID = PROJECTID;  
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATECOUNTRY` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATECOUNTRY`(IN USERID INT, IN COUNTRY VARCHAR(255))
BEGIN
UPDATE USERREG SET USERREG.COUNTRY = COUNTRY WHERE USERREG.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEEMAIL` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEEMAIL`(IN USERID INT, IN EMAIL varchar(255))
BEGIN
  UPDATE USERREG U SET U.PRIMARYEMAIL = EMAIL WHERE U.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEFIRSTNAME` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEFIRSTNAME`(IN USERID INT, IN FIRSTNAME VARCHAR(255))
BEGIN
UPDATE USERREG SET USERREG.FIRSTNAME = FIRSTNAME WHERE USERREG.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEJOBTITLE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEJOBTITLE`(IN USERID INT, IN JOBTITLE VARCHAR(255))
BEGIN
    UPDATE USERREG SET USERREG.JOBTITLE = JOBTITLE WHERE USERREG.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATELASTNAME` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATELASTNAME`(IN USERID INT, IN LASTNAME VARCHAR(255))
BEGIN
UPDATE USERREG SET USERREG.LASTNAME = LASTNAME WHERE USERREG.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATENEWSLETTERSUBSCRIPTION` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATENEWSLETTERSUBSCRIPTION`(IN USERID INT, IN SUBSCRIPTION INT)
BEGIN
UPDATE USERREG SET USERREG.NEWSLETTER = SUBSCRIPTION WHERE USERREG.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEORGANIZATION` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEORGANIZATION`(IN USERID INT, IN ORGANIZATION VARCHAR(255))
BEGIN
UPDATE USERREG SET USERREG.ORGANIZATION = ORGANIZATION WHERE USERREG.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEPROJECTDATAFILE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEPROJECTDATAFILE`(IN PROJECTID INT, IN REQUIREDFLAG INT)
BEGIN
UPDATE PROJECTS SET PROJECTS.DATAFILE = REQUIREDFLAG WHERE PROJECTS.PROJECTID = PROJECTID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEPROJECTDESCRIPTION` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEPROJECTDESCRIPTION`(IN PROJECTID INT, IN DESCRIPTION VARCHAR(255))
BEGIN
UPDATE PROJECTS SET PROJECTS.DESCRIPTION = DESCRIPTION WHERE PROJECTS.PROJECTID = PROJECTID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEPROJECTNAME` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEPROJECTNAME`(IN PROJECTID INT, IN PROJECTNAME VARCHAR(255), OUT TEMP INT)
BEGIN
SET TEMP = -1;
SELECT COUNT(PROJECTS.PROJECTID) INTO TEMP FROM PROJECTS WHERE PROJECTS.PROJECTNAME = PROJECTNAME;
IF (TEMP = 0) THEN
    UPDATE PROJECTS SET PROJECTS.PROJECTNAME = PROJECTNAME WHERE PROJECTS.PROJECTID = PROJECTID;
END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEPROJECTPATH` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEPROJECTPATH`(IN PROJECTID INT, IN PATH VARCHAR(255))
BEGIN
UPDATE PROJECTS SET PROJECTS.PATH = PATH WHERE PROJECTS.PROJECTID = PROJECTID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEUSERQUOTA` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEUSERQUOTA`(IN USERID INT, IN ADDQUOTA DOUBLE, OUT TOTALQUOTA DOUBLE, OUT USEDUNITS DOUBLE)
BEGIN
    UPDATE USERREG SET USERREG.TOTALUNITS = (USERREG.TOTALUNITS + ADDQUOTA) WHERE USERREG.USERID = USERID;
    SELECT USERREG.TOTALUNITS INTO TOTALQUOTA
    FROM USERREG
    WHERE USERREG.USERID = USERID;
    
    CALL USERUSAGE(USERID, @A);
    SELECT @A INTO USEDUNITS;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEUSERSTATUS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEUSERSTATUS`(IN USERID INT, IN STATUS INT)
BEGIN
UPDATE USERREG SET USERREG.STATUS = STATUS WHERE USERREG.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UPDATEUSERUSAGE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `UPDATEUSERUSAGE`(IN USERNAME VARCHAR(255), IN USED_UNITS DOUBLE, IN PROJECTNAME VARCHAR(255))
BEGIN
    DECLARE UNITS DOUBLE;
    DECLARE USERID INT;
    DECLARE PROJECTID INT;
    SET UNITS = 0;
    
    SELECT USERREG.USERID INTO USERID
    FROM USERREG WHERE USERREG.USERNAME = USERNAME;
    
    SELECT PROJECTS.PROJECTID INTO PROJECTID
    FROM PROJECTS WHERE PROJECTS.PROJECTNAME = PROJECTNAME;
    
    /*SELECT USERPROJECTS.USEDUNITS INTO UNITS
    FROM USERPROJECTS WHERE USERPROJECTS.USERID = USERID;*/
    
    UPDATE USERPROJECTS SET USERPROJECTS.USEDUNITS = (USED_UNITS) 
    WHERE USERPROJECTS.USERID = USERID
    AND USERPROJECTS.PROJECTID = PROJECTID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `USERUSAGE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `USERUSAGE`(IN USERID INT, OUT USEDUNITS DOUBLE)
BEGIN
    SELECT SUM(USERPROJECTS.USEDUNITS) INTO USEDUNITS
    FROM USERPROJECTS
    WHERE USERPROJECTS.USERID = USERID;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `VALIDATEUSER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `VALIDATEUSER`(IN USERNAME VARCHAR(150))
BEGIN
  SELECT * FROM USERREG WHERE USERREG.USERNAME = USERNAME;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `VALIDATEUSEREMAIL` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `VALIDATEUSEREMAIL`(IN EMAIL VARCHAR(150), OUT CNT INT)
BEGIN
  SELECT COUNT(*) INTO CNT FROM USERREG WHERE USERREG.PRIMARYEMAIL = EMAIL;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-05-13 21:26:07
