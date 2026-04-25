#!/bin/bash
# 週次レポート実行スクリプト
# 毎週金曜 20:00 に cron から呼ばれる

set -e

# パス設定
AGENT_DIR="/Users/yockdesign/yock_work/claude_project/yockdesign-REKISHILabel_Yoshikuni/x_agent"
WEEKLY_DIR="$AGENT_DIR/weekly"
OUTPUT_DIR="$AGENT_DIR/output"
DATE=$(date +%Y-%m-%d)
REPORT_PATH="$OUTPUT_DIR/weekly_${DATE}.md"

# 環境変数の読み込み
source ~/.zshrc

echo "🚀 週次レポート開始: $DATE"

# Claude Code CLI のパスを確認
CLAUDE_BIN=$(find /Users/yockdesign/.npm/_npx -name "claude" -type f 2>/dev/null | head -1)
if [ -z "$CLAUDE_BIN" ]; then
    CLAUDE_BIN=$(which claude 2>/dev/null)
fi
if [ -z "$CLAUDE_BIN" ]; then
    echo "エラー：Claude CLIが見つかりません"
    exit 1
fi

echo "📍 Claude CLI: $CLAUDE_BIN"

# ① レポート生成（Claude Code CLI で weekly エージェントを実行）
echo "📊 トレンド分析・投稿案生成中..."
cd "$WEEKLY_DIR"
"$CLAUDE_BIN" \
    --print \
    --dangerously-skip-permissions \
    "今週のXでバズった投稿構造を分析して、Yoshikuniの投稿案3本を含む週次レポートを生成してください。レポートは $REPORT_PATH に保存してください。" \
    > /tmp/weekly_report_log.txt 2>&1

# レポートファイルが生成されたか確認
if [ ! -f "$REPORT_PATH" ]; then
    echo "⚠️  レポートファイルが見つかりません。ログを確認してください: /tmp/weekly_report_log.txt"
    exit 1
fi

echo "✅ レポート生成完了: $REPORT_PATH"

# ② メール送信
echo "📧 メール送信中..."
python3 "$WEEKLY_DIR/send_report.py" "$REPORT_PATH"

echo "🎉 週次レポート完了"
