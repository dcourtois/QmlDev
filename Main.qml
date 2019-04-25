import QtQuick 2.12
import QtQuick.Controls 2.12


Item {
	id: root

	Button {
		anchors.centerIn: parent
		text: "Hello"
		onClicked: text = text === "Hello" ? "World" : "Hello"
	}
}
