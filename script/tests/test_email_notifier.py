import unittest
from unittest.mock import patch, MagicMock
import os

# We have to patch the environment before importing email_notifier
# Or we can just patch smtplib and builtins.print where it is imported

class TestEmailNotifier(unittest.TestCase):

    @patch('script.email_notifier.EMAIL_SENDER', 'test_sender@example.com')
    @patch('script.email_notifier.EMAIL_PASSWORD', 'test_password')
    @patch('script.email_notifier.smtplib.SMTP')
    @patch('builtins.print')
    def test_send_weekly_report_success(self, mock_print, mock_smtp):
        from script.email_notifier import send_weekly_report

        # Setup mock for SMTP instance
        mock_smtp_instance = MagicMock()
        mock_smtp.return_value = mock_smtp_instance

        # Call the function
        send_weekly_report("Test body")

        # Assertions
        mock_smtp.assert_called_once_with('smtp.gmail.com', 587)
        mock_smtp_instance.starttls.assert_called_once()
        mock_smtp_instance.login.assert_called_once_with('test_sender@example.com', 'test_password')
        mock_smtp_instance.send_message.assert_called_once()
        mock_smtp_instance.quit.assert_called_once()

        mock_print.assert_called_once_with("E-posta başarıyla gönderildi.")

    @patch('script.email_notifier.EMAIL_SENDER', None)
    @patch('script.email_notifier.EMAIL_PASSWORD', None)
    @patch('builtins.print')
    def test_send_weekly_report_missing_credentials(self, mock_print):
        from script.email_notifier import send_weekly_report

        # Call the function
        send_weekly_report("Test body")

        # Assertion
        mock_print.assert_called_once_with("E-posta gönderimi atlandı: Kimlik bilgileri (Secrets) bulunamadı.")

    @patch('script.email_notifier.EMAIL_SENDER', 'test_sender@example.com')
    @patch('script.email_notifier.EMAIL_PASSWORD', 'test_password')
    @patch('script.email_notifier.smtplib.SMTP')
    @patch('builtins.print')
    def test_send_weekly_report_exception(self, mock_print, mock_smtp):
        from script.email_notifier import send_weekly_report

        # Setup mock to raise exception
        mock_smtp.side_effect = Exception("SMTP error")

        # Call the function
        send_weekly_report("Test body")

        # Assertion
        mock_print.assert_called_once_with("E-posta gönderilirken hata oluştu: SMTP error")

if __name__ == '__main__':
    unittest.main()
