 import QtQuick 2.4
import QtQuick.Window 2.2
import QtBluetooth 5.3
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQml 2.0
import QtGraphicalEffects 1.0
import QtSensors 5.3 as Sensors

//import Qt.labs.gestures 1.0

// adding localstorage :)
import "Database.js" as Db

Item {
    id: mainPageWraper
    visible: true
    property string selected_main

    // import font
    FontLoader { id: customFont; source: "Typ1451.otf" }


    // save state on close
    Component.onDestruction: {
        Db.init()
        var savedColors = Db.getRecords()
        Db.updateRecord(lightController.getColors().topLeft, "topLeft")
        Db.updateRecord(lightController.getColors().topRight, "topRight")
        Db.updateRecord(lightController.getColors().botLeft, "botLeft")
        Db.updateRecord(lightController.getColors().botRight, "botRight")
        Db.updateRecord(lightController.getColors().center, "center")
        Db.updateRecord(lightController.getColors().right, "right")
        Db.updateRecord(lightController.getColors().leftControl, "leftControl")
        Db.updateRecord(lightController.getColors().rightControl, "rightControl")
        console.log("QML exit")
    }

    // outside click event when color popup open
    MouseArea {
        anchors.fill: parent
        onClicked: {

            FileIO.save("/home/erwan/Desktop/test42.txt", "nouvelle donnee");
            function is_open(){
                if (colorSelector.visible == true)
                    return true
                return false
            }

            if (is_open() == true) {
                lightController.changeColor(lightController.prevColor, selected_main)
                lightController.closeSelector()
            }
        }
    }

    /*GestureArea {
        anchors.fill: parent
        onGesture: {
            console.debug("swipe")
        }
    }*/

    // background of the main page
    Rectangle {
        anchors.fill: parent
        color: stackView.currentItem == scanner?"#eaeaea":"white"
        Image {
            height: parent.height * 0.6
            width: parent.height * 0.6
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.1
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0.2
            id: background
            visible: stackView.currentItem == scanner?false:true
            source: "logo.png"
        }
    }

    // load previous colors from db
    Item {
        Component.onCompleted: {
            Db.init()
            var savedColors = Db.getRecords()
            lightController.changeColor(savedColors[0].content, "topLeft")
            lightController.changeColor(savedColors[1].content, "topRight")
            lightController.changeColor(savedColors[2].content, "botLeft")
            lightController.changeColor(savedColors[3].content, "botRight")
            lightController.changeColor(savedColors[4].content, "center")
            lightController.changeColor(savedColors[5].content, "right")
            lightController.changeColor(savedColors[6].content, "leftControl")
            lightController.changeColor(savedColors[7].content, "rightControl")
        }
    }

    // FIRST VIEW WRAPPER (main view, not bluetooth)
    Item {
        id: mainView
        width: parent.width
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right

        // JOYSTICK ELEMENT (JoyStick.qml)
        JoyStick {
            id:joystick

            property string oldDir
            property int oldPower

            width: parent.height * 0.5
            height: parent.height * 0.5
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50

            function set_value(val) {
                val = Math.round(val * 100) / 100
                if (val < 100 && val >= 10)
                    val = "+0"+val
                else if (val > -100 && val <= -10)
                    val = "-0"+Math.abs(val)
                else if (val === 0)
                    val = "+000"
                else if (val < 10 && val > 0)
                    val = "+00"+val
                else if (val > -10 && val < 0)
                    val = "-00"+Math.abs(val)
                else if (val >= 100)
                    val = "+"+val
                else if (val <= -100)
                    val = val
                return val
            }

            function set_value_led(val) {
                val = Math.round(val * 100) / 100
                if (val < 100 && val >= 10)
                    val = "0"+val
                else if (val > -100 && val <= -10)
                    val = "0"+Math.abs(val)
                else if (val === 0)
                    val = "000"
                else if (val < 10 && val > 0)
                    val = "00"+val
                else if (val > -10 && val < 0)
                    val = "00"+Math.abs(val)
                else if (val >= 100)
                    val = val
                else if (val <= -100)
                    val = val
                return val
            }

            function rgbToBin(r,g,b){
                var bin = r << 16 | g << 8 | b;
                return (function(h){
                    return new Array(25-h.length).join("0")+h
                })(bin.toString(2))
            }

            function rgbToUint32(color) {
                var red = Math.round(color.r * 255)
                var green = Math.round(color.g * 255)
                var blue = Math.round(color.b * 255)
                var uint32 = rgbToBin(red,green,blue)
                return uint32
            }

            onDirChanged: {
                if (socket.connected == true) {
                    //                if (true) {
                    var colorArray = lightController.getColors()
                    var colorEars = colorArray.center
                    var colorTopLeft = colorArray.topLeft
                    var colorTopRight = colorArray.topRight
                    var colorBotLeft = colorArray.botLeft
                    var colorBotRight = colorArray.botRight
                    var ct
                    var fl
                    var fr
                    var bl
                    var br
                    var mainControl = colorArray.right
                    var rightControl = colorArray.rightControl
                    var leftControl = colorArray.leftControl

                    // MAIN CONTROLL
                    if (lightController.getSelected().right == true)
                        mainControl = set_value_led(Math.round(mainControl.r * 255))+","+set_value_led(Math.round(mainControl.g * 255))+","+set_value_led(Math.round(mainControl.b * 255))
                    else if (lightController.getSelected().right == false)
                        mainControl = "000,000,000"

                    // RIGHT CONTROLL
                    if (lightController.getSelected().rightControl == true)
                        rightControl = set_value_led(Math.round(rightControl.r * 255))+","+set_value_led(Math.round(rightControl.g * 255))+","+set_value_led(Math.round(rightControl.b * 255))
                    else if (lightController.getSelected().rightControl == false)
                        rightControl = null

                    // LEFT CONTROLL
                    if (lightController.getSelected().leftControl == true)
                        leftControl = set_value_led(Math.round(leftControl.r * 255))+","+set_value_led(Math.round(leftControl.g * 255))+","+set_value_led(Math.round(leftControl.b * 255))
                    else if (lightController.getSelected().leftControl == false)
                        leftControl = null


                    if (lightController.getSelected().center == true)
                        ct = set_value_led(Math.round(colorEars.r * 255))+","+set_value_led(Math.round(colorEars.g * 255))+","+set_value_led(Math.round(colorEars.b * 255))
                    else if(lightController.getSelected().center == false)
                        ct = mainControl

                    if (lightController.getSelected().topLeft == true)
                        fl = set_value_led(Math.round(colorTopLeft.r * 255))+","+set_value_led(Math.round(colorTopLeft.g * 255))+","+set_value_led(Math.round(colorTopLeft.b * 255))
                    else if(lightController.getSelected().topLeft == false) {
                        if (leftControl != null)
                            fl = leftControl
                        else
                            fl = mainControl
                    }

                    if (lightController.getSelected().topRight == true)
                        fr = set_value_led(Math.round(colorTopRight.r * 255))+","+set_value_led(Math.round(colorTopRight.g * 255))+","+set_value_led(Math.round(colorTopRight.b * 255))
                    else if(lightController.getSelected().topRight == false) {
                        if (rightControl != null)
                            fr = rightControl
                        else
                            fr = mainControl
                    }

                    if (lightController.getSelected().botLeft == true)
                        bl = set_value_led(Math.round(colorBotLeft.r * 255))+","+set_value_led(Math.round(colorBotLeft.g * 255))+","+set_value_led(Math.round(colorBotLeft.b * 255))
                    else if(lightController.getSelected().botLeft == false){
                        if (leftControl != null)
                            bl = leftControl
                        else
                            bl = mainControl
                    }
                    if (lightController.getSelected().botRight == true)
                        br = set_value_led(Math.round(colorBotRight.r * 255))+","+set_value_led(Math.round(colorBotRight.g * 255))+","+set_value_led(Math.round(colorBotRight.b * 255))
                    else if(lightController.getSelected().botRight == false) {
                        if (rightControl != null)
                            br = rightControl
                        else
                            br = mainControl
                    }

                    socket.sendStringData("["+set_value(left)+","+set_value(right)+","+ct+","+fl+","+fr+","+bl+","+br+"]")
                    //                    console.debug("["+set_value(left)+","+set_value(right)+","+ct+","+fl+","+fr+","+bl+","+br+"]")
                }
            }
        }

        /***********************************************/

        // timer (StopWatch.qml)


        StopWatch {
            id: stopWatch

            anchors.top: parent.top
            anchors.topMargin: 3 * Screen.logicalPixelDensity
            anchors.left: parent.left
            anchors.leftMargin: 0.5 * Screen.logicalPixelDensity

            width: 50 * Screen.logicalPixelDensity
            height: 15 * Screen.logicalPixelDensity
        }

        // robot light controller (LightControl.qml)
        LightControl {
            id: lightController
            height: parent.height * 0.5 + 10
            width: parent.height* 0.5 + 25
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
        }

        // colorPicker for lightcontroller
        Item {
            id: colorpicker
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height / 2
            width: (parent.height / 2) * 9/14

            // colorPicker
            ColorDialogTab {
                id: colorSelector
                onColorChanged: {
                    console.debug("color: "+color+"  prev_color: "+lightController.prevColor)
                    lightController.changeColor(color, selected)
                    selected_main = selected
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
            }
        }

        // SCANNER
        Scanner {
            id: scanner
            onSelected: {
                socket.connected = false
                socket.setService(remoteService)
                socket.connected = true
                stackView.pop()
            }
        }


        BluetoothSocket {
            id: socket
            connected: true
//            service: BluetoothService
            onSocketStateChanged: {

            }

            // receive arduino info
            onDataAvailable: {
                var abc;
                abc = stringData;
//                console.debug(stringData);
//                console.debug(data);
                console.debug(abc.toString())

/*                if (abc.length > 0) {
                    console.debug("size: "+ abc.length + "  | string: " +abc);
                    var parsed = JSON.parse(abc);
                    console.debug("stringParsed : " + parsed);
                    console.debug("Rotation : "+ parsed[4]);
                    if (parsed[7] != undefined)
                        joystick.changeRotation(Math.round((360*parsed[4]) / 4));
                }
*/
            }

            onStringDataChanged: {

            }
        }
        Rectangle {
            color: "transparent"
            anchors.top: parent.top
            anchors.topMargin: 0
            width: parent.width
            height: mainPageWraper.height * 0.1

            Text {
                //                text: socket.connected ? socket.service.deviceName : ""
                text: ""
                visible: socket.connected
                font.pointSize: 35
                anchors.right: btScanButton.left
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            ImgButton {
                id: btScanButton
                anchors.right: parent.right
                anchors.rightMargin: mainPageWraper.width * 0.01
                anchors.verticalCenter: parent.verticalCenter
                imgSrc: "btScanButton.png"
                ColorOverlay {
                    anchors.fill: btScanButton
                    source: btScanButton
                    color: "green"

                    visible: socket.connected?true:false
                }

                width: height * 0.7
                height: mainPageWraper.height * 0.08

                onClicked: {
                    console.debug("BT scannig menu selected.")
                    stackView.push({item:scanner, immediate: true, replace: true})
                }
            }

        }
    }

    StackView {
        id: stackView
        initialItem: mainView
        focus: true
        anchors.fill: parent
        Keys.onReleased: {
            console.debug(event.key)
            if (event.key === Qt.Key_Back && stackView.depth > 1) {
                stackView.pop()
                event.accepted = true
                console.debug("Back key pressed.")
            }
        }
    }
}
