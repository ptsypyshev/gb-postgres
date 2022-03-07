-- Connect to DB
\c simpletask;

-- Insert Users
INSERT INTO users(login, password, first_name, last_name, email, status)
VALUES
    ('admin', crypt('password', gen_salt('bf', 8)), 'Administrator', 'TaskSystem', 'admin@example.loc', 'enabled'),
    ('ptsypyshev', crypt('testpass', gen_salt('bf', 8)), 'Pavel', 'Tsypyshev', 'ptsypyshev@example.loc', 'enabled'),
    ('vpupkin', crypt('puptest', gen_salt('bf', 8)), 'Vasiliy', 'Pupkin', 'vpupkin@example.loc', 'disabled'),
    ('iivanov', crypt('ivantest', gen_salt('bf', 8)), 'Ivan', 'Ivanov', 'iivanov@example.loc', 'enabled'),
    ('ppetrov', crypt('petrtest', gen_salt('bf', 8)), 'Petr', 'Petrov', 'ppetrov@example.loc', 'enabled'),
    ('ssidorov', crypt('sidrtest', gen_salt('bf', 8)), 'Sidor', 'Sidorov', 'ssidorov@example.loc', 'enabled');

-- Insert Groups
INSERT INTO groups(group_name, group_description, group_type, group_leader, status)
VALUES
    ('it_dept', 'IT department', 'staffing', (SELECT id FROM users WHERE last_name = 'Tsypyshev'), 'enabled'),
    ('hr_dept', 'HR department', 'staffing', 3, 'enabled'),
    ('acc_dept', 'Accounting department', 'staffing', null, 'enabled'),
    ('can_read', 'Users can read tasks owned by another users', 'security', null, 'enabled'),
    ('can_modify', 'Users can modify tasks owned by another users', 'security', null, 'enabled'),
    ('erp_implementation', 'Implementation of ERP System', 'project', null, 'enabled'),
    ('new_branch_building', 'Building of new branch', 'project', null, 'disabled');

-- Insert Users into Groups
INSERT INTO user_group_membership(group_id, user_id)
VALUES
    (1, 2),
    (1, 4),
    (1, 5),
    (2, 3),
    (3, 6),
    (4, 2),
    (5, 1);

-- Insert Groups into Groups
INSERT INTO group_group_membership(parent_id, child_id)
VALUES
    (6, 1),
    (7, 3);

-- Insert Task statuses
INSERT INTO task_statuses(task_status_name, task_status_description)
VALUES
    ('open', 'Task is open'),
    ('todo', 'Task is scheduled'),
    ('in_progress', 'Task is in progress'),
    ('done', 'Task is done (Waiting to approve by controller'),
    ('approved', 'Task is approved'),
    ('completed', 'Task is completed'),
    ('cancelled', 'Task is cancelled'),
    ('draft', 'Task is draft');

-- Insert Tasks
INSERT INTO tasks(task_name, task_description, priority, is_flexible, task_status, responsible, start_datetime,
                  due_datetime, created_date)
VALUES
    ('Создать должностные инструкции', 'Создать должностные инструкции для всех сотрудников отдела ИТ', 'not important but urgent',
     true, (SELECT id FROM task_statuses WHERE task_status_name = 'in_progress'), 2, now() - INTERVAL '1 day', now() + 2 * INTERVAL '1 day', now() - 3 * INTERVAL '1 day'),
    ('Совещание по проекту ERP', 'Подготовиться к совещанию по проекту ERP', 'important and urgent',
     false, (SELECT id FROM task_statuses WHERE task_status_name = 'in_progress'), 4, now() - INTERVAL '1 hour', now() + 2 * INTERVAL '1 hour', now() - 2 * INTERVAL '1 day'),
    ('Выполнить обновление системы резервного копирования', 'Создать задачи для обновления системы резервного копирования',
     'important but not urgent', true, (SELECT id FROM task_statuses WHERE task_status_name = 'todo'), 2, now() + INTERVAL '5 day', NULL, now()),
    ('Выполнить ДЗ 02 курса PostgreSQL', 'Выполнить и сдать ДЗ 02', 'important and urgent',
     true, (SELECT id FROM task_statuses WHERE task_status_name = 'done'), 2, now() + INTERVAL '1 hour', now() + 2 * INTERVAL '1 day', now()),
    ('Выполнить ДЗ 06 курса Golang-Level01', 'Выполнить и сдать ДЗ 06', 'important but not urgent',
     true, (SELECT id FROM task_statuses WHERE task_status_name = 'todo'), 4, now() + 1 * INTERVAL '1 day', now() + 5 * INTERVAL '1 day', now() - 2 * INTERVAL '1 day'),
    ('Выполнить ДЗ 07 курса Golang-Level01', 'Выполнить и сдать ДЗ 07', 'important but not urgent',
     true, (SELECT id FROM task_statuses WHERE task_status_name = 'todo'), 5, NULL, NULL, now()),
    ('Создать MindMap по курсу PostgreSQL', 'Создать MindMap по курсу PostgreSQL', 'important but not urgent',
     true, (SELECT id FROM task_statuses WHERE task_status_name = 'open'), NULL, NULL, NULL, now()),
    ('Сделать музыкальную подборку', 'Сделать музыкальную подборку в машину', 'not important and not urgent',
     true, (SELECT id FROM task_statuses WHERE task_status_name = 'cancelled'), NULL, NULL, NULL, now());

-- Insert Task Membership
INSERT INTO task_membership(parent_id, child_id)
VALUES
    (3, 4),
    (3, 5),
    (3, 6),
    (4, 7);

-- Insert Task Control Membership
INSERT INTO task_control_membership(task_id, controller_id)
VALUES
    (2, 2),
    (2, 5),
    (2, 6);

-- Insert Attachments
INSERT INTO attachments(attachment_link)
VALUES
    ('/var/www/html/uploads/1.pdf'),
    ('/var/www/html/uploads/2.pdf'),
    ('/var/www/html/uploads/3.pdf'),
    ('/var/www/html/uploads/4.pdf'),
    ('/var/www/html/uploads/5.pdf');

-- Insert Attachments Membership (to Tasks)
INSERT INTO attachment_membership(task_id, attachment_id)
VALUES
    (1, 1),
    (2, 2),
    (2, 3),
    (2, 4),
    (3, 5);