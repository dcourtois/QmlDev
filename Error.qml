import QtQuick 2.3
import QtQuick.Window 2.2
import Qt.labs.settings 1.0

Item {
	id: root

	Settings {
		category: "errors"
		property alias x: root.x
		property alias y: root.y
		property alias width: root.width
		property alias height: root.height
	}

	width: 1000
	height: 500

	Text {
		anchors.fill: parent
		anchors.topMargin: 10
		anchors.leftMargin: 10
		font: fixedFont
		text: errors
	}
}
