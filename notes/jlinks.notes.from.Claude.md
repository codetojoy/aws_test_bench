
### Question

Without taking any action, do you think it is worth investigating jlink from the JDK to try and trim the modules used by the JDK? I'm concerned that it will have marginal gains in terms of size reduction, and be fairly complicated to maintain. What is your view?

### Claude:

I agree with your assessment - jlink is probably not worth it for this use case. Here's my reasoning:

Marginal gains:

* You're already at ~200-250 MB with Alpine JRE
* jlink might save another 50-100 MB at best (getting you to ~150-200 MB)
* For ECR/ECS deployment, this difference is negligible in terms of:
    * Pull times (minimal difference on AWS infrastructure)
    * Storage costs (pennies per month difference)
    * Cold start performance (not significantly impacted)
    * High maintenance cost:

* You'd need to analyze which JDK modules Play Framework actually uses (not trivial)
* Play uses reflection heavily, which makes module detection tricky
* Every dependency update could require re-validating the module set
* Runtime failures from missing modules are hard to debug
* The jlink configuration would add complexity to your build process
* When jlink DOES make sense:
    * Lambda functions (where every MB affects cold start)
    * Embedded/IoT deployments (severe size constraints)
    * Distributing desktop applications
    * Situations where you control the entire dependency tree

* Better optimization opportunities (if you really need smaller images):
    * Distroless images (Google's distroless Java images can be smaller)
    * UPX compression on the JAR (rarely worth the complexity)
    * Removing unused dependencies from build.sbt

My recommendation: Stick with your current Alpine-based solution. You've already achieved the 80/20 rule - you got 50% size reduction with minimal complexity. The additional effort for jlink would violate the principle of avoiding over-engineering for minimal gains.


