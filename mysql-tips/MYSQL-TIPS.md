# MYSQL TIPS
## FIX GONE AWAY  MYSQL 
### MENAIKAN 
: max_allowed_packet =512M \
: wait_timeout= 1000 \
: interaktive_timeout =1000   \
jika masih gone away coba naikan lebih tinggi

## FIX SQL ONLY GROUP BY 
### untuk yang menggunakan docker bisa docker exec dulu dan masuk user root nya;
```python
sudo docker exec -it container_name bash
```
```python
mysql> set global sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
mysql> set session sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
0mysql> exit;
```
### jika menggunakan ubuntu setting di /etc/mysql/my.cnf tambahkan : 
      sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

### fix 00-00-000 date mysql tidak dizinkan
      sql_mode = "STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

### fix integer disallow null value  for fbt 
      sql_mode = "ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
