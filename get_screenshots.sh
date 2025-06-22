#!/bin/bash

# Wellness Logger - Screenshot and Documentation Script
# Run this script to capture screenshots and update documentation

echo "🏥 Wellness Logger - Documentation Helper"
echo "========================================"

# Create screenshots directory
mkdir -p screenshots

echo "📱 Screenshot Instructions:"
echo ""
echo "1. Connect your Android device via USB"
echo "2. Enable USB Debugging in Developer Options"
echo "3. Install the app: adb install releases/wellness-logger-v1.0.1-clean.apk"
echo "4. Open the app and navigate through screens"
echo "5. Take screenshots using: adb exec-out screencap -p > screenshots/screenshot_X.png"
echo ""
echo "Recommended screenshots:"
echo "  - Home screen with entries"
echo "  - Add new entry form (SVT/Exercise/Medication)"
echo "  - Calendar view with entries"
echo "  - Analytics dashboard"
echo "  - Settings screen"
echo "  - Empty state"
echo ""

echo "📊 App Info:"
echo "============"
echo "APK Location: releases/wellness-logger-v1.0.1-clean.apk (RECOMMENDED - Clean UI)"
echo "APK Location: releases/wellness-logger-v1.0.0.apk (Original with debug info)"
echo "App Bundle: releases/wellness-logger-v1.0.0.aab"
echo "Package Name: com.example.wellness_logger_mobile"
echo ""

echo "🚀 Next Steps:"
echo "============="
echo "1. Take screenshots following the instructions above"
echo "2. Add screenshots to README.md"
echo "3. Create a demo video (optional)"
echo "4. Share on social media/portfolio"
echo "5. Submit to Google Play Store (optional)"
echo ""

echo "📝 Portfolio Documentation:"
echo "=========================="
echo "✅ README.md - Complete project overview"
echo "✅ PROJECT_SUMMARY.md - Technical achievement story"
echo "✅ RELEASE_NOTES_v1.0.0.md - Release documentation"
echo "✅ DEVELOPMENT_PLAN.md - Development journey"
echo ""

echo "🏆 Achievement Unlocked: Production-Ready App!"
echo "Time to show the world your technical excellence! 🌟"
