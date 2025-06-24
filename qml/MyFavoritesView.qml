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
                            console.log("播放我喜欢的全部歌曲")
                        }
                    }
                    
                    Button {
                        text: "随机播放"
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        
                        background: Rectangle {
                            color: parent.hovered ? "#e0e0e0" : "white"
                            border.color: "#ddd"
                            radius: 20
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "#666"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            // 随机播放喜欢的歌曲
                            console.log("随机播放我喜欢的歌曲")
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
            
            // 歌曲列表（当有收藏歌曲时显示）
            SongView {
                id: favoriteSongsList
                anchors.fill: parent
                visible: !emptyState.visible
                
                // 这里应该显示用户收藏的歌曲
                // 可以通过筛选SongModel中favorite标记为true的歌曲来实现
            }
        }
    }
    
    // 更新收藏数量的函数
    function updateFavoriteCount(count) {
        favoriteCountText.text = "收藏了 " + count + " 首歌曲"
        emptyState.visible = (count === 0)
        favoriteSongsList.visible = (count > 0)
    }
    
    Component.onCompleted: {
        // 初始化时获取收藏歌曲数量
        // 这里应该从后端获取实际的收藏数量
        updateFavoriteCount(0)
    }
}
