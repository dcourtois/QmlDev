#include <QApplication>
#include <QDir>
#include <QFileInfo>
#include <QFileSystemWatcher>
#include <QFontDatabase>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QTimer>

#include "QuickView.h"
#include "Settings.h"


//! The QQuickView instance used to display our QML app
QuickView * view = nullptr;

//! True when the view is loading
bool loading = false;

//! Current dir
QString currentDir = QDir::currentPath();

//! Current exe dir
QString exeDir;

//! Timer used to avoid re-creating the view too many times when multiple file events are sent
QTimer timer;

//! Instance of the settings
Settings * settings = nullptr;

//! The errors
QString errors;

//!
//! Capture errors
//!
void messageHandler(QtMsgType type, const QMessageLogContext &, const QString & message)
{
	// only get the errors / warnings (QML compile errors are sent as warnings...)
	bool error = false;
	switch (type)
	{
		case QtWarningMsg:
		case QtCriticalMsg:
		case QtFatalMsg:
			error = true;
			errors += message + "\n";
			break;
	}

	// log to either Visual Studio debug output or the standard output, we're still interested
	// in console.log and such
#ifdef OutputDebugString
	OutputDebugStringA(qPrintable(message + "\n"));
#else
	printf("%s\n", qPrintable(message));
#endif

	// if we get a warning during runtime, reload to show it
	if (loading == false && error == true)
	{
		timer.start(100);
	}
}

//!
//! Set the application engine with our main QML file
//!
void setup(void)
{
	// delete the previous view
	if (view != nullptr)
	{
		// cleanup the previous view
		qInstallMessageHandler(nullptr);
		view->close();
		delete view;
		view = nullptr;
	}

	// re-create the view
	view = new QuickView();
	auto * engine = view->engine();
	loading = true;
	qInstallMessageHandler(messageHandler);

	// add import paths
	engine->addImportPath(currentDir);
	engine->addImportPath(exeDir);

	// set the source, only if we don't have errors already
	if (errors.isEmpty() == true)
	{
		view->setSource(QUrl::fromLocalFile("Main.qml"));
	}

	// check for errors
	if (errors.isEmpty() == false)
	{
		// just to be sure
		view->close();

		// display the errors
		engine->rootContext()->setContextProperty("fixedFont", QFontDatabase::systemFont(QFontDatabase::FixedFont));
		engine->rootContext()->setContextProperty("errors", errors);
		view->setSource(QUrl::fromLocalFile("Error.qml"));
		errors.clear();
	}

	// done loading
	loading = false;

	// raise
	view->raise();
	view->requestActivate();
}

//!
//! Recursively watch everything
//!
void watch(QFileSystemWatcher & watcher, QDir directory)
{
	watcher.addPath(directory.currentPath());
	for (const auto & name : directory.entryList())
	{
		if (name.startsWith(".") == false)
		{
			QString file = directory.absoluteFilePath(name);
			QFileInfo(file).isDir() == true ?
				watch(watcher, QDir(file)) :
				(void)watcher.addPath(file);
		}
	}
}

//!
//! Entry point of the application
//!
int main(int argc, char *argv[])
{
	int code = -1;
	{
		// create and setup the application
		QApplication app(argc, argv);
		app.setOrganizationName("Citron");
		app.setOrganizationDomain("Citron.org");
		app.setApplicationName("QmlTestBed");
		app.setApplicationVersion("0.2");

		// init the settings
		settings = new Settings();

		// get the application directory
		exeDir = QApplication::applicationDirPath();

		// set style
		QQuickStyle::setStyle("Material");

		// initialize the application engine
		setup();

		// install a file system watcher to be able to hot-reload the QML when it changes
		QFileSystemWatcher watcher;
		watch(watcher, exeDir);
		watch(watcher, currentDir);
		timer.callOnTimeout(setup);
		timer.setSingleShot(true);
		QObject::connect(&watcher, &QFileSystemWatcher::directoryChanged, [] (const QString &) { timer.start(100); });
		QObject::connect(&watcher, &QFileSystemWatcher::fileChanged, [] (const QString &) { timer.start(100); });

		// run the application
		code = app.exec();

		// cleanup
		delete view;
		delete settings;
	}

	return code;
}
