# VoicelyAI 存股助理

用手機錄音說出交易內容，AI 自動辨識買賣、股數、價格，寫入 Google Sheets 試算表。

---

## 📁 專案結構

```
VoicelyAI/
├── app.py                  # Flask 主程式（語音轉錄 + AI 分析 + 儲存）
├── recorder.html           # 前端錄音介面（行動版優化）
├── requirements.txt        # Python 依賴套件
├── docker-compose.yml      # Docker Compose 部署設定
├── Dockerfile              # Docker 映像設定
├── Caddyfile               # Caddy 反向代理設定（VPS 用）
├── entrypoint.sh           # Docker 容器啟動腳本
├── .env.example            # 環境變數範例（請複製為 .env）
├── .env                    # 環境變數（含 API Key，不提交 Git）
├── .gitignore
├── gas-trade-receiver.md   # Google Apps Script — 交易記錄接收端
├── gas-daily-snapshot.md   # Google Apps Script — 每日資產快照
├── 腳本.md                 # 原始 GAS 備份（每日快照）
├── 腳本2.md                # 原始 GAS 備份（交易接收）
└── data/
    └── Stock Savings Record.csv  # 本機 CSV（自動產生）
```

---

## ⚡ 快速開始（本機開發）

### 1. 安裝 Python 依賴

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. 設定環境變數

```bash
# 複製範例檔，填入你的 API Key
cp .env.example .env
```

編輯 `.env`，填入你的：

| 變數 | 說明 |
|------|------|
| `GROQ_API_KEY` | Groq API Key（Whisper 轉錄 + LLM 分析） |
| `GOOGLE_APPS_SCRIPT_URL` | Google Apps Script 部屬網址 |

### 3. 啟動

```bash
python app.py
```

打開瀏覽器 `http://localhost:8080` 即可開始錄音。

---

## 🐳 Docker 部署

```bash
# 建構並啟動
docker compose up -d --build

# 確認服務狀態
curl http://localhost:8080/health

# 查看日誌
docker compose logs -f

# 停止
docker compose down
```

---

## 🔗 Google Sheets 整合

本專案透過 Google Apps Script（GAS）將交易紀錄寫入 Google Sheets。

### 需要部署兩份 GAS 腳本

| 腳本 | 用途 | 觸發方式 |
|------|------|---------|
| `gas-trade-receiver.md` | 接收 VoicelyAI 交易，寫入「現有庫存明細」 | `app.py` POST 呼叫 |
| `gas-daily-snapshot.md` | 每日資產快照，寫入「每日歷史紀錄」 | Google Sheet 定時觸發 |

### Google Sheet 分頁架構

```
Stock Savings Record（試算表）
├── 現有庫存明細     ← VoicelyAI 逐筆寫入（跳過公式欄）
├── 配置總覽與再平衡  ← 公式自動彙總（B3=總市值, B4=本金）
└── 每日歷史紀錄     ← 每日定時快照
```

---

## 📱 使用流程

```
iPhone 打開 recorder.html
    │
    ▼
對手機說出交易內容（自動錄音）
  例：「我用 3552 元買入 3 股聯發科」
    │
    ▼
點「停止」→ 上傳到 Flask
    │
    ▼
AI 分析：Whisper 轉錄 → Groq LLM 提取欄位
    │
    ▼
網頁顯示可編輯表單（可修正名稱、代碼、單價）
    │
    ▼
點「確認儲存」→ 寫入 CSV + 同步 Google Sheets
```

---

## 🔒 安全注意

- `.env` 已加入 `.gitignore`，不會洩漏到 GitHub
- 請確認 `.env` 內沒有密鑰被提交
- Docker 部署時，`.env` 路徑掛載不會包含在映像層

---

## 📊 效能參考

| 指標 | 數值 |
|------|------|
| 映像大小 | ~150 MB |
| 記憶體 | ~50-100 MB |
| 每次請求延遲 | ~5-15 秒（含語音轉錄） |
| Port | 8080 |
