import QtQuick
import Quickshell
Item {
 id: scene
 property bool reducedMotion: false
 property bool showClock: true
 property date now: new Date()
 property real phase: (now.getTime() % 180000) / 180000 * Math.PI * 2
 Timer { interval: scene.reducedMotion ? 1000 : 50; running: scene.visible; repeat: true; onTriggered: scene.now = new Date() }
 Rectangle { anchors.fill: parent; color: "#060b08" }
 Image {
  anchors.fill:parent
  source: "file://"+Quickshell.env("HOME")+"/.config/omarchy/themes/bone-grove/backgrounds/01-bone-grove.png"
  fillMode:Image.PreserveAspectCrop;asynchronous:true
 }
 Rectangle {anchors.fill:parent;color:"#060b08";opacity:.16}
 Rectangle {
  width:scene.width*.62;height:scene.height;x:-width*.20
  gradient:Gradient {orientation:Gradient.Horizontal;GradientStop{position:0;color:"#99060b08"}GradientStop{position:1;color:"#00060b08"}}
 }
 // A low-opacity light breathes over the existing mist without moving the artwork.
 Rectangle { anchors.fill:parent;color:"#86c8a3";opacity:scene.reducedMotion?0:.012+.010*Math.sin(scene.phase) }

 Column {
  visible:scene.showClock; x:parent.width*.13; y:parent.height*.30; spacing:12
  Text { text:Qt.formatDateTime(scene.now,"h:mm"); color:"#e1ebe4";font.family:"Adwaita Sans";font.weight:Font.Light;font.pixelSize:Math.min(scene.width*.115,148);font.letterSpacing:-4 }
  Text { text:Qt.formatDateTime(scene.now,"dddd, MMMM d");color:"#aeb9ad";font.family:"Adwaita Sans";font.pixelSize:18;font.letterSpacing:.5 }
 }
 Text { anchors.horizontalCenter:parent.horizontalCenter;anchors.bottom:parent.bottom;anchors.bottomMargin:40;text:"G R O V E   /   E M E R A L D";color:"#849c86";font.family:"Adwaita Sans";font.pixelSize:10 }
}
