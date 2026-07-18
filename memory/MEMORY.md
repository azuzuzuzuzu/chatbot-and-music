# MEMORY — Project project36 (Discord Chatbot + Music Bot)

File này ghi chú project để assistant (a.i) đọc lại mỗi session, nhớ context
sau khi tắt/bật lại. Cập nhật khi có thay đổi lớn.

## Tổng quan
- Bot Discord chạy trong ĐÚNG 1 server (GUILD_ID cố định trong bot.py).
- Vừa chatbot AI (tiếng Việt) vừa phát nhạc qua kênh thoại.
- Ngôn ngữ code: Python 3, thư viện discord.py + yt-dlp.
- Chạy bằng `run.bat` (tự load `.env`) hoặc `python bot.py`.

## File quan trọng
- `bot.py` (~150KB) — toàn bộ logic. Config nằm đầu file (line ~33-142).
- `prompt.txt` — personality mặc định chatbot (cache lúc khởi động, sửa cần restart).
- `HUONG_DAN.txt` — tài liệu dùng đầy đủ.
- `.env` / `.env.example` — biến môi trường (token, key, OPUS_LIB). `.env` đã gitignore.
- `run.bat` — load `.env` rồi chạy. Không ghi token thật vào đây.
- `sa.py` — script test OpenRouter API (không phải logic bot).

## Config cố định (bot.py)
- GUILD_ID = 1327664793544560661
- OWNER_IDS = [1004917748264087665]
- CHAT_API_URL = https://anticode.vn/v1/chat/completions (model grok_4.5, KHÔNG cần key)
- PREFIX = "c" (lệnh text: cplay, cskip ...)
- Cooldown 1s/user; giữ 40 lượt lịch sử/user.
- Nhạc: yt-dlp + Spotify (tùy chọn) + AudD nhận diện file (tùy chọn).

## CẢNH BÁO BẢO MẬT (quan trọng)
- `sa.py` dòng 3 chứa API key OpenRouter HARDCODE plaintext:
  `API_KEY = "sk-or-v1-1cb828f6..."`. File này KHÔNG nằm trong .gitignore.
  -> Nếu từng commit/share thư mục là lộ key. Khuyên: reset key tại openrouter.ai,
     xoá dòng hardcode (hoặc xoá luôn sa.py).
- Token bot chỉ qua biến môi trường DISCORD_TOKEN (trong .env, đã gitignore).
- Nguyên tắc: tuyệt đối không ghi token/key thật vào run.bat hay bot.py.

## File data tự sinh (trong project)
- `memory/<user_id>.txt` — lịch sử chat từng user.
- `system_prompts.json`, `allowed_channels.json`, `music_channels.json`,
  `playlists.json`, `disabled_features.json`.

## Các lệnh (slash + prefix tương ứng)
- Nhạc: /play=cplay, /skip=cskip, /stop=cstop, /pause=cpause, /resume=cresume,
  /queue=cqueue(cq), /remove=cremove, /act=cact, /skipto=cskipto,
  /volume=cvolume (float 1.0-100.0, percent, 100.0=gốc), /nowplaying=cnowplaying,
  /saveplaylist=csaveplaylist, /playplaylist=cplayplaylist,
  /mylists=cmylists, /deletelist=cdeletelist.
- Tìm kiếm: /nhac=cnhac, /nhacfile=cnhacfile (cnhacfile cần file đính kèm).
- Owner: /disable=cdisable, /enable=cenable, /setkenh=csetkenh,
  /setkenhmusic=csetkenhmusic. Ví dụ: `cdisable phát nhạc lý do bảo trì`.
- Chatbot: /xoa=cxoa. (promptsys/rsprompt CHƯA có prefix theo ý user.)

## Trạng thái task gần nhất (session 2026-07-18)
- Đã thêm: nút Hủy + timeout 60s cho playlist prompt (PlaylistChoiceView),
  auto-xóa + báo "Đã hủy" khi hủy/timeout.
- Đã thêm: ConfirmView (Xác nhận/Hủy) cho /skipto + cskipto.
- Đã đổi /volume thành float 1.0-100.0 (thay thế int 0-100).
- Đã cải thiện build_nowplaying_embed (color, footer, percent float).
- Đã thêm prefix cho: music + owner + cxoa + cnhac/cnhacfile + playlist subs.
- Quy tắc emoji: chỉ dọn emoji ở phần code sửa đổi, giữ nguyên chỗ cũ.
- Đã sửa cskipto off-by-one (n-1): music_skipto đổi sang quy ước queue
  (position 1 = bài đầu hàng đợi, KHÔNG tính bài đang phát) — khớp /queue và
  /remove. Trước đó tính current = #1 nên cskipto 9 phát bài #8.
- Cancel (playlist / skipto): thay vì xóa prompt rồi gửi "Đã hủy.", giờ edit
  prompt thành "Đã hủy." để tin nhắn tồn tại (không auto-xóa sau 5s).
- Đã sửa bug "Thêm cả playlist" chỉ thêm 1 bài: link watch?v=..&list=PL..
  truyền thẳng vào yt-dlp extract_flat chỉ lấy 1 video. Thêm
  _normalize_youtube_playlist_url đổi sang playlist?list=PL.. để lấy đủ.

## Sự cố playlist 403 (2026-07-18) — quan trọng
- Triệu chứng: `cplay` link có `list=PL...` -> bot báo "Không lấy được bài nào" /
  log `yt-dlp lỗi ... HTTP Error 403: Forbidden (youtube:tab)`.
- KHÔNG phải rate-limit (rate-limit = 429). KHÔNG phải IP block (single video
  `v=...` vẫn chạy được, test trực tiếp trả title). Là YouTube siết chặt browse
  API: giờ bắt buộc session hợp lệ (PO-token/visitor data) để lấy playlist;
  request trần bị 403 "caller does not have permission". Video đơn dùng endpoint
  `player` khác nên vẫn OK.
- Tại sao giờ lỗi mà trước chạy được: YouTube đổi chính sách 2026, browse API
  yêu cầu session. Bot KHÔNG đổi behavior (code giữ nguyên).
- Đã test trên máy dev: `player_client=tv` -> vẫn 403. `--js-runtimes node`
  (node v24 có sẵn) -> vẫn 403. `--cookies-from-browser chrome` -> lỗi DPAPI ở
  sandbox (cơ chế đúng, chỉ sandbox không decrypt được cookie user).
  => Kết luận: cookie (session YouTube) là fix duy nhất đáng tin.
- Đã sửa code: thêm `YTDL_COOKIE_FILE` (env) -> tự nạp `cookiefile` vào yt-dlp
  (nếu file tồn tại). Cách lấy cookie: `yt-dlp --cookies-from-browser chrome`
  hoặc extension "Get cookies.txt for Youtube". Đặt `YTDL_COOKIE_FILE` trong
  `.env`. Đã cập nhật `.env.example`.
- Loại playlist Radio/Mix (`list` bắt đầu `RD*`) khỏi prompt playlist (YouTube
  báo "unviewable", không lấy được) -> giờ chỉ phát 1 bài (`v=`).
- Rủi ro ban account YouTube: THẤP. Bot chỉ lấy metadata (title/link), không
  tải file, không upload. Cookie chỉ gửi session như trình duyệt đã login. Nếu
  user e ngại -> khuyên dùng account Google PHỤ để lấy cookie.

## Cách chạy / test
- Cài: `pip3 install -r requirements.txt`, ffmpeg, libopus (OPUS_LIB).
- Bật MESSAGE CONTENT INTENT + SERVER MEMBERS/VOICE INTENT trên Developer Portal.
- Check syntax: `python -m py_compile bot.py`.
- Bot cần token thật + vào đúng GUILD_ID mới chạy thực tế được.

## Khi chuyển sang máy khác
- Copy nguyên folder project36 (gồm bot.py, MEMORY.md, prompt.txt, .env.example...).
  File chat `memory/<id>.txt` cũng mang theo nếu muốn giữ lịch sử.
- Trên máy mới: tạo lại `.env` từ `.env.example` (điền DISCORD_TOKEN, OPUS_LIB,
  YTDL_COOKIE_FILE nếu dùng cookie). `.env` có secret -> KHÔNG commit/share.
- Cài lại deps + ffmpeg + libopus. Nếu phát playlist bị 403 -> cần cookie YouTube
  (xem mục "Sự cố playlist 403").
- System memory của assistant nằm ở máy này (C:\Users\HP\.claude\...), KHÔNG tự
  mang sang. Context cross-machine nằm trong project36/memory/MEMORY.md này.
