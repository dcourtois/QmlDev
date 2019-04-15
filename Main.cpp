#include <QApplication>
#include <QDir>
#include <QFileInfo>
#include <QFileSystemWatcher>
#include <QFontDatabase>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickView>
#include <QSettings>
#include <QTimer>


//! The QQuickView instance used to display our QML app
QQuickView * view = nullptr;

//! True when the view is loading
bool loading = false;

//! Current dir
QString currentDir = QDir::currentPath();

//! Current exe dir
QString exeDir;

//! Timer used to avoid re-creating the view too many times when multiple file events are sent
QTimer timer;

//! Settings to store and restore the view settings
QSettings * settings = nullptr;

//! The errors
QString errors;

// forward declaration
void messageHandler(QtMsgType type, const QMessageLogContext &, const QString & message);

//!
//! Set the application engine with our main QML file
//!
void setup(bool error = false)
{
	// delete the previous view
	if (view != nullptr)
	{
		// backup settings
		settings->setValue("x", view->position().x());
		settings->setValue("y", view->position().y());
		settings->setValue("w", view->size().width());
		settings->setValue("h", view->size().height());

		// cleanup the previous view
		qInstallMessageHandler(nullptr);
		view->close();
		delete view;
		view = nullptr;
	}

	// re-create the view
	view = new QQuickView();
	auto * engine = view->engine();
	qInstallMessageHandler(messageHandler);

	// add import paths
	engine->addImportPath(currentDir);
	engine->addImportPath(exeDir);

	// set the source
	if (error == false)
	{
		loading = true;
		errors.clear();
		view->setSource(QUrl::fromLocalFile("Main.qml"));
		loading = false;
	}

	// check for errors
	if (errors.isEmpty() == false)
	{
		// just to be sure
		view->close();

		// display the errors
		errors = QString("Error %1 'Main.qml':\n\n%2").arg(error ? "executing" : "loading").arg(errors);
		engine->rootContext()->setContextProperty("fixedFont", QFontDatabase::systemFont(QFontDatabase::FixedFont));
		engine->rootContext()->setContextProperty("errors", errors);
		view->setSource(QUrl::fromLocalFile("Error.qml"));
		errors.clear();
	}

	// apply settings
	view->setPosition(
		qMax(100, settings->value("x", view->position().x()).toInt()),
		qMax(100, settings->value("y", view->position().y()).toInt())
	);
	view->resize(
		qMax(400, settings->value("w", view->size().width()).toInt()),
		qMax(200, settings->value("h", view->size().height()).toInt())
	);

	// raise
	view->show();
	view->raise();
	view->requestActivate();
}

//!
//! Capture errors
//!
void messageHandler(QtMsgType type, const QMessageLogContext &, const QString & message)
{
	// only get the errors / warnings (QML compile errors are sent as warnings...)
	switch (type)
	{
		case QtWarningMsg:
		case QtCriticalMsg:
		case QtFatalMsg:
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
	if (loading == false && errors.isEmpty() == false)
	{
		QTimer::singleShot(100, [] (void) { setup(true); });
	}
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
				watcher.addPath(file);
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

		// get the application directory
		exeDir = QApplication::applicationDirPath();

		// create the settings
		settings = new QSettings(QSettings::IniFormat, QSettings::UserScope, "Citron", "QmlTestBed");

		// set style
		QQuickStyle::setStyle("Material");

		// initialize the application engine
		setup();

		// install a file system watcher to be able to hot-reload the QML when it changes
		QFileSystemWatcher watcher;
		watch(watcher, exeDir);
		watch(watcher, currentDir);
		timer.callOnTimeout([&] () { setup(); });
		timer.setSingleShot(true);
		QObject::connect(&watcher, &QFileSystemWatcher::directoryChanged, [] (const QString &) { timer.start(100); });
		QObject::connect(&watcher, &QFileSystemWatcher::fileChanged, [] (const QString &) { timer.start(100); });

		// run the application
		code = app.exec();

		// settings
		settings->setValue("x", view->position().x());
		settings->setValue("y", view->position().y());
		settings->setValue("w", view->size().width());
		settings->setValue("h", view->size().height());

		// cleanup
		delete view;
		delete settings;
	}

	return code;
}
