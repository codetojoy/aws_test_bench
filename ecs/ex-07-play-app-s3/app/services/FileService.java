package services;

import models.FileInfo;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

import javax.inject.Inject;
import javax.inject.Singleton;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Singleton
public class FileService {
    private final S3Client s3Client;
    private final String bucketName;

    @Inject
    public FileService() {
        String regionStr = System.getenv("AWS_REGION");
        if (regionStr == null || regionStr.isEmpty()) {
            regionStr = "us-east-1";
        }

        this.bucketName = System.getenv("S3_BUCKET_NAME");

        this.s3Client = S3Client.builder()
                .region(Region.of(regionStr))
                .build();
    }

    public List<FileInfo> listFiles() {
        List<FileInfo> files = new ArrayList<>();

        if (bucketName == null || bucketName.isEmpty()) {
            return files;
        }

        try {
            ListObjectsV2Request listRequest = ListObjectsV2Request.builder()
                    .bucket(bucketName)
                    .build();

            ListObjectsV2Response listResponse = s3Client.listObjectsV2(listRequest);

            for (S3Object s3Object : listResponse.contents()) {
                Map<String, String> metadata = getObjectMetadata(s3Object.key());

                FileInfo fileInfo = new FileInfo(
                        s3Object.key(),
                        s3Object.size(),
                        s3Object.lastModified(),
                        metadata
                );
                files.add(fileInfo);
            }
        } catch (S3Exception e) {
            System.err.println("Error listing S3 objects: " + e.awsErrorDetails().errorMessage());
        }

        return files;
    }

    private Map<String, String> getObjectMetadata(String key) {
        Map<String, String> metadata = new HashMap<>();

        try {
            HeadObjectRequest headRequest = HeadObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            HeadObjectResponse headResponse = s3Client.headObject(headRequest);

            if (headResponse.contentType() != null) {
                metadata.put("Content-Type", headResponse.contentType());
            }

            if (headResponse.metadata() != null) {
                metadata.putAll(headResponse.metadata());
            }
        } catch (S3Exception e) {
            System.err.println("Error getting metadata for " + key + ": " + e.awsErrorDetails().errorMessage());
        }

        return metadata;
    }

    public String getBucketName() {
        return bucketName;
    }
}
