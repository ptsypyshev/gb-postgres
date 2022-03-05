-- Connect to DB
\c simpletask;

-- Get all users from DB
SELECT * FROM users;

-- Get all groups from DB
SELECT * FROM groups;

-- Get all users in groups from DB
SELECT * FROM user_group_membership;

-- Get all groups in groups from DB
SELECT * FROM group_group_membership;

-- Get all task statuses from DB
SELECT * FROM task_statuses;

-- Get all tasks from DB
SELECT * FROM tasks;

-- Get all task membership from DB
SELECT * FROM task_membership;

-- Get all task control membership from DB
SELECT * FROM task_control_membership;

-- Get all attachments from DB
SELECT * FROM attachments;

-- Get all attachments membership from DB
SELECT * FROM attachment_membership;
