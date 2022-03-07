-- Connect to DB
\c simpletask;

-- Get all tasks for ptsypyshev with 'in_progress' status
SELECT *
FROM tasks
WHERE
    responsible IN (SELECT id FROM users WHERE LOGIN = 'ptsypyshev')
    AND
    task_status IN (SELECT id FROM task_statuses WHERE task_status_name = 'in_progress')
;

-- Get all attachments for task number 2
SELECT t.id, a.attachment_link
FROM tasks t
LEFT JOIN attachment_membership am
ON t.id = am.task_id
LEFT JOIN attachments a
ON a.id = am.attachment_id
WHERE t.id = 2
;

-- Get all children tasks for task number 3 (one level down)
SELECT parent_id, child_id
FROM task_membership
WHERE parent_id = 3;

-- Get all children tasks for task number 3 recursive (all nested levels)
WITH RECURSIVE tm_chain(parent_id, child_id) AS (
    SELECT parent_id, child_id
    FROM task_membership
    WHERE parent_id = 3

    UNION

    SELECT tm.parent_id, tm.child_id
    FROM task_membership tm
    JOIN tm_chain tmc
    ON tmc.child_id = tm.parent_id
)
SELECT *
FROM tm_chain;

-- Get all tasks controlled by user 'ppetrov'
SELECT tcm.task_id
FROM users u
LEFT JOIN task_control_membership tcm
ON u.id = tcm.controller_id
WHERE u.login = 'ppetrov';