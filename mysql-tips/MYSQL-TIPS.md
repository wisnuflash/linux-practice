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

## 📊 Query Performance Monitoring

### Check InnoDB Status
```sql
SHOW ENGINE INNODB STATUS\G
```

### Identify Slow Queries
```sql
SELECT 
    DIGEST_TEXT, 
    COUNT_STAR, 
    SUM_TIMER_WAIT/1000000000000 AS total_time_sec 
FROM performance_schema.events_statements_summary_by_digest 
ORDER BY total_time_sec DESC 
LIMIT 10;
```

### Check Index Efficiency
```sql
SHOW STATUS LIKE 'Handler%';
```

**Key metrics to monitor:**
- `Handler_read_rnd_next`: High values indicate table scans
- `Handler_read_key`: Shows index usage
- `Handler_read_rnd`: Random reads (should be low)

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