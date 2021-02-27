-- --------------------------------------------------------
-- Värd:                         127.0.0.1
-- Serverversion:                10.1.35-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win32
-- HeidiSQL Version:             9.5.0.5196
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for qalle
CREATE DATABASE IF NOT EXISTS `qalle` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `qalle`;

-- Dumping structure for tabell qalle.characters_plants
CREATE TABLE IF NOT EXISTS `characters_plants` (
  `plantId` int(11) NOT NULL,
  `plantLevel` int(11) NOT NULL DEFAULT '1',
  `plantWaterLeft` int(11) NOT NULL DEFAULT '1',
  `plantTime` int(11) NOT NULL DEFAULT '60',
  `plantCreated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `plantEdited` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`plantId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumpar data för tabell qalle.characters_plants: ~2 rows (ungefär)
/*!40000 ALTER TABLE `characters_plants` DISABLE KEYS */;
INSERT INTO `characters_plants` (`plantId`, `plantLevel`, `plantWaterLeft`, `plantTime`, `plantCreated`, `plantEdited`) VALUES
	(21, 2, 0, 59, '2019-03-07 21:12:58', '2019-03-08 17:55:30');
/*!40000 ALTER TABLE `characters_plants` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
