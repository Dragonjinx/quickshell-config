pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

// Centralized notification state — one instance shared across all bar instances.
// A single NotificationServer receives notifications once and broadcasts to all bars.
Singleton {
    id: root

    property bool dndEnabled: false
    property var notificationHistory: []
    property var unreadHistory: []
    property int unreadCount: 0
    property int historyVersion: 0

    // Active toasts shown on all bars — max 4, newest at top, auto-dismiss after 4s
    property var activeToasts: []
    property int toastVersion: 0
    property ListModel toastAnimModel: ListModel {}
    property var toastQueue: []
    property bool toastAnimBusy: false

    // Retained Notification QObject references for action invocation from history.
    // Only populated for notifications with actions. Bounded to prevent memory leaks.
    // Each has `tracked = true` to prevent the Notification from being destroyed.
    // Released when dismissed or when pushed out by newer notifications.
    property var _retainedNotifications: ({})
    readonly property int _MAX_RETAINED: 20

    // ── Notification Server (single instance) ───────────────
    NotificationServer {
        id: notifServer
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        inlineReplySupported: true
        persistenceSupported: true

        onNotification: (notification) => {
            if (root.dndEnabled && notification.urgency !== NotificationUrgency.Critical) {
                return
            }

            // Serialize actions to plain JS objects (prevents dangling QObject pointers)
            var serializedActions = (() => {
                var list = notification.actions
                var result = []
                for (var i = 0; i < list.length; i++) {
                    var a = list[i]
                    result.push({ identifier: a.identifier, text: a.text })
                }
                return result
            })()

            var notif = {
                id: notification.id,
                appName: notification.appName,
                appIcon: notification.appIcon,
                summary: notification.summary,
                body: notification.body,
                desktopEntry: notification.desktopEntry,
                urgency: notification.urgency,
                time: new Date(),
                read: false,
                actions: serializedActions,
                image: notification.image,
                hasInlineReply: notification.hasInlineReply,
                inlineReplyPlaceholder: notification.inlineReplyPlaceholder,
                _shownAt: new Date()
            }

            // Retain notification if it has actions (for invocation from history)
            if (serializedActions.length > 0) {
                root._retainNotification(notification)
            }

            root.notificationHistory = root.notificationHistory.concat([notif])
            root.unreadHistory = root.unreadHistory.concat([notif])
            root.unreadCount = root.unreadHistory.length
            root.historyVersion++

            if (root.toastAnimBusy) {
                root.toastQueue.push(notif)
            } else {
                root._showToast(notif)
            }

            if (!expiryTimer.running) {
                expiryTimer.running = true
            }
        }
    }

    // ── Show toast — remove oldest immediately if full ──────
    function _showToast(notif) {
        root.toastAnimBusy = true

        if (root.toastAnimModel.count >= 4) {
            root.toastAnimModel.remove(root.toastAnimModel.count - 1)
        }

        root.toastAnimModel.insert(0, notif)

        var toasts = [notif].concat(root.activeToasts)
        if (toasts.length > 4) {
            toasts = toasts.slice(0, 4)
        }
        root.activeToasts = toasts
        root.toastVersion++

        gateTimer.interval = 300
        gateTimer.running = true
    }

    // ── Notification retention — prevents dangling QObject pointers ────
    // Keeps Notification alive via `tracked = true` while in history.
    // Bounded to _MAX_RETAINED; oldest are released first to limit memory.
    function _retainNotification(notification) {
        notification.tracked = true
        _retainedNotifications[notification.id] = notification

        // Enforce bound — release oldest by notification id (ascending = oldest)
        var ids = Object.keys(_retainedNotifications).sort((a, b) => a - b)
        while (ids.length > _MAX_RETAINED) {
            var oldId = ids.shift()
            var old = _retainedNotifications[oldId]
            if (old) old.tracked = false
            delete _retainedNotifications[oldId]
        }
    }

    function _releaseNotification(id) {
        var retained = _retainedNotifications[id]
        if (retained) {
            retained.tracked = false
            delete _retainedNotifications[id]
        }
    }

    // Invoke an action from a retained notification (safe, null-guarded)
    function invokeAction(notifId, actionIdentifier) {
        var notif = _retainedNotifications[notifId]
        if (!notif || !notif.actions) return false
        for (var i = 0; i < notif.actions.length; i++) {
            if (notif.actions[i].identifier === actionIdentifier) {
                notif.actions[i].invoke()
                return true
            }
        }
        return false
    }

    // ── Gate timer — unblocks queue after add+mwove animate ─
    Timer {
        id: gateTimer
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            root.toastAnimBusy = false
            if (root.toastQueue.length > 0) {
                root._showToast(root.toastQueue.shift())
            }
        }
    }

    // ── Toast expiry ────────────────────────────────────────
    Timer {
        id: expiryTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            var expired = []
            for (var i = root.toastAnimModel.count - 1; i >= 0; i--) {
                var t = root.toastAnimModel.get(i)
                if ((now - t._shownAt) >= 4000) {
                    expired.push(i)
                }
            }
            // Remove in reverse order to preserve indices
            for (var j = expired.length - 1; j >= 0; j--) {
                root.toastAnimModel.remove(expired[j])
            }

            var keep = []
            for (var i = 0; i < root.activeToasts.length; i++) {
                var t = root.activeToasts[i]
                if ((now - t._shownAt) < 4000) {
                    keep.push(t)
                }
            }
            if (keep.length !== root.activeToasts.length) {
                root.activeToasts = keep
                root.toastVersion++
            }

            if (root.toastAnimModel.count === 0) {
                expiryTimer.running = false
            }
        }
    }

    // ── Public actions ─────────────────────────────────────
    // Handle click on a notification: invoke default action or open app.
    // Returns true if an action was taken, false if caller should fall back.
    function handleDefaultAction(notifData) {
        // 1. Try to invoke "default" action from retained notification
        var notif = _retainedNotifications[notifData.id]
        if (notif && notif.actions && notif.actions.length > 0) {
            for (var i = 0; i < notif.actions.length; i++) {
                if (notif.actions[i].identifier === "default") {
                    notif.actions[i].invoke()
                    return true
                }
            }
        }

        // 2. Fall back: activate existing window or launch app
        if (notifData.desktopEntry) {
            // Try exact match first, then capitalized first letter (e.g. Alacritty),
            // then fall back to launching. Works across all monitors.
            var entry = notifData.desktopEntry
            var cap = entry.charAt(0).toUpperCase() + entry.slice(1)
            var cmd = "hyprctl dispatch focuswindow 'class:^(" + entry + ")$' 2>/dev/null"
            if (cap !== entry) {
                cmd += " || hyprctl dispatch focuswindow 'class:^(" + cap + ")$' 2>/dev/null"
            }
            cmd += " || " + entry
            _launchProc.command = cmd
            _launchProc.running = true
            return true
        }

        return false
    }

    // ── Persistent process for launching apps via desktop entry ──
    Process {
        id: _launchProc
        command: ""
        running: false
    }

    function clearAll() {
        root.toastQueue = []
        root.notificationHistory = []
        root.unreadHistory = []
        root.unreadCount = 0
        root.historyVersion++
        root.dismissAllToasts()
        // Release all retained notification objects
        for (var id in _retainedNotifications) {
            _retainedNotifications[id].tracked = false
        }
        _retainedNotifications = {}
    }

    function markRead(notif) {
        notif.read = true
        root.unreadHistory = root.unreadHistory.filter(n => n.id !== notif.id)
        root.unreadCount = root.unreadHistory.length
        root.historyVersion++
    }

    function dismissAllToasts() {
        root.toastAnimBusy = false
        root.activeToasts = []
        root.toastAnimModel.clear()
        root.toastVersion++
        expiryTimer.running = false
    }

    function dismissToast(notif) {
        for (var i = 0; i < root.toastAnimModel.count; i++) {
            if (root.toastAnimModel.get(i).id === notif.id) {
                root.toastAnimModel.remove(i)
                break
            }
        }
        root.activeToasts = root.activeToasts.filter(n => n.id !== notif.id)
        root.toastVersion++
        if (root.activeToasts.length === 0) {
            expiryTimer.running = false
        }
    }

    // Remove a single notification from history (used by swipe-to-dismiss in Dash)
    function dismissNotification(notif) {
        root._releaseNotification(notif.id)
        root.notificationHistory = root.notificationHistory.filter(n => n.id !== notif.id)
        root.unreadHistory = root.unreadHistory.filter(n => n.id !== notif.id)
        root.unreadCount = root.unreadHistory.length
        root.historyVersion++
        root.dismissToast(notif)
    }
}
