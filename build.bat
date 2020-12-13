@echo off
echo "SET Base URL"
cmd -c "flutter pub run environment_config:generate --base_url=http://47.99.189.70/api"
echo "Build APK"
flutter build apk -t lib\pvt\study\main.dart
pause