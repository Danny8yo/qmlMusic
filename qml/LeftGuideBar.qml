import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qmltest

Rectangle {
    id: sideBar
    width: 200
    color: "#d2d2d2"

    // 导航信号（向MusicUi.qml传递）
    signal navigationRequested(string page)
    signal mylistRequested(var playlistId)//

    // 自定义歌单
    //property var myList : []// 存的数据是添加的自定义歌单

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
                ListElement { title: "发现"; page: "discover" }
                ListElement { title: "我的喜欢"; page: "favorites" }
                ListElement { title: "本地音乐"; page: "local" }
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

                        background: Rectangle {
                            color: parent.hovered ? "#e0e0e0" : "#d2d2d2"
                        }

                        TapHandler {
                            onTapped: {
                                console.log("Clicked:", model.title);
                                //将点击的页面传递出去
                                sideBar.navigationRequested(model.page)
                            }
                        }
                    }
                }
            }
        }

        // 功能按钮
        Button {
            Layout.fillWidth: true
            text: "扫描音乐"

            contentItem: Text {
                text: parent.text
                horizontalAlignment: Text.AlignHCenter
            }

            background: Rectangle {
                color: parent.hovered ? "#e0e0e0" : "#d2d2d2"
                radius: 4
            }

            TapHandler {
                onTapped: {
                    console.log("Clicked: 扫描音乐")
                    sideBar.navigationRequested("scan")
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout{
                Layout.fillWidth: true
                Text{
                    text:"我的歌单"

                }

                Item{
                    Layout.fillWidth: true

                }


                Button {
                    Text{
                        text:"+"
                        color:"black"
                    }
                    //background: null
                    onClicked: {
                        _addDialog.open()
                        //BackendManager.playlistModel.addPlaylist(BackendManager.createPlaylist(listname))
                    }
                }
            }

            Dialog {
                    id: _addDialog
                    title: "请输入"
                    anchors.centerIn: parent

                    TextField {
                        id: inputField
                        width: parent.width
                    }

                    standardButtons: Dialog.Ok | Dialog.Cancel

                    onAccepted: {
                        let newPlaylist = BackendManager.createLocalPlaylist(inputField.text)
                        BackendManager.locallistModel.addPlaylist(newPlaylist)
                        //let num = newPlaylist.id
                        //myListId = newPlaylist.id // 这里会出现id固定为最后一个加入的列表的id的错误,必须让id和myList绑定起来
                        //console.log("sadddddddddddddddddddd" + num)
                        //BackendManager.playlistModel.addPlaylist(BackendManager.createPlaylist(inputField.text)) //创建新歌单
                        //myList.push(inputField.text)
                        // myList.push(newPlaylist)

                        // myList = myList
                        inputField.text = ""           // 清空输入框
                    }
                }
        }
        // 播放列表项
        ListView {
            id:_locallistView
            //anchors.fill: parent
            Layout.fillHeight: true
            Layout.fillWidth: true
            //model: myList
            clip: true // 关键！确保超出部分被裁剪
            model:BackendManager.locallistModel
            delegate: Rectangle {
                width: _locallistView.width
                height: 40
                color: "transparent"

                Text {
                    //text: modelData.name
                    text:model.name
                    font.pixelSize: 16
                    //anchors.centerIn: parent
                    color: "black"  // 黑色字体

                }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: {
                        // console.log("点击", modelData.name, modelData.id)

                        // mylistRequested(modelData.id)
                        console.log("点击", model.name, model.id)

                        sideBar.mylistRequested(model.id)//如果当前页面已经是播放列表详情页，再次点击（新建歌单）歌单名称时，
                                                        //无法更新当前展示的播放列表详情页，而是会重复加载已经被展示的
                                                        //播放列表详情页，除非当前页面已经退出
                                                        //原因：该信号由MusicUi.qml接收，并且生成组件的需求由其中的Loader执行
                                                        // 当 source（也就是重复点击新建歌单名称，向Loader重复请求创建source为PlaylistView.qml的组件） 不变时，
                                                        //Loader 会​​复用已有实例​​（也就是第一个被创建的播放列表详情页），不会重新创建组件
                                                        // onLoaded 也 ​​不会再次触发​​
                                                        // 因此必须要先清空原有suorce,并且重新赋值

                    }
                }
                TapHandler { // 右键点击时出现删除，重命名的选项（功能还未实现）
                    acceptedButtons: Qt.RightButton
                    onTapped: {
                        _choiceMenu.popup()

                    }
                }

                Menu {
                    id: _choiceMenu

                    MenuItem {
                        text: "删除"
                        //BackendManager.
                        onTriggered: console.log("删除:")
                    }

                    MenuItem {
                        text: "重命名"
                        onTriggered: console.log("重命名:")
                    }
                }
            }
        }

        // Item {
        //     Layout.fillHeight: true
        // }

    }
}
