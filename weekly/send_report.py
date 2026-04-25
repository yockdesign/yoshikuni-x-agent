#!/usr/bin/env python3
"""
週次レポートをGmailで送信するスクリプト
使い方: python3 send_report.py <レポートファイルパス>
"""

import smtplib
import sys
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime

def send_report(report_path: str):
    # 環境変数からパスワードを取得（不可視文字を除去）
    import re
    raw = os.environ.get('GMAIL_APP_PASSWORD', '')
    password = re.sub(r'[^\x21-\x7E]', '', raw)
    if not password:
        print("エラー：GMAIL_APP_PASSWORD が設定されていません")
        sys.exit(1)

    # レポートファイルを読み込む
    try:
        with open(report_path, 'r', encoding='utf-8') as f:
            report_content = f.read()
    except FileNotFoundError:
        print(f"エラー：レポートファイルが見つかりません: {report_path}")
        sys.exit(1)

    # メール設定
    sender   = "yockdesign@gmail.com"
    receiver = "yockdesign@gmail.com"
    today    = datetime.now().strftime("%Y年%m月%d日")

    msg = MIMEMultipart()
    msg['Subject'] = f'【Yoshikuni週次レポート】{today} 今週使える投稿構造'
    msg['From']    = sender
    msg['To']      = receiver

    msg.attach(MIMEText(report_content, 'plain', 'utf-8'))

    # 送信
    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(sender, password)
            server.send_message(msg)
        print(f"✅ メール送信完了 → {receiver}")
    except smtplib.SMTPAuthenticationError:
        print("エラー：Gmail認証に失敗しました。アプリパスワードを確認してください")
        sys.exit(1)
    except Exception as e:
        print(f"エラー：送信失敗 - {e}")
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("使い方: python3 send_report.py <レポートファイルパス>")
        sys.exit(1)
    send_report(sys.argv[1])
