CREATE DATABASE IF NOT EXISTS `ragnarok`;

USE `ragnarok`;

CREATE TABLE IF NOT EXISTS `users` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(15) NOT NULL,
    `usafe` VARCHAR(15) NOT NULL,
    `password` VARCHAR(127) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `privileges` INT NOT NULL,
    `country` VARCHAR(2) NOT NULL,
    `registered` TIMESTAMP NOT NULL DEFAULT current_timestamp,
    `lastest_login` TIMESTAMP NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (`id`)
);

INSERT INTO `users` (`username`, `usafe`, `password`, `email`, `privileges`, `country`) 
              VALUES ('Louise', 'louise', 'no', 'louise@ragnarok.v', 254, 'DK');

INSERT INTO `users` (`username`, `usafe`, `password`, `email`, `privileges`, `country`) 
              VALUES ('Simon', 'simon', 'no', 'simon@penis.man', 254, 'DK');

CREATE TABLE IF NOT EXISTS `stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ranked_score_std` int(11) NOT NULL DEFAULT 0,
  `ranked_score_taiko` int(11) NOT NULL DEFAULT 0,
  `ranked_score_catch` int(11) NOT NULL DEFAULT 0,
  `ranked_score_mania` int(11) NOT NULL DEFAULT 0,
  `total_score_std` int(11) NOT NULL DEFAULT 0,
  `total_score_taiko` int(11) NOT NULL DEFAULT 0,
  `total_score_catch` int(11) NOT NULL DEFAULT 0,
  `total_score_mania` int(11) NOT NULL DEFAULT 0,
  `accuracy_std` float NOT NULL DEFAULT 0,
  `accuracy_taiko` float NOT NULL DEFAULT 0,
  `accuracy_catch` float NOT NULL DEFAULT 0,
  `accuracy_mania` float NOT NULL DEFAULT 0,
  `playcount_std` int(11) NOT NULL DEFAULT 0,
  `playcount_taiko` int(11) NOT NULL DEFAULT 0,
  `playcount_catch` int(11) NOT NULL DEFAULT 0,
  `playcount_mania` int(11) NOT NULL DEFAULT 0,
  `pp_std` float NOT NULL DEFAULT 0,
  `pp_taiko` float NOT NULL DEFAULT 0,
  `pp_catch` float NOT NULL DEFAULT 0,
  `pp_mania` float NOT NULL DEFAULT 0,
  `pp_4k` int(11) DEFAULT NULL,
  `pp_7k` int(11) DEFAULT NULL,
  `level_std` float NOT NULL DEFAULT 0,
  `level_taiko` float NOT NULL DEFAULT 0,
  `level_catch` float NOT NULL DEFAULT 0,
  `level_mania` float NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `stats` (`id`) VALUES (1);
INSERT INTO `stats` (`id`) VALUES (2);

CREATE TABLE IF NOT EXISTS `friends` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `user_id` int(11) NOT NULL,
    `friend_id` int(11) NOT NULL,
    PRIMARY KEY (`id`)
);