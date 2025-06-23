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

            //展示 Item 的一个模板
            delegate: Rectangle {
                width: _guideBar.width
                height: 40
                color: "#d2d2d2"
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    // anchors.leftMargin: 5
                    // anchors.rightMargin: 5

                    Button {
                        id: _guideBarButton
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        text: model.title

                        contentItem: Text {
                            text: model.title
                            font.pixelSize: 14
                            color: "black"
                            // color: appTheme.primaryText
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        // font {
                        //     pixelSize: 14
                        //     bold: true
                        // }
                        // font.pixelSize: 14
                        // font.bold: true

                        background: Rectangle {
                            color: parent.hovered ? "#e0e0e0" : "#d2d2d2"
                        }

                        TapHandler {
                            onTapped: {
                                // sideBar.selectedIndex = index;
                                // sideBar.itemClicked(index);
                                console.log("Clicked:", model.title);
                                // 可以在这里添加导航逻辑
                            }
                        }
                    }

                    // Text {
                    //     // anchors.centerIn: parent
                    //     Layout.alignment: Qt.AlignHCenter
                    //     text: model.title
                    //     font.pixelSize: 14
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

            // background: Rectangle {
            //     color: parent.hoverd? "#e0e0e0" : "#d2d2d2"
            //     radius: 4
            // }

            contentItem: Text {
                text: parent.text
                // color: "black"
                horizontalAlignment: Text.AlignHCenter
                // verticalAlignment: Text.AlignVCenter
            }

        }

        Item {
            Layout.fillHeight: true
        }
    }
}
