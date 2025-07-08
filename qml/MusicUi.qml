import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: _root
    
    // 当前页面类型
    property string currentPage: "discover"
    property var navigationHistory: []
    property int currentHistoryIndex: -1
    property int selectedPlaylistId: -1 // 用于传递播放列表ID
    property var playlistNavigationHistory: [] // 专门用于播放列表导航的历史
    property int playlistHistoryIndex: -1
    
    // 导航函数
    function navigateToPage(pageName, addToHistory = true, playlistId = -1) {
        // 检查是否已经在目标页面且播放列表ID相同（如果适用）
        if (currentPage === pageName && (pageName !== "playlist" || selectedPlaylistId === playlistId)) {
            console.log("已经在目标页面:", pageName, "播放列表ID:", playlistId)
            return; // 如果已经在目标页面，直接返回，不重复加载
        }
        
        // 如果是播放列表相关的导航，使用专门的历史记录
        if (pageName === "playlist" || (currentPage === "playlist" && playlistNavigationHistory.length > 0)) {
            if (addToHistory && pageName === "playlist") {
                // 处理播放列表导航历史
                if (playlistHistoryIndex < playlistNavigationHistory.length - 1) {
                    playlistNavigationHistory = playlistNavigationHistory.slice(0, playlistHistoryIndex + 1)
                }
                
                if (currentPage === "discover") {
                    playlistNavigationHistory.push("discover")
                }
                playlistNavigationHistory.push("playlist")
                playlistHistoryIndex = playlistNavigationHistory.length - 1
            }
        } else {
            // 清空播放列表导航历史，因为离开了播放列表相关页面
            if (currentPage === "playlist") {
                playlistNavigationHistory = []
                playlistHistoryIndex = -1
            }
            
            // 处理一般导航历史
            if (addToHistory && pageName !== currentPage) {
                // 如果不是在历史记录的末尾，清除后面的记录
                if (currentHistoryIndex < navigationHistory.length - 1) {
                    navigationHistory = navigationHistory.slice(0, currentHistoryIndex + 1)
                }
                
                // 添加当前页面到历史记录
                navigationHistory.push(currentPage)
                currentHistoryIndex = navigationHistory.length - 1
            }
        }
        
        currentPage = pageName
        selectedPlaylistId = playlistId
        _contentLoader.loadPage(pageName)
        _topBar.updateNavigationButtons()
    }
    

    // 后退函数 - 只处理播放列表导航
    function goBack() {
        // 只处理播放列表相关的后退
        if (playlistNavigationHistory.length > 0 && playlistHistoryIndex > 0) {
            playlistHistoryIndex--
            let targetPage = playlistNavigationHistory[playlistHistoryIndex]
            currentPage = targetPage
            _contentLoader.loadPage(targetPage)
            _topBar.updateNavigationButtons()
        }
    }
    
    // 前进函数 - 只处理播放列表导航
    function goForward() {
        // 只处理播放列表相关的前进
        if (playlistNavigationHistory.length > 0 && playlistHistoryIndex < playlistNavigationHistory.length - 1) {
            playlistHistoryIndex++
            let targetPage = playlistNavigationHistory[playlistHistoryIndex]
            currentPage = targetPage
            _contentLoader.loadPage(targetPage)
            _topBar.updateNavigationButtons()
        }
    }

    RowLayout {
        spacing: 0
        anchors.fill: parent // 填充整个 StackView

        //左侧导航栏
        LeftGuideBar {
            id: _leftGuideBar
            Layout.preferredWidth: 200 // 固定宽度
            Layout.fillHeight: true // 填充高度
            
            // 连接导航信号
            onNavigationRequested: function(page) {
                _root.navigateToPage(page)
            }

            // 连接新增的我的歌单信号
            onMylistRequested: function(playlistId)  {
                console.log("接收到我的歌单请求:", playlistId)
                _root.navigateToPage("playlist", true, playlistId)
            }

        }
        
        //列排序导航栏和主界面
        ColumnLayout {
            spacing: 0
            //顶部的导航栏
            TopBar {
                id: _topBar

                //遮盖内容
                z:1

                Layout.fillWidth: true // 填充宽度
                Layout.preferredHeight: 60 // 固定高度
                
                // 连接导航按钮
                onBackRequested: _root.goBack()
                onForwardRequested: _root.goForward()
                
                // 检查导航按钮状态 - 只针对播放列表导航
                function updateNavigationButtons() {
                    backEnabled = playlistNavigationHistory.length > 0 && playlistHistoryIndex > 0
                    forwardEnabled = playlistNavigationHistory.length > 0 && playlistHistoryIndex < playlistNavigationHistory.length - 1
                }
                
                property alias backEnabled: _topBar.backEnabled
                property alias forwardEnabled: _topBar.forwardEnabled
            }

            //主内容区域
            Loader {
                id: _contentLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                // 页面加载函数
                function loadPage(pageName) {
                    var componentSource = ""
                    console.log("接收到page", pageName)
                    switch(pageName) {
                        case "discover":
                            componentSource = "PlaylistGridView.qml"
                            break
                        case "favorites":
                            componentSource = "MyFavoritesView.qml"
                            break
                        case "local":
                            componentSource = "Local.qml"
                            break
                        case "scan":
                            componentSource = "ScanMusicView.qml"
                            break
                        case "playlist":
                            componentSource = "PlaylistView.qml"
                            break
                        default:
                            componentSource = "PlaylistGridView.qml"
                    }
                    
                    // if (source.toString() !== componentSource) {
                    //     source = componentSource
                    // }
                    source = ""//清空
                    source = componentSource// 立即切回目标组件
                }
                
                // 为加载的组件设置导航函数
                onLoaded: {
                    //item为loader当前加载出来的组件实例
                    if (item) {
                        // 连接我的喜欢页面的信号
                        if (item.hasOwnProperty("discoverRequested")) {
                            item.discoverRequested.connect(function() {
                                _root.navigateToPage("discover")
                            })
                        }
                        
                        // 连接播放列表点击信号
                        if (item.hasOwnProperty("playlistRequested")) {
                            item.playlistRequested.connect(function(playlistId) {
                                _root.navigateToPage("playlist", true, playlistId)
                            })
                        }
                        
                        // 连接PlaylistView的返回信号
                        if (item.hasOwnProperty("backRequested")) {
                            item.backRequested.connect(function() {
                                _root.goBack()
                            })
                        }
                        
                        // 如果是播放列表详情页面，加载对应的播放列表
                        if (_root.currentPage === "playlist" && _root.selectedPlaylistId >= 0) {
                            if (typeof item.loadPlaylist === "function") {
                                item.loadPlaylist(_root.selectedPlaylistId)
                            }
                        }
                    }
                }
            }
        }
    }
    
    Component.onCompleted: {
        // 初始化页面
        _contentLoader.loadPage("discover")
    }
}
