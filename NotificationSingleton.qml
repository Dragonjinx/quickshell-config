pragma Singleton

import Quickshell
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

            // Store as plain JS object for history
            var notif = {
                id: notification.id,
                appName: notification.appName,
                appIcon: notification.appIcon,
                summary: notification.summary,
                body: notification.body,
                urgency: notification.urgency,
                time: new Date(),
                read: false,
                actions: notification.actions,
                image: notification.image,
                hasInlineReply: notification.hasInlineReply,
                inlineReplyPlaceholder: notification.inlineReplyPlaceholder,
                _shownAt: new Date()
            }

            root.notificationHistory = root.notificationHistory.concat([notif])
            root.unreadHistory = root.unreadHistory.concat([notif])
            root.unreadCount = root.unreadHistory.length
            root.historyVersion++

            // Add to animated toast model (newest at top)
            root.toastAnimModel.insert(0, notif)
            if (root.toastAnimModel.count > 4) {
                root.toastAnimModel.remove(4, root.toastAnimModel.count - 4)
            }

            // Keep var array for history lookups
            var toasts = [notif].concat(root.activeToasts)
            if (toasts.length > 4) {
                toasts = toasts.slice(0, 4)
            }
            root.activeToasts = toasts
            root.toastVersion++

            // Ensure expiry timer is running
            if (!expiryTimer.running) {
                expiryTimer.running = true
            }
        }
    }

    // ── Toast expiry checker (runs every second) ─────────────
    Timer {
        id: expiryTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            // Remove expired toasts from anim model one by one
            var removed = false
            for (var i = root.toastAnimModel.count - 1; i >= 0; i--) {
                var t = root.toastAnimModel.get(i)
                if ((now - t._shownAt) >= 4000) {
                    root.toastAnimModel.remove(i)
                    removed = true
                }
            }

            // Keep var array in sync
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
    function clearAll() {
        root.notificationHistory = []
        root.unreadHistory = []
        root.unreadCount = 0
        root.historyVersion++
        root.dismissAllToasts()
    }

    function markRead(notif) {
        notif.read = true
        root.unreadHistory = root.unreadHistory.filter(n => n.id !== notif.id)
        root.unreadCount = root.unreadHistory.length
        root.historyVersion++
    }

    function dismissAllToasts() {
        root.activeToasts = []
        root.toastAnimModel.clear()
        root.toastVersion++
        expiryTimer.running = false
    }

    function dismissToast(notif) {
        // Remove from anim model
        for (var i = 0; i < root.toastAnimModel.count; i++) {
            if (root.toastAnimModel.get(i).id === notif.id) {
                root.toastAnimModel.remove(i)
                break
            }
        }

        // Remove from var array
        root.activeToasts = root.activeToasts.filter(n => n.id !== notif.id)
        root.toastVersion++
        if (root.activeToasts.length === 0) {
            expiryTimer.running = false
        }
    }
}
