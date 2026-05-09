CREATE TABLE IF NOT EXISTS `apartment_assignments` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`apartment_id` INT NOT NULL,
	`character_id` INT NULL DEFAULT NULL,
	`character_sid` INT NOT NULL,
	`assigned_at` BIGINT NOT NULL,
	`last_seen` BIGINT NULL DEFAULT NULL,
	PRIMARY KEY (`id`),
	UNIQUE KEY `uniq_apartment_id` (`apartment_id`),
	UNIQUE KEY `uniq_character_sid` (`character_sid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
