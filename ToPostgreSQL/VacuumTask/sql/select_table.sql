SELECT
  relname
FROM
  pg_stat_user_tables
WHERE
  n_dead_tup > 0
