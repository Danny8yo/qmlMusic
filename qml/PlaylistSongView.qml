import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import qmltest

Rectangle{
    id:_playlistSongView
    color: "#95cac5"
    
    property var playlist: null
    property var songs: []
    
    // 加载播放列表歌曲
    function loadPlaylistSongs(playlistObj) {
        playlist = playlistObj
        if (playlist) {
            songs = playlist.getAllSongs()
            console.log("播放列表歌曲数量:", songs.length)
            // 刷新ListView
            _songListView.model = songs
        }
    }

    ListView {
        id: _songListView
        anchors.fill: parent
        clip: true
        spacing: 5
        model: songs

        highlight: Rectangle {
            color: "#bdd3d1"
            width: _songListView.width
            height: 30
            radius: 4
        }

        delegate: Rectangle {
            width: _songListView.width
            height: 60
            color: index === _songListView.currentIndex ? "white" : "#95cac5"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 15

                // 歌曲序号
                Text {
                    Layout.preferredWidth: 30
                    text: (index + 1).toString().padStart(2, '0')
                    font.pixelSize: 14
                    color: "#666"
                    horizontalAlignment: Text.AlignCenter
                }

                // 封面（简化示例）
                Rectangle {
                    width: 50
                    height: 50
                    color: "#bdd3d1"
                    radius: 4

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: {
                            if (modelData && modelData.albumArt && modelData.albumArt.toString() !== "") {
                                return modelData.albumArt
                            }
                            return "file://" + BackendManager.appDirPath + "/test_Music/Local_Playlist/covers/default.jpg"
                        }
                        fillMode: Image.PreserveAspectCrop
                        radius: 2

                        // 加载失败时显示默认图标
                        Rectangle {
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            color: "transparent"
                            visible: parent.status === Image.Error

                            Text {
                                anchors.centerIn: parent
                                text: "♪"
                                font.pixelSize: 16
                                color: "#999"
                            }
                        }
                    }
                }

                // 歌曲信息
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        Layout.fillWidth: true
                        text: modelData ? (modelData.title || "未知标题") : "未知标题"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData ? (modelData.artist || "未知艺术家") : "未知艺术家"
                        font.pixelSize: 12
                        color: "#666"
                        elide: Text.ElideRight
                    }
                }

                // 歌曲时长
                Text {
                    Layout.preferredWidth: 60
                    text: modelData ? formatDuration(modelData.duration) : "00:00"
                    font.pixelSize: 12
                    color: "#666"
                    horizontalAlignment: Text.AlignRight
                }

                // 更多操作按钮
                Button {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    text: "⋯"
                    
                    background: Rectangle {
                        color: parent.hovered ? "#e0e0e0" : "transparent"
                        radius: 15
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    TapHandler {
                        onTapped: {
                            console.log("歌曲操作菜单")
                        }
                    }
                }
            }

            // 双击播放歌曲
            TapHandler {
                acceptedButtons: Qt.LeftButton
                onDoubleTapped: {
                    if (modelData) {
                        console.log("播放歌曲:", modelData.title)
                        BackendManager.playSongById(modelData.id)
                        _songListView.currentIndex = index
                    }
                }
            }

            // 单击选中
            TapHandler {
                acceptedButtons: Qt.LeftButton
                onTapped: {
                    _songListView.currentIndex = index
                }
            }
        }

        // 空状态
        Rectangle {
            anchors.centerIn: parent
            width: 200
            height: 100
            color: "transparent"
            visible: songs.length === 0

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "暂无歌曲"
                    font.pixelSize: 16
                    color: "#999"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "这个播放列表还没有歌曲"
                    font.pixelSize: 12
                    color: "#ccc"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    // 格式化时长函数
    function formatDuration(seconds) {
        if (!seconds || seconds <= 0) return "00:00"
        
        var minutes = Math.floor(seconds / 60)
        var remainingSeconds = Math.floor(seconds % 60)
        
        return minutes.toString().padStart(2, '0') + ":" + 
               remainingSeconds.toString().padStart(2, '0')
    }
}
