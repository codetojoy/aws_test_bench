FROM amazoncorretto:21-alpine-jdk AS builder

WORKDIR /app

COPY play-ex-02.jar /app/play-ex-02.jar

FROM amazoncorretto:21-alpine

WORKDIR /app

COPY --from=builder /app/play-ex-02.jar /app/play-ex-02.jar

EXPOSE 9000

CMD ["java", "-jar", "play-ex-02.jar"]
