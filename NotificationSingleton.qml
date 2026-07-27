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

    // Dismissing animation tracker — ids of toasts currently animating out
    property var dismissingIds: []

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

            // Queue if animating, otherwise show immediately
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

    // ── Queue and busy state ────────────────────────────────
    property var toastQueue: []
    property bool toastAnimBusy: false

    // ── Show a single toast ─────────────────────────────────
    function _showToast(notif) {
        root.toastAnimBusy = true

        // Update var array
        var toasts = [notif].concat(root.activeToasts)
        if (toasts.length > 4) {
            toasts = toasts.slice(0, 4)
        }
        root.activeToasts = toasts
        root.toastVersion++

        // If stack is full, dismiss the oldest with animation first
        if (root.toastAnimModel.count >= 4) {
            var oldestId = root.toastAnimModel.get(root.toastAnimModel.count - 1).id
            root._dismissAndInsert(oldestId, notif)
        } else {
            // Just insert directly
            root.toastAnimModel.insert(0, notif)
            gateTimer.interval = 300
            gateTimer.running = true
        }
    }

    // ── Dismiss oldest, then insert new ─────────────────────
    function _dismissAndInsert(oldestId, newNotif) {
        // Mark oldest as dismissing (starts the exit animation in the delegate)
        root.dismissingIds = root.dismissingIds.concat([oldestId])
        root.toastVersion++

        // Wait for animation to play, then remove and insert
        dismissTimer.oldestIndex = -1
        dismissTimer.newNotif = newNotif
        dismissTimer.running = true
    }

    // ── Timer: wait for dismiss animation, then swap ────────
    Timer {
        id: dismissTimer
        interval: 300
        running: false
        repeat: false
        property int oldestIndex: -1
        property var newNotif: null

        onTriggered: {
            if (root.toastAnimModel.count > 0) {
                var lastId = root.toastAnimModel.get(root.toastAnimModel.count - 1).id
                root.toastAnimModel.remove(root.toastAnimModel.count - 1)
                // Clean up dismissing id
                root.dismissingIds = root.dismissingIds.filter(id => id !== lastId)
            }
            root.toastAnimModel.insert(0, dismissTimer.newNotif)
            // Unblock queue
            gateTimer.interval = 350
            gateTimer.running = true
        }
    }

    // ── Gate timer — unblocks queue after animations finish ─
    Timer {
        id: gateTimer
        interval: 350
        running: false
        repeat: false
        onTriggered: {
            root.toastAnimBusy = false
            if (root.toastQueue.length > 0) {
                var nextNotif = root.toastQueue.shift()
                root._showToast(nextNotif)
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
            for (var i = root.toastAnimModel.count - 1; i >= 0; i--) {
                var t = root.toastAnimModel.get(i)
                // Only expire if not already dismissing
                if ((now - t._shownAt) >= 4000 && !root.dismissingIds.includes(t.id)) {
                    // Start dismiss animation, then remove
                    var expId = t.id
                    root.dismissingIds = root.dismissingIds.concat([expId])
                    root.toastVersion++
                    expireRemoveTimer.pendingId = expId
                    expireRemoveTimer.running = true
                }
            }

            // Sync var array
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

    // ── Timer: remove expired toast after dismiss animation ─
    Timer {
        id: expireRemoveTimer
        interval: 300
        running: false
        repeat: false
        property int pendingId: -1
        onTriggered: {
            for (var i = 0; i < root.toastAnimModel.count; i++) {
                if (root.toastAnimModel.get(i).id === expireRemoveTimer.pendingId) {
                    root.toastAnimModel.remove(i)
                    break
                }
            }
            root.dismissingIds = root.dismissingIds.filter(id => id !== expireRemoveTimer.pendingId)
            expireRemoveTimer.pendingId = -1
        }
    }

    // ── Check if a toast is currently dismissing ────────────
    function isDismissing(id) {
        return root.dismissingIds.indexOf(id) >= 0
    }

    // ── Public actions ─────────────────────────────────────
    function clearAll() {
        root.toastQueue = []
        root.dismissingIds = []
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
}
