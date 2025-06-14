@echo off
title 123云盘秒传

echo.
echo.123云盘秒传
echo.秒传的目标文件需要存在于123云盘的存储池。
echo.提供目标文件的MD5,文件名和字节数。文件名可以任意填写
echo.Authorization可以通过登录或浏览器F12 开发者选项-网络 获取

:: 默认不启用延迟扩展
set account=
set password=
set authorization=

:: 仅在需要延迟扩展的代码块启用
echo.
if exist "123response.txt" (
    setlocal enabledelayedexpansion
    set /p "use_saved_token=找到登录凭证，输入 666 使用保存值: "
    if "!use_saved_token!"=="666" (
        endlocal
        goto login_status
    )
    endlocal
)
goto login

:login
echo.
echo.如果账号被风控，需要验证码。
echo.请在下面输入 123 ，跳转至手动 authorization 登录。
echo.
set /p account="请输入手机号: "
if "%account%"=="" goto login
if "%account%"=="123" goto customize_authorization
set /p password="请输入密码: "
if "%password%"=="" goto login

:: 发送登录请求（无需延迟扩展）
curl -s -X POST "https://www.123pan.com/api/user/sign_in" ^
-H "Content-Type: application/json" ^
-d "{\"passport\":\"%account%\", \"password\":\"%password%\", \"remember\":\"true\"}" > 123response.txt 2>nul

:login_status
:: 检查登录结果（无需延迟扩展）
findstr "\"code\":1" "123response.txt" >nul
if %errorlevel%==0 (
    echo.
    echo.凭证错误
    goto login
)

findstr "\"code\":200" "123response.txt" >nul
if %errorlevel%==0 (
    echo.
    echo.凭证正确
    goto authorization
)

echo.
echo.未知的凭证
goto login

:authorization
:: 提取 token（需要延迟扩展）
setlocal enabledelayedexpansion
for /f "tokens=11 delims=:" %%A in ('type 123response.txt ^| findstr /C:"\"token\""') do @set "authorization_tmp=%%A"
set "authorization_tmp=!authorization_tmp:~1,-3!"
set "authorization=Bearer !authorization_tmp!"
endlocal & set "authorization=%authorization%"
goto send_file

:customize_authorization
echo.
set /p "authorization=请输入authorization: "
if "%authorization%"=="" goto customize_authorization
goto send_file

:send_file
:: 获取文件参数（无需延迟扩展）
echo.
set /p "fileMD5=请输入文件MD5: "
set /p "fileName=请输入文件名: "
set /p "fileSize=请输入文件字节数: "
echo.
echo.尝试将文件秒传至123云盘根目录...
echo.

:: 执行秒传请求（注意转义字符）
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