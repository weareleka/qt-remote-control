import QtQuick 2.4
import QtQml 2.0
import QtQuick.Controls 1.4

Item {
    id:gamepage

    Rectangle{
        id: gamepage_statusbar
        //color: "#56AED4"
        color:"transparent"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        height: parent.height * 0.1
        z: 2


        ImgButton {
            id: backButton
            imgSrc: "pictures/backButton.svg"
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.01
            height: parent.height * 0.6
            anchors.verticalCenter: parent.verticalCenter

            width: height
            visible: stackView.currentItem == gamepage?true:false
            onClicked: {
                console.debug("Leaving GamePage")
                stackView.push({item:mainView, immediate: true, replace: true})
            }
        }
    }

    //Game Grid View
    GridView {
        id: gameGrid
        width:  400
        height: 300
        cellWidth: 100; cellHeight: 100

        anchors.top:gamepage_statusbar.bottom
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        //Header and Footer Components
        header:headerComponent

        //This make sthat no item is initially picked
        currentIndex: -1;

        //Component, Game Grid
        Component {
            id: gamesDelegate
            Rectangle {
                id: wrapper
                width: 100
                height: 100
                color: GridView.isCurrentItem ? "lightsteelblue" : "transparent"
                Image {
                    source: icon
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter:parent.verticalCenter
                }

                Text {
                    id: contactInfo
                    text: name
                    anchors.horizontalCenter: parent.horizontalCenter
                    //color: wrapper.GridView.isCurrentItem ? "red" : "black"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        gameGrid.currentIndex = index
                        timer.start()

                    }
                }
            }
        }

        model: GameModel {}
        delegate: gamesDelegate

        Timer {
            id: timer
                interval: 200; running: false; repeat: false
                onTriggered: gameGrid.currentIndex = -1
            }
    }

    Component{
        id: headerComponent
        Text{
            width: GridView.view.width
            height: 20
            horizontalAlignment: Text.AlignHCenter
            //font.family: customFont
            text: 'Select a routine:'

        }
    }


    Button{
        id: gameButtonRainbow
        text: "rainbow"

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        onClicked:{
            if(socket.connected == true){
                socket.sendStringData("<R>")
                console.debug("<R>")
                }
        }
    }




}