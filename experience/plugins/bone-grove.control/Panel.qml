import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
Panel {
 id: root
 moduleName:"bone-grove.control";manageIpc:false
 implicitWidth:button.implicitWidth;implicitHeight:button.implicitHeight
 property var state: ({})
 property string page:"controls"
 property string message:""
 property string cli:Quickshell.env("HOME")+"/.local/bin/bone-grove"
 function refresh() { if(!reader.running && !writer.running)reader.running=true }
 function act(args) { if(writer.running)return;message="";writer.command=[cli].concat(args);writer.running=true }
 onOpenedChanged: if(opened)refresh()
 Process {
  id:reader;command:[root.cli,"status"]
  stdout:StdioCollector { onStreamFinished: { try {root.state=JSON.parse(text);if(root.bar && "groveStatus" in root.bar)root.bar.groveStatus=root.state} catch(e){root.message="Unable to read controls"} } }
 }
 Process {
  id:writer
  stdout:StdioCollector { onStreamFinished: { try{var r=JSON.parse(text);if(r.error)root.message=r.error}catch(e){} } }
  onExited:function(code,status) {if(code && !root.message)root.message="Could not apply this change";Qt.callLater(root.refresh)}
 }
 Timer { interval:15000;running:true;repeat:true;triggeredOnStart:true;onTriggered:root.refresh() }
 IpcHandler {
  target:"bone-grove.control"
  function open():void {root.open()}
  function close():void {root.close()}
  function toggle():void {root.toggle()}
  function showSettings():void {root.page="appearance";root.open()}
 }
 WidgetButton {
  id:button;bar:root.bar;text:"󰒓";fontFamily:Style.font.family;fixedWidth:34
  tooltipText:"Grove Controls · sound, display and appearance";active:root.opened
  onPressed:function(mouseButton){if(mouseButton===Qt.RightButton)root.page="appearance";else root.page="controls";root.toggle()}
 }
 component Action: QQC.Button {
  id:a
  property bool selected:false
  implicitHeight:38
  font.family:"Adwaita Sans";font.pixelSize:12
  contentItem:Text {text:a.text;color:a.selected?"#b1e5c8":"#dde7e0";font:a.font;horizontalAlignment:Text.AlignHCenter;verticalAlignment:Text.AlignVCenter;elide:Text.ElideRight}
  background:Rectangle {radius:10;color:a.down?"#294338":a.hovered?"#1e3027":a.selected?"#1b3528":"#15211b";border.width:a.activeFocus?1:0;border.color:"#86c8a3";Behavior on color {ColorAnimation{duration:root.bar && root.bar.reducedMotion ? 0 : 120}}}
 }
 component Meter: Column {
  id:meter
  property string title:""
  property real current:0
  property real lower:0
  property real upper:100
  property real increment:1
  property string suffix:"%"
  signal committed(real value)
  width:parent.width;spacing:3
  Row {
   width:parent.width
   Text {width:parent.width-60;text:meter.title;color:"#dde7e0";font.family:"Adwaita Sans";font.pixelSize:13}
   Text {width:60;text:Math.round(slider.value)+meter.suffix;color:"#94ad9e";font.family:"Adwaita Sans";font.pixelSize:12;horizontalAlignment:Text.AlignRight}
  }
  QQC.Slider {
   id:slider;width:parent.width;height:30;from:meter.lower;to:meter.upper;stepSize:meter.increment;value:meter.current;enabled:!writer.running
   onPressedChanged:if(!pressed)meter.committed(value)
   Keys.onReleased:function(event){if(event.key===Qt.Key_Left || event.key===Qt.Key_Right)meter.committed(value)}
   background:Rectangle {x:slider.leftPadding;y:slider.topPadding+slider.availableHeight/2-3;width:slider.availableWidth;height:6;radius:3;color:"#283a30"
    Rectangle {width:slider.visualPosition*parent.width;height:6;radius:3;color:"#86c8a3"}
   }
   handle:Rectangle {x:slider.leftPadding+slider.visualPosition*(slider.availableWidth-width);y:slider.topPadding+slider.availableHeight/2-height/2;width:16;height:16;radius:8;color:"#e5eee8";border.color:slider.activeFocus?"#86c8a3":"#e5eee8";border.width:2}
  }
 }
 GrovePopup {
  id:popup;anchorItem:button;owner:root;bar:root.bar;open:root.opened;contentWidth:374;contentHeight:body.implicitHeight+34;focusTarget:body
  Column {
   id:body;width:340;spacing:18;focus:true
   Keys.onEscapePressed:root.close()
   Row {
    width:parent.width
    Column {width:parent.width-42;spacing:3
     Text {text:"Grove";color:"#e5eee8";font.family:"Adwaita Sans";font.pixelSize:21;font.weight:Font.DemiBold}
     Text {text:root.page==="controls"?"Everything within reach":"Make it yours";color:"#94ad9e";font.family:"Adwaita Sans";font.pixelSize:12}
    }
    Action {width:38;text:"×";onClicked:root.close()}
   }
   Row {width:parent.width;spacing:6
    Action {width:167;text:"Controls";selected:root.page==="controls";onClicked:root.page="controls"}
    Action {width:167;text:"Appearance";selected:root.page==="appearance";onClicked:root.page="appearance"}
   }
   Column {
    width:parent.width;spacing:16;visible:root.page==="controls"
    Row {width:parent.width;spacing:6
     Action {width:109;text:root.state.wifi?"Wi-Fi · On":"Wi-Fi · Off";selected:root.state.wifi===true;enabled:!writer.running;onClicked:root.act(["toggle","wifi"])}
     Action {width:109;text:"Bluetooth";selected:root.state.bluetooth===true;enabled:!writer.running;onClicked:root.act(["toggle","bluetooth"])}
     Action {width:110;text:"Night light";selected:root.state.nightlight===true;enabled:!writer.running;onClicked:root.act(["toggle","nightlight"])}
    }
    Meter {title:root.state.muted?"Volume · muted":"Volume";current:root.state.volume||0;enabled:root.state.volume!==null;onCommitted:function(v){root.act(["set","volume",String(Math.round(v))])}}
    Meter {title:"Brightness";current:root.state.brightness||0;enabled:root.state.brightness!==null;onCommitted:function(v){root.act(["set","brightness",String(Math.round(v))])}}
    Row {width:parent.width;spacing:6
     Action {width:109;text:root.state.muted?"Unmute":"Mute";onClicked:root.act(["toggle","mute"])}
     Action {width:109;text:"Connections";onClicked:{root.close();Quickshell.execDetached(["omarchy-shell","shell","toggle","omarchy.network"])}}
     Action {width:110;text:"Displays";onClicked:{root.close();Quickshell.execDetached(["omarchy-shell","shell","toggle","omarchy.monitor"])}}
    }
   }
   Column {
    width:parent.width;spacing:16;visible:root.page==="appearance"
    Text {text:"Motion";color:"#dde7e0";font.family:"Adwaita Sans";font.pixelSize:13}
    Row {width:parent.width;spacing:6
     Repeater {model:[{name:"Off",value:0},{name:"Quick",value:.65},{name:"Balanced",value:1},{name:"Soft",value:1.2}]
      Action {required property var modelData;width:80.5;text:modelData.name;selected:(root.state.reduceMotion?0:(root.state.groveMotion===undefined?1:root.state.groveMotion))===modelData.value;enabled:!writer.running;onClicked:root.act(["set","motion",String(modelData.value)])}
     }
    }
    Meter {title:"Bar height";lower:24;upper:40;suffix:" px";current:root.state.groveSize||30;onCommitted:function(v){root.act(["set","size",String(Math.round(v))])}}
    Meter {title:"Bar opacity";lower:75;upper:100;current:(root.state.groveOpacity||.94)*100;onCommitted:function(v){root.act(["set","opacity",String(v/100)])}}
    Action {width:parent.width;text:"Preview screensaver";onClicked:{root.close();Quickshell.execDetached([Quickshell.env("HOME")+"/.local/bin/omarchy-launch-screensaver","force"])}}
    Text {width:parent.width;wrapMode:Text.WordWrap;text:"Update: bone-grove update\nUndo last install: bone-grove restore";color:"#94ad9e";font.family:"Adwaita Sans";font.pixelSize:12;lineHeight:1.4}
   }
   Text {width:parent.width;visible:text.length>0;text:root.message;wrapMode:Text.WordWrap;color:"#dda7a0";font.family:"Adwaita Sans";font.pixelSize:12}
  }
 }
}
