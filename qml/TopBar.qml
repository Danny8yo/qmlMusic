import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmltest


//顶部组件,包含搜索栏,前后箭头操作StackView,以及用户头像,还有设置图标
Rectangle{
    id: _topBar
    width: parent.width
    height: parent.height
    color: "lightgrey"

    RowLayout{
        anchors.fill: parent
        // anchors.margins: 8 // 给整体一些边距

        //左侧搜索栏,前后进
        RowLayout{
            spacing: 1
            //左右箭头
            ToolButton{
                id: _backButton
                icon.source: "qrc:/OtherUi/resources/back.png"
                // Layout.preferredWidth: 25
                // Layout.preferredHeight: 25
                icon.height: 25
                icon.width: 25
            }
            ToolButton{
                id: _forwardButton
                icon.source: "qrc:/OtherUi/resources/forward.png"
                icon.height: 25
                icon.width: 25
            }

            //搜索框
            TextField{
                id: _searchField
                // Layout.fillWidth: true
                Layout.preferredWidth:250
                Layout.preferredHeight: 32
                placeholderText: "搜索..."
                font.pixelSize: 15
                padding: 4 // 设置内边距
                background: Rectangle {
                    color: "white"
                    border.color: "lightgrey"
                    radius: 8
                }

            }
        }


        //右侧用户头像和设置图标,主题图标
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight // 右对齐

        //圆形用户头像
            Image {
                id: _userProfileImage
                // source: "file:///home/lius/Documents/qmlMusic-dev/1/qmlMusic/test_Music/Local_Playlist/covers/I Really want to stay at your house.jpg"
                source: {
                    return "file://" + BackendManager.appDirPath + "/test_Music/Local_Playlist/covers/I Really want to stay at your house.jpg"
                }

                Layout.preferredWidth: 50
                Layout.preferredHeight: 50

            }

        //设置图标
            ToolButton {
                id: _settingsButton
                icon.source: "qrc:/OtherUi/resources/setting.png"
                icon.height: 25
                icon.width: 25
            }

        //更换主题图标
            ToolButton{
                id: _themeButton
                icon.source: "qrc:/OtherUi/resources/theme.png"
                icon.height: 25
                icon.width: 25
            }
        }

    }
}
