-- Проект "Simple Task Manager" - будет использоваться для постановки задач и контроля за ними.
-- Сущности: пользователи, группы (могут быть подчинены иерархически), задачи (могут быть привязанными и не привязанными ко времени, иметь разные приоритеты и статусы, могут быть назначены исполнителю, а также поставлены на контроль проверяющим), вложения (прикрепляются к задаче, одно вложение может быть прикреплено к нескольким задачам).
-- Логика работы - пользователь авторизуется и может создавать задачи. По умолчанию, задача имеет минимальный приоритет и не назначается в работу.
-- Пользователь может указать для задачи жесткое время выполнения (встреча) или поставить в план выполнения в любое удобное для себя время.
-- Контролирующий может видеть задачи для проверки.

-- Connect to DB
\c simpletask;

-- Security settings
REVOKE ALL ON DATABASE simpletask FROM PUBLIC;

-- Понял в чем ошибки - если создаем всё из одного скрипта, тогда хоть simpletask и владелец, но все таблицы принадлежат пользователю postgres
-- GRANT ALL PRIVILEGES ON DATABASE simpletask TO simpletask; -- Вопрос, почему данная команда не дает привилегии на все таблицы?
-- GRANT ALL PRIVILEGES ON ALL tables IN SCHEMA public TO simpletask; -- Ещё вопрос - данная команда отрабатывает из консоли psql, но не при запуске скрипта

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
                       expired_date TIMESTAMP,
                       CONSTRAINT users_id_check CHECK ( users.id > 0 )
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
                        FOREIGN KEY (group_leader) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE,
                        CONSTRAINT groups_id_check CHECK ( groups.id > 0 )
);

-- Create table user_group_membership
DROP TABLE IF EXISTS user_group_membership CASCADE;
CREATE TABLE user_group_membership (
                                       id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                       group_id INT NOT NULL,
                                       user_id INT NOT NULL,
                                       FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE ON UPDATE CASCADE,
                                       FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
                                       CONSTRAINT user_group_id_check CHECK ( user_group_membership.id > 0 ),
                                       CONSTRAINT group_id_check CHECK ( user_group_membership.group_id > 0 ),
                                       CONSTRAINT user_id_check CHECK ( user_group_membership.user_id > 0 )
);


-- Create table group_group_membership
DROP TABLE IF EXISTS group_group_membership CASCADE;
CREATE TABLE group_group_membership (
                                        id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                        parent_id INT NOT NULL,
                                        child_id INT NOT NULL,
                                        FOREIGN KEY (parent_id) REFERENCES groups (id) ON DELETE CASCADE ON UPDATE CASCADE,
                                        FOREIGN KEY (child_id) REFERENCES groups (id) ON DELETE CASCADE ON UPDATE CASCADE,
                                        CONSTRAINT group_group_id_check CHECK ( group_group_membership.id > 0 ),
                                        CONSTRAINT group_id_check CHECK ( group_group_membership.parent_id > 0 ),
                                        CONSTRAINT user_id_check CHECK ( group_group_membership.child_id > 0 )
);

-- Create table task_statuses
DROP TABLE IF EXISTS task_statuses CASCADE;
CREATE TABLE task_statuses (
                               id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                               task_status_name VARCHAR(100) NOT NULL,
                               task_status_description TEXT,
                               CONSTRAINT task_status_id_check CHECK ( task_statuses.id > 0 )
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
                       CONSTRAINT due_datetime_check CHECK ( tasks.due_datetime >= tasks.start_datetime ),
                       CONSTRAINT task_id_check CHECK ( tasks.id > 0 ),
                       CONSTRAINT responsible_check CHECK ( tasks.responsible > 0 ),
                       CONSTRAINT task_status_check CHECK ( tasks.task_status > 0 )
);

-- Create table task_membership
DROP TABLE IF EXISTS task_membership CASCADE;
CREATE TABLE task_membership (
                                 id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                 parent_id INT NOT NULL,
                                 child_id INT NOT NULL,
                                 FOREIGN KEY (parent_id) REFERENCES tasks (id) ON DELETE CASCADE ON UPDATE CASCADE,
                                 FOREIGN KEY (child_id) REFERENCES tasks (id) ON DELETE CASCADE ON UPDATE CASCADE,
                                 CONSTRAINT task_id_check CHECK ( task_membership.id > 0 ),
                                 CONSTRAINT parent_id_check CHECK ( task_membership.parent_id > 0 ),
                                 CONSTRAINT child_id_check CHECK ( task_membership.child_id > 0 )
);

-- Create table task_control_membership
DROP TABLE IF EXISTS task_control_membership CASCADE;
CREATE TABLE task_control_membership (
                                         id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                         task_id INT NOT NULL,
                                         controller_id INT NOT NULL,
                                         FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE ON UPDATE CASCADE,
                                         FOREIGN KEY (controller_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
                                         CONSTRAINT id_check CHECK ( task_control_membership.id > 0 ),
                                         CONSTRAINT task_check CHECK ( task_control_membership.task_id > 0 ),
                                         CONSTRAINT controller_id_check CHECK ( task_control_membership.controller_id > 0 )
);

-- Create table attachments
DROP TABLE IF EXISTS attachments CASCADE;
CREATE TABLE attachments (
                             id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                             attachment_link TEXT NOT NULL,
                             CONSTRAINT id_check CHECK ( attachments.id > 0 )
);

-- Create table attachment_membership
DROP TABLE IF EXISTS attachment_membership CASCADE;
CREATE TABLE attachment_membership (
                                       id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
                                       task_id INT NOT NULL,
                                       attachment_id INT NOT NULL,
                                       FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE ON UPDATE CASCADE,
                                       FOREIGN KEY (attachment_id) REFERENCES attachments (id) ON DELETE CASCADE ON UPDATE CASCADE,
                                       CONSTRAINT id_check CHECK ( attachment_membership.id > 0 ),
                                       CONSTRAINT task_check CHECK ( attachment_membership.task_id > 0 ),
                                       CONSTRAINT attachment_id_check CHECK ( attachment_membership.attachment_id > 0 )
);
