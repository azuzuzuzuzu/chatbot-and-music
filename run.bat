@echo off
:: ============================================================
::  Chạy bot Discord. Khuyên dùng: đặt secret vào file .env
::  (đã gitignore), run.bat sẽ tự load. Không ghi token thật
::  trực tiếp vào đây.
:: ============================================================

:: Load biến từ .env nếu tồn tại (bỏ qua dòng trống và dòng #).
if exist .env (
    for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
        if not "%%A"=="" if not "%%A:~0,1%"=="#" (
            set "%%A=%%B"
        )
    )
)

:: Giá trị mặc định nếu chưa có trong .env (điền vào .env thay vì đây).
if not defined DISCORD_TOKEN set "DISCORD_TOKEN=YOUR_BOT_TOKEN_HERE"
if not defined CHAT_API_KEY set "CHAT_API_KEY="
if not defined SPOTIFY_CLIENT_ID set "SPOTIFY_CLIENT_ID="
if not defined SPOTIFY_CLIENT_SECRET set "SPOTIFY_CLIENT_SECRET="
if not defined OPUS_LIB set "OPUS_LIB=D:\!Tai_Xuong\HuyDepChai\project36\libopus-0.dll"
if not defined AUDD_API_KEY set "AUDD_API_KEY="

python bot.py
pause
