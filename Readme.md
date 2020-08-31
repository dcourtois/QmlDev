Qml Dev
-------

[![](https://github.com/dcourtois/QmlDev/workflows/Continuous%20Integration/badge.svg)](https://github.com/dcourtois/QmlDev/actions)

This little project is a hot-reload test-bed for QML applications. This means that you run once, and then can
edit your QML application during runtime. As soon as you save, the app is reloaded, taking your changes into
account. Compilation / runtime errors are dynamically shown in place of the application if needed:

![demo](https://github.com/dcourtois/Images/raw/master/QmlDev/qmldev.gif)

Build
-----

It's built using CMake or any IDE supporting it.
Tested:

- [Visual Studio 2019](https://visualstudio.microsoft.com/vs/community/) (2017 is also supported)
- [Visual Studio Code](https://code.visualstudio.com/download) (requires C/C++ and CMake Tools extensions)
- [QtCreator](https://www.qt.io/download)

The project includes example configuration files for Visual Studio Code and 2019. You just need to update the
path to Qt library in their launch settings (in `.vscode/settings.json` for Code and `.vs/launch.vs.json` for
201x)
The path to the Qt libraries is located in `CMakeLists.txt` and setup for my installs, but you can easily
use your own by setting the `QT_DIR` CMake variable when configuring (e.g. run `cmake` with `-DQT_DIR=<path_to_qt>`
while configuring)

Usage
-----

Once built, run it and it will try to load a `Main.qml` file from the current working directory, and if not
found, from the executable's directory.

If it succeeds, the app will show, and a file watcher will listen for any modification of any file / directory
in the current working directory or the executable's directory. When something changes, it will re-load the `Main.qml`
file (so it's advised to create an empty workspace to avoid other file modifications to trigger the reloading)

This allows live development of quick QML test applications.

In case of error, an `Error.qml` file will be loaded in the same way as `Main.qml` (e.g. tries loading it
from the current working directory, and if not found, from the exeuctable's directory)
The provided `Error.qml` file displays the QML errors that prevented `Main.qml` to be correctly loaded.

You can customize `Error.qml` as long as you make absolutely certain it's valid QML. 2 context properties
are made available:

- `fixedFont`: system's default fixed width font (returned by QFontDatabase::systemFont(QFontDatabase::FixedFont))
- `errors`: a string containing the QQuickView's errors that happened while loading `Main.qml`

This project being based on [QtUtils](https://github.com/dcourtois/QtUtils) I also made a few utilities
globally available:

- `rootView`: the main [QuickView](https://github.com/dcourtois/QtUtils/blob/master/API.md#class-quickview) instance
- `settings`: global instance of the [Settings](https://github.com/dcourtois/QtUtils/blob/master/API.md#class-settings) class.
- `file`: global instance of the [File](https://github.com/dcourtois/QtUtils/blob/master/API.md#class-file) class.

Options
-------

The executable supports a few options to allow overriding the application (in C++, so no hot-reload there)

- `--style <style>`: by default, the style used is `Material`, you can override that with this option.
- `--transparent`: if you want to experiment with transparent / frameless QML applications, use this flag,
and in the root QML item's `Component.onCompleted` callback, set the `rootView`'s flags to `Qt.Window | Qt.WindowlessHint`)
- `--backend <backend>`: override the default backend used to render the QQuick scene.
- `--app <file.qml>`: override the name of the main QML file which is loaded (the `Main.qml` file)

Use the `--help` option to display a bit more informations.

Contributing
------------

Feel free to open an issue if you find some bugs, broken things, or have an idea of a an interesting feature
you'd like to see implemented.
