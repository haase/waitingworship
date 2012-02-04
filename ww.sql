CREATE DATABASE ww character set=utf8 collate=utf8_general_ci;

CREATE TABLE spaces (
   uuid BINARY(16) PRIMARY KEY,
   name VARCHAR(128) NOT NULL,
   about TEXT,
   mural VARCHAR(128),
   icon VARCHAR(128),
   knock VARCHAR(128));

CREATE TABLE ministers (
   space BINARY(16) NOT NULL REFERENCES spaces(uuid),
   minister VARCHAR(128) NOT NULL,
   joined DATETIME NOT NULL,
   uid INT(10));
CREATE INDEX by_space on ministers(space);

CREATE TABLE messages (
   msgid BINARY(16) PRIMARY KEY,
   space BINARY(16) NOT NULL REFERENCES spaces(uuid),
   minister VARCHAR(128) NOT NULL, uid INT(10),
   content TEXT,
   spoken DATETIME NOT NULL,
   shared DATETIME);
CREATE INDEX msgs_by_space on messages(space);

