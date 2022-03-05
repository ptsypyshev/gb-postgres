-- Create user
CREATE USER simpletask
WITH PASSWORD '$1mpLeP@ss';

-- Create database
CREATE DATABASE simpletask WITH OWNER simpletask
    TEMPLATE = 'template0'
    ENCODING = 'utf-8'
    LC_COLLATE = 'C.UTF-8'
    LC_CTYPE = 'C.UTF-8';

-- Security settings
REVOKE ALL ON DATABASE simpletask FROM PUBLIC;