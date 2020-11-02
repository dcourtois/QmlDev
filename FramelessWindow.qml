import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.3


// Make the main window a Pane to be able to inherit from the Material themes
Pane {
	id: root

	//! This is the height of the header (which contains the menu, title and minimize/maximize/close buttons)
	//! It's a pain in this ass in QML to correctly size things due du cyclic dependencies, so to avoid bloating
	//! the code, the simplest is to define this here. For Material themed, this is usually set to 40, but you
	//! override if you use a custom theme.
	property int headerHeight: 40

	//! This is the place where you put your main menu
	property alias menu: menuPlaceholder.children

	//! This is where you put your application title
	property alias title: titlePlaceholder.children

	//! This is where you put your main content
	property alias content: contentPlaceholder.children

	// remove spacing and padding
	padding: 0
	spacing: 0

	// remove the frame of the main window
	Component.onCompleted: {
		rootView.flags |= Qt.FramelessWindowHint;
	}

	// This controls the size of the handles used to resize the window. And the inset are
	// necessary to leave a transparent area for the handles.
	property int borderSize: rootView.visibility === Window.Windowed && rootView.fullscreen === false ? 10 : 0
	topInset: borderSize
	bottomInset: borderSize
	leftInset: borderSize
	rightInset: borderSize

	// This is a reusable component used to handle risizing. It's basically a transparent rectangle with a
	// MouseArea which is used to simulate the way a usual desktop window is resized
	component ResizeHandle : Rectangle {
		width: edges & (Qt.LeftEdge | Qt.RightEdge) ? root.borderSize : undefined
		height: edges & (Qt.TopEdge | Qt.BottomEdge) ? root.borderSize : undefined
		property var edges: 0
		property var cursor: Qt.ArrowCursor
		enabled: root.borderSize !== 0
		color: Qt.rgba(0, 0, 0, 0)
		opacity: 0
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

	// Reusable component used to display the 3 buttons on the top-right corner of the window (the minimize, maximize and close ones)
	// Note: I coulnd't find any way to correctly customize existing controls, thus this custom one
	component SquareToolButton : ToolButton {
		id: control
		implicitWidth: implicitHeight + 10
		implicitHeight: headerHeight
		padding: 0
		spacing: 0
		property bool close: false
		Material.foreground: close && hovered && Material.theme === Material.Light ? Material.background : undefined
		background: Rectangle {
			color: control.close ? Qt.rgba(1, 0, 0, 1) : (Material.theme === Material.Dark ? Qt.rgba(1, 1, 1, 1) : Qt.rgba(0, 0, 0, 1))
			opacity: control.hovered ? (control.close ? 0.7 : 0.2) : 0
		}
	}

	//
	// The following are the resizing borders and corners
	//

	// upper-left
	ResizeHandle {
		id: upperLeft
		anchors { left: parent.left; top: parent.top }
		edges: Qt.LeftEdge | Qt.TopEdge
		cursor: Qt.SizeFDiagCursor
	}

	// upper
	ResizeHandle {
		id: upper
		anchors { left: upperLeft.right; top: parent.top; right: upperRight.left }
		edges: Qt.TopEdge
		cursor: Qt.SizeVerCursor
	}

	// upper-right
	ResizeHandle {
		id: upperRight
		anchors { top: parent.top; right: parent.right }
		edges: Qt.RightEdge | Qt.TopEdge
		cursor: Qt.SizeBDiagCursor
	}

	// right
	ResizeHandle {
		id: right
		anchors { top: upperRight.bottom; right: parent.right; bottom: bottomRight.top }
		edges: Qt.RightEdge
		cursor: Qt.SizeHorCursor
	}

	// bottom-right
	ResizeHandle {
		id: bottomRight
		anchors { right: parent.right; bottom: parent.bottom }
		edges: Qt.RightEdge | Qt.BottomEdge
		cursor: Qt.SizeFDiagCursor
	}

	// bottom
	ResizeHandle {
		id: bottom
		anchors { left: bottomLeft.right; bottom: parent.bottom; right: bottomRight.left }
		edges: Qt.BottomEdge
		cursor: Qt.SizeVerCursor
	}

	// bottom-left
	ResizeHandle {
		id: bottomLeft
		anchors { left: parent.left; bottom: parent.bottom }
		edges: Qt.LeftEdge | Qt.BottomEdge
		cursor: Qt.SizeBDiagCursor
	}

	// left
	ResizeHandle {
		id: left
		anchors { left: parent.left; top: upperLeft.bottom; bottom: bottomLeft.top }
		edges: Qt.LeftEdge
		cursor: Qt.SizeHorCursor
	}

	// Custom title bar. This is a row with a menu on the left, and central item where you can
	// set a title, and the right part where the 3 buttons controlling the window are located.
	RowLayout {
		id: header
		height: headerHeight

		anchors {
			top: upper.bottom
			left: left.right
			right: right.left
		}

		spacing: 0

		// The main menu
		Item {
			id: menuPlaceholder
			width: childrenRect.width
			height: headerHeight
		}

		// The title
		Item {
			Layout.fillWidth: true
			height: headerHeight
			Item {
				anchors.centerIn: parent
				id: titlePlaceholder
			}
			MouseArea {
				anchors.fill: parent
				onPressed: rootView.startSystemMove()
				onDoubleClicked: rootView.maximized = !rootView.maximized
			}
		}

		// The buttons used to minimize, maximize and close the application
		SquareToolButton {
			id: minimizeButton
			text: "🗕"
			font.pixelSize: Qt.application.font.pixelSize * 1.5
			onClicked: rootView.showMinimized()
		}
		SquareToolButton {
			id: maximizeButton
			text: rootView.maximized ? "🗗" : "🗖"
			font.pixelSize: Qt.application.font.pixelSize * 1.5
			onClicked: rootView.maximized = !rootView.maximized
		}
		SquareToolButton {
			id: closeButton
			text: "🗙"
			close: true
			font.pixelSize: Qt.application.font.pixelSize * 1.5
			onClicked: rootView.close()
		}
	}

	// And finally, the content
	Item {
		id: contentPlaceholder
		anchors {
			margins: 0
			top: header.bottom
			bottom: bottom.top
			left: left.right
			right: right.left
		}
	}
}
