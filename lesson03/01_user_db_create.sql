-- Create user
DROP ROLE IF EXISTS simpletask;
CREATE USER simpletask
    WITH PASSWORD '$1mpLeP@ss';

-- Create database
DROP DATABASE IF EXISTS simpletask;
CREATE DATABASE simpletask WITH OWNER simpletask
    TEMPLATE = 'template0'
    ENCODING = 'utf-8'
    LC_COLLATE = 'C.UTF-8'
    LC_CTYPE = 'C.UTF-8';