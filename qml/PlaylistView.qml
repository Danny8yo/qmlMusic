//该页面为歌单详情表
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import qmltest


Item {
    id:_playlist
    anchors.fill: parent
    visible: true
    
    // 播放列表属性
    property int playlistId: -1
    //通过backend.getPlaylistById获取的当前歌单实例
    property var currentPlaylist: null
    //property var currentLocalPlaylist: null
    
    // 导航信号
    signal backRequested()
    
    // 加载播放列表数据的函数
    function loadPlaylist(id) {
        playlistId = id
        //getPlaylistById 返回Playlist实例
        currentPlaylist = BackendManager.getPlaylistById(id)

        if (currentPlaylist) {
            console.log("加载播放列表:", currentPlaylist.name)
            updatePlaylistInfo()
        } else { //处理本地（新增）列表处理
            currentPlaylist = BackendManager.getLocalPlaylistById(id)
            if(currentPlaylist) {
                console.log("加载播放列表:", currentPlaylist.name)
                updatePlaylistInfo()
            } else {
                console.log("未找到播放列表，ID:", id)
            }
        }
    }
    
    // 更新播放列表信息显示
    //ListView model在此获取
    function updatePlaylistInfo() {
        if (currentPlaylist) {
            _playlistName.text = currentPlaylist.name || "未命名歌单"
            _playlistAutor.text = "创作者：系统" // 暂时写死，后续可从数据库获取
            _playlistDate.text = "创建时间：" + (currentPlaylist.creationDate ? 
                Qt.formatDateTime(currentPlaylist.creationDate, "yyyy-MM-dd") : "未知")
            _playlistOther.text = currentPlaylist.description || "暂无描述"
            
            // 更新封面图片
            if (currentPlaylist.coverUrl && currentPlaylist.coverUrl.toString() !== "") {
                _cover.source = currentPlaylist.coverUrl
                console.log("dangdangdadadfadadgfadhadadgadaydsgdyad 封面", currentPlaylist.coverUrl)
            } else {
                _cover.source = "file://" + BackendManager.appDirPath + "/test_Music/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg"
            }
            
            // 加载播放列表的歌曲
            if (currentPlaylist) {
                let songs = currentPlaylist.getAllSongs()
                console.log("播放列表歌曲数量:", songs.length)
                _playlistSongList.model = songs
            }
        }
    }
    // 总体垂直

    ColumnLayout{

        spacing: 0
        anchors.fill: parent

        // 顶头退出按钮
        Rectangle{
            id:_headerBar
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "#dac1c1"
            Button {
                text: "返回"
                background: Rectangle {
                    color: parent.hovered ? "#e0e0e0" : "transparent"
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                TapHandler {
                    onTapped: _playlist.backRequested()
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
                   id:_coverShow
                   Layout.fillWidth: true
                   Layout.fillHeight: true
                   //Layout.preferredHeight: 500
                   color: "#dac1c1"
                   Image {
                       id: _cover
                       anchors.fill:parent
                       width: Math.min(parent.width, parent.height) / 2 // 取宽高中的较小值
                       height: width // 强制保持正方形
                       //width: 200
                       //height:200
                       anchors.centerIn: parent

                       // source: "file:///root/MusicTest/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg"
                       source: {
                           return "file://" + BackendManager.appDirPath + "/test_Music/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg"
                       }

                       fillMode: Image.PreserveAspectFit  // 保持比例缩放

                   }


               }

               // 右侧歌单信息矩形
               Rectangle{
                   // Layout.fillWidth: true
                   Layout.preferredWidth: parent.width * 0.2
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
                           spacing: 10

                           // 播放歌单按钮
                           Button{
                               id:_play
                               Layout.alignment: Qt.AlignLeft
                               text:"▶ 播放"

                               background: Rectangle {
                                   color: parent.hovered ? "#1976D2" : "#2196F3"
                                   radius: 20
                               }

                               contentItem: Text {
                                   text: parent.text
                                   color: "white"
                                   font.pixelSize: 14
                                   horizontalAlignment: Text.AlignHCenter
                                   verticalAlignment: Text.AlignVCenter
                               }

                               TapHandler {
                                   onTapped: {
                                       if (currentPlaylist) {
                                           console.log("播放播放列表:", currentPlaylist.name)
                                           BackendManager.playPlaylist(currentPlaylist.id)
                                       }
                                   }
                               }
                           }

                           // 收藏歌单按钮
                           Button{
                               id:_like
                               Layout.alignment: Qt.AlignLeft
                               text:"♥ 喜欢"

                               background: Rectangle {
                                   color: parent.hovered ? "#e0e0e0" : "white"
                                   border.color: "#ddd"
                                   radius: 20
                               }

                               contentItem: Text {
                                   text: parent.text
                                   color: "#666"
                                   font.pixelSize: 14
                                   horizontalAlignment: Text.AlignHCenter
                                   verticalAlignment: Text.AlignVCenter
                               }

                               TapHandler {
                                   onTapped: {
                                       console.log("收藏播放列表")
                                       // TODO: 实现收藏功能
                                   }
                               }
                           }

                           Button{ //点击后进入添加歌曲进播放列表的界面，能添加的歌曲由数据库提供
                               id:_more
                               Layout.alignment: Qt.AlignLeft
                               text:"+"

                               background: Rectangle {
                                   color: parent.hovered ? "#e0e0e0" : "transparent"
                                   radius: 20
                               }

                               contentItem: Text {
                                   text: parent.text
                                   color: "#666"
                                   font.pixelSize: 14
                                   horizontalAlignment: Text.AlignHCenter
                                   verticalAlignment: Text.AlignVCenter
                               }

                               TapHandler {
                                   onTapped: {
                                       _addsongView.visible = !_addsongView.visible
                                       console.log("添加歌曲")
                                       // TODO: 显示更多选项菜单
                                   }
                               }
                           }
                       }

                   }//ColumnLayout



               }
               Rectangle {// _addsongView的矩形
                   //Layout.fillWidth: true
                   Layout.preferredWidth: parent.width * 0.3
                   Layout.fillHeight: true
                   //color: "red"
                   color:"#dac1c1"
                   ListView{
                       id:_addsongView
                       // Layout.fillHeight: true
                       // Layout.fillWidth: true
                       anchors.fill: parent
                       visible: false

                       model:BackendManager.songModel

                       //
                       highlight: Rectangle {
                           color: "#bdd3d1"
                           width: _addsongView.width
                           height: 30
                           radius: 4  // 可选圆角
                           //anchors.horizontalCenter: parent.horizontalCenter

                       }

                       delegate: Rectangle {
                           width: _addsongView.width
                           height: 60
                           // color: index === songView.currentIndex ? "#e3f2fd" :
                           //        (index % 2 ? "#f5f5f5" : "white")
                           color: index === _addsongView.currentIndex ? "white" : "#95cac5"

                           RowLayout {
                               anchors.fill: parent
                               anchors.margins: 5
                               spacing: 15

                               // 封面（简化示例）
                               Rectangle {
                                   width: 40
                                   height: 40
                                   color: "#bdd3d1"
                                   radius: 4
                                   Image {
                                       anchors.fill: parent
                                       //source: coverArt || "qrc:/default_cover.png"  // 使用实际封面或默认图
                                       source:model.coverArt
                                       fillMode: Image.PreserveAspectFit
                                   }
                                   // Text {
                                   //     anchors.centerIn: parent
                                   //     text: model.index + 1
                                   //     font.bold: true
                                   // }
                               }

                               // 歌曲信息
                               ColumnLayout {
                                   spacing: 2
                                   Text {
                                       text: model.title || "未知标题"
                                       font.pixelSize: 13
                                       elide: Text.ElideRight
                                       Layout.fillWidth: true
                                   }
                                   Text {
                                       text: (model.artist || "未知艺术家") + " · " + (model.album || "未知专辑")
                                       font.pixelSize: 10
                                       color: "#666"
                                       elide: Text.ElideRight
                                       Layout.fillWidth: true
                                   }
                               }

                           }
                           // 双击添加歌曲
                           TapHandler {
                               acceptedButtons: Qt.LeftButton
                               onDoubleTapped: {
                                   if (model) {
                                       console.log("添加歌曲:", model.title)
                                       let list = currentPlaylist
                                       let song = BackendManager.getSongById(model.id)
                                       console.log("获取的歌单名", list.name)
                                       console.log(model.title, model.filePath)
                                       //list.addSong(song)
                                       BackendManager.addSongToPlaylist(song,list);
                                       updatePlaylistInfo()
                                   }
                               }
                           }

                           // 单击选中
                           TapHandler {
                               acceptedButtons: Qt.LeftButton
                               onTapped: {
                                   _addsongView.currentIndex = index
                               }
                           }
                       }
                   }//_addsongViiew
               }
           }//RowLayout
        }

        // 播放列表歌曲显示区域
        Rectangle {
            id: _songListContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#95cac5"
            
            ListView {
                id: _playlistSongList
                anchors.fill: parent
                clip: true
                spacing: 5
                
                delegate: Rectangle {
                    width: _playlistSongList.width
                    height: 60
                    color: index === _playlistSongList.currentIndex ? "white" : "#95cac5"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 15

                        // 歌曲序号
                        Text {
                            Layout.preferredWidth: 30
                            text: (index + 1).toString().padStart(2, '0')
                            font.pixelSize: 14
                            color: "#666"
                            horizontalAlignment: Text.AlignCenter
                        }

                        //封面
                        Rectangle {
                            width: 50
                            height: 50
                            color: "#bdd3d1"
                            radius: 4

                            Image {
                                anchors.fill: parent
                                source: modelData ? modelData.coverArtUrl : "file://" + BackendManager.appDirPath + "/test_Music/Local_Playlist/covers/最好的时光 - 安溥 anpu.jpg"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        // 歌曲信息
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                Layout.fillWidth: true
                                text: modelData ? (modelData.title || "未知标题") : "未知标题"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData ? (modelData.artist || "未知艺术家") : "未知艺术家"
                                font.pixelSize: 12
                                color: "#666"
                                elide: Text.ElideRight
                            }
                        }

                        //歌曲时间
                        Text {
                            text: modelData.durationString /*|| "00:00"*/
                            // text: {
                                   // console.log("!!!!!!!!!!song.durationString():",modelData.durationString)
                            // }

                            font.pixelSize: 14
                            color: "#666"
                        }
                    }

                    // 双击播放歌曲
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onDoubleTapped: {
                            if (modelData) {

                                //index为双击选中的歌曲索引
                                _playlistSongList.currentIndex = index
                                 let song = BackendManager.getSongById(modelData.id)
                                console.log("播放歌曲:", modelData.title)
                                BackendManager.playerController.playSong(song)
                            }
                        }
                    }

                    // 单击选中
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: {
                            _playlistSongList.currentIndex = index
                        }
                    }
                }

                // 空状态
                Rectangle {
                    anchors.centerIn: parent
                    width: 200
                    height: 100
                    color: "transparent"
                    visible: _playlistSongList.count === 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "暂无歌曲"
                            font.pixelSize: 16
                            color: "#999"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "这个播放列表还没有歌曲"
                            font.pixelSize: 12
                            color: "#ccc"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
