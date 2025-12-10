@echo off
echo Starting Backend...
start "Backend Server" cmd /k "cd backend && mvn spring-boot:run"

echo Waiting for backend to initialize completely...
timeout /t 10

echo Starting Frontend...
start "Flutter App" cmd /k "flutter run"

echo App is starting. Check the database and backend logs if issues arise.
