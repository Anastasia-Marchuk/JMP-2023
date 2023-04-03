
# Project Builders 

Test build project using Maven and Gradle scripts


## Build application: Maven 
start only tests
```
mvn clean test
```
build project
```
mvn clean install
```
for start web-app...
```
mvn jetty:run
```
This starts application and serves up your project on [http://localhost:8085](http://localhost:8085) for web-app
## Build application: Gradle

build project
```
./gradlew clean build
```

start only tests
```
./gradlew clean test
```

