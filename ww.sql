CREATE DATABASE ww character set=utf8 collate=utf8_general_ci;

CREATE TABLE spaces (
   uuid BINARY(16) PRIMARY KEY,
   name VARCHAR(128) NOT NULL,
   background VARCHAR(128),
   icon VARCHAR(128),
   knock VARCHAR(128));

CREATE TABLE ministers (
   space BINARY(16) NOT NULL,
   minister VARCHAR(128) NOT NULL,
   joined DATETIME NOT NULL,
   uid INT(10));
CREATE INDEX by_space on waiting(space);

CREATE TABLE messages (
   msgid INT(10) NOT NULL AUTO INCREMENT,
   minister VARCHAR(128) NOT NULL, uid INT(10),
   moment DATETIME NOT NULL);
CREATE INDEX msgs_by_space on messages(space);

