import QtQuick

// AnchorAnimation wrapper with Material 3 inspired spatial timing tokens.
// Usage:
//   Transition { AnchorAnim { type: AnchorAnim.DefaultSpatial } }
AnchorAnimation {
    enum Type {
        Standard = 0,
        Emphasized,
        FastSpatial,
        DefaultSpatial,
        SlowSpatial
    }

    property int type: AnimAnchor.DefaultSpatial

    readonly property int _duration: {
        switch (type) {
        case AnimAnchor.Standard:       return 400
        case AnimAnchor.Emphasized:     return 400
        case AnimAnchor.FastSpatial:    return 350
        case AnimAnchor.DefaultSpatial: return 500
        case AnimAnchor.SlowSpatial:    return 650
        default:                        return 500
        }
    }

    readonly property var _curve: {
        switch (type) {
        case AnimAnchor.Standard:       return [0.20, 0,    0,    1,    1, 1]
        case AnimAnchor.Emphasized:     return [0.05, 0,    0.25, 1,    1, 1]
        case AnimAnchor.FastSpatial:    return [0.40, 1.60, 0.20, 0.90, 1, 1]
        case AnimAnchor.DefaultSpatial: return [0.38, 1.21, 0.22, 1,    1, 1]
        case AnimAnchor.SlowSpatial:    return [0.39, 1.29, 0.35, 0.98, 1, 1]
        default:                        return [0.38, 1.21, 0.22, 1,    1, 1]
        }
    }

    duration: _duration
    easing.type: Easing.BezierSpline
    easing.bezierCurve: _curve
}