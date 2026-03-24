import os
from email.mime.multipart import MIMEMultipart
import smtplib

EMAIL_SENDER = os.environ.get("EMAIL_SENDER")
EMAIL_PASSWORD = os.environ.get("EMAIL_PASS")
EMAIL_RECIPIENT = "gururlu_kimya7o@icloud.com" # Buraya kendi mail adresinizi yazın

def send_weekly_report(report_body):
    if not EMAIL_SENDER or not EMAIL_PASSWORD:
        print("E-posta gönderimi atlandı: Kimlik bilgileri (Secrets) bulunamadı.")
        return

    msg = MIMEMultipart()
    msg['From'] = EMAIL_SENDER
    msg['To'] = EMAIL_RECIPIENT
    msg['Subject'] = "Haftalık Rapor"

    # Attach the report_body to the email message
    from email.mime.text import MIMEText
    msg.attach(MIMEText(report_body, 'plain'))

    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(EMAIL_SENDER, EMAIL_PASSWORD)
        server.send_message(msg)
        server.quit()
        print("E-posta başarıyla gönderildi.")
    except Exception as e:
        print(f"E-posta gönderilirken hata oluştu: {e}")
