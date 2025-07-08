import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmltest


Rectangle {
    id: playController
    width: parent.width
    //高度为主界面的1/8
    height: parent.height/8
    color: "lightgrey"
    // radius: 10
    property int playControllerWidth: width // 用于外部访问宽度
    clip: true // 确保内容被正确裁剪
    z: 1 // 确保 PlayController 在主内容之上
    
    // 调试边界 - 可以临时启用来查看组件边界
    // border.color: "red"
    // border.width: 2

    // 添加 MouseArea 来捕获所有鼠标事件，防止事件穿透
    // MouseArea {
    //     anchors.fill: parent
    //     acceptedButtons: Qt.AllButtons
    //     propagateComposedEvents: false // 阻止事件传播到下层
    //     // 不处理任何事件，只是阻止穿透
    // }

    // 接收来自 main.qml 的 StackView 引用
    // property alias stackView: stackViewDelegate.stackView

    // 底部控制栏布局,歌曲进度独占一列
    //其他占一列
    ColumnLayout{
        anchors.fill: parent
        // anchors.margins: 5 // 给整体一些边距

        // 进度条
        Slider {
            id: progressBar
            from: 0
            to: BackendManager.playerController.duration

            value: BackendManager.playerController.position
            Layout.fillWidth: true // 填充整个宽度
            Layout.preferredHeight: 5 // 给进度条一个合适的高度，包含把手
            Layout.topMargin: 2 // 顶部留一些边距
            // Layout.bottomMargin: 5 // 底部留一些边距

            onMoved: {
                    BackendManager.playerController.setPosition(value)
            }

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 4 // 实际轨道高度
                radius: 2
                color: "#cccccc" // 未经过部分为灰色

                // 进度填充
                Rectangle {
                    width: parent.width * progressBar.position
                    height: parent.height
                    radius: 2
                    color: "#e91962" // 经过部分为蓝色
                }
            }

            handle: Rectangle {
                x: progressBar.leftPadding + progressBar.visualPosition * (progressBar.availableWidth - width)
                y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
                width: 12
                height: 12
                radius: 6
                color: "#e91962"//  把手颜色
                border.color: "#ffffff"
                border.width: 1
            }
        }

        //其他控件
        RowLayout {
            Layout.fillHeight: true // 填充父组件剩余内容
            Layout.fillWidth: true
            Layout.leftMargin: 10 // 确保这里有内边距，否则内容会贴边
            Layout.rightMargin: 10

            spacing: 0 // 设置固定间距

            //左部歌曲信息
            RowLayout {
                id : leftSection
                // Layout.fillHeight: true
                // Layout.fillWidth: true
                // Layout.alignment: Qt.AlignLeft //左
                Layout.preferredWidth: playControllerWidth / 5
                Layout.alignment: Qt.AlignLeft
                spacing: 10
                // Rectangle { color: "red"; opacity: 0.2; anchors.fill: parent }

                // 圆角图片
                Item {
                    id: _albumCoverContainer
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    // radius: 8
                    Layout.alignment: Qt.AlignVCenter

                    Image {
                        anchors.fill: parent
                        id: _albumCover
                        z:1
                        // source: "file:///home/lius/Documents/qmlMusic-dev/1/qmlMusic/test_Music/Local_Playlist/covers/城里的月光 - 许美静.jpg"
                        source: {
                            //return "file://" + BackendManager.appDirPath + "/test_Music/Local_Playlist/covers/城里的月光 - 许美静.jpg"
                            console.log(BackendManager.playerController.currentSong.coverArtUrl)
                            return BackendManager.playerController.currentSong.coverArtUrl
                        }

                        clip: true
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                    }

                    ToolButton {
                        id: _clickToLyrics
                        anchors.fill:parent
                        icon.source: "qrc:/OtherUi/resources/up.png"
                        z:1
                        //添加属性,确认歌词是否被展示
                        property bool isLyricsShowing: false

                        opacity: 0.0
                        //设置默认透明,鼠标进入才显示
                        onHoveredChanged: {
                            if (hovered) {
                                _clickToLyrics.opacity = 0.5; // 鼠标进入时显示
                            } else {
                                _clickToLyrics.opacity = 0.0; // 鼠标离开时隐藏
                            }
                        }
                        // 修改点击处理
                        onClicked: {
                            if (!isLyricsShowing) {
                                console.log("切换到歌词页面")
                                stack.push(_lyricsComponent)
                                isLyricsShowing = true
                                icon.source = "qrc:/OtherUi/resources/down.png"
                            } else {
                                console.log("返回主页面")
                                stack.pop()
                                isLyricsShowing = false
                                icon.source = "qrc:/OtherUi/resources/up.png"
                            }
                        }
                    }

                }


                // 歌曲信息文本
                ColumnLayout {
                    //Layout.alignment: Qt.AlignLeft
                    //Layout.fillWidth: true
                    //Rectangle { color: "red"; opacity: 0.2; anchors.fill: parent }
                    Layout.preferredWidth: parent.width - 70 //// 不加的话文字和图片间距会过大

                    Text {
                        //text: "城里的月光"
                        text:BackendManager.playerController.currentSong.title
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                    }
                    Text {
                        //text: "许美静"
                        text:BackendManager.playerController.currentSong.artist
                        font.pixelSize: 12
                        color: "#666666"
                    }
                }


            }

            Item{ // 左部填充（不加的话播放控制按钮不能正确居中）
                id: _left
                // Rectangle {
                //     color: "green"
                //     anchors.fill: parent
                // }
                Layout.fillHeight: true
                Layout.preferredWidth: playControllerWidth / 5
            }

            //中间的播放控制按钮
            RowLayout {                
                //()1  anchors.centerIn: parent//将按钮组居中
                ///Layout.fillWidth: true
                Layout.preferredWidth: playControllerWidth / 5
                Layout.alignment: Qt.AlignHCenter  // 使用Layout属性

                spacing: 20 // 设置按钮间固定间距

                ToolButton {
                    id: _previous
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    //靠齐左侧
                    Layout.alignment: Qt.AlignLeft

                    icon.height: 50
                    icon.width: 50
                    icon.source: "qrc:/playControl/resources/previous.png"
                    onClicked: {
                        BackendManager.playerController.previous()
                        console.log("Previous button clicked")
                    }
                }

                ToolButton {
                    id: _play
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: 70
                    Layout.alignment: Qt.AlignHCenter // 居中对齐
                    //icon.source: "qrc:/playControl/resources/circlePlay.png"
                    icon.source: BackendManager.playerController.isPlaying ? "qrc:/playControl/resources/circlePause.png" : "qrc:/playControl/resources/circlePlay.png"
                    icon.height: 70
                    icon.width: 70
                    onClicked: {


                        if(BackendManager.playerController.isPlaying) {
                            BackendManager.playerController.pause()
                        } else if(BackendManager.playerController.currentIndex === -1 && BackendManager.playerController.playQueue.length > 0) {// 如果当前无歌曲且队列不为空，自动从第一首开始
                            BackendManager.playerController.playQueueIndex(0)
                        } else {BackendManager.playerController.play()
                        }

                        //BackendManager.playerController.play()
                        console.log("Play button clicked")
                    }
                }

                ToolButton {
                    id: _next
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignRight // 靠齐右侧
                    icon.height: 50
                    icon.width: 50
                    icon.source: "qrc:/playControl/resources/next.png"
                    onClicked: {
                        BackendManager.playerController.next()
                        console.log("Next button clicked")
                    }
                }
            }


            Item { // 右部填充（不加的话功能按钮不能正确靠右）
                id: _right
                // Rectangle {
                //     color: "blue"
                //     anchors.fill: parent
                // }
                Layout.fillHeight: true
                Layout.preferredWidth: playControllerWidth / 5
            }

            //右侧功能按钮(播放列表,音量调节,播放模式,歌词显示等)
            RowLayout {
                spacing: 0
                Layout.preferredWidth: parent.width / 5
                Layout.alignment: Qt.AlignRight
                //anchors.right: parent.right
                //Layout.fillWidth: true
                //Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                // Layout.preferredWidth: parent.width/3

                ToolButton {
                    id: _playMode
                    icon.source: {
                        switch(BackendManager.playerController.playbackMode){
                        // case 0:   return "qrc:/playControl/resources/playlist.png"//BackendManager.playerController.Sequential
                        case 0:   return "qrc:/playControl/resources/listPlay.png"//BackendManager.playerController.Loop
                        case 1:   return "qrc:/playControl/resources/randomPlay.png"//BackendManager.playerController.Random
                        case 2:   return "qrc:/playControl/resources/repeatPlay.png"//BackendManager.playerController.RepeatOne
                        }

                    }
                        //"qrc:/playControl/resources/listPlay.png"
                    icon.height: 30
                    icon.width: 30

                    onClicked: {
                        let nextMode = (BackendManager.playerController.playbackMode + 1) % 3
                        BackendManager.playerController.playbackMode = nextMode
                        console.log(BackendManager.playerController.playbackMode)
                    }
                }
                ToolButton {
                    //音量控制
                    id: _volumeButton
                    icon.source: "qrc:/playControl/resources/volume.png"
                    icon.height: 30
                    icon.width: 30
                    onClicked: {
                        console.log("拉满或者设置音量为0")
                    }
                }
                //水平音量条
                Slider {
                    id: _volumeSlider
                    from: 0
                    to: 100
                    value: BackendManager.playerController.volume
                    stepSize: 1//步长
                    Layout.preferredWidth: 100

                    onMoved:{
                        BackendManager.playerController.setVolume(value)

                    }

                }
                

                ToolButton {
                    //播放列表图标
                    id: _playlist
                    icon.source: "qrc:/playControl/resources/playlist.png"
                    icon.height: 30
                    icon.width: 30
                    property bool _isListshowing: false

                    onClicked: {
                        if (_isListshowing) {
                            console.log("隐藏播放队列")
                            stack.pop()
                            _isListshowing = false
                        } else {
                            console.log("显示播放队列")
                            stack.push(_playQueueComponent)
                            _isListshowing = true
                        }
                    }
                }
            }
        }
    }
}
