package models;

import java.time.Instant;

public class ParameterInfo {
    private final String name;
    private final String value;
    private final String type;
    private final Instant lastModifiedDate;
    private final Long version;

    public ParameterInfo(String name, String value, String type, Instant lastModifiedDate, Long version) {
        this.name = name;
        this.value = value;
        this.type = type;
        this.lastModifiedDate = lastModifiedDate;
        this.version = version;
    }

    public String getName() {
        return name;
    }

    public String getValue() {
        return value;
    }

    public String getType() {
        return type;
    }

    public Instant getLastModifiedDate() {
        return lastModifiedDate;
    }

    public Long getVersion() {
        return version;
    }

    public String getMaskedValue() {
        if (value == null || value.isEmpty()) {
            return "***";
        }
        if (value.length() <= 4) {
            return "***";
        }
        return value.substring(0, 2) + "***" + value.substring(value.length() - 2);
    }

    public String getFormattedLastModified() {
        if (lastModifiedDate == null) return "Unknown";
        return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(java.util.Date.from(lastModifiedDate));
    }
}
