import QtQuick

// ColorAnimation wrapper with consistent Material 3 inspired timing.
// Usage:
//   Behavior on color { AnimC {} }
ColorAnimation {
    duration: 300
    easing.type: Easing.BezierSpline
    easing.bezierCurve: [0.34, 0.88, 0.34, 1, 1, 1]
}