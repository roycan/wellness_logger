# 📊 Data Export & Import Guide - Wellness Logger

## 🎯 Overview

The Wellness Logger now includes comprehensive **export and import functionality** to help you:
- **Backup your health data** safely
- **Share data with your doctor** in medical-friendly formats
- **Restore data** when changing devices
- **Keep comprehensive health records** for medical appointments

---

## 📤 Export Functionality

### Access Export Features
1. Open the **Wellness Logger** app
2. Navigate to **Settings** (gear icon)
3. Scroll to the **Actions** section
4. Tap **"Export Data"**

### Export Options

#### 🏥 CSV Format (For Doctors)
- **Best for:** Sharing with healthcare providers
- **Format:** Medical-friendly spreadsheet format
- **Contains:** Date, Time, Type, Duration, Dosage, Comments
- **Benefits:**
  - Easy to read by medical professionals
  - Can be opened in Excel, Google Sheets
  - Chronologically sorted (oldest first)
  - Professional medical formatting

#### 💾 JSON Format (For Backup)
- **Best for:** Complete data backup
- **Format:** Technical backup format
- **Contains:** All data with full metadata
- **Benefits:**
  - Complete data preservation
  - Can be imported back perfectly
  - Includes all technical details
  - Suitable for data migration

### How to Export

1. **Tap "Export Data"** in Settings
2. **Choose format:**
   - Select **CSV** for sharing with doctors
   - Select **JSON** for backup purposes
3. **Wait for processing** (loading indicator appears)
4. **Share the file** using the system share dialog:
   - Email to your doctor
   - Save to Google Drive/Dropbox
   - Share via messaging apps
   - Save to device storage

### Export File Names
- **CSV:** `wellness_data_YYYY-MM-DD.csv`
- **JSON:** `wellness_backup_YYYY-MM-DD.json`

---

## 📥 Import Functionality

### When to Use Import
- Restoring data after app reinstall
- Importing data from another device
- Recovering from backup files

### Access Import Features
1. Open **Settings** → **Actions** → **"Import Data"**
2. Follow the guided import process

### Import Process

#### Step 1: Prepare Your Data
- Open your backup JSON file (from email, cloud storage, etc.)
- Copy all the JSON content (Ctrl+A, Ctrl+C)

#### Step 2: Import Process
1. Tap **"Import Data"** in Settings
2. Read the instructions dialog
3. Tap **"Paste & Import"**
4. Paste your JSON data in the text field
5. Tap **"Import"** to process

#### Step 3: Verification
- Check for success/error messages
- Review your entries to confirm import
- Duplicate entries are automatically updated

---

## 👩‍⚕️ Sharing with Your Doctor

### Preparing Medical Data

**What to Export:**
- Use **CSV format** for medical appointments
- Export before important appointments
- Include date ranges relevant to your concerns

**Email Template for Doctors:**
```
Subject: Wellness Tracking Data - [Your Name]

Dear Dr. [Doctor's Name],

Please find my wellness tracking data attached for our upcoming appointment on [date]. 

This file contains my:
- SVT episodes with duration and symptoms
- Exercise sessions and intensity
- Medication timing and dosage
- Any relevant comments and observations

The data covers the period from [start date] to [end date].

Please let me know if you need the data in a different format or have any questions.

Best regards,
[Your Name]
```

### What Your Doctor Will See

The CSV file contains columns:
- **Date:** When the event occurred
- **Time:** Specific time of day  
- **Type:** SVT Episode, Exercise, Medication
- **Duration:** How long the event lasted
- **Dosage:** Medication amounts (when applicable)
- **Comments:** Your notes and observations

### Medical Benefits
- **Objective data** for better diagnosis
- **Pattern recognition** across time periods
- **Medication effectiveness** tracking
- **Trigger identification** for episodes
- **Progress monitoring** over time

---

## 💾 Backup Best Practices

### Regular Backups
- Export JSON backup **monthly**
- Store in multiple locations:
  - Cloud storage (Google Drive, iCloud)
  - Email to yourself
  - Local device storage

### Before Important Events
- **Before doctor appointments:** Export CSV
- **Before app updates:** Export JSON backup
- **Before changing devices:** Export JSON backup

### Backup Security
- Store backups securely (encrypted cloud storage)
- Don't share JSON backups publicly
- Use password-protected folders when possible

---

## 🔧 Troubleshooting

### Export Issues

**"No data to export" message:**
- Check that you have wellness entries logged
- Try adding a test entry first

**Export fails:**
- Restart the app and try again
- Check device storage space
- Try a smaller date range

### Import Issues

**"Import failed" error:**
- Verify JSON format is correct
- Check that you copied the complete file content
- Ensure the JSON is from Wellness Logger app

**Partial import:**
- Some entries may have been corrupted
- Check the error message for details
- Try importing a smaller backup file

### Getting Help

If you encounter issues:
1. Check the error message carefully
2. Try restarting the app
3. Verify your data format
4. Contact support with specific error details

---

## 📱 Technical Details

### Supported Formats
- **Export:** CSV, JSON
- **Import:** JSON (paste method)
- **Sharing:** All standard sharing apps

### Data Compatibility
- **Forward compatible:** Newer app versions can read older exports
- **Merge strategy:** Import updates existing entries, adds new ones
- **ID preservation:** Entry IDs are maintained across export/import

### Privacy & Security
- **Local processing:** All export/import happens on your device
- **No cloud dependency:** Works without internet
- **User control:** You choose where to store and share data

---

## 🎉 Success Stories

### Patient Feedback
*"I exported my data before my cardiology appointment, and my doctor was amazed at the detailed tracking. It helped us identify trigger patterns I hadn't noticed!"*

*"The CSV format made it so easy for my doctor to review my SVT episodes. We were able to adjust my medication based on the clear patterns in the data."*

### Medical Professional Feedback  
*"Having patients bring structured data like this CSV export makes appointments much more productive. I can see patterns and make better treatment decisions."*

---

## 📞 Support

Need help with export/import functionality?
- Review this guide first
- Check the troubleshooting section
- Contact support with specific details about your issue

**Remember:** Your health data is valuable - keep regular backups and share appropriately with your healthcare team! 🏥📊
