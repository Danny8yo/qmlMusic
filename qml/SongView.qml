//该页面用于自定义显示导入的全部歌曲
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import qmltest// 导入自定义模块

// #f8f8f8
Rectangle{
    id:_bottom
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#95cac5"

    ListView {
        id: _songView
        // Layout.fillWidth: true
        anchors.fill: parent
        clip: true
        spacing: 10  // 行间距
        model: BackendManager.songModel


        //highlightRangeMode: ListView.ApplyRange
        highlight: Rectangle {
            color: "#bdd3d1"
            width: _songView.width
            height: 30
            radius: 4  // 可选圆角
            //anchors.horizontalCenter: parent.horizontalCenter

        }

        delegate: Rectangle {
            width: _songView.width
            height: 60
            // color: index === songView.currentIndex ? "#e3f2fd" :
            //        (index % 2 ? "#f5f5f5" : "white")
            color: index === _songView.currentIndex ? "white" : "#95cac5"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 15

                // 封面（简化示例）
                Rectangle {
                    width: 50
                    height: 50
                    color: "#bdd3d1"
                    radius: 4
                    Image {
                        anchors.fill: parent
                        //source: coverArt || "qrc:/default_cover.png"  // 使用实际封面或默认图
                        source:model.coverArt
                        fillMode: Image.PreserveAspectFit
                    }
                    // Text {
                    //     anchors.centerIn: parent
                    //     text: model.index + 1
                    //     font.bold: true
                    // }
                }

                // 歌曲信息
                ColumnLayout {
                    spacing: 2
                    Text {
                        text: model.title || "未知标题"
                        font.pixelSize: 16
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: (model.artist || "未知艺术家") + " · " + (model.album || "未知专辑")
                        font.pixelSize: 12
                        color: "#666"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // 时长
                Text {
                    text: model.formattedDuration || "00:00"
                    font.pixelSize: 14
                    color: "#666"
                }
            }
        }


        Component.onCompleted: {
            console.log("=== SongView 调试信息 ===")
            console.log("BackendManager 是否存在:", typeof BackendManager !== 'undefined')
            console.log("BackendManager 对象:", BackendManager)
            
            if (BackendManager) {
                console.log("BackendManager.songModel:", BackendManager.songModel)
                console.log("BackendManager.songModel 是否为 null:", BackendManager.songModel === null)
                console.log("BackendManager.songModel 是否为 undefined:", BackendManager.songModel === undefined)
                
                if (BackendManager.songModel) {
                    console.log("ListView 模型数据量:", BackendManager.songModel.count)
                    console.log("ListView rowCount:", BackendManager.songModel.rowCount())
                } else {
                    console.log("songModel 为 null 或 undefined!")
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
                if (typeof BackendManager !== 'undefined' && BackendManager.songModel) {
                    console.log("延迟检查 - 模型数据量:", BackendManager.songModel.count)
                    // 强制重新绑定模型
                    _songView.model = null
                    _songView.model = BackendManager.songModel
                } else {
                    console.log("延迟检查 - songModel 仍然为空")
                }
            }
        }

        // 监听模型变化
        Connections {
            target: BackendManager.songModel
            function onCountChanged() {
                console.log("模型数据量变化:", BackendManager.songModel.count)
            }
        }
    }
}
