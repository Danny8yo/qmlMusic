import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Dialogs
import Song 1.0
Window {
    visible:true

    // 测试Song暴露的封面路径，创建了Song的实例，实际上应该通过MusicScanner或者Playlist或者PlayerController访问
    Song {
        id: ma
        coverArtPath: {
            var path = "/root/MusicTest/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg"
            console.log("尝试加载封面路径:", path)
            return "file://" + path
        }
    }

    Image {
        id: name
        anchors.fill:parent
        source: ma.coverArtPath
    }
    Text{
        //text:Song.coverArtPath
        text:"sddsds"
    }

}
