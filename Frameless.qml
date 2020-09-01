import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.15


Item {
	id: root

	property int borderSize: 10

	Component.onCompleted: {
		rootView.flags |= Qt.FramelessWindowHint;
	}

	component ResizeBorder : Rectangle {
		property var edges: 0
		property var cursor: Qt.ArrowCursor
		color: Qt.rgba(0, 0, 0, 0)
		MouseArea {
			anchors.fill: parent
			hoverEnabled: true
			onEntered: cursorShape = parent.cursor
			onExited: cursorShape = Qt.ArrowCursor
			onPressed: {
				mouse.accepted = true;
				rootView.startSystemResize(parent.edges);
			}
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
			cursor: Qt.SizeFDiagCursor
		}

		// upper
		ResizeBorder {
			Layout.fillWidth: true
			height: borderSize
			edges: Qt.TopEdge
			cursor: Qt.SizeVerCursor
		}

		// upper-right
		ResizeBorder {
			width: borderSize
			height: borderSize
			edges: Qt.RightEdge | Qt.TopEdge
			cursor: Qt.SizeBDiagCursor
		}

		// left
		ResizeBorder {
			width: borderSize
			Layout.fillHeight: true
			edges: Qt.LeftEdge
			cursor: Qt.SizeHorCursor
		}

		// center
		Pane {
			Layout.fillWidth: true
			Layout.fillHeight: true

			padding: 0

			Material.accent: Material.Blue
			Material.theme: Material.Dark

			// custom title bar
			Rectangle {
				anchors {
					left: parent.left
					top: parent.top
					right: parent.right
				}

				height: 30

				MouseArea {
					anchors.fill: parent
					onPressed: {
						mouse.accepted = true;
						rootView.startSystemMove();
					}
				}

				Rectangle {
					anchors {
						top: parent.top
						right: parent.right
					}

					width: 30
					height: 30

					color: "black"

					MouseArea {
						anchors.fill: parent
						onPressed: rootView.close()
					}
				}

			}
		}

		// right
		ResizeBorder {
			width: borderSize
			Layout.fillHeight: true
			edges: Qt.RightEdge
			cursor: Qt.SizeHorCursor
		}

		// bottom-left
		ResizeBorder {
			width: borderSize
			height: borderSize
			edges: Qt.LeftEdge | Qt.BottomEdge
			cursor: Qt.SizeBDiagCursor
		}

		// bottom
		ResizeBorder {
			Layout.fillWidth: true
			height: borderSize
			edges: Qt.BottomEdge
			cursor: Qt.SizeVerCursor
		}

		// bottom-right
		ResizeBorder {
			width: borderSize
			height: borderSize
			edges: Qt.RightEdge | Qt.BottomEdge
			cursor: Qt.SizeFDiagCursor
		}

	}

}