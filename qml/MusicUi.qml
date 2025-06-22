import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: _root

    RowLayout {
        spacing: 0
        anchors.fill: parent // 填充整个 StackView

        //左侧导航栏
        LeftGuideBar {
            id: _leftGuideBar
            Layout.preferredWidth: 200 // 固定宽度
            Layout.fillHeight: true // 填充高度
        }
        //列排序导航栏和主界面
        ColumnLayout {
            spacing: 0
            //顶部的导航栏
            TopBar {
                anchors.top: root.top //位置在主界面顶部
                Layout.fillWidth: true // 填充宽度
                Layout.preferredHeight: 60 // 固定高度
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#2b2c2e"

            }
        }
    }
}
