#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include "backendmanager.h"

BackendManager *BackendManager::s_instance = nullptr;

BackendManager::BackendManager(QObject *parent)
    : QObject(parent)
    , m_dbManager(nullptr)
    , m_scanner(nullptr)
    , m_playerController(nullptr)
    , m_songModel(nullptr)
    , m_playlistModel(nullptr)
{}

BackendManager *BackendManager::instance()
{
    if (!s_instance) { s_instance = new BackendManager(); }
    return s_instance;
}

QObject *BackendManager::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine) // 标记参数未使用，避免编译器警告
    Q_UNUSED(scriptEngine)
    return instance();
}

bool BackendManager::initialize()
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    // QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/MusicDatas.db";
    // QDir().mkpath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    // db.setDatabaseName(dbPath);

    // 路径有错
    // QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    // QDir().mkpath(dbPath); // 确保目录存在
    // db.setDatabaseName(dbPath + "/MusicDatas.db");

    db.setDatabaseName("/root/qmlMusic-dev/qmlMusic/sql/MusicDatas.db"); // 使用内存数据库测试
    if (!db.open()) {
        //qCritical() << "无法打开数据库:" << db.lastError().text();
        qCritical() << "数据库路径:";
        return false;
    }

    // 创建DatabaseManager实例
    m_dbManager = new DatabaseManager(db, this);
    if (!m_dbManager->isDatabaseValid()) {
        qCritical() << "Database connection is invalid";
        return false;
    }

    Song *song = m_dbManager->getSong(1);
    qDebug() << "从数据库提取";
    //qDebug() << "从数据库提dsadasdas取";
    if (!song) { qDebug() << "歌曲为空"; }
    qDebug() << song->title() << song->artist();

    // 初始化音乐扫描器
    m_scanner = new MusicScanner(this);

    // 初始化播放控制器
    // m_playerController = new PlayerController(this);

    // 初始化数据模型
    m_songModel = new SongModel(this);
    m_playlistModel = new PlaylistModel(this);

    // 连接信号
    connectSignals();

    // 加载现有数据
    // loadSongLibrary();
    // loadAllPlaylists();

    emit initialized();
    return true;
}

void BackendManager::scanMusicLibrary(const QStringList &directories)
{
    if (!m_scanner) {
        qDebug() << "Scanner not initialized";
        return;
    }
    // directories每个元素若含file://前缀的路径,需要去除

    // QUrl::toLocalFile(directories);
    // qDebug() << "!!!!!!!!!!!!!!!!!!!!!!!!!BackendManager startScan directories: " << directories;

    m_scanner->startScan(directories);
}

void BackendManager::playSongById(int songId) {}

void BackendManager::playPlaylist(int playlistId) {}

//Playlist *BackendManager::createPlaylist(const QString &name, const QString &description) {}

void BackendManager::onScanFinished(const QList<Song *> &foundSongs)
{
    // if (!m_dbManager || !m_songModel)
    // {
    //     return;
    // }
    // QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

    m_songModel->loadSongs(foundSongs);
}

// void BackendManager::onCurrentSongChanged()
// {

// }

// void BackendManager::loadAllPlaylists()
// {

// }

// void BackendManager::loadSongLibrary()
// {

// }

void BackendManager::connectSignals()
{
    // 连接扫描器信号
    // connect(m_scanner, &MusicScanner::scanProgress, this, &BackendManager::scanProgressChanged);
    connect(m_scanner, &MusicScanner::scanFinished, this, &BackendManager::onScanFinished);

    // 连接播放器信号
    // connect(m_playerController, &PlayerController::currentSongChanged, this, &BackendManager::onCurrentSongChanged);
    // connect(m_playerController, &PlayerController::positionChanged, m_lyricsModel, &LyricsModel::updateCurrentLine);
}
