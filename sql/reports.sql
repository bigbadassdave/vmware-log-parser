--------------------------------------------------------------------------------
-- average and extreme logon times
--------------------------------------------------------------------------------

-- average logon time
SELECT AVG(total) AS average_logon
FROM logon_times;

-- average logon time in the last 5 minutes
SELECT AVG(total) AS average_logon_last_5_minutes
FROM logon_times
WHERE (NOW() - completed_at_server) < 300;

-- average logon time within 1 standard deviation (68% of population)
SELECT AVG(total) + STDDEV(total) AS average_logon_1_std_dev
FROM logon_times;

-- average logon time within 3 standard deviations (0.1% of population)
SELECT AVG(total) + (3*STDDEV(total)) AS average_logon_3_std_dev
FROM logon_times;

-- all logins that took longer than 3 standard deviations
SELECT total, completed_at_server, username, filename
FROM logon_times
WHERE total > (SELECT AVG(total) + (3*STDDEV(total)) FROM logon_times)
ORDER BY total DESC;

-- summary of users with logins *repeatedly* longer than 3 standard deviations
SELECT AVG(total) AS average_logon, COUNT(id) AS count_logons, username
FROM logon_times
WHERE total > (SELECT AVG(total) + (3*STDDEV(total)) FROM logon_times)
GROUP BY username
HAVING count_logons > 1
ORDER BY count_logons DESC;

-- all logins that took longer than 1 minute
SELECT total, completed_at_server, username, filename
FROM logon_times
WHERE total > 60
ORDER BY total DESC;

-- summary of users with logins *repeatedly* longer than 1 minute
SELECT AVG(total) AS average_logon, COUNT(id) AS count_logons, username
FROM logon_times
WHERE total > 60
GROUP BY username
HAVING count_logons > 1
ORDER BY count_logons DESC;

--------------------------------------------------------------------------------
-- timezone differences
--------------------------------------------------------------------------------

-- logons with more than 5 minute client-server difference
SELECT TIMEDIFF(completed_at_server, completed_at_client) AS difference,
    completed_at_server, completed_at_client, total, username, filename
FROM logon_times
WHERE ABS(TIMESTAMPDIFF(MINUTE, completed_at_server, completed_at_client)) > 5;

-- summary of logons with more than 5 minute client-server difference
SELECT SEC_TO_TIME(AVG(TIMESTAMPDIFF(SECOND, completed_at_server, completed_at_client))) AS average_difference,
    COUNT(id) AS count_logons,
    AVG(total) AS average_total,
    username
FROM logon_times
WHERE ABS(TIMESTAMPDIFF(MINUTE, completed_at_server, completed_at_client)) > 5
GROUP BY username
ORDER BY average_difference;
