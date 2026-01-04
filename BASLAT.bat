@echo off
echo Redmine Status Tracker Baslatiliyor...
echo Lutfen bekleyin, konteynerler ayaga kalkiyor.
docker compose up -d
echo.
echo =================================================
echo  UYGULAMA BASARIYLA CALISTI!
echo  Tarayicinizdan http://localhost:3000 adresine gidin.
echo =================================================
pause