import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Quickshell 1.0
import Quickshell.Widgets 1.0
import qs.components 1.0
import qs.config 1.0

Window {
    id: root
    
    title: "Wallpaper Selector"
    width: 900
    height: 650
    flags: Qt.FramelessWindowHint
    color: "transparent"
    
    property string wallpaperDir: Paths.home + "/Pictures/Wallpapers/"
    property var wallpapers: []
    
    Component.onCompleted: {
        loadWallpapers()
    }
    
    function loadWallpapers() {
        wallpapers = []
        var files = Quickshell.listDir(wallpaperDir)
        for (var i = 0; i < files.length; i++) {
            var ext = files[i].split('.').pop().toLowerCase()
            if (ext === "jpg" || ext === "jpeg" || ext === "png" || ext === "webp") {
                wallpapers.push(files[i])
            }
        }
        gridView.model = wallpapers
        countText.text = wallpapers.length + " wallpapers"
    }
    
    function setWallpaper(path) {
        Quickshell.execDetached(["caelestia", "wallpaper", "-f", path])
        Quickshell.execDetached(["notify-send", "Wallpaper", "Changed to: " + path.split('/').pop()])
        root.close()
    }
    
    // Background blur
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }
    
    // Main card
    Rectangle {
        anchors.centerIn: parent
        width: 850
        height: 600
        color: Colours.palette.m3surfaceContainer
        radius: 28
        border.width: 1
        border.color: Colours.palette.m3outlineVariant
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Rectangle {
                    width: 48
                    height: 48
                    radius: 24
                    color: Colours.palette.m3primaryContainer
                    
                    Text {
                        anchors.centerIn: parent
                        text: "🖼️"
                        font.pixelSize: 28
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "Wallpaper Selector"
                        font.pixelSize: 22
                        font.bold: true
                        color: Colours.palette.m3onSurface
                    }
                    
                    Text {
                        id: countText
                        text: "0 wallpapers"
                        font.pixelSize: 12
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
                
                // Close button
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: 18
                        color: Colours.palette.m3onSurfaceVariant
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Colours.palette.m3surfaceContainerHighest
                        onExited: parent.color = "transparent"
                        onClicked: root.close()
                    }
                }
            }
            
            // Search bar
            Rectangle {
                Layout.fillWidth: true
                height: 48
                color: Colours.palette.m3surfaceContainerHighest
                radius: 24
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    Text { text: "🔍"; font.pixelSize: 18; color: Colours.palette.m3onSurfaceVariant }
                    
                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        placeholderText: "Search wallpaper..."
                        font.pixelSize: 14
                        color: Colours.palette.m3onSurface
                        background: Rectangle { color: "transparent" }
                        
                        onTextChanged: {
                            var filter = text.toLowerCase()
                            var filtered = []
                            for (var i = 0; i < wallpapers.length; i++) {
                                if (wallpapers[i].toLowerCase().includes(filter))
                                    filtered.push(wallpapers[i])
                            }
                            gridView.model = filtered
                            countText.text = filtered.length + " wallpapers"
                        }
                    }
                    
                    Text {
                        text: "✕"
                        font.pixelSize: 14
                        color: Colours.palette.m3onSurfaceVariant
                        visible: searchInput.text !== ""
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchInput.text = ""
                                gridView.model = wallpapers
                                countText.text = wallpapers.length + " wallpapers"
                            }
                        }
                    }
                }
            }
            
            // Thumbnail grid
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                GridView {
                    id: gridView
                    width: parent.width
                    cellWidth: 130
                    cellHeight: 120
                    model: wallpapers
                    
                    delegate: Rectangle {
                        width: 118
                        height: 108
                        color: mouseArea.containsMouse ? Colours.palette.m3surfaceContainerHighest : Colours.palette.m3surfaceContainerHigh
                        radius: 16
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 4
                            
                            Image {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 70
                                source: "file://" + wallpaperDir + modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                radius: 8
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: {
                                    var name = modelData
                                    var dotIndex = name.lastIndexOf('.')
                                    if (dotIndex > 0) name = name.substring(0, dotIndex)
                                    if (name.length > 12) name = name.substring(0, 9) + "..."
                                    return name
                                }
                                color: Colours.palette.m3onSurfaceVariant
                                font.pixelSize: 9
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: setWallpaper(wallpaperDir + modelData)
                        }
                    }
                }
            }
            
            // Action buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 22
                    color: Colours.palette.m3surfaceContainerHighest
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "🎲"; font.pixelSize: 18 }
                        Text { text: "Random"; color: Colours.palette.m3onSurface; font.pixelSize: 14 }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Colours.palette.m3surfaceContainer
                        onExited: parent.color = Colours.palette.m3surfaceContainerHighest
                        onClicked: {
                            Quickshell.execDetached(["waypaper", "--random"])
                            root.close()
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 22
                    color: Colours.palette.m3surfaceContainerHighest
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "📁"; font.pixelSize: 18 }
                        Text { text: "Open Folder"; color: Colours.palette.m3onSurface; font.pixelSize: 14 }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Colours.palette.m3surfaceContainer
                        onExited: parent.color = Colours.palette.m3surfaceContainerHighest
                        onClicked: Quickshell.execDetached(["nautilus", wallpaperDir])
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 22
                    color: Colours.palette.m3surfaceContainerHighest
                    
                    Text {
                        anchors.centerIn: parent
                        text: "ESC"
                        color: Colours.palette.m3onSurface
                        font.pixelSize: 14
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.close()
                    }
                }
            }
        }
    }
    
    Shortcut {
        sequence: "Escape"
        onActivated: root.close()
    }
}
