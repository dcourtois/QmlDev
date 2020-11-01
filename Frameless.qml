import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15


FramelessWindow {
	id: root

	// example menu
	menu: MenuBar {
		background: Rectangle { opacity: 0 }
		Menu {
			title: qsTr("&File")
			Action { text: qsTr("&New...") }
			Action { text: qsTr("&Open...") }
			Action { text: qsTr("&Save") }
			Action { text: qsTr("Save &As...") }
			MenuSeparator { }
			Action { text: qsTr("&Quit") }
		}
	}

	// example title
	title: Label {
		text: "This is a title"
		anchors.fill: parent
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}

	// example content
	content: ColumnLayout {
		anchors.centerIn: parent

		Button {
			text: "Hello"
			onClicked: text = text === "Hello" ? "World" : "Hello"
		}

		// note that ComboBox in Dark theme is buggy: you won't see the text (white on white -_-')
		ComboBox {
			id: accent
			model: [
				"Red",
				"Pink",
				"Purple",
				"DeepPurple",
				"Indigo",
				"Blue",
				"LightBlue",
				"Cyan",
				"Teal",
				"Green",
				"LightGreen",
				"Lime",
				"Yellow",
				"Amber",
				"Orange",
				"DeepOrange",
				"Brown",
				"Grey",
				"BlueGrey",
			]
			onCurrentTextChanged: switch (currentText) {
				case "Red":			root.Material.accent = Material.Red;		break;
				case "Pink":		root.Material.accent = Material.Pink;		break;
				case "Purple":		root.Material.accent = Material.Purple;		break;
				case "DeepPurple":	root.Material.accent = Material.DeepPurple;	break;
				case "Indigo":		root.Material.accent = Material.Indigo;		break;
				case "Blue":		root.Material.accent = Material.Blue;		break;
				case "LightBlue":	root.Material.accent = Material.LightBlue;	break;
				case "Cyan":		root.Material.accent = Material.Cyan;		break;
				case "Teal":		root.Material.accent = Material.Teal;		break;
				case "Green":		root.Material.accent = Material.Green;		break;
				case "LightGreen":	root.Material.accent = Material.LightGreen;	break;
				case "Lime":		root.Material.accent = Material.Lime;		break;
				case "Yellow":		root.Material.accent = Material.Yellow;		break;
				case "Amber":		root.Material.accent = Material.Amber;		break;
				case "Orange":		root.Material.accent = Material.Orange;		break;
				case "DeepOrange":	root.Material.accent = Material.DeepOrange;	break;
				case "Brown":		root.Material.accent = Material.Brown;		break;
				case "Grey":		root.Material.accent = Material.Grey;		break;
				case "BlueGrey":	root.Material.accent = Material.BlueGrey;	break;
			}
		}

		Switch {
			id: theme
			checked: false
			text: checked ? "Dark" : "Light"
			onCheckedChanged: root.Material.theme = checked ? Material.Dark : Material.Light
		}

		Switch {
			checked: false
			text: checked ? "Fullscreen" : "Windowed"
			onCheckedChanged: rootView.fullscreen = checked
		}
	}
}
