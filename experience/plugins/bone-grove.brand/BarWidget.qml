import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "bone-grove.brand"
  implicitWidth: root.vertical ? root.barSize : 92
  implicitHeight: root.barSize
  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "Grove"
    labelVisible: false
    tooltipText: "Grove menu · right-click: screensaver · middle-click: reduced motion"
    onPressed: function(mouseButton) {
      if (!root.bar) return
      if (mouseButton === Qt.RightButton) root.bar.run("$HOME/.local/bin/omarchy-launch-screensaver force")
      else if (mouseButton === Qt.MiddleButton) root.bar.run("$HOME/.local/bin/bone-grove-motion toggle")
      else root.bar.run("omarchy-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
    }
    Canvas {
      id: leaf
      width: 23; height: 24
      anchors.left: parent.left; anchors.leftMargin: 5
      anchors.verticalCenter: parent.verticalCenter
      rotation: button.tooltipHovered ? -5 : 0
      Behavior on rotation { NumberAnimation { duration: root.bar && root.bar.reducedMotion ? 0 : 280; easing.type: Easing.OutCubic } }
      property color ink: Color.accent
      onInkChanged: requestPaint()
      onPaint: {
        var c = getContext("2d"); c.reset(); c.fillStyle = ink
        c.beginPath(); c.moveTo(11,20); c.bezierCurveTo(0,16,1,6,3,3); c.bezierCurveTo(13,4,15,12,11,20); c.fill()
        c.beginPath(); c.moveTo(12,18); c.bezierCurveTo(11,7,17,2,22,2); c.bezierCurveTo(24,11,18,17,12,18); c.fill()
        c.strokeStyle = ink; c.lineWidth=1.2; c.beginPath(); c.moveTo(11,18); c.lineTo(11,23); c.stroke()
      }
    }
    Text {
      visible: !root.vertical
      anchors.left: leaf.right; anchors.leftMargin: 7
      anchors.verticalCenter: parent.verticalCenter
      text: "GROVE"; color: Color.foreground
      font.family: "Adwaita Sans"; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1.6
    }
  }
}
