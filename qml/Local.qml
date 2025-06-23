import QtQuick
import QtQuick.Layouts
import qmltest

Item {
    id: _Local
    anchors.fill: parent
    visible: true

    ColumnLayout {
        spacing: 5
        anchors.fill: parent

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            text: qsTr("本地音乐")
            font.pixelSize: 38
            font.bold: true
            color: "black"
        }

        SongView {
            id: _localList
        }
    }

}
