FROM maven as build
WORKDIR /app
COPY . .
RUN mvn package -DskipTests

FROM tomcat
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
CMD ["catalina.sh", "run"]
EXPOSE 8080
