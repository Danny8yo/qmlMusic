import QtQuick
import QtQuick.Layouts
import QtQuick.Controls


Rectangle {
    id: sideBar
    width: 200
    color: "#d2d2d2"

    // property int selectedIndex: 0

    // signal itemClicked(int index)
    // signal scanMusicClicked()

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        // anchors.margins:
        // spacing: appTheme.normalSpacing

        // 标题
        Text {
            text: "QML Music"
            font.pixelSize: 25
            font.bold: true
            // color:
            Layout.alignment: Qt.AlignHCenter
        }

        // 导航菜单
        ListView {
            id: _guideBar
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight

            //设置标题
            header: Text {
                text: "导航菜单"
                font.pixelSize: 18
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            model: ListModel {
                ListElement { title: "发现"}
                ListElement { title: "我的喜欢"}
                ListElement { title: "本地音乐"}
            }

            // 滚动条 (可选)
            ScrollBar.vertical: ScrollBar {
                id: verticalScrollBar
            }

            //如何展示 Item 的一个模板
            delegate: Rectangle {
                width: _guideBar.width
                height: 40
                color: "#d2d2d2"
                radius: 4

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: parent.color = parent.color === "transparent" ? "#f5f7fe" : parent.color
                    // onExited: parent.color = index === sideBar.selectedIndex ? appTheme.selectedColor : "transparent"
                    // onClicked: {
                    //     sideBar.selectedIndex = index
                    //     sideBar.itemClicked(index)
                    // }
                }

                RowLayout {
                    anchors.fill: parent
                    // anchors.leftMargin: 5
                    // anchors.rightMargin: 5

                    Text {
                        // anchors.centerIn: parent
                        Layout.alignment: Qt.AlignHCenter
                        text: model.title
                        font.pixelSize: 14
                    }

                    // Text {
                    //     text: model.title
                    //     font.pixelSize: 14
                    //     // color: appTheme.primaryText
                    //     Layout.fillWidth: true
                    // }
                }
            }
        }

        // Rectangle {
        //     Layout.fillWidth: true
        //     height: 1
        //     // color: appTheme.borderColor
        // }

        // 功能按钮
        Button {
            Layout.fillWidth: true
            text: "扫描音乐"

            background: Rectangle {
                // color: parent.hovered ? appTheme.hoverColor : appTheme.primaryColor
                // radius: appTheme.smallRadius
            }

            contentItem: Text {
                text: parent.text
                // color: appTheme.primaryText
                // horizontalAlignment: Text.AlignHCenter
                // verticalAlignment: Text.AlignVCenter
            }

            // onClicked: sideBar.scanMusicClicked()
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
