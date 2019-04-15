Qml Dev
-------

This little project is a hot-reload test-bed for QML applications. It's built using CMake or any IDE supporting it.
Tested:

- [Visual Studio 2019](https://visualstudio.microsoft.com/vs/community/) (2017 is also supported)
- [Visual Studio Code](https://code.visualstudio.com/download) (requires C/C++ and CMake Tools extensions)
- [QtCreator](https://www.qt.io/download)

The project includes configuration files for Visual Studio Code and 2019. You might need to update the
path to Qt library in those setting files and the `CMakeLists.txt` file. This can be done by using
`-DQT_DIR=<path_to_qt_cmake_dir>` while configuring.

Once built, run it and it will try to load a `Main.qml` file from the current working directory, or the directory
where the executable is located (in case both are different)

If it succeeds, the app will show, and a file watcher will listen for any modification of any file / directory
in the current working directory or the executable's directory, and in such case, it will re-load the `Main.qml`
file (so it's advised to create an empty workspace to avoid other file modifications to trigger the reloading)

This allows live development of quick QML test applications.

In case of error, the `Error.qml` file will be loaded from the same directories as the `Main.qml` one
(it **must** be found, or else the `qmldev` process won't show anything and won't stop by itself)
The provided `Error.qml` file displays the QML errors that prevented `Main.qml` to be correctly loaded.

You can customize `Error.qml` as long as you make absolutely certain it's valid QML. 2 context properties
are made available:

- fixedFont: system's default fixed width font (returned by QFontDatabase::systemFont(QFontDatabase::FixedFont))
- errors: a string containing the QQuickView's errors that happened while loading `Main.qml`
