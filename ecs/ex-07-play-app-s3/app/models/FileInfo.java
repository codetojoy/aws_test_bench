package models;

import java.time.Instant;
import java.util.Map;

public class FileInfo {
    private final String key;
    private final Long size;
    private final Instant lastModified;
    private final Map<String, String> metadata;

    public FileInfo(String key, Long size, Instant lastModified, Map<String, String> metadata) {
        this.key = key;
        this.size = size;
        this.lastModified = lastModified;
        this.metadata = metadata;
    }

    public String getKey() {
        return key;
    }

    public Long getSize() {
        return size;
    }

    public Instant getLastModified() {
        return lastModified;
    }

    public Map<String, String> getMetadata() {
        return metadata;
    }

    public String getFormattedSize() {
        if (size == null) return "Unknown";
        if (size < 1024) return size + " B";
        if (size < 1024 * 1024) return String.format("%.2f KB", size / 1024.0);
        if (size < 1024 * 1024 * 1024) return String.format("%.2f MB", size / (1024.0 * 1024));
        return String.format("%.2f GB", size / (1024.0 * 1024 * 1024));
    }

    public String getFormattedLastModified() {
        if (lastModified == null) return "Unknown";
        return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(java.util.Date.from(lastModified));
    }
}
