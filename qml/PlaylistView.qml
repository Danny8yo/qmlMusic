import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import qmltest// 导入自定义模块
// #f8f8f8
//  #95cac5
//  #dac1c1
// #bdd3d1
// #e8e2e1

Item {
    id:playlist
    anchors.fill: parent
    visible: true
    // 总体垂直

    ColumnLayout{

        spacing: 0
        anchors.fill: parent
        // 顶头退出按钮
        Rectangle{
            id:headerBar
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "#dac1c1"
            Button {
                text: "关闭"
                background: null
                //Layout.alignment: Qt.AlignRight
                onClicked: {
                    // 从堆栈弹出当前页面
                    stack.pop()
                    // 如果需要传递数据回前一页
                   // StackView.view.pop({someData: value})
                }
            }
        }
        //上方的矩形
        Rectangle{
            id:_top
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#95cac5"
           RowLayout{
               //左侧封面矩形
               anchors.fill:parent
               spacing: 0
               Rectangle{
                   id:coverShow
                   Layout.fillWidth: true
                   Layout.fillHeight: true
                   //Layout.preferredHeight: 500
                   color: "#dac1c1"
                   Image {
                       id: cover
                       anchors.fill:parent
                       width: Math.min(parent.width, parent.height) / 2 // 取宽高中的较小值
                       height: width // 强制保持正方形
                       //width: 200
                       //height:200
                       anchors.centerIn: parent

                       source: "file:///root/MusicTest/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg"
                       fillMode: Image.PreserveAspectFit  // 保持比例缩放
                   }

               }

               // 右侧歌单信息矩形
               Rectangle{
                   Layout.fillWidth: true
                   Layout.fillHeight: true
                   color: "#dac1c1"
                   ColumnLayout{
                       anchors.fill:parent
                       spacing: 5
                       // 歌单名
                       Text{
                           id:_playlistName
                           Layout.fillWidth: true
                           //Layout.preferredHeight: 30
                           horizontalAlignment: Text.AlignLeft
                           verticalAlignment: Text.AlignLeft
                           text: "歌单名称"
                           color:"gray"
                           font.pixelSize:25
                       }

                       // 歌单添加者
                       Text{
                           id:_playlistAutor
                           Layout.fillWidth: true
                           //Layout.preferredHeight: 15
                           horizontalAlignment: Text.AlignLeft
                           verticalAlignment: Text.AlignLeft
                           text: "创作者名"
                           color:"gray"
                           font.pixelSize:10
                       }

                       // 歌曲创建时间
                       Text{
                           id:_playlistDate
                           Layout.fillWidth: true
                           //Layout.preferredHeight: 10
                           horizontalAlignment: Text.AlignLeft
                           verticalAlignment: Text.AlignLeft
                           text: "创建时间"
                           color:"gray"
                           font.pixelSize:10
                       }

                       // 其他描述
                       Text{
                           id:_playlistOther
                           Layout.fillWidth: true
                           Layout.preferredHeight: 10
                           horizontalAlignment: Text.AlignLeft
                           verticalAlignment: Text.AlignLeft
                           text: "其他描述"
                           color:"gray"
                           font.pixelSize:10
                       }
                       RowLayout{
                           width: parent.width

                           // 播放歌单按钮
                           Button{
                               id:_play
                               Layout.alignment: Qt.AlignLeft
                               text:"播放"
                               background: null  // 完全移除背景元素
                           }
                           // 收藏歌单按钮
                           Button{
                               id:_like
                               Layout.alignment: Qt.AlignLeft
                               text:"喜欢"
                               background: null  // 完全移除背景元素
                           }

                           Button{
                               id:_more
                               Layout.alignment: Qt.AlignLeft
                               text:"..."
                               background: null  // 完全移除背景元素
                           }
                       }

                   }

               }
           }

        }

        //下方的矩形(播放列表组件，后面会独立）
        Rectangle{
            id:_bottom
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#95cac5"

            // 使用自定义的Song和SongModel放进ListView中
            // 但实际上应该由自定义的BackendManager管理这两个类
            // 这里只是为了单纯的测试
            Song{
                id:song
                title: "爱上了你"
                artist: "www"
                album: "fuusd"
                coverArtPath: "file:///root/qmlMusic-dev/qmlMusic/test_Music/Local_Playlist/covers/The Nights.jpg"
                filePath: "/root/qmlMusic-dev/qmlMusic/test_Music/Local_Playlist/The Nights.mp3"
            }

            SongModel{
                id:songModel
                Component.onCompleted: addSong(song)
            }

            ListView {
                id: songView
                // Layout.fillWidth: true
                anchors.fill: parent
                clip: true
                spacing: 10  // 行间距
                model: songModel// 自定义的songmodel
                //highlightRangeMode: ListView.ApplyRange
                highlight: Rectangle {
                    color: "#bdd3d1"
                    width: songView.width
                    height: 30
                    radius: 4  // 可选圆角
                    //anchors.horizontalCenter: parent.horizontalCenter
                }

                delegate: Rectangle {
                    width: songView.width
                    height: 60
                    color: index === songView.currentIndex ? "#e3f2fd" :
                           (index % 2 ? "#f5f5f5" : "white")

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
                                text: model.title
                                font.pixelSize: 16
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: model.artist + " · " + model.album
                                //text:model.coverArt
                                font.pixelSize: 12
                                color: "#666"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        // 时长
                        Text {
                            text: Qt.formatTime(new Date(0, 0, 0, 0, 0, model.duration), "mm:ss")
                            font.pixelSize: 14
                            color: "#666"
                        }
                    }
                }



                // 自定义的Model:



                // model: ListModel { //最终采用的模型是自定义songModel
                //            id: songModel
                //            // 测试数据（实际使用时通过songModel动态加载）
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第二首歌曲" }
                //            ListElement { lineText: "这是第三首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第二首歌曲" }
                //            ListElement { lineText: "这是第三首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第二首歌曲" }
                //            ListElement { lineText: "这是第三首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第二首歌曲" }
                //            ListElement { lineText: "这是第三首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第二首歌曲" }
                //            ListElement { lineText: "这是第三首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第二首歌曲" }
                //            ListElement { lineText: "这是第三首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第二首歌曲" }
                //            ListElement { lineText: "这是第三首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第二首歌曲" }
                //            ListElement { lineText: "这是第三首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第一首歌曲" }
                //            ListElement { lineText: "这是第二首歌曲" }
                //            ListElement { lineText: "这是第三首歌曲" }

                //        }

                // delegate: Text {
                //     text: lineText  // 假设每行数据有 lineText 属性
                //     color: index === songView.currentIndex ? "#95cac5" : "white"
                //     font.pixelSize: index === songView.currentIndex ? 22 : 16  //
                //     horizontalAlignment: Text.AlignHCenter
                //     width: parent.width

                //     TapHandler{
                //         onTapped:{
                //             songView.currentIndex = index
                //             console.log("点击行:", index, "当前高亮行:", songView.currentIndex)// 调试输出

                //         }
                //     }
                // }

                // 检查模型是否有数据
                Component.onCompleted: {
                    //positionViewAtIndex(0, ListView.Beginning)
                    console.log("模型数据量:", songModel.count)
                    for(var i=0; i<songModel.count; i++) {
                        console.log("歌曲", i, ":", songModel.get(i).title)
                    }
                }
                //Component.onCompleted: positionViewAtIndex(0, ListView.Beginning)

            }
        }
    }
}
