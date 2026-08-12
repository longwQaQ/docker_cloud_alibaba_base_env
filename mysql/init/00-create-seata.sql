CREATE DATABASE IF NOT EXISTS `seata`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON `seata`.* TO 'cloud'@'%';
