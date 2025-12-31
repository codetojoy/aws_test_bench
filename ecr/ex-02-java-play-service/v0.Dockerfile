FROM amazoncorretto:21

WORKDIR /app

COPY play-ex-02.jar /app/play-ex-02.jar

EXPOSE 9000

CMD ["java", "-jar", "play-ex-02.jar"]
