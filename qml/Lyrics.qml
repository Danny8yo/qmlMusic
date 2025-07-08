import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import qmltest

Item {
    id: lyricsPage
    // width: 1000
    // height: 600
    width: parent.width
    height: parent.height
    //visible: true 与窗口控制方法会发生QML QQuickWindowQmlImpl*: Conflicting properties 'visible' and 'visibility'
    signal requestClose()

    // 歌词相关属性
    property var currentLyrics: []
    property var parsedLyrics: []
    property int currentLyricIndex: -1
    property bool lyricsLoaded: false

    // 使用 BackendManager 的歌词提取器
    property var lyricsExtractor: BackendManager.lyricsExtractor

    // 监听播放进度，实现歌词滚动
    Connections {
        target: BackendManager.playerController
        function onPositionChanged() {
            updateCurrentLyric()
        }
        function onCurrentSongChanged() {
            loadCurrentSongLyrics()
        }
    }

    // 页面加载时自动加载歌词
    Component.onCompleted: {
        loadCurrentSongLyrics()
    }

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

                        // source: "file:///root/MusicTest/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg"
                        source: BackendManager.playerController.currentSong.coverArtUrl


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
                            text: BackendManager.playerController.currentSong.title || "未知歌曲"
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
                            text: BackendManager.playerController.currentSong.artist || "未知歌手"
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
                            text: "专辑: " + (BackendManager.playerController.currentSong.album || "未知专辑")
                            color:"gray"
                            font.pixelSize:10
                        }
                        ListView {
                            id: _lyricView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 10  // 行间距

                            // 关键：使当前行始终居中
                            preferredHighlightBegin: height / 2 - 30  // 30 是单行近似高度
                            preferredHighlightEnd: height / 2 + 30  // 必须成对出现
                            highlightRangeMode: ListView.ApplyRange  // 比StrictlyEnforceRange更灵活

                            model: ListModel {
                                id: lyricModel
                                // 动态加载歌词数据
                            }

                            // 动态加载歌词
                            delegate: Text {
                                text: lineText  // 只显示歌词文本，不显示时间戳
                                color: index === currentLyricIndex ? "#95cac5" : "white"
                                font.pixelSize: index === currentLyricIndex ? 22 : 16
                                font.bold: index === currentLyricIndex
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                                wrapMode: Text.WordWrap

                                TapHandler{
                                    onTapped:{
                                        if (parsedLyrics.length > 0 && index < parsedLyrics.length) {
                                            _lyricView.currentIndex = index
                                            _lyricView.positionViewAtIndex(index, ListView.Center)
                                            // 跳转到对应时间
                                            BackendManager.playerController.setPosition(parsedLyrics[index].time)
                                        }
                                    }
                                }
                            }

                            // 无歌词时的占位文本
                            Text {
                                anchors.centerIn: parent
                                text: "当前歌曲暂无歌词"
                                color: "#888888"
                                font.pixelSize: 18
                                visible: lyricModel.count === 0 && lyricsLoaded
                            }

                            // 歌词加载提示
                            Text {
                                anchors.centerIn: parent
                                text: "正在加载歌词..."
                                color: "#888888"
                                font.pixelSize: 16
                                visible: !lyricsLoaded
                            }
                        }
                    }
                }
            }
        }
    }

    // 歌词处理函数
    function loadCurrentSongLyrics() {
        console.log("开始加载当前歌曲歌词")
        lyricsLoaded = false
        currentLyricIndex = -1
        lyricModel.clear()
        
        var currentSong = BackendManager.playerController.currentSong
        if (!currentSong || !currentSong.filePath) {
            console.log("没有当前歌曲")
            lyricsLoaded = true
            return
        }

        console.log("当前歌曲路径:", currentSong.filePath)
        
        // 使用 BackendManager 的 lyricsExtractor
        currentLyrics = BackendManager.lyricsExtractor.extractLyricsFromFile(currentSong.filePath)
        
        if (currentLyrics.length > 0) {
            console.log("成功提取歌词，行数:", currentLyrics.length)
            // 解析 LRC 格式歌词
            parsedLyrics = BackendManager.lyricsExtractor.parseLrcLyrics(currentLyrics)
            
            if (parsedLyrics.length > 0) {
                console.log("成功解析带时间戳的歌词，行数:", parsedLyrics.length)
                // 加载解析后的歌词到模型
                for (var i = 0; i < parsedLyrics.length; i++) {
                    lyricModel.append({
                        "lineText": parsedLyrics[i].text,
                        "time": parsedLyrics[i].time
                    })
                }
            } else {
                // 如果没有时间戳，加载原始歌词
                console.log("加载原始歌词")
                for (var j = 0; j < currentLyrics.length; j++) {
                    lyricModel.append({
                        "lineText": currentLyrics[j],
                        "time": j * 3000  // 每行默认3秒间隔
                    })
                }
            }
        } else {
            console.log("未找到歌词")
        }
        
        lyricsLoaded = true
        _lyricView.currentIndex = 0
    }

    function updateCurrentLyric() {
        if (parsedLyrics.length === 0) return
        
        var currentPosition = BackendManager.playerController.position
        var newIndex = -1
        
        // 找到当前播放时间对应的歌词行
        for (var i = 0; i < parsedLyrics.length; i++) {
            if (currentPosition >= parsedLyrics[i].time) {
                newIndex = i
            } else {
                break
            }
        }
        
        // 更新当前歌词索引和滚动位置
        if (newIndex !== currentLyricIndex && newIndex >= 0) {
            currentLyricIndex = newIndex
            _lyricView.currentIndex = newIndex
            _lyricView.positionViewAtIndex(newIndex, ListView.Center)
        }
    }
}
