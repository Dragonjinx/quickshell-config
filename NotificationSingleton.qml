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

    // ── Toast display queue ─────────────────────────────────
    // Queues notifications when an animation is in progress to prevent
    // overlapping transitions when notifications arrive faster than
    // animations can play.
    property var toastQueue: []
    property bool toastAnimBusy: false
    property bool _removeWasDone: false

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

            // Queue or show immediately based on animation state
            if (root.toastAnimBusy) {
                root.toastQueue.push(notif)
            } else {
                root._showToast(notif)
            }

            // Ensure expiry timer is running
            if (!expiryTimer.running) {
                expiryTimer.running = true
            }
        }
    }

    // ── Show a single toast with proper animation sequencing ──
    function _showToast(notif) {
        root.toastAnimBusy = true
        root._removeWasDone = false

        // Keep var array
        var toasts = [notif].concat(root.activeToasts)
        if (toasts.length > 4) {
            toasts = toasts.slice(0, 4)
        }
        root.activeToasts = toasts
        root.toastVersion++

        // Remove excess first (oldest slides out)
        if (root.toastAnimModel.count >= 4) {
            root._removeWasDone = true
            root.toastAnimModel.remove(4, root.toastAnimModel.count - 4)
        }

        // Defer insert to next frame so remove animation can start first
        deferInsert.pendingNotif = notif
        deferInsert.running = true
    }

    // ── Process next toast from queue ───────────────────────
    function _processQueue() {
        root.toastAnimBusy = false
        if (root.toastQueue.length > 0) {
            var nextNotif = root.toastQueue.shift()
            root._showToast(nextNotif)
        }
    }

    // ── Deferred insert (fires next frame, after remove starts) ─
    Timer {
        id: deferInsert
        interval: 0
        running: false
        repeat: false
        property var pendingNotif: null
        onTriggered: {
            if (deferInsert.pendingNotif) {
                root.toastAnimModel.insert(0, deferInsert.pendingNotif)
                deferInsert.pendingNotif = null

                // Start timer to unblock queue after animations complete
                // Remove: 200ms + Move pause: 200ms + Add: 250ms + Move: 200ms
                // Without remove: Add 250ms + Move 250ms
                var delay = root._removeWasDone ? 700 : 300
                animGateTimer.interval = delay
                animGateTimer.running = true
            }
        }
    }

    // ── Animation gate — unblocks queue after animations finish ─
    Timer {
        id: animGateTimer
        interval: 700
        running: false
        repeat: false
        onTriggered: {
            root._processQueue()
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
            for (var i = root.toastAnimModel.count - 1; i >= 0; i--) {
                var t = root.toastAnimModel.get(i)
                if ((now - t._shownAt) >= 4000) {
                    root.toastAnimModel.remove(i)
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
