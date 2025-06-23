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

            spacing: 20 // 设置固定间距

            //左部歌曲信息
            RowLayout {
                id : leftSection
                Layout.fillHeight: true
                spacing: 15

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
                Column {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true

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


            //中间的播放控制按钮
            RowLayout {
                //anchors.centerIn: parent 将按钮组居中
                anchors.centerIn: parent
                // Layout.alignment:
                spacing: 20 // 设置按钮间固定间距

                ToolButton {
                    id: _previous
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
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
                    icon.height: 50
                    icon.width: 50
                    icon.source: "qrc:/playControl/resources/next.png"
                    onClicked: {
                        BackendManager.playerController.next()
                        console.log("Next button clicked")
                    }
                }
            }


            //右侧功能按钮(播放列表,音量调节,播放模式,歌词显示等)
            RowLayout {
                spacing: 1
                // Layout.preferredWidth: parent.width/3

                ToolButton {
                    id: _playMode
                    icon.source: {
                        switch(BackendManager.playerController.playbackMode){
                        case 0:   return "qrc:/playControl/resources/playlist.png"//BackendManager.playerController.Sequential
                        case 1:   return "qrc:/playControl/resources/listPlay.png"//BackendManager.playerController.Loop
                        case 2:   return "qrc:/playControl/resources/randomPlay.png"//BackendManager.playerController.Random
                        case 3:   return "qrc:/playControl/resources/repeatPlay.png"//BackendManager.playerController.RepeatOne
                        }

                    }
                        //"qrc:/playControl/resources/listPlay.png"
                    icon.height: 30
                    icon.width: 30
                    text:{
                        switch(BackendManager.playerController.playbackMode){
                        case 0:   return "Seq顺序"//BackendManager.playerController.Sequential
                        case 1:   return "Loop列表循环"//BackendManager.playerController.Loop
                        case 2:   return "Random随机"//BackendManager.playerController.Random
                        case 3:   return "RepeatOne单曲循环"//BackendManager.playerController.RepeatOne
                        }

                    }

                    onClicked: {
                        let nextMode = (BackendManager.playerController.playbackMode + 1) % 4
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

                ToolButton{
                    id: _loveButton
                    icon.source: "qrc:/playControl/resources/love.png"
                    icon.height: 30
                    icon.width: 30
                }

                ToolButton {
                    //播放列表图标
                    id: _playlist
                    icon.source: "qrc:/playControl/resources/playlist.png"
                    icon.height: 30
                    icon.width: 30

                    property bool isPlaylistViewShowing: false
                    onClicked: {
                        stack.push(Qt.resolvedUrl("SongView.qml"))
                    }
                }
            }
        }
    }
}

