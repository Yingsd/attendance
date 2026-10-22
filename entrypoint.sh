#!/bin/bash
# The platform runs this container with a READ-ONLY root filesystem.
# Tomcat must write conf (port patch), logs, work and webapps expansion,
# so we build a writable CATALINA_BASE under /tmp at startup.
set -e

BASE=/tmp/tomcat
rm -rf "$BASE"
mkdir -p "$BASE"/conf "$BASE"/logs "$BASE"/temp "$BASE"/work "$BASE"/webapps
cp -r "$CATALINA_HOME"/conf/* "$BASE"/conf/

# the war we want to serve
cp "$CATALINA_HOME"/webapps/attendance.war "$BASE"/webapps/

# a tiny ROOT page so that "/" is healthy and redirects to /attendance/
mkdir -p "$BASE"/webapps/ROOT
cat > "$BASE"/webapps/ROOT/index.html <<'HTML'
<!DOCTYPE html><html><head><meta charset="UTF-8"><meta http-equiv="refresh" content="0;url=/attendance/"><title>Simple Attendance by Seat Id</title></head><body><a href="/attendance/">Simple Attendance by Seat Id</a></body></html>
HTML

export CATALINA_BASE="$BASE"
export CATALINA_PID="$BASE/tomcat.pid"
export JAVA_OPTS="$JAVA_OPTS -Djava.io.tmpdir=$BASE/temp"

# follow the port the platform gives us
if [ -n "$PORT" ] && [ "$PORT" != "8080" ]; then
  sed -i "s/port=\"8080\"/port=\"$PORT\"/" "$BASE/conf/server.xml"
fi

exec "$CATALINA_HOME/bin/catalina.sh" run
