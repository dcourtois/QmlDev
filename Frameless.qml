import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.15


Pane {
	id: root

	padding: 0

	Material.accent: Material.Blue
	Material.theme: Material.Dark

	property int borderSize: 10

	Component.onCompleted: {
		rootView.flags |= Qt.FramelessWindowHint;
	}

	component ResizeBorder : Rectangle {
		property var edges: 0
		color: "red"
		DragHandler {
			target: null
			onActiveChanged: if (active) { rootView.startSystemResize(edges); }
		}
	}

	GridLayout {
		anchors {
			fill: parent
			margins: 0
		}

		columnSpacing: 0
		rowSpacing: 0

		columns: 3
		rows: 3

		// upper-left
		ResizeBorder {
			width: borderSize
			height: borderSize
			edges: Qt.LeftEdge | Qt.TopEdge
			color: "blue"
		}

		// upper
		ResizeBorder {
			Layout.fillWidth: true
			height: borderSize
			edges: Qt.TopEdge
		}

		// upper-right
		ResizeBorder {
			width: borderSize
			height: borderSize
			edges: Qt.RightEdge | Qt.TopEdge
			color: "blue"
		}

		// left
		ResizeBorder {
			width: borderSize
			Layout.fillHeight: true
			edges: Qt.LeftEdge
		}

		// center
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true

			// custom title bar
			Rectangle {
				anchors {
					left: parent.left
					top: parent.top
					right: parent.right
				}

				height: 30

				Rectangle {
					anchors {
						top: parent.top
						right: parent.right
					}

					width: 30
					height: 30

					color: "black"

					PointHandler {
						target: null
						onActiveChanged: rootView.close()
					}
				}

				DragHandler {
					target: null
					onActiveChanged: if (active) { rootView.startSystemMove(); }
				}
			}
		}

		// right
		ResizeBorder {
			width: borderSize
			Layout.fillHeight: true
			edges: Qt.RightEdge
		}

		// bottom-left
		ResizeBorder {
			width: borderSize
			height: borderSize
			edges: Qt.LeftEdge | Qt.BottomEdge
			color: "blue"
		}

		// bottom
		ResizeBorder {
			Layout.fillWidth: true
			height: borderSize
			edges: Qt.BottomEdge
		}

		// bottom-right
		ResizeBorder {
			width: borderSize
			height: borderSize
			edges: Qt.RightEdge | Qt.BottomEdge
			color: "blue"
		}

	}

}