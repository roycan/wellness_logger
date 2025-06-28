# Cross-Platform Compatibility Guide

This document outlines the technical details of the JSON data format used for export and import in the Wellness Logger application, ensuring compatibility between the web and mobile versions.

## JSON Data Structure

To maintain interoperability, both the web and mobile applications adhere to a standardized JSON structure for data exchange. The root of the JSON object contains metadata and the primary data payload.

### Root Object Properties

| Key            | Type     | Description                                                                                                                        | Example                               |
| :------------- | :------- | :--------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------ |
| `version`      | `String` | The application version from which the data was exported.                                                                          | `"1.1.0"`                             |
| `exportedAt`   | `String` | An ISO 8601 timestamp indicating when the export was generated.                                                                    | `"2023-10-27T10:00:00Z"`              |
| `source`       | `String` | Indicates the platform of origin. Can be `"web"` or `"mobile"`.                                                                    | `"web"`                               |
| `totalEntries` | `Number` | The total number of wellness log entries included in the export.                                                                   | `150`                                 |
| `entries`      | `Array`  | An array of wellness log entry objects. This is the main data payload. See the [Entry Object Structure](#entry-object-structure) below. | `[...]`                               |

### Entry Object Structure

Each object within the `entries` array represents a single wellness log entry.

| Key           | Type     | Description                                                                 | Example                                   |
| :------------ | :------- | :-------------------------------------------------------------------------- | :---------------------------------------- |
| `id`          | `String` | A unique identifier for the log entry.                                      | `"1750652909142"`                         |
| `type`        | `String` | The type of wellness entry (Exercise, SVT Episode, Medication).             | `"Exercise"`                              |
| `timestamp`   | `String` | ISO 8601 timestamp indicating when the entry occurred.                      | `"2025-06-23T10:28:00.000"`               |
| `details`     | `Object` | An object containing type-specific details for the entry.                   | `{"duration": "10 minutes"}`              |

#### Details Object Properties

The `details` object contains different properties based on the entry type:

**For Exercise entries:**
- `duration` (String): How long the exercise lasted (e.g., "10 minutes", "1 hour")
- `comments` (String, optional): Additional notes about the exercise

**For SVT Episode entries:**
- `duration` (String): How long the episode lasted (e.g., "1 minute", "30 seconds")
- `comments` (String, optional): Additional symptoms or notes

**For Medication entries:**
- `dosage` (String): The amount taken (e.g., "1/2 tablet", "10mg")
- `comments` (String, optional): Additional notes about the medication

## Compatibility Notes

### Web Application

*   **Export:** The web app exports data in the standard JSON object format described above.
*   **Import:** The web app is backward-compatible. It can import:
    1.  The standard JSON object format (from mobile or newer web exports).
    2.  A legacy JSON array format (from older web app exports), which is a simple array of entry objects.

### Mobile Application (Flutter)

*   **Export:** The mobile app exports data in the standard JSON object format.
*   **Import:** The mobile app currently only supports the standard JSON object format. It will fail to import the legacy array format.

This unified JSON structure ensures that users can seamlessly move their data between platforms while allowing for future evolution of the data model.
