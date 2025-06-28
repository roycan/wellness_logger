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

Each object within the `entries` array represents a single wellness log.

| Key           | Type     | Description                                                                 | Example                                   |
| :------------ | :------- | :-------------------------------------------------------------------------- | :---------------------------------------- |
| `id`          | `String` | A unique identifier for the log entry.                                      | `"log-1698399600000"`                     |
| `date`        | `String` | The date of the log in `YYYY-MM-DD` format.                                 | `"2023-10-27"`                            |
| `mood`        | `String` | The user's recorded mood.                                                   | `"Happy"`                                 |
| `sleep`       | `Number` | Hours of sleep recorded.                                                    | `8`                                       |
| `activities`  | `Array`  | A list of activities performed. Can be an array of strings.                 | `["Exercise", "Meditation"]`              |
| `notes`       | `String` | Any additional notes or comments for the day.                               | `"Felt great after the morning workout."` |
| `medications` | `Array`  | A list of medications taken. Each item is an object with `name` and `dosage`. | `[{"name": "Vitamin D", "dosage": "1000 IU"}]` |
| `timestamp`   | `Number` | The epoch timestamp (in milliseconds) when the entry was created.           | `1698399600000`                           |

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
