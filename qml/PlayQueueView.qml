import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmltest

Rectangle {
    id: _root
    color: "#f5f5f5"
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        // 标题
        Text {
            text: "当前播放队列"
            font.pixelSize: 18
            font.bold: true
            color: "#333333"
            Layout.alignment: Qt.AlignHCenter
        }
        
        // 队列为空时的提示
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: BackendManager.playerController.playQueue.length === 0
            
            Text {
                anchors.centerIn: parent
                text: "当前队列暂无歌曲"
                font.pixelSize: 16
                color: "#666666"
            }
        }
        
        // 播放队列列表
        ListView {
            id: _queueListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: BackendManager.playerController.playQueue.length > 0
            
            model: BackendManager.playerController.playQueue
            
            delegate: Rectangle {
                width: _queueListView.width
                height: 50
                color: index === BackendManager.playerController.currentIndex ? "#e3f2fd" : "transparent"
                border.color: index === BackendManager.playerController.currentIndex ? "#2196f3" : "transparent"
                border.width: 1
                radius: 4
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10
                    
                    // 播放状态指示器
                    Rectangle {
                        width: 4
                        height: 20
                        color: index === BackendManager.playerController.currentIndex ? "#2196f3" : "transparent"
                        radius: 2
                    }
                    
                    // 歌曲信息
                    Column {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: modelData.title
                            font.pixelSize: 14
                            font.bold: index === BackendManager.playerController.currentIndex
                            color: index === BackendManager.playerController.currentIndex ? "#2196f3" : "#333333"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        
                        Text {
                            text: modelData.artist
                            font.pixelSize: 12
                            color: "#666666"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                    
                    // 时长
                    Text {
                        text: modelData.durationString
                        font.pixelSize: 12
                        color: "#666666"
                    }
                    
                    // 移除按钮
                    ToolButton {
                        icon.source: "qrc:/OtherUi/resources/close.png"
                        icon.width: 16
                        icon.height: 16
                        
                        onClicked: {
                            BackendManager.playerController.removeFromQueue(index)
                        }
                    }
                }
                
                TapHandler {
                    onTapped: {
                        BackendManager.playerController.playQueueIndex(index)
                    }
                }
            }
        }
        
        // 底部操作按钮
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: BackendManager.playerController.playQueue.length > 0
            
            Button {
                text: "清空队列"
                Layout.fillWidth: true
                
                onClicked: {
                    BackendManager.playerController.clearQueue()
                }
            }
        }
    }
}
