import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qmltest

Item {
    id: _Local
    anchors.fill: parent
    visible: true

    ColumnLayout {
        spacing: 5
        anchors.fill: parent

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            text: qsTr("本地音乐")
            font.pixelSize: 38
            font.bold: true
            color: "black"
        }

        // 显示歌曲数量
        Text {
            Layout.fillWidth: true
            text: BackendManager.localSongModel.count > 0 ? 
                  qsTr("共 %1 首歌曲").arg(BackendManager.localSongModel.count) : 
                  qsTr("暂无本地音乐，请先扫描音乐库")
            font.pixelSize: 14
            color: "#666"
            visible: true
        }

        // 本地歌曲列表
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: BackendManager.localSongModel
            visible: BackendManager.localSongModel.count > 0
            
            delegate: Rectangle {
                width: ListView.view.width
                height: 60
                // color: hovered? "#f0f0f0" : "transparent"


                
                // Rectangle {
                //     anchors.bottom: parent.bottom
                //     width: parent.width
                //     height: 1
                //     color: parent.hovered ? "#e0e0e0" : "transparent"
                // }
                
                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 15
                    spacing: 15
                    
                    // 歌曲信息
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 70
                        spacing: 5
                        
                        Text {
                            text: model.title || "未知标题"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        
                        Text {
                            text: (model.artist || "未知艺术家") + " - " + (model.album || "未知专辑")
                            font.pixelSize: 12
                            color: "#666"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                }

                HoverHandler {
                    onHoveredChanged: {
                        // 当鼠标悬停时改变颜色
                        if (hovered) {
                            color = "#f0f0f0";
                        } else {
                            color = "transparent";
                        }
                    }
                }
                
                //taphandler双击播放歌曲
                TapHandler {
                    onDoubleTapped: {
                        // 双击播放这首歌
                        console.log("双击播放歌曲: " + model.title);
                        
                        // 获取当前歌曲对象
                        let song = BackendManager.localSongModel.getSong(index);
                        if (song) {
                            // 将本地音乐列表设置为播放队列
                            let localSongs = [];
                            for (var i = 0; i < BackendManager.localSongModel.count; ++i) {
                                localSongs.push(BackendManager.localSongModel.getSong(i));
                            }
                            
                            // 加载队列并播放指定歌曲
                            BackendManager.playerController.loadQueue(localSongs);
                            BackendManager.playerController.playQueueIndex(index);
                            
                            console.log("开始播放本地音乐:", song.title, "位置:", index);
                        }
                    }
                }
            }
        }
        
        // 空状态提示
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            visible: BackendManager.localSongModel.count === 0
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "🎵"
                    font.pixelSize: 64
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#ccc"
                }
                
                Text {
                    text: "暂无本地音乐"
                    font.pixelSize: 18
                    color: "#999"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "请前往扫描页面扫描音乐库"
                    font.pixelSize: 14
                    color: "#bbb"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
