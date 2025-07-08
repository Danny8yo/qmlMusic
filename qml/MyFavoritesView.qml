import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmltest

Rectangle {
    id: myFavoritesView
    color: "#f8f8f8"

    // 导航信号
    signal discoverRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 0

        // 标题区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20

                // 喜欢图标
                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    color: "#e91e63"
                    radius: 30

                    Text {
                        anchors.centerIn: parent
                        text: "♥"
                        font.pixelSize: 30
                        color: "white"
                    }
                }

                // 标题信息
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: "我的喜欢"
                        font.pixelSize: 28
                        font.bold: true
                        color: "#333"
                    }

                    Text {
                        id: favoriteCountText
                        text: "收藏了 0 首歌曲"
                        font.pixelSize: 14
                        color: "#666"
                    }
                }

                // 操作按钮
                RowLayout {
                    spacing: 10

                    Button {
                        text: "播放全部"
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40

                        background: Rectangle {
                            color: parent.hovered ? "#1976D2" : "#2196F3"
                            radius: 20
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // 播放所有喜欢的歌曲

                            let favoritelist = BackendManager.favoriteModel.getAllSongs()
                            BackendManager.playPlaylist(favoritelist)
                            console.log("播放我喜欢的全部歌曲")
                        }
                    }
                }
            }
        }

        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#e0e0e0"
        }

        // 歌曲列表
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            // 如果没有喜欢的歌曲，显示空状态
            Item {
                id: emptyState
                anchors.centerIn: parent
                visible: true // 暂时设为true，实际应该根据收藏歌曲数量判断

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20

                    // 空状态图标
                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 100
                        Layout.alignment: Qt.AlignHCenter
                        color: "#f0f0f0"
                        radius: 50

                        Text {
                            anchors.centerIn: parent
                            text: "♥"
                            font.pixelSize: 50
                            color: "#ccc"
                        }
                    }

                    Text {
                        text: "还没有收藏的歌曲"
                        font.pixelSize: 18
                        color: "#666"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "在播放歌曲时点击♥按钮可以收藏到这里"
                        font.pixelSize: 14
                        color: "#999"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Button {
                        text: "去发现音乐"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 40

                        background: Rectangle {
                            color: parent.hovered ? "#1976D2" : "#2196F3"
                            radius: 20
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // 导航到发现页面
                            myFavoritesView.discoverRequested()
                        }
                    }
                }
            }


            ListView {
                id: _favoriteSongList
                anchors.fill: parent
                clip: true
                spacing: 5
                model: BackendManager.favoriteModel

                delegate: Rectangle {
                    width: _favoriteSongList.width
                    height: 60
                    color: index === _favoriteSongList.currentIndex ? "white" : "#95cac5"

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

                        //封面
                        Rectangle {
                            width: 50
                            height: 50
                            color: "#bdd3d1"
                            radius: 4
                            Image {
                                anchors.fill: parent

                                source: model ? model.coverArt : "file://" + BackendManager.appDirPath + "/test_Music/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg"
                                fillMode: Image.PreserveAspectFit
                                // Component.onCompleted: {
                                //         console.log("Trying to load image from:", model.coverArtUrl);
                                //     }
                            }
                        }

                        // 歌曲信息
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                Layout.fillWidth: true
                                text: model ? (model.title || "未知标题") : "未知标题"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model ? (model.artist || "未知艺术家") : "未知艺术家"
                                font.pixelSize: 12
                                color: "#666"
                                elide: Text.ElideRight
                            }
                        }

                        //歌曲时间
                        Text {
                            text: model.formattedDuration /*|| "00:00"*/
                            font.pixelSize: 14
                            color: "#666"
                        }
                    }

                    // 双击播放歌曲
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onDoubleTapped: {
                            if (model) {

                                //index为双击选中的歌曲索引
                                _favoriteSongList.currentIndex = index
                                 let song = BackendManager.getSongById(model.id)
                                console.log("播放喜欢的歌曲:", model.title)
                                BackendManager.playerController.playSong(song)
                            }
                        }
                    }

                    // 单击选中
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: {
                            _favoriteSongList.currentIndex = index
                        }
                    }
                }

                // 空状态
                Rectangle {
                    anchors.centerIn: parent
                    width: 200
                    height: 100
                    color: "transparent"
                    visible: _favoriteSongList.count === 0

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

            // 歌曲列表（当有收藏歌曲时显示）
            // FavoriteView {
            //     id: favoriteSongsList
            //     anchors.fill: parent
            //     visible: !emptyState.visible
            //     //model: BackendManager.favoriteModel

            //     // 这里应该显示用户收藏的歌曲
            //     // 可以通过筛选SongModel中favorite标记为true的歌曲来实现
            // }
        }
    }

    // 更新收藏数量的函数
    function updateFavoriteCount(count) {
        favoriteCountText.text = "收藏了 " + count + " 首歌曲"
        emptyState.visible = (count === 0)
        _favoriteSongList.visible = (count > 0)
    }

    Component.onCompleted: {
        // 初始化时获取收藏歌曲数量
        // 这里应该从后端获取实际的收藏数量
        //let favoritelist = BackendManager.favoriteModel.getAllSongs()
        updateFavoriteCount(BackendManager.favoriteModel.count)
    }
    // 监听模型变化
    // Connections {
    //     target: BackendManager.favoriteModel
    //     function onCountChanged() {
    //         console.log("喜欢歌曲数据量变化:", BackendManager.favoriteModel.count)

    //     }
    // }
}
