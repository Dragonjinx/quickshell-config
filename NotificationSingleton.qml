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
    property var toastQueue: []
    property bool toastAnimBusy: false

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
    function clearAll() {
        root.toastQueue = []
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
        root.notificationHistory = root.notificationHistory.filter(n => n.id !== notif.id)
        root.unreadHistory = root.unreadHistory.filter(n => n.id !== notif.id)
        root.unreadCount = root.unreadHistory.length
        root.historyVersion++
        root.dismissToast(notif)
    }
}
