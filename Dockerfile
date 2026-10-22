# Use the official Tomcat 9 image with Java 11
FROM tomcat:9.0-jdk11-corretto

# Remove the default Tomcat applications (we deploy our own war)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the war file and the entry point
COPY attendance.war /usr/local/tomcat/webapps/attendance.war
COPY entrypoint.sh /usr/local/tomcat/bin/entrypoint.sh
RUN chmod +x /usr/local/tomcat/bin/entrypoint.sh

# Keep the JVM heap small (free plan has 512 MB)
ENV CATALINA_OPTS="-Xmx256m"

EXPOSE 8080
CMD ["/usr/local/tomcat/bin/entrypoint.sh"]
