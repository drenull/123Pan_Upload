@echo off
title 123�����봫

echo.
echo.123�����봫
echo.�봫��Ŀ���ļ���Ҫ������123���̵Ĵ洢�ء�
echo.�ṩĿ���ļ���MD5,�ļ������ֽ������ļ�������������д
echo.Authorization����ͨ����¼�������F12 ������ѡ��-���� ��ȡ

:: Ĭ�ϲ������ӳ���չ
set account=
set password=
set authorization=

:: ������Ҫ�ӳ���չ�Ĵ��������
echo.
if exist "123response.txt" (
    setlocal enabledelayedexpansion
    set /p "use_saved_token=�ҵ���¼ƾ֤������ 666 ʹ�ñ���ֵ: "
    if "!use_saved_token!"=="666" (
        endlocal
        goto login_status
    )
    endlocal
)
goto login

:login
echo.
echo.����˺ű���أ���Ҫ��֤�롣
echo.������������ 123 ����ת���ֶ� authorization ��¼��
echo.
set /p account="�������ֻ���: "
if "%account%"=="" goto login
if "%account%"=="123" goto customize_authorization
set /p password="����������: "
if "%password%"=="" goto login

:: ���͵�¼���������ӳ���չ��
curl -s -X POST "https://www.123pan.com/api/user/sign_in" ^
-H "Content-Type: application/json" ^
-d "{\"passport\":\"%account%\", \"password\":\"%password%\", \"remember\":\"true\"}" > 123response.txt 2>nul

:login_status
:: ����¼����������ӳ���չ��
findstr "\"code\":1" "123response.txt" >nul
if %errorlevel%==0 (
    echo.
    echo.ƾ֤����
    goto login
)

findstr "\"code\":200" "123response.txt" >nul
if %errorlevel%==0 (
    echo.
    echo.ƾ֤��ȷ
    goto authorization
)

echo.
echo.δ֪��ƾ֤
goto login

:authorization
:: ��ȡ token����Ҫ�ӳ���չ��
setlocal enabledelayedexpansion
for /f "tokens=11 delims=:" %%A in ('type 123response.txt ^| findstr /C:"\"token\""') do @set "authorization_tmp=%%A"
set "authorization_tmp=!authorization_tmp:~1,-3!"
set "authorization=Bearer !authorization_tmp!"
endlocal & set "authorization=%authorization%"
goto send_file

:customize_authorization
echo.
set /p "authorization=������authorization: "
if "%authorization%"=="" goto customize_authorization
goto send_file

:send_file
:: ��ȡ�ļ������������ӳ���չ��
echo.
set /p "fileMD5=�������ļ�MD5: "
set /p "fileName=�������ļ���: "
set /p "fileSize=�������ļ��ֽ���: "
echo.
echo.���Խ��ļ��봫��123���̸�Ŀ¼...
echo.

:: ִ���봫����ע��ת���ַ���
curl ^"https://www.123pan.com/b/api/file/upload_request?3552184930=1749803518-4868942-1261728467^" ^
  -H ^"App-Version: 9999999^" ^
  -H ^"Authorization: %authorization%^" ^
  -H ^"Origin: https://www.123pan.com^" ^
  -H ^"Referer: https://www.123pan.com/^" ^
  -H ^"platform: web^" ^
  --data-raw ^"^{^\^"driveId^\^":0,^\^"etag^\^":^\^"%fileMD5%^\^",^\^"fileName^\^":^\^"%fileName%^\^",^\^"parentFileId^\^":0,^\^"size^\^":%fileSize%,^\^"type^\^":0,^\^"RequestSource^\^":null,^\^"duplicate^\^":0^}^"
echo.
echo.

pause