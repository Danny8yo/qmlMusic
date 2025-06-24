import QtQuick
import QtQuick.Controls
//import QtQuick.Controls.Material
import QtQuick.Layouts
import QtMultimedia

Item {
    id: lyricsPage
    // width: 1000
    // height: 600
    width: parent.width
    height: parent.height
    //visible: true 与窗口控制方法会发生QML QQuickWindowQmlImpl*: Conflicting properties 'visible' and 'visibility'
    signal requestClose()

    ColumnLayout{
        anchors.fill: parent  // 关键点1：让布局填满整个窗口
        //width: parent.width //使headerBar位于顶端
        spacing: 0          // 关键点2：消除默认间距

        Rectangle{
            id:headerBar
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "#dac1c1"
            Button {
                text: "关闭"

                onClicked: {
                    // 从堆栈弹出当前页面
                    stack.pop()
                    // 如果需要传递数据回前一页
                   // StackView.view.pop({someData: value})
                }
            }
        }

        Item {  // 改用Item作为容器
              Layout.fillWidth: true
              Layout.fillHeight: true  // 关键点：填满剩余空间
              Layout.minimumHeight: 500

        // 左端展示组件
            RowLayout {
                //width: parent.width
                anchors.fill: parent
                spacing: 0
                Rectangle{
                    id:coverShow
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //Layout.preferredHeight: 500
                 color: "#dac1c1"
                    Image {
                        id: cover
                        //anchors.fill:parent
                        width: Math.min(parent.width, parent.height) / 2 // 取宽高中的较小值
                        height: width // 强制保持正方形
                        anchors.centerIn: parent

                        source: "file:///root/MusicTest/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg"
                        fillMode: Image.PreserveAspectFit  // 保持比例缩放
                    }
                }

                // 右端歌曲歌词
                Rectangle{
                    id:wordsShow
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //Layout.preferredHeight: 500
                    color: "#dac1c1"


                    ColumnLayout {
                        anchors.fill: parent
                        // 歌曲名
                        Text{
                            id:name
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            horizontalAlignment: Text.AlignHCenter //居中
                            verticalAlignment: Text.AlignVCenter
                            text: "歌曲名称"
                            color:"gray"
                            font.pixelSize:25
                        }

                        // 作者名
                        Text{
                            id:autor
                            Layout.fillWidth: true
                            Layout.preferredHeight: 15
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: "歌手名"
                            color:"gray"
                            font.pixelSize:10
                        }

                        // 其他歌曲信息
                        Text{
                            id:other
                            Layout.fillWidth: true
                            Layout.preferredHeight: 10
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: "专辑: 专辑名"
                            color:"gray"
                            font.pixelSize:10
                        }
                        ListView {
                            id: lyricView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 10  // 行间距

                            // 关键：使当前行始终居中
                            preferredHighlightBegin: height / 2 - 30  // 30 是单行近似高度
                            preferredHighlightEnd: height / 2 + 30  // 必须成对出现
                            //preferredHighlightRange: height / 2
                            //highlightRangeMode: ListView.StrictlyEnforceRange
                            highlightRangeMode: ListView.ApplyRange  // 比StrictlyEnforceRange更灵活

                            // 高亮当前行样式
                            // highlight: Rectangle {
                            //     color: "#bdd3d1"
                            //     width: lyricView.width
                            //     height: 30
                            //     radius: 4  // 可选圆角
                            //     anchors.horizontalCenter: parent.horizontalCenter
                            // }
                            // highlightMoveDuration: 200  // 200毫秒动画

                            model: ListModel { //将歌词一行一行添加进模型就好
                                       id: lyricModel
                                       // 测试数据（实际使用时通过loadLyrics()动态加载）
                                       ListElement { lineText: "这是第一行歌词"; time: 0 }
                                       ListElement { lineText: "这是第二行歌词"; time: 2000 }
                                       ListElement { lineText: "这是第三行歌词"; time: 4000 }
                                       ListElement { lineText: "这是第一行歌词"; time: 0 }
                                       ListElement { lineText: "这是第二行歌词"; time: 2000 }
                                       ListElement { lineText: "这是第三行歌词"; time: 4000 }
                                       ListElement { lineText: "这是第一行歌词"; time: 0 }
                                       ListElement { lineText: "这是第二行歌词"; time: 2000 }
                                       ListElement { lineText: "这是第三行歌词"; time: 4000 }
                                       ListElement { lineText: "这是第一行歌词"; time: 0 }
                                       ListElement { lineText: "这是第二行歌词"; time: 2000 }
                                       ListElement { lineText: "这是第三行歌词"; time: 4000 }
                                       ListElement { lineText: "这是第一行歌词"; time: 0 }
                                       ListElement { lineText: "这是第二行歌词"; time: 2000 }
                                       ListElement { lineText: "这是第三行歌词"; time: 4000 }
                                       ListElement { lineText: "这是第一行歌词"; time: 0 }
                                       ListElement { lineText: "这是第二行歌词"; time: 2000 }
                                       ListElement { lineText: "这是第三行歌词"; time: 4000 }

                                   }
                             // 动态加载歌词
                            delegate: Text {
                                text: lineText  // 假设每行数据有 lineText 属性
                                color: index === lyricView.currentIndex ? "#95cac5" : "white"
                                // font {
                                //     pixelSize: index === lyricView.currentIndex ? 22 : 16
                                //     bold: index === lyricView.currentIndex// 加粗
                                //     }
                                font.pixelSize: index === lyricView.currentIndex ? 22 : 16  //
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width

                                TapHandler{
                                    onTapped:{
                                        lyricView.currentIndex = index
                                        lyricView.positionViewAtIndex(index, ListView.Center)  // 强制居中

                                        console.log("点击行:", index, "当前高亮行:", lyricView.currentIndex)// 调试输出

                                    }
                                }
                            }

                            // 控制当前行（外部通过修改 currentIndex 滚动）
                            //property int currentIndex: 0
                            //Component.onCompleted: currentIndex = 0
                            Component.onCompleted: positionViewAtIndex(0, ListView.Beginning)

                        }
                    }
                }
            }
        }
    }
}
