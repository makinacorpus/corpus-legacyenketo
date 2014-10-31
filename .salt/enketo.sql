-- MySQL dump 10.13  Distrib 5.5.31, for Linux (x86_64)
DROP TABLE IF EXISTS `instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instances` (
  `instanceid` varchar(255) NOT NULL,
  `subdomain` varchar(100) NOT NULL,
  `return_url` varchar(255) NOT NULL,
  `instance_xml` mediumtext,
  `timestamp` bigint(20) NOT NULL,
  UNIQUE KEY `idx_instanceid` (`instanceid`),
  KEY `idx_subdomain` (`subdomain`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `languages` (
  `alpha3_bib` varchar(7) DEFAULT NULL,
  `alpha3_ter` varchar(3) DEFAULT NULL,
  `alpha2` varchar(2) DEFAULT NULL,
  `name_en` varchar(80) DEFAULT NULL,
  `name_fr` varchar(63) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `properties`
--

DROP TABLE IF EXISTS `properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `properties` (
  `xsl_version` int(11) NOT NULL,
  `form_xsl_hash` varchar(32) NOT NULL,
  `model_xsl_hash` varchar(32) NOT NULL,
  PRIMARY KEY (`xsl_version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `session_id` varchar(40) NOT NULL DEFAULT '0',
  `ip_address` varchar(45) NOT NULL DEFAULT '0',
  `user_agent` varchar(120) NOT NULL,
  `last_activity` int(10) unsigned NOT NULL DEFAULT '0',
  `user_data` text NOT NULL,
  PRIMARY KEY (`session_id`),
  KEY `last_activity_idx` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `surveys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `surveys` (
  `subdomain` varchar(12) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `server_url` varchar(100) NOT NULL,
  `form_id` varchar(100) NOT NULL,
  `submissions` int(11) NOT NULL DEFAULT '0',
  `offline` tinyint(1) NOT NULL,
  `submission_url` varchar(100) NOT NULL,
  `data_url` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `hash` varchar(40) NOT NULL,
  `media_hash` varchar(40) DEFAULT NULL,
  `transform_result_model` mediumtext NOT NULL,
  `transform_result_form` longtext NOT NULL,
  `transform_result_title` text NOT NULL,
  `xsl_version` int(11) NOT NULL,
  `launch_date` datetime NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`subdomain`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
-- Dump completed on 2014-09-06  1:00:05
