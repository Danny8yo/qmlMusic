import QtQuick
import qmltest
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    color: "lightgrey"

    // ColumnLayout{
    //     anchors.fill: parent

    //     Text {
    //         Layout.fillWidth: true
    //         Layout.preferredHeight: 50
    //         text: qsTr("发现")
    //         font.pixelSize: 36
    //         font.bold: true
    //         color: "black"

    //     }

        GridView {
            id: _playlistGrid
            anchors.fill: parent
            // Layout.fillWidth: true
            // Layout.fillHeight: true
            anchors.margins: 10 // 给整个GridView添加外边距

            model: BackendManager.playlistModel

            cellHeight: 220 // 增加高度来容纳间距
            cellWidth: 220  // 增加宽度来容纳间距

            delegate: Rectangle {
                width: _playlistGrid.cellWidth
                height: _playlistGrid.cellHeight
                color: "transparent" // 透明背景

                // GridView 没有spacing属性设置间距,只能自己将delegate设置为透明rectange,再内嵌一个
                //rectangle,并设置margins,装歌曲信息

                // 内部容器，通过margins创建间距效果
                Rectangle {
                    id: _contentRect
                    anchors.fill: parent
                    anchors.margins: 10 // 这里创建间距效果
                    color: "transparent"
                    radius: 8
                    border.color: "#ddd"
                    border.width: 1

                    // 指针设备输入处理
                    TapHandler {
                        id: tapHandler
                        onTapped: {
                            console.log("点击歌单:", model.name)
                            // 这里可以添加点击歌单的逻辑
                        }
                    }

                    HoverHandler {
                        id: hoverHandler
                        onHoveredChanged: {
                            if (hovered) {
                                // console.log("鼠标进入歌单")
                                _contentRect.color = "#e8e8e8"
                            } else {
                                // console.log("鼠标离开歌单")
                                _contentRect.color = "transparent"
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        // 显示封面图
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#ddd"
                            radius: 4

                            Image {
                                id: _playlistCover
                                anchors.fill: parent
                                anchors.margins: 2
                                source: model.coverUrl || "qrc:/resources/default_playlist_cover.png"
                                fillMode: Image.PreserveAspectCrop

                                // 添加加载状态处理
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 40
                                    height: 40
                                    color: "#bbb"
                                    radius: 20
                                    visible: _playlistCover.status === Image.Loading

                                    Text {
                                        anchors.centerIn: parent
                                        text: "♪"
                                        font.pixelSize: 20
                                        color: "white"
                                    }
                                }
                            }
                        }

                        //显示标题和描述
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: "transparent"

                            Column {
                                anchors.fill: parent
                                spacing: 2

                                Text {
                                    width: parent.width
                                    text: model.name || "未命名歌单"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333"
                                    elide: Text.ElideRight
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                }

                                Text {
                                    width: parent.width
                                    text: model.description || "暂无描述"
                                    font.pixelSize: 12
                                    color: "#666"
                                    elide: Text.ElideRight
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                }
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                console.log("=== PlaylistGridView 调试信息 ===")
                console.log("BackendManager 是否存在:", typeof BackendManager !== 'undefined')
                console.log("BackendManager 对象:", BackendManager)

                if (BackendManager) {
                    console.log("BackendManager.playlistModel:", BackendManager.playlistModel)
                    console.log("BackendManager.playlistModel 是否为 null:", BackendManager.playlistModel === null)
                    console.log("BackendManager.playlistModel 是否为 undefined:", BackendManager.playlistModel === undefined)

                    if (BackendManager.playlistModel) {
                        console.log("GridView 模型数据量:", BackendManager.playlistModel.count)
                        console.log("GridView rowCount:", BackendManager.playlistModel.rowCount())
                    } else {
                        console.log("playlistModel 为 null 或 undefined!")
                    }
                } else {
                    console.log("BackendManager 为 undefined!")
                }
                console.log("========================")
            }

            // 添加延迟检查
            Timer {
                interval: 1000
                running: true
                repeat: false
                onTriggered: {
                    console.log("=== 延迟检查 ===")
                    if (typeof BackendManager !== 'undefined' && BackendManager.playlistModel) {
                        console.log("延迟检查 - 模型数据量:", BackendManager.playlistModel.count)
                        // 强制重新绑定模型
                        _playlistGrid.model = null
                        _playlistGrid.model = BackendManager.playlistModel
                    } else {
                        console.log("延迟检查 - playlistModel 仍然为空")
                    }
                }
            }

            // 监听模型变化
            Connections {
                target: BackendManager.playlistModel
                function onCountChanged() {
                    console.log("模型数据量变化:", BackendManager.playlistModel.count)
                }
            }
        // }
    }
}
