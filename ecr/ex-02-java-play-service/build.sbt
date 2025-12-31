name := "play-ex-02"

version := "1.0.0"

lazy val root = (project in file("."))
  .enablePlugins(PlayJava)
  .settings(
    scalaVersion := "2.13.12",
    javacOptions ++= Seq("-source", "21", "-target", "21"),
    libraryDependencies ++= Seq(
      guice
    ),
    // Assembly settings for fat JAR
    assembly / assemblyJarName := "play-ex-02.jar",
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
