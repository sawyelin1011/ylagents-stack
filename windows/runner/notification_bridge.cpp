#include "notification_bridge.h"

#include <shellapi.h>

NotificationBridge::NotificationBridge() = default;

NotificationBridge::~NotificationBridge() {
  Cleanup();
}

void NotificationBridge::Initialize(HWND parent_window) {
  parent_window_ = parent_window;
}

bool NotificationBridge::Show(const std::string& title,
                               const std::string& body) {
  if (!parent_window_) {
    return false;
  }

  // Convert UTF-8 strings to wide strings for Windows API
  auto Utf8ToWide = [](const std::string& s) -> std::wstring {
    int len = MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, nullptr, 0);
    if (len <= 0) return std::wstring();
    std::wstring w(static_cast<size_t>(len - 1), L'\0');
    MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, w.data(), len);
    return w;
  };

  std::wstring wideTitle = Utf8ToWide(title);
  std::wstring wideBody = Utf8ToWide(body);

  return ShowBalloon(wideTitle, wideBody);
}

bool NotificationBridge::ShowBalloon(const std::wstring& title,
                                      const std::wstring& body) {
  if (!EnsureIconExists()) {
    return false;
  }

  NOTIFYICONDATAW nid = {};
  nid.cbSize = sizeof(NOTIFYICONDATAW);
  nid.hWnd = parent_window_;
  nid.uID = kNotificationId;
  nid.uFlags = NIF_INFO;
  nid.dwInfoFlags = NIIF_INFO | NIIF_NOSOUND;
  nid.uTimeout = 5000;  // 5 seconds display time

  wcsncpy_s(nid.szInfoTitle, title.c_str(), _TRUNCATE);
  wcsncpy_s(nid.szInfo, body.c_str(), _TRUNCATE);

  // Attempt to modify first (icon already exists), then add as fallback
  return Shell_NotifyIconW(NIM_MODIFY, &nid) ||
         Shell_NotifyIconW(NIM_ADD, &nid);
}

bool NotificationBridge::EnsureIconExists() {
  if (icon_added_) {
    return true;
  }

  NOTIFYICONDATAW nid = {};
  nid.cbSize = sizeof(NOTIFYICONDATAW);
  nid.hWnd = parent_window_;
  nid.uID = kNotificationId;
  nid.uFlags = NIF_MESSAGE | NIF_ICON;
  nid.uCallbackMessage = kCallbackMessage;
  nid.hIcon = LoadIcon(nullptr, IDI_APPLICATION);

  if (Shell_NotifyIconW(NIM_ADD, &nid)) {
    icon_added_ = true;
    return true;
  }
  return false;
}

void NotificationBridge::Cleanup() {
  if (icon_added_ && parent_window_) {
    NOTIFYICONDATAW nid = {};
    nid.cbSize = sizeof(NOTIFYICONDATAW);
    nid.hWnd = parent_window_;
    nid.uID = kNotificationId;
    Shell_NotifyIconW(NIM_DELETE, &nid);
    icon_added_ = false;
  }
}