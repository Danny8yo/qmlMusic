import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import qmltest

Rectangle {
    id: scanMusicView
    color: "#f8f8f8"
    
    property bool isScanning: false
    property string scanPath: ""
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20
        
        // 标题
        Text {
            text: "扫描本地音乐"
            font.pixelSize: 28
            font.bold: true
            color: "#333"
            Layout.alignment: Qt.AlignHCenter
        }
        
        // 扫描说明
        Text {
            text: "选择音乐文件夹，自动扫描并添加到音乐库"
            font.pixelSize: 16
            color: "#666"
            Layout.alignment: Qt.AlignHCenter
        }
        
        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#e0e0e0"
        }
        
        // 扫描选项区域
        GroupBox {
            title: "扫描设置"
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                
                // 选择文件夹
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "扫描路径："
                        font.pixelSize: 14
                        color: "#333"
                        Layout.preferredWidth: 80
                    }
                    
                    TextField {
                        id: pathField
                        Layout.fillWidth: true
                        text: scanPath
                        placeholderText: "请选择要扫描的音乐文件夹..."
                        readOnly: true
                        background: Rectangle {
                            color: "#f5f5f5"
                            border.color: "#ddd"
                            radius: 4
                        }
                    }
                    
                    Button {
                        text: "浏览"
                        onClicked: folderDialog.open()
                        
                        background: Rectangle {
                            color: parent.hovered ? "#e3f2fd" : "#2196F3"
                            radius: 4
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
                
                // 扫描选项
                CheckBox {
                    id: includeSubfoldersCheck
                    text: "包含子文件夹"

                    contentItem: Text {
                        text: parent.text
                        color: "black"
                        font: parent.font
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: parent.indicator.width + parent.spacing
                    }
                    checked: true
                }
                
                CheckBox {
                    id: replaceExistingCheck
                    text: "替换已存在的音乐文件"
                    
                    contentItem: Text {
                        text: parent.text
                        color: "black"
                        font: parent.font
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: parent.indicator.width + parent.spacing
                    }

                    checked: false
                }
            }
        }
        
        // 扫描按钮
        Button {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 200
            Layout.preferredHeight: 50
            text: isScanning ? "扫描中..." : "开始扫描"
            enabled: !isScanning && scanPath !== ""
            
            background: Rectangle {
                color: parent.enabled ? (parent.hovered ? "#1976D2" : "#2196F3") : "#ccc"
                radius: 25
            }
            
            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 16
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                startScan()
            }
        }
        
        // 进度条
        ProgressBar {
            id: scanProgress
            Layout.fillWidth: true
            Layout.preferredHeight: 10
            visible: isScanning
            indeterminate: true
            
            background: Rectangle {
                color: "#e0e0e0"
                radius: 5
            }
        }
        
        // 扫描状态
        Text {
            id: scanStatusText
            text: ""
            font.pixelSize: 14
            color: "#666"
            Layout.alignment: Qt.AlignHCenter
            visible: text !== ""
        }
        
        // 扫描结果列表
        GroupBox {
            title: "扫描到的音乐文件"
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: isScanning
            
            SongView {
                anchors.fill: parent
                // 可以在这里显示扫描到的音乐
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
    }
    
    // 文件夹选择对话框
    FolderDialog {
        id: folderDialog
        title: "选择音乐文件夹"
        onAccepted: {
            scanPath = selectedFolder.toString().replace("file://", "")
            pathField.text = scanPath
        }
    }
    
    // 扫描函数
    function startScan() {
        if (scanPath === "") {
            scanStatusText.text = "请先选择扫描路径"
            return
        }
        
        isScanning = true
        scanStatusText.text = "正在扫描音乐文件..."
        
        // 调用后端扫描功能
        // if (BackendManager.musicScanner) {
        //     BackendManager.musicScanner.scanFolder(
        //         scanPath,
        //         includeSubfoldersCheck.checked,
        //         replaceExistingCheck.checked
        //     )
        // }
        console.log(scanPath)
        BackendManager.scanMusicLibrary(scanPath)
        
        // 模拟扫描过程（实际应该通过信号连接）
        scanTimer.start()
    }
    
    // 扫描完成计时器（模拟）
    Timer {
        id: scanTimer
        interval: 3000
        onTriggered: {
            isScanning = false
            scanStatusText.text = "扫描完成！发现 15 首新音乐"
        }
    }
}
