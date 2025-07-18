import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs


Window {
    visible:true
    height: 700
    width: 1200

    //歌词stack
    Component{
        id: _lyricsComponent
        Lyrics{
            // Layout.fillWidth: true
            // Layout.fillHeight: true
            anchors.fill: parent
        }
    }

    // 播放队列组件
    Component {
        id: _playQueueComponent
        PlayQueueView {
            width: parent.width
            height: parent.height
        }
    }

    property alias stack: _stack

    //导航栏StackView  和  下侧控制栏
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StackView{
            id: _stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true // 确保内容被正确裁剪在边界内
            initialItem: MusicUi {

            }
            
            // 自定义页面切换动画
            pushEnter: Transition {
                id: pushEnter
                ParallelAnimation {
                    PropertyAnimation {
                        property: "y"
                        from: pushEnter.ViewTransition.destination.height
                        to: 0
                        duration: 300
                        easing.type: Easing.OutQuart
                    }
                    PropertyAnimation {
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 300
                    }
                }
            }
            
            pushExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: 300
                }
            }
            
            popEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 300
                }
            }
            
            popExit: Transition {
                id: popExit
                ParallelAnimation {
                    PropertyAnimation {
                        property: "y"
                        from: 0
                        to: popExit.ViewTransition.destination.height
                        duration: 300
                        easing.type: Easing.InQuart
                    }
                    PropertyAnimation {
                        property: "opacity"
                        from: 1.0
                        to: 0.0
                        duration: 300
                    }
                }
            }
        }


        //第二行:底部的播放控制器
        PlayController {
            id: _playController
            Layout.fillWidth: true
            Layout.preferredHeight: 100//固定高度
        }

    }

}

