package services;

import models.ParameterInfo;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.ssm.SsmClient;
import software.amazon.awssdk.services.ssm.model.*;

import javax.inject.Inject;
import javax.inject.Singleton;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Singleton
public class ParameterService {
    private final SsmClient ssmClient;

    @Inject
    public ParameterService() {
        String regionStr = System.getenv("AWS_REGION");
        if (regionStr == null || regionStr.isEmpty()) {
            regionStr = "us-east-1";
        }

        this.ssmClient = SsmClient.builder()
                .region(Region.of(regionStr))
                .build();
    }

    public List<ParameterInfo> getParameterValues() {
        List<ParameterInfo> parameters = new ArrayList<>();

        try {
            DescribeParametersRequest describeRequest = DescribeParametersRequest.builder()
                    .build();

            DescribeParametersResponse describeResponse = ssmClient.describeParameters(describeRequest);

            List<String> parameterNames = describeResponse.parameters().stream()
                    .map(ParameterMetadata::name)
                    .collect(Collectors.toList());

            if (!parameterNames.isEmpty()) {
                GetParametersRequest getRequest = GetParametersRequest.builder()
                        .names(parameterNames)
                        .withDecryption(true)
                        .build();

                GetParametersResponse getResponse = ssmClient.getParameters(getRequest);

                for (Parameter param : getResponse.parameters()) {
                    ParameterInfo paramInfo = new ParameterInfo(
                            param.name(),
                            param.value(),
                            param.typeAsString(),
                            param.lastModifiedDate(),
                            param.version()
                    );
                    parameters.add(paramInfo);
                }
            }
        } catch (SsmException e) {
            System.err.println("Error getting SSM parameters: " + e.awsErrorDetails().errorMessage());
        }

        return parameters;
    }
}
