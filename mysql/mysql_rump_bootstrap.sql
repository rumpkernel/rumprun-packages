-- Rump-specific bootstrap for MySQL.

-- For demonstration purposes, drop all users except 'rump' which is made
-- equivalent to the 'root' user and allowed to login from any host.
USE mysql;
UPDATE user SET User = 'rump', Host = '%' WHERE User = 'root' AND Host = 'localhost';
DELETE from user WHERE User != 'rump';
