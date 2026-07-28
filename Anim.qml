import QtQuick

// NumberAnimation wrapper with Material 3 inspired timing tokens.
// Usage:
//   Behavior on opacity { Anim { type: Anim.FastEffects } }
//   Behavior on x { Anim { type: Anim.DefaultSpatial } }
//   add: Transition { Anim { type: Anim.Emphasized } }
NumberAnimation {
    enum Type {
        Standard = 0,
        Emphasized,
        FastSpatial,
        DefaultSpatial,
        SlowSpatial,
        FastEffects,
        DefaultEffects,
        SlowEffects
    }

    // --- Type selector ---
    property int type: Anim.DefaultSpatial

    // --- Duration by type (milliseconds) ---
    readonly property int _duration: {
        switch (type) {
        case Anim.Standard:        return 400
        case Anim.Emphasized:      return 400
        case Anim.FastSpatial:     return 350
        case Anim.DefaultSpatial:  return 500
        case Anim.SlowSpatial:     return 650
        case Anim.FastEffects:     return 150
        case Anim.DefaultEffects:  return 200
        case Anim.SlowEffects:     return 300
        default:                   return 400
        }
    }

    // --- Cubic bezier curve by type (single segment: c1x, c1y, c2x, c2y, 1, 1) ---
    readonly property var _curve: {
        switch (type) {
        case Anim.Standard:        return [0.20, 0,    0,    1,    1, 1]   // smooth deceleration
        case Anim.Emphasized:      return [0.05, 0,    0.25, 1,    1, 1]   // fast start, slow finish
        case Anim.FastSpatial:     return [0.40, 1.60, 0.20, 0.90, 1, 1]   // slight overshoot
        case Anim.DefaultSpatial:  return [0.38, 1.21, 0.22, 1,    1, 1]   // subtle overshoot
        case Anim.SlowSpatial:     return [0.39, 1.29, 0.35, 0.98, 1, 1]   // more overshoot
        case Anim.FastEffects:     return [0.31, 0.94, 0.34, 1,    1, 1]   // quick fade
        case Anim.DefaultEffects:  return [0.34, 0.80, 0.34, 1,    1, 1]   // standard fade
        case Anim.SlowEffects:     return [0.34, 0.88, 0.34, 1,    1, 1]   // slow fade
        default:                   return [0.20, 0,    0,    1,    1, 1]
        }
    }

    duration: _duration
    easing.type: Easing.BezierSpline
    easing.bezierCurve: _curve
}