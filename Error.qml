import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
	ScrollView {
		anchors.fill: parent
		Text {
			padding: 20
			font: fixedFont
			text: errors
		}
	}
}
