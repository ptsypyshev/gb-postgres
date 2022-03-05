-- Проект "Simple Task Manager" - будет использоваться для постановки задач и контроля за ними.
-- Сущности: пользователи, группы (могут быть подчинены иерархически), задачи (могут быть привязанными и не привязанными ко времени, иметь разные приоритеты и статусы, могут быть назначены исполнителю, а также поставлены на контроль проверяющим), вложения (прикрепляются к задаче, одно вложение может быть прикреплено к нескольким задачам).
-- Логика работы - пользователь авторизуется и может создавать задачи. По умолчанию, задача имеет минимальный приоритет и не назначается в работу.
-- Пользователь может указать для задачи жесткое время выполнения (встреча) или поставить в план выполнения в любое удобное для себя время.
-- Контролирующий может видеть задачи для проверки.

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

-- Security settings
REVOKE ALL ON DATABASE simpletask FROM PUBLIC;
GRANT ALL PRIVILEGES ON DATABASE simpletask TO simpletask; -- Вопрос, почему данная команда не дает привилегии на все таблицы?
GRANT ALL PRIVILEGES ON ALL tables IN SCHEMA public TO simpletask;

-- Connect to DB
\c simpletask;

-- Create some required settings
-- Set timezone to Yekaterinburg (GMT+05)
set timezone = 'Asia/Yekaterinburg';
-- Create extension to use cryptography functions in queries
CREATE EXTENSION pgcrypto;
-- Create enumeration type
CREATE TYPE status AS ENUM ('enabled', 'blocked', 'disabled');
CREATE TYPE group_type AS ENUM ('security', 'staffing', 'project');
CREATE TYPE priority AS ENUM ('important and urgent', 'important but not urgent', 'not important but urgent', 'not important and not urgent');

-- Create table users
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    login VARCHAR(100) NOT NULL,
    password TEXT NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    middle_name VARCHAR(100),
    email TEXT,
    phone TEXT,
    avatar TEXT,
    status status NOT NULL,
    created_date TIMESTAMP NOT NULL DEFAULT now(),
    expired_date TIMESTAMP
);

-- Create table groups
DROP TABLE IF EXISTS groups CASCADE;
CREATE TABLE groups (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    group_name VARCHAR(100) NOT NULL,
    group_description TEXT,
    group_type group_type NOT NULL,
    group_leader INT,
    status status NOT NULL,
    created_date TIMESTAMP NOT NULL DEFAULT now(),
    expired_date TIMESTAMP,
    FOREIGN KEY (group_leader) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Create table user_group_membership
DROP TABLE IF EXISTS user_group_membership CASCADE;
CREATE TABLE user_group_membership (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Create table group_group_membership
DROP TABLE IF EXISTS group_group_membership CASCADE;
CREATE TABLE group_group_membership (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    parent_id INT NOT NULL,
    child_id INT NOT NULL,
    FOREIGN KEY (parent_id) REFERENCES groups (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (child_id) REFERENCES groups (id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create table task_statuses
DROP TABLE IF EXISTS task_statuses CASCADE;
CREATE TABLE task_statuses (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    task_status_name VARCHAR(100) NOT NULL,
    task_status_description TEXT
);

-- Create table tasks
DROP TABLE IF EXISTS tasks CASCADE;
CREATE TABLE tasks (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    task_name VARCHAR(100) NOT NULL,
    task_description TEXT,
    priority priority NOT NULL DEFAULT 'not important and not urgent',
    is_flexible BOOLEAN NOT NULL DEFAULT TRUE,
    task_status INT NOT NULL,
    responsible INT,
    start_datetime TIMESTAMP,
    due_datetime TIMESTAMP,
    finish_datetime TIMESTAMP,
    guess_time TIME,
    spent_time TIME,
    created_date TIMESTAMP NOT NULL DEFAULT now(),
    updated_date TIMESTAMP,
    FOREIGN KEY (task_status) REFERENCES task_statuses (id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (responsible) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT due_datetime_check CHECK ( tasks.due_datetime >= tasks.start_datetime )
);

-- Create table task_membership
DROP TABLE IF EXISTS task_membership CASCADE;
CREATE TABLE task_membership (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    parent_id INT NOT NULL,
    child_id INT NOT NULL,
    FOREIGN KEY (parent_id) REFERENCES tasks (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (child_id) REFERENCES tasks (id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create table task_control_membership
DROP TABLE IF EXISTS task_control_membership CASCADE;
CREATE TABLE task_control_membership (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    task_id INT NOT NULL,
    controller_id INT NOT NULL,
    FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (controller_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create table attachments
DROP TABLE IF EXISTS attachments CASCADE;
CREATE TABLE attachments (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    attachment_link TEXT NOT NULL
);

-- Create table attachment_membership
DROP TABLE IF EXISTS attachment_membership CASCADE;
CREATE TABLE attachment_membership (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    task_id INT NOT NULL,
    attachment_id INT NOT NULL,
    FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (attachment_id) REFERENCES attachments (id) ON DELETE CASCADE ON UPDATE CASCADE
);
