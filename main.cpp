
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include "PlayerController.h"
#include "MusicScanner.h"
#include "playlist.h"
#include "backendmanager.h"
#include "song.h"


//设置项目根目录地址
QString appDir = QString(PROJECT_ROOT_DIR);

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    //关键: 在qml引擎创建前 初始化管理器
    BackendManager *backend = BackendManager::instance();
    qDebug() << "backmanager初始化完成";

    if (!backend->initialize())
    {
        qCritical() << "Failed to initialize BackendManager";
        return -1;
    }

    qDebug() << "BackendManager 初始化完成，songModel 数据量:" << backend->songModel()->rowCount();
    qDebug() << "BackendManager 地址:" << backend;
    qDebug() << "songModel 地址:" << backend->songModel();

    QQmlApplicationEngine engine;

    // 手动注册 BackendManager 为单例
    qmlRegisterSingletonInstance("qmltest", 1, 0, "BackendManager", backend);
    qDebug() << "手动注册 BackendManager 单例到 QML";

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("qmltest", "Main");


    return app.exec();
}
