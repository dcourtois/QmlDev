import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
	Button {
		anchors.centerIn: parent
		text: "Click Me To Toggle Fullscreen"
		onClicked: rootView.fullscreen = !rootView.fullscreen
	}
}
