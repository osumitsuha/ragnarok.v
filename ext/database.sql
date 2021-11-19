CREATE DATABASE IF NOT EXISTS `ragnarok`;

CREATE TABLE IF NOT EXISTS `users` (
    `id` INT NOT NULL AUTO_INCREMENT,
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

CREATE TABLE IF NOT EXISTS `friends` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `friend_id` INT NOT NULL,
    PRIMARY KEY (`id`)
);