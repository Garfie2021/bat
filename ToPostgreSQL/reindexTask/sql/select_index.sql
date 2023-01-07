SELECT indexrelname
FROM pg_stat_user_indexes
WHERE relname in (
  SELECT tablename 
  FROM pg_tables 
  WHERE schemaname not like 'pg_%' and schemaname != 'information_schema'
) AND (idx_scan > 0 OR idx_tup_read > 0 OR idx_tup_fetch > 0)
