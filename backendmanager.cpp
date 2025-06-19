#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include "backendmanager.h"

BackendManager *BackendManager::s_instance = nullptr;

BackendManager::BackendManager(QObject *parent)
    :QObject(parent)
    ,m_scanner(nullptr)
    ,m_playerController(nullptr)
    ,m_songModel(nullptr)
    ,m_playlistModel(nullptr)
{}

BackendManager *BackendManager::instance()
{
    if (!s_instance)
    {
        s_instance = new BackendManager();
    }
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
    if (!m_scanner)
    {
        qDebug() << "Scanner not initialized";
        return;
    }
    // directories每个元素若含file://前缀的路径,需要去除

    // QUrl::toLocalFile(directories);
    // qDebug() << "!!!!!!!!!!!!!!!!!!!!!!!!!BackendManager startScan directories: " << directories;

    m_scanner->startScan(directories);
}

void BackendManager::playSongById(int songId)
{

}

void BackendManager::playPlaylist(int playlistId)
{

}

Playlist *BackendManager::createPlaylist(const QString &name, const QString &description)
{

}

void BackendManager::onScanFinished(const QList<Song *> &foundSongs)
{
    // if (!m_dbManager || !m_songModel)
    // {
    //     return;
    // }

    // QList<Song *> songs = m_dbManager->getAllSongs();
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

