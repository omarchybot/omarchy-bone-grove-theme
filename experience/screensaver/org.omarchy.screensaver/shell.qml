//@ pragma AppId org.omarchy.screensaver
//@ pragma ShellId bone-grove-screensaver
import QtQuick
import Quickshell
import Quickshell.Io
ShellRoot {
 id: root
 property bool leaving: false
 property bool armed: false
 property bool reduced: false
 function dismiss() { if (!leaving) { leaving=true; exitTimer.start() } }
 Timer { interval:700;running:true;onTriggered:root.armed=true }
 Timer { id:exitTimer;interval:root.reduced?1:180;onTriggered:Qt.quit() }
 FileView { path:Quickshell.env("HOME")+"/.local/state/omarchy/bone-grove/reduced-motion";printErrors:false;onLoaded:root.reduced=true }
 IpcHandler { target:"grove"; function dismiss():void { root.dismiss() } }
 Variants {
  model:Quickshell.screens
  FloatingWindow {
   id:window
   required property var modelData
   screen:modelData;visible:true;fullscreen:true;color:"transparent";title:"Bone Grove"
   Item {
    anchors.fill:parent;focus:true;opacity:root.leaving?0:1
    Behavior on opacity { NumberAnimation { duration:root.reduced?0:180;easing.type:Easing.OutCubic } }
    Keys.onPressed:function(event) { if (root.armed) { root.dismiss();event.accepted=true } }
    GroveScene { anchors.fill:parent; reducedMotion:root.reduced }
    MouseArea {
     anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.BlankCursor
     property real lastX:-1;property real lastY:-1
     onPressed:if(root.armed)root.dismiss()
     onWheel:if(root.armed)root.dismiss()
     onPositionChanged:function(mouse) {
      if(root.armed && lastX>=0 && (Math.abs(mouse.x-lastX)>3 || Math.abs(mouse.y-lastY)>3))root.dismiss()
      if(lastX<0 || !root.armed) {lastX=mouse.x;lastY=mouse.y}
     }
    }
   }
  }
 }
}
