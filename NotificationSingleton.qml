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
    property var activeToast: null

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
                ref: notification
            }

            root.notificationHistory = root.notificationHistory.concat([notif])
            root.unreadHistory = root.unreadHistory.concat([notif])
            root.unreadCount = root.unreadHistory.length

            // Show toast on all bars
            root.activeToast = notif
            toastTimer.restart()
        }
    }

    // ── Auto-dismiss toast ─────────────────────────────────
    Timer {
        id: toastTimer
        interval: 4000
        onTriggered: {
            if (root.activeToast) {
                root.activeToast.ref.dismiss()
                root.activeToast = null
            }
        }
    }

    // ── Public actions ─────────────────────────────────────
    function clearAll() {
        for (var i = 0; i < root.notificationHistory.length; i++) {
            var n = root.notificationHistory[i]
            if (n && n.ref) n.ref.dismiss()
        }
        root.notificationHistory = []
        root.unreadHistory = []
        root.unreadCount = 0
        root.dismissToast()
    }

    function markRead(notif) {
        notif.read = true
        root.unreadHistory = root.unreadHistory.filter(n => n.id !== notif.id)
        root.unreadCount = root.unreadHistory.length
    }

    function dismissToast() {
        if (root.activeToast) {
            root.activeToast.ref.dismiss()
            root.activeToast = null
        }
        toastTimer.stop()
    }
}
