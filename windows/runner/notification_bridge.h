#ifndef RUNNER_NOTIFICATION_BRIDGE_H_
#define RUNNER_NOTIFICATION_BRIDGE_H_

#include <windows.h>
#include <string>

// Windows notification bridge using shell notification icons (balloon/toast).
// Works on all Windows versions without WinRT/UWP dependencies.
class NotificationBridge {
 public:
  NotificationBridge();
  ~NotificationBridge();

  // Initialize the bridge with a parent window handle.
  // Must be called before Show().
  void Initialize(HWND parent_window);

  // Show a toast notification with the given title and body.
  bool Show(const std::string& title, const std::string& body);

  // Remove the notification icon from the tray.
  void Cleanup();

 private:
  static constexpr UINT kNotificationId = 2002;
  static constexpr UINT kCallbackMessage = WM_APP + 1001;

  HWND parent_window_ = nullptr;
  bool icon_added_ = false;

  bool EnsureIconExists();
  bool ShowBalloon(const std::wstring& title, const std::wstring& body);
};

#endif  // RUNNER_NOTIFICATION_BRIDGE_H_