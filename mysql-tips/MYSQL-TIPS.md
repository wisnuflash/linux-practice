# MySQL Troubleshooting & Performance Guide

## 🔧 Fix "MySQL Server Has Gone Away" Error

The "MySQL server has gone away" error typically occurs due to connection timeouts or packet size limitations.

### Configuration Parameters

Add these settings to your MySQL configuration file (`/etc/mysql/my.cnf` or `/etc/mysql/mysql.conf.d/mysqld.cnf`):

```ini
[mysqld]
max_allowed_packet = 512M
wait_timeout = 1000
interactive_timeout = 1000
```

**Note:** If the error persists, increase these values further:
- `max_allowed_packet = 1024M` (or higher)
- `wait_timeout = 2000`
- `interactive_timeout = 2000`

## 🔧 Fix SQL "ONLY_FULL_GROUP_BY" Mode Issues

### For Docker Containers

1. **Access the container as root:**
```bash
sudo docker exec -it container_name bash
```

2. **Connect to MySQL and update sql_mode:**
```sql
mysql> SET GLOBAL sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
mysql> SET SESSION sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
mysql> EXIT;
```

### For Ubuntu/Linux Systems

Add this line to `/etc/mysql/my.cnf` under the `[mysqld]` section:

```ini
[mysqld]
sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
```

### Special Cases

**Fix for "0000-00-00" date issues:**
```ini
sql_mode = "STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
```

**Fix for integer null value issues (for FBT):**
```ini
sql_mode = "ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
```

## ⚡ Performance Optimization

### InnoDB & Thread Configuration

Add these settings to improve MySQL performance:

```ini
[mysqld]
# Set based on CPU cores (recommended: 50-60% of total cores)
innodb_thread_concurrency = 8

# Handle new connections efficiently (multiply default by 2-4x)
# Default is usually 8-18, increase to 36-72
thread_cache_size = 36
```

**Guidelines:**
- `innodb_thread_concurrency`: Set to 50-60% of your CPU cores
- `thread_cache_size`: Start with 2-4x the default value (usually 36-72)

## 📊 Advanced Performance Monitoring

### 1. Real-time Performance Schema Queries

**Check Current Running Queries:**
```sql
SELECT 
    pst.thread_id,
    pst.processlist_id,
    pst.processlist_user,
    pst.processlist_host,
    pst.processlist_db,
    pst.processlist_command,
    pst.processlist_time,
    pst.processlist_state,
    pst.processlist_info,
    pst.connection_type,
    format_pico_time(pst.processlist_time) as formatted_time
FROM performance_schema.threads pst
WHERE pst.processlist_command != 'Sleep'
ORDER BY pst.processlist_time DESC;
```

**Memory Usage by Thread:**
```sql
SELECT 
    t.processlist_id,
    t.processlist_user,
    t.processlist_host,
    t.processlist_db,
    format_bytes(mem.current_allocated) as current_memory,
    format_bytes(mem.total_allocated) as total_allocated
FROM performance_schema.threads t
JOIN performance_schema.memory_summary_by_thread_by_event_name mem
    ON t.thread_id = mem.thread_id
WHERE t.processlist_id IS NOT NULL
    AND mem.event_name = 'memory/sql/THD::main_mem_root'
ORDER BY mem.current_allocated DESC
LIMIT 10;
```

**Top Resource Consuming Statements:**
```sql
SELECT 
    digest_text,
    count_star as executions,
    format_pico_time(avg_timer_wait) as avg_latency,
    format_pico_time(max_timer_wait) as max_latency,
    format_bytes(avg_memory_used) as avg_memory,
    avg_rows_examined,
    avg_rows_sent,
    first_seen,
    last_seen
FROM performance_schema.events_statements_summary_by_digest 
ORDER BY avg_timer_wait DESC 
LIMIT 10;
```

### 2. Advanced InnoDB Monitoring

**Buffer Pool Usage:**
```sql
SELECT 
    pool_id,
    pool_size,
    free_buffers,
    database_pages,
    old_database_pages,
    modified_database_pages,
    pending_decompress,
    pending_reads,
    pending_flush_lru,
    pending_flush_list
FROM information_schema.innodb_buffer_pool_stats;
```

**Lock Waits and Deadlocks:**
```sql
SELECT 
    r.trx_id waiting_trx_id,
    r.trx_mysql_thread_id waiting_thread,
    r.trx_query waiting_query,
    b.trx_id blocking_trx_id,
    b.trx_mysql_thread_id blocking_thread,
    b.trx_query blocking_query
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;
```

### 3. Connection and Thread Monitoring

**Connection Statistics:**
```sql
SELECT 
    processlist_user as user,
    processlist_host as host,
    COUNT(*) as connections,
    SUM(CASE WHEN processlist_command = 'Sleep' THEN 1 ELSE 0 END) as sleeping,
    SUM(CASE WHEN processlist_command != 'Sleep' THEN 1 ELSE 0 END) as active
FROM performance_schema.threads 
WHERE processlist_id IS NOT NULL
GROUP BY processlist_user, processlist_host
ORDER BY connections DESC;
```

**Thread Cache Efficiency:**
```sql
SELECT 
    VARIABLE_NAME,
    VARIABLE_VALUE
FROM performance_schema.global_status 
WHERE VARIABLE_NAME IN (
    'Threads_cached',
    'Threads_connected', 
    'Threads_created',
    'Threads_running'
);
```

### 4. I/O Performance Analysis

**Table I/O Statistics:**
```sql
SELECT 
    object_schema,
    object_name,
    count_read,
    count_write,
    count_fetch,
    count_insert,
    count_update,
    count_delete,
    format_pico_time(sum_timer_read) as total_read_time,
    format_pico_time(sum_timer_write) as total_write_time
FROM performance_schema.table_io_waits_summary_by_table
WHERE object_schema NOT IN ('mysql', 'information_schema', 'performance_schema')
ORDER BY sum_timer_read + sum_timer_write DESC
LIMIT 10;
```

**File I/O Summary:**
```sql
SELECT 
    event_name,
    count_star as operations,
    format_bytes(sum_number_of_bytes_read) as bytes_read,
    format_bytes(sum_number_of_bytes_write) as bytes_written,
    format_pico_time(sum_timer_read) as read_time,
    format_pico_time(sum_timer_write) as write_time
FROM performance_schema.file_summary_by_event_name
WHERE count_star > 0
ORDER BY sum_timer_read + sum_timer_write DESC
LIMIT 10;
```

### 5. Legacy Monitoring (Still Useful)

**Check InnoDB Status:**
```sql
SHOW ENGINE INNODB STATUS\G
```

**Check Index Efficiency:**
```sql
SHOW STATUS LIKE 'Handler%';
```

**Key Handler metrics to monitor:**
- `Handler_read_rnd_next`: High values indicate table scans
- `Handler_read_key`: Shows index usage
- `Handler_read_rnd`: Random reads (should be low)

## 🔮 Future Improvements & Modern Monitoring

### 1. Monitoring Tools Integration

**Open Source Tools:**
- **Percona Monitoring and Management (PMM)**: Free, open-source platform for monitoring MySQL database performance with real-time server data
- **Grafana + Prometheus**: Custom dashboards with MySQL exporter
- **MySQL Workbench**: Built-in performance dashboard and reports
- **SYS Schema**: Simplified views of Performance Schema data

**Enterprise/Cloud Solutions:**
- **MySQL Enterprise Monitor**: Real-time monitoring with no agent required
- **Datadog**: Query-level metrics with execution time analysis
- **New Relic & Dynatrace**: Application performance insights
- **AWS RDS Performance Insights**: For AWS RDS MySQL instances

### 2. Automated Alerting & Thresholds

**Key Metrics to Monitor:**
```sql
-- CPU Usage Alert
SELECT 
    CASE WHEN (
        SELECT VARIABLE_VALUE 
        FROM performance_schema.global_status 
        WHERE VARIABLE_NAME = 'Threads_running'
    ) > 10 THEN 'HIGH_CPU_ALERT' ELSE 'CPU_OK' END as cpu_status;

-- Memory Usage Alert  
SELECT 
    CASE WHEN (
        SELECT VARIABLE_VALUE 
        FROM performance_schema.global_variables 
        WHERE VARIABLE_NAME = 'innodb_buffer_pool_size'
    ) * 0.9 < (
        SELECT database_pages * @@innodb_page_size 
        FROM information_schema.innodb_buffer_pool_stats
    ) THEN 'MEMORY_PRESSURE_ALERT' ELSE 'MEMORY_OK' END as memory_status;
```

**Recommended Alert Thresholds:**
- Connection usage > 80% of max_connections
- Buffer pool hit ratio < 95%
- Slow query rate > 5% of total queries
- Replication lag > 60 seconds
- Disk space usage > 85%

### 3. Performance Schema 2.0 Features

**Advanced Event Filtering:**
```sql
-- Enable specific instruments
UPDATE performance_schema.setup_instruments 
SET ENABLED = 'YES', TIMED = 'YES' 
WHERE NAME = 'statement/sql/select';

-- Configure event retention
UPDATE performance_schema.setup_consumers 
SET ENABLED = 'YES' 
WHERE NAME = 'events_statements_history_long';
```

**Query Profiling with Performance Schema:**
```sql
-- Profile specific query execution
SELECT 
    event_name,
    count_star,
    format_pico_time(sum_timer_wait) as total_time,
    format_pico_time(avg_timer_wait) as avg_time
FROM performance_schema.events_stages_summary_global_by_event_name
WHERE event_name LIKE 'stage/sql/%'
ORDER BY sum_timer_wait DESC;
```

### 4. Cloud-Native Monitoring

**Container/Kubernetes Monitoring:**
```yaml
# Example Prometheus MySQL Exporter config
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-exporter-config
data:
  .my.cnf: |
    [client]
    user=exporter
    password=password
    host=mysql-service
```

**Docker Health Checks:**
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
CMD mysqladmin ping -h localhost -u health_check_user -p$MYSQL_PASSWORD || exit 1
```

### 5. Predictive Analytics & AI

**Query Pattern Analysis:**
- Machine learning for query optimization suggestions
- Predictive scaling based on historical patterns
- Anomaly detection for unusual performance patterns

**Automated Tuning Recommendations:**
- Configuration parameter optimization
- Index recommendation engines
- Query rewrite suggestions

### 6. Next-Generation Monitoring Features

**Real-time Streaming Metrics:**
- WebSocket-based live monitoring dashboards
- Real-time query execution visualization
- Live performance heatmaps

**Multi-dimensional Analysis:**
- Cross-correlation of application and database metrics  
- Business impact analysis of database performance
- Cost optimization recommendations

## 🔄 Applying Changes

### Restart MySQL Service
```bash
# Ubuntu/Debian
sudo systemctl restart mysql

# CentOS/RHEL
sudo systemctl restart mysqld

# Docker
docker restart container_name
```

### Verify Configuration
```sql
SHOW VARIABLES LIKE 'max_allowed_packet';
SHOW VARIABLES LIKE '%timeout%';
SHOW VARIABLES LIKE 'sql_mode';
```

## 📝 Quick Reference

| Issue | Solution |
|-------|----------|
| Server Gone Away | Increase `max_allowed_packet`, `wait_timeout`, `interactive_timeout` |
| GROUP BY Errors | Modify `sql_mode` to remove `ONLY_FULL_GROUP_BY` |
| Date Issues (0000-00-00) | Remove `NO_ZERO_DATE` from `sql_mode` |
| Slow Performance | Tune `innodb_thread_concurrency` and `thread_cache_size` |
| Slow Queries | Use performance_schema queries to identify bottlenecks |

## ⚠️ Important Notes

- Always backup your database before making configuration changes
- Test configuration changes in a development environment first
- Monitor system resources after applying performance optimizations
- Restart MySQL service after configuration file changes