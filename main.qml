import QtQuick 2.4
import QtQuick.Window 2.2
import QtBluetooth 5.3
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQml 2.0
// adding localstorage :)
import QtQuick.LocalStorage 2.0 as Sql

Item {
    id: mainPageWraper
    visible: true

    MouseArea {
        anchors.fill: parent
        onClicked: lightController.closeSelector()
    }

    // CREATE DATABASE FOR SAVING USER DATA
    function getDatabase() {
        var db = Sql.LocalStorage.openDatabaseSync("TestDB", "", "Description", 100000);
        db.transaction(
                    function(tx) {
                        var query="CREATE TABLE IF NOT EXISTS DATA(type VARCHAR(100), value VARCHAR(100))";
                        var debug =tx.executeSql(query);
                        console.debug(JSON.stringify(debug));
                    });
        return db;
    }

    function printValues() {
        var db = getDatabase();
        db.transaction( function(tx) {
            var rs = tx.executeSql("SELECT * FROM DATA");
            console.debug(JSON.stringify(rs));
            console.debug("===============================");
            for(var i = 0; i < rs.rows.length; i++) {
                var dbItem = rs.rows.item(i);
                console.log("TYPE"+ dbItem.type + ", VALUE"+dbItem.value);
            }
            console.debug("-------------------------------");
        });
    }
    Item {
        Component.onCompleted: {
            printValues()
        }
    }

    // FIRST VIEW WRAPPER (main view, not bluetooth)
    Item {
        id: mainView
        width: parent.width
        height: parent.height
        // JOYSTICK ELEMENT (JoyStick.qml)
        JoyStick {
            id:joystick
            //            anchors.verticalCenter: parent.verticalCenter
            //            anchors.horizontalCenter: parent.horizontalCenter

            property string oldDir
            property int oldPower

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

            onDirChanged: {
                var colorArray = lightController.getColors()
                socket.sendStringData("["+set_value(x)+","+set_value(y)+",000,000,000,000,000,000]")
                console.log(set_value(x), set_value(y))
            }

            width: parent.height * 0.4
            height: parent.height * 0.4
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
        }


        /*************************************************/

        LightControl {
            id: lightController
            height: parent.height * 0.4 + 200
            width: parent.height* 0.4 + 100
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
        }
        Item {
            id: colorpicker
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            ColorDialogTab {
                selected: "topLeft"
                id: colorSelectorTopLeft
                width: 300
                height: 400
                onColorChanged: {
                    console.debug(color + " : " + selected)
                    lightController.changeColor(color, selected)
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
            }
            ColorDialogTab {
                selected: "topRight"
                id: colorSelectorTopRight
                width: 300
                height: 400
                onColorChanged: {
                    console.debug(color + " : " + selected)
                    lightController.changeColor(color, selected)
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
            }
            ColorDialogTab {
                selected: "botLeft"
                id: colorSelectorBotLeft
                width: 300
                height: 400
                onColorChanged: {
                    console.debug(color + " : " + selected)
                    lightController.changeColor(color, selected)
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
            }
            ColorDialogTab {
                selected: "botRight"
                id: colorSelectorBotRight
                width: 300
                height: 400
                onColorChanged: {
                    console.debug(color + " : " + selected)
                    lightController.changeColor(color, selected)
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
            }
            ColorDialogTab {
                selected: "center"
                id: colorSelectorCenter
                width: 300
                height: 400
                onColorChanged: {
                    console.debug(color + " : " + selected)
                    lightController.changeColor(color, selected)
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
            }
            ColorDialogTab {
                selected: "right"
                id: colorSelectorRight
                width: 300
                height: 400
                onColorChanged: {
                    console.debug(color + "(right) : " + selected)
                    lightController.changeColor(color, selected)
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
            onSocketStateChanged: {
                console.log("Socket state: " + socketState)
            }

            onStringDataChanged: {
                var data = socket.stringData
                //                console.log("Received data: " + data)
            }
        }
        Rectangle {
            color: "transparent"
            anchors.top: parent.top
            anchors.topMargin: 0
            width: parent.width
            height: 100

            Text {
                text: socket.connected ? socket.service.deviceName : ""
                visible: socket.connected
                font.pointSize: 35
                anchors.leftMargin: 10
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: btScanButton.left
            }

            ImgButton {
                id: btScanButton

                imgSrc: "btScanButton.svg"
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 80
                height: 80

                onClicked: {
                    console.debug("BT scannig menu selected.")
                    stackView.push(scanner)
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
            if (event.key === Qt.Key_Back && stackView.depth > 1) {
                stackView.pop()
                event.accepted = true
                console.debug("Back key pressed.")
            }
        }
    }
}