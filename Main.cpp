#include <QApplication>
#include <QCommandLineOption>
#include <QCommandLineParser>
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
#include "File.h"


//! The QQuickView instance used to display our QML app
QuickView * view = nullptr;

//! True when the view is loading
bool loading = false;

//! Get the system's fixed font
QFont fixedFont = QFontDatabase::systemFont(QFontDatabase::FixedFont);

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

//! Transparent option
bool transparent = false;

//! Instance of the settings
File * fileHelper = nullptr;


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
//! Get a file from (first) the working directory, and if not found, from the
//! executable folder.
//!
QUrl findFile(const QString & file)
{
	if (QDir(currentDir).exists(file) == true)
	{
		return QUrl::fromLocalFile(QDir(currentDir).filePath(file));
	}
	else if (QDir(exeDir).exists(file) == true)
	{
		return QUrl::fromLocalFile(QDir(exeDir).filePath(file));
	}
	return QUrl();
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
		// set options
		if (transparent == true)
		{
			view->setDefaultAlphaBuffer(true);
			view->setColor(Qt::transparent);
		}

		// expose a few usefull things
		engine->rootContext()->setContextProperty("rootView", view);
		engine->rootContext()->setContextProperty("fixedFont", fixedFont);
		engine->rootContext()->setContextProperty("file", fileHelper);
		engine->rootContext()->setContextProperty("settings", settings);

		// set the source
		view->setSource(findFile("Main.qml"));
	}

	// check for errors
	if (errors.isEmpty() == false)
	{
		// recreate the view, it's the easiest way to restore its default state: at this
		// point, the users might have changed the window flags, default color, transparency,
		// etc. And reading errors on a transparent window is kinda hard
		view->close();
		delete view;
		view = new QuickView();
		engine = view->engine();

		// display the errors
		engine->rootContext()->setContextProperty("fixedFont", fixedFont);
		engine->rootContext()->setContextProperty("errors", errors);
		view->setSource(findFile("Error.qml"));
		errors.clear();
	}

	// done loading
	loading = false;

	// restore and raise
	view->Restore(800, 600, QWindow::Visibility::Windowed);
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
//! Process the command line arguments
//!
void options(int argc, char ** argv)
{
	// command line
	QCommandLineParser parser;
	parser.setApplicationDescription("QmlDev");
	parser.addHelpOption();
	parser.addVersionOption();
	parser.addOption(QCommandLineOption("transparent", "Create a transparent window. This allows to test frameless QML application."));
	parser.addOption(QCommandLineOption("style", "Override the default `Material` style. See Qt's QQuickStyle::setStyle documentation.", "style", "Material"));
	parser.addOption(QCommandLineOption("backend", "Override the default QQuick rendering backend. See Qt's QQuickWindow::setSceneGraphBackend documentation.", "backend"));

	// get the arguments manually (we disabled QApplication's access to them to avoid
	// the default arguments to mix with ours)
	QStringList arguments;
	for (int i = 0; i < argc; ++i)
	{
		arguments << argv[i];
	}

	// process
	parser.process(arguments);

	// style (Material by default, no need to check if it's set)
	QQuickStyle::setStyle(parser.value("style"));

	// backend
	if (parser.isSet("backend") == true)
	{
		QQuickWindow::setSceneGraphBackend(parser.value("backend"));
	}

	// transparency (used in setup())
	if (parser.isSet("transparent") == true)
	{
		transparent = true;
	}
}

//!
//! Entry point of the application
//!
int main(int argc, char ** argv)
{
	int code = -1;
	{
		// create and setup the application (note that we disable arguments to avoid
		// QApplication handling our command line arguments)
		int dummyArgc = 1;
		QApplication app(dummyArgc, argv);
		app.setOrganizationName("Citron");
		app.setOrganizationDomain("Citron.org");
		app.setApplicationName("QmlDev");
		app.setApplicationVersion("0.3");

		// process options
		options(argc, argv);

		// init some helpers
		settings = new Settings();
		fileHelper = new File();

		// get the application directory
		exeDir = QApplication::applicationDirPath();

		// initialize the application engine
		setup();
		Q_ASSERT(view != nullptr);

		// install a file system watcher to be able to hot-reload the QML when it changes
		// note: we're using a timer to avoid too many reloads
		QFileSystemWatcher watcher;
		watch(watcher, exeDir);
		watch(watcher, currentDir);
		timer.callOnTimeout(setup);
		timer.setSingleShot(true);
		QObject::connect(&watcher, &QFileSystemWatcher::directoryChanged, [&] (const QString & name) {
			watch(watcher, name);
			timer.start(250);
		});
		QObject::connect(&watcher, &QFileSystemWatcher::fileChanged, [] (const QString & name) {
			Q_UNUSED(name);
			timer.start(250);
		});

		// run the application
		code = app.exec();

		// cleanup
		delete view;
		delete settings;
		delete fileHelper;
	}

	return code;
}
