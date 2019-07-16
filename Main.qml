import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12


Pane {
	id: root

	Material.accent: Material.Blue
	Material.theme: theme.checked ? Material.Dark : Material.Light

	ColumnLayout {
		anchors.centerIn: parent

		Button {
			text: "Hello"
			onClicked: text = text === "Hello" ? "World" : "Hello"
		}

		Switch {
			id: theme
			checked: true
			text: checked ? "Dark" : "Light"
		}

	}

}
