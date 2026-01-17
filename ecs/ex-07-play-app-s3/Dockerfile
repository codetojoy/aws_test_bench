FROM amazoncorretto:21-alpine-jdk AS builder

WORKDIR /app

COPY play-ecs-ex-07.jar /app/play-ecs-ex-07.jar

FROM amazoncorretto:21-alpine

WORKDIR /app

COPY --from=builder /app/play-ecs-ex-07.jar /app/play-ecs-ex-07.jar

EXPOSE 9000

CMD ["java", "-jar", "play-ecs-ex-07.jar"]
