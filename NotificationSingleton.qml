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

    // Active toasts shown on all bars — max 4, newest at the end, auto-dismiss after 4s
    property var activeToasts: []
    property int toastVersion: 0

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

            // Add to active toasts (newest at top), cap at 4
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
                if (keep.length === 0) {
                    expiryTimer.running = false
                }
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
        root.toastVersion++
        expiryTimer.running = false
    }

    function dismissToast(notif) {
        root.activeToasts = root.activeToasts.filter(n => n.id !== notif.id)
        root.toastVersion++
        if (root.activeToasts.length === 0) {
            expiryTimer.running = false
        }
    }
}
