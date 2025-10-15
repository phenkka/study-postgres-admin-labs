#!/bin/bash
LOG_DIR="/var/lib/postgresql/data/log"
OUT="/backups/monitor_log.txt"

FAIL_COUNT=$(grep -h "password authentication failed" "$LOG_DIR"/postgresql-*.log 2>/dev/null | wc -l)

echo "$(date): $FAIL_COUNT failed login(s) found" >> $OUT

if [ "$FAIL_COUNT" -gt 3 ]; then
  echo "$(date): ALERT! $FAIL_COUNT failed login attempts detected!" >> $OUT
  mail -s "ALERT: PostgreSQL login failures" phenkka21@gmail.com
fi
