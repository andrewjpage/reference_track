CREATE TABLE `repositories` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `short_name` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `latest` tinyint(2) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


CREATE TABLE `version_visibility` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `version` varchar(255) DEFAULT NULL,
  `public_version` varchar(255) DEFAULT NULL,
  `visible_on_ftp_site` tinyint(2) NOT NULL DEFAULT '0',
  `repository_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `version` (`version`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


CREATE VIEW `latest_repositories`
AS select *
from `repositories`
where (`repositories`.`latest` = 1);

