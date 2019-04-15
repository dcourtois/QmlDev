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

//!
//! Capture errors
//!
void messageHandler(QtMsgType type, const QMessageLogContext &, const QString & message)
{
	switch (type)
	{
		case QtWarningMsg:
		case QtCriticalMsg:
		case QtFatalMsg:
			errors += message + "\n";
			break;
	}
}

//!
//! Set the application engine with our main QML file
//!
void setup(QQuickView *& view)
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
		view->close();
		delete view;
	}

	// re-create the view
	view = new QQuickView();
	auto * engine = view->engine();

	// add import paths
	engine->addImportPath(currentDir);
	engine->addImportPath(exeDir);

	// set the source
	errors.clear();
	qInstallMessageHandler(messageHandler);
	view->setSource(QUrl::fromLocalFile("Main.qml"));
	qInstallMessageHandler(nullptr);

	// check for errors
	if (errors.isEmpty() == false)
	{
		// just to be sure
		view->close();

		// display the errors
		engine->rootContext()->setContextProperty("fixedFont", QFontDatabase::systemFont(QFontDatabase::FixedFont));
		engine->rootContext()->setContextProperty("errors", errors);
		view->setSource(QUrl::fromLocalFile("Error.qml"));
	}

	// apply settings
	view->setPosition(
		qMax(50, settings->value("x", view->position().x()).toInt()),
		qMax(50, settings->value("y", view->position().y()).toInt())
	);
	view->resize(
		qMax(100, settings->value("w", view->size().width()).toInt()),
		qMax(100, settings->value("h", view->size().height()).toInt())
	);

	// raise
	view->show();
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
		QApplication app(argc, argv);
		app.setOrganizationName("Citron");
		app.setOrganizationDomain("Citron.org");
		app.setApplicationName("QmlTestBed");
		app.setApplicationVersion("0.2");
		exeDir = QApplication::applicationDirPath();
		settings = new QSettings(QSettings::IniFormat, QSettings::UserScope, "Citron", "QmlTestBed");

		// set style
		QQuickStyle::setStyle("Material");

		// initialize the application engine
		QQuickView * view = nullptr;
		setup(view);

		// install a file system watcher to be able to hot-reload the QML when it changes
		QFileSystemWatcher watcher;
		watch(watcher, exeDir);
		watch(watcher, currentDir);
		timer.callOnTimeout([&] (void) { setup(view); });
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
