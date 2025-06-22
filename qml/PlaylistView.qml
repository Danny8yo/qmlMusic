import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
// import SongModel 1.0
// import Song 1.0
import qmltest
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
            ListView {
                id: songView
                // Layout.fillWidth: true
                anchors.fill: parent
                clip: true
                spacing: 10  // 行间距
                //highlightRangeMode: ListView.ApplyRange
                highlight: Rectangle {
                    color: "#bdd3d1"
                    width: songView.width
                    height: 30
                    radius: 4  // 可选圆角
                    //anchors.horizontalCenter: parent.horizontalCenter
                }



                // 自定义的Model:


                model: ListModel { //最终采用的模型是自定义songModel
                           id: songModel
                           // 测试数据（实际使用时通过songModel动态加载）
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第二首歌曲" }
                           ListElement { lineText: "这是第三首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第二首歌曲" }
                           ListElement { lineText: "这是第三首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第二首歌曲" }
                           ListElement { lineText: "这是第三首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第二首歌曲" }
                           ListElement { lineText: "这是第三首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第二首歌曲" }
                           ListElement { lineText: "这是第三首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第二首歌曲" }
                           ListElement { lineText: "这是第三首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第二首歌曲" }
                           ListElement { lineText: "这是第三首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第二首歌曲" }
                           ListElement { lineText: "这是第三首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第一首歌曲" }
                           ListElement { lineText: "这是第二首歌曲" }
                           ListElement { lineText: "这是第三首歌曲" }

                       }

                delegate: Text {
                    text: lineText  // 假设每行数据有 lineText 属性
                    color: index === songView.currentIndex ? "#95cac5" : "white"
                    font.pixelSize: index === songView.currentIndex ? 22 : 16  //
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width

                    TapHandler{
                        onTapped:{
                            songView.currentIndex = index
                            console.log("点击行:", index, "当前高亮行:", songView.currentIndex)// 调试输出

                        }
                    }
                }

                Component.onCompleted: positionViewAtIndex(0, ListView.Beginning)

            }
        }
    }
}
