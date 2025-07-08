
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QStringList>
#include <QDebug>
#include "PlayerController.h"
#include "MusicScanner.h"
#include "playlist.h"
#include "backendmanager.h"
#include "song.h"
#include "LyricsExtractor.h"

// 设置项目根目录地址
QString appDir = QString(PROJECT_ROOT_DIR);

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 为了稳定性，BackendManager仍使用手动初始化和注册
    // 其他类使用QML_ELEMENT自动注册
    BackendManager *backend = BackendManager::instance();
    qDebug() << "手动创建BackendManager实例";

    if (!backend->initialize())
    {
        qCritical() << "Failed to initialize BackendManager";
        return -1;
    }

    qDebug() << "BackendManager手动初始化完成，songModel数据量:" << backend->songModel()->rowCount();

    QQmlApplicationEngine engine;

    // BackendManager手动注册，其他类使用QML_ELEMENT自动注册 
    qmlRegisterSingletonInstance("qmltest", 1, 0, "BackendManager", backend);
    qDebug() << "使用混合注册: BackendManager手动注册 + 其他类QML_ELEMENT自动注册";

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
