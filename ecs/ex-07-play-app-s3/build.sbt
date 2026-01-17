name := "play-07"

version := "1.0.0"

lazy val root = (project in file("."))
  .enablePlugins(PlayJava)
  .settings(
    scalaVersion := "2.13.12",
    javacOptions ++= Seq("-source", "21", "-target", "21"),
    libraryDependencies ++= Seq(
      guice,
      "software.amazon.awssdk" % "s3" % "2.25.16",
      "software.amazon.awssdk" % "ssm" % "2.25.16"
    ),
    // Assembly settings for fat JAR
    assembly / assemblyJarName := "play-ecs-ex-07.jar",
    assembly / mainClass := Some("play.core.server.ProdServerStart"),
    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", "MANIFEST.MF") => MergeStrategy.discard
      case PathList("META-INF", xs @ _*) => MergeStrategy.first
      case PathList("reference.conf") => MergeStrategy.concat
      case PathList("application.conf") => MergeStrategy.concat
      case "module-info.class" => MergeStrategy.discard
      case x if x.endsWith(".proto") => MergeStrategy.first
      case x if x.contains("io.netty.versions.properties") => MergeStrategy.first
      case x => MergeStrategy.first
    }
  )
