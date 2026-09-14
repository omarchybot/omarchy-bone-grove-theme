import QtQuick
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"
  readonly property bool reduce: root.bar && root.bar.reducedMotion === true
  readonly property int cell: 24
  readonly property var ids: {
    var result=[1,2,3,4,5]; var all=Hyprland.workspaces.values
    for (var i=0;i<all.length;i++) if(all[i].id>0 && result.indexOf(all[i].id)<0) result.push(all[i].id)
    return result.sort(function(a,b){return a-b})
  }
  readonly property int current: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
  function occupied(id) {
    var all=Hyprland.workspaces.values
    for(var i=0;i<all.length;i++) if(all[i].id===id) return all[i].toplevels.values.length>0
    return false
  }
  function focus(id) {
    if(root.bar) root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }
  implicitWidth: root.vertical ? root.barSize : ids.length*cell+4
  implicitHeight: root.vertical ? ids.length*cell : root.barSize
  Rectangle {
    x: root.vertical ? 4 : Math.max(0,root.ids.indexOf(root.current))*root.cell
    y: root.vertical ? Math.max(0,root.ids.indexOf(root.current))*root.cell : (root.barSize-20)/2
    width: root.vertical ? root.barSize-8 : 22
    height: 20; radius: 8
    color: Color.accent; opacity: 0.18
    Behavior on x { NumberAnimation { duration: root.reduce ? 0 : 340; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: root.reduce ? 0 : 340; easing.type: Easing.OutCubic } }
  }
  Repeater {
    model: root.ids
    WidgetButton {
      required property int modelData
      required property int index
      readonly property bool current: root.current===modelData
      readonly property bool occupied: root.occupied(modelData)
      x: root.vertical ? 0 : index*root.cell
      y: root.vertical ? index*root.cell : 0
      width: root.vertical ? root.barSize : root.cell
      height: root.vertical ? root.cell : root.barSize
      bar: root.bar
      text: String(modelData); labelVisible: false
      tooltipText: "Workspace "+modelData+" · scroll to switch"
      onPressed: root.focus(modelData)
      onWheelMoved: function(delta) { if(delta) root.focus(Math.max(1,root.current+(delta<0 ? 1 : -1))) }
      Text {
        anchors.centerIn: parent
        text: parent.current || parent.tooltipHovered ? String(parent.modelData).padStart(2,"0") : ""
        font.family: "Adwaita Sans"; font.pixelSize: 11; font.weight: Font.DemiBold
        color: Color.foreground
        opacity: parent.current ? 1 : 0.75
        Behavior on opacity { NumberAnimation { duration: root.reduce ? 0 : 180 } }
      }
      Rectangle {
        anchors.centerIn: parent
        width: parent.occupied ? 5 : 3; height: width; radius: width/2
        color: Color.accent
        opacity: parent.current || parent.tooltipHovered ? 0 : (parent.occupied ? 0.8 : 0.3)
        Behavior on opacity { NumberAnimation { duration: root.reduce ? 0 : 160 } }
      }
    }
  }
}
