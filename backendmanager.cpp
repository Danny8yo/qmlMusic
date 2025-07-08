#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include "backendmanager.h"
#include "localsongmodel.h"
#include <QCoreApplication>

extern QString appDir;

BackendManager *BackendManager::s_instance = nullptr;

BackendManager::BackendManager(QObject *parent)
    : QObject(parent), m_dbManager(nullptr), m_scanner(nullptr), m_playerController(nullptr), m_songModel(nullptr), m_localSongModel(nullptr), m_playlistModel(nullptr), m_lyricsExtractor(nullptr)
{
}

BackendManager *BackendManager::instance()
{
    if (!s_instance)
    {
        s_instance = new BackendManager();
    }
    return s_instance;
}

BackendManager *BackendManager::create(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    BackendManager *backend = instance();

    // QML_SINGLETON首次创建时自动初始化
    static bool initialized = false;
    if (!initialized)
    {
        qDebug() << "QML_SINGLETON首次创建BackendManager，开始初始化";
        if (!backend->initialize())
        {
            qCritical() << "Failed to initialize BackendManager in QML singleton";
        }
        else
        {
            qDebug() << "BackendManager通过QML_SINGLETON初始化完成，songModel数据量:" << backend->songModel()->rowCount();
        }
        initialized = true;
    }

    return backend;
}

bool BackendManager::initialize()
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

    db.setDatabaseName(appDir + "/sql/MusicDatas.db"); // 使用内存数据库测试
    if (!db.open())
    {
        return false;
    }

    // 创建DatabaseManager实例
    m_dbManager = new DatabaseManager(db, this);
    if (!m_dbManager->isDatabaseValid())
    {
        qCritical() << "Database connection is invalid";
        return false;
    }

    Song *song = m_dbManager->getSong(1);
    qDebug() << "从数据库提取";

    if (!song)
    {
        qDebug() << "歌曲为空";
    }
    else
    {
        qDebug() << song->title() << song->artist();
    }

    // 初始化音乐扫描器
    m_scanner = new MusicScanner(this);

    // 初始化播放控制器
    m_playerController = new PlayerController(this);

    // 初始化歌词提取器
    m_lyricsExtractor = new LyricsExtractor(this);

    // 初始化数据模型
    m_songModel = new SongModel(this);
    m_favoriteModel = new SongModel(this);
    m_localSongModel = new LocalSongModel(this);
    m_playlistModel = new PlaylistModel(this);
    m_locallistModel = new PlaylistModel(this);

    // 连接信号
    connectSignals();

    // 加载现有数据
    loadSongLibrary();
    loadAllPlaylists();

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
    Playlist *playlist = getPlaylistById(playlistId);
    Playlist *localplaylist = getLocalPlaylistById(playlistId);
    if (playlist && m_playerController)
    {
        QList<Song *> songs = playlist->getAllSongs();
        if (!songs.isEmpty())
        {
            m_playerController->loadQueue(songs);
            qDebug() << "开始播放歌单:" << playlist->name();
        }
        else
        {
            qDebug() << "歌单为空:" << playlist->name();
        }
    }
    else if (localplaylist && m_playerController)
    {
        QList<Song *> songs = localplaylist->getAllSongs();
        if (!songs.isEmpty())
        {
            m_playerController->loadQueue(songs);
            qDebug() << "开始播放歌单:" << localplaylist->name();
        }
        else
        {
            qDebug() << "歌单为空:" << localplaylist->name();
        }
    }
    else
    {
        qDebug() << "找不到指定的歌单，ID:" << playlistId;
    }
}

void BackendManager::playPlaylist(QList<Song *> favoritelist)
{
    if (!favoritelist.isEmpty())
    {
        m_playerController->loadQueue(favoritelist);
        qDebug() << "开始播放我的喜欢";
    }
    else
    {
        qDebug() << "我的喜欢为空";
    }
}

Song *BackendManager::getSongById(int songId)
{
    if (!m_songModel)
    {
        return nullptr;
    }

    // 遍历歌曲模型查找指定ID的歌曲
    for (int i = 0; i < m_songModel->rowCount(); ++i)
    {
        Song *song = m_songModel->getSong(i);
        if (song && song->id() == songId)
        {
            return song;
        }
    }
    return nullptr;
}

Playlist *BackendManager::getPlaylistById(int playlistId)
{
    if (!m_playlistModel)
    {
        return nullptr;
    }

    // 遍历播放列表模型查找指定ID的播放列表
    for (int i = 0; i < m_playlistModel->rowCount(); ++i)
    {
        Playlist *playlist = m_playlistModel->getPlaylist(i);
        if (playlist && playlist->id() == playlistId)
        {
            return playlist;
        }
    }
    return nullptr;
}

Playlist *BackendManager::getPlaylistByIndex(int index)
{
    if (!m_playlistModel || index < 0 || index >= m_playlistModel->rowCount())
    {
        return nullptr;
    }

    return m_playlistModel->getPlaylist(index);
}

// get本地
Playlist *BackendManager::getLocalPlaylistById(int playlistId)
{
    if (!m_playlistModel)
    {
        return nullptr;
    }

    // 遍历播放列表模型查找指定ID的播放列表
    for (int i = 0; i < m_locallistModel->rowCount(); ++i)
    {
        Playlist *playlist = m_locallistModel->getPlaylist(i);
        if (playlist && playlist->id() == playlistId)
        {
            return playlist;
        }
    }
    return nullptr;
}

Playlist *BackendManager::getLocalPlaylistByIndex(int index)
{
    if (!m_locallistModel || index < 0 || index >= m_locallistModel->rowCount())
    {
        return nullptr;
    }

    return m_locallistModel->getPlaylist(index);
}

void BackendManager::addSongToPlaylist(Song *song, Playlist *playlist)
{
    if (playlist->getAllSongs().contains(song))
    {
        qDebug() << "歌曲已存在于歌单中，跳过添加";
        return;
    }
    playlist->addSong(song); // 列表操作
    // 检查是否已经存在该歌曲

    m_dbManager->addSongToPlaylist(song->id(), playlist->id()); // 同时更新数据库
}

void BackendManager::setSongFavorite(Song *song)
{
    if (!song->isFavorite())
    {
        song->setIsFavorite(true);
        qDebug() << "设置喜欢歌曲" << song->coverArtUrl();
        m_favoriteModel->addSong(song);
    }
    else
    {
        song->setIsFavorite(false);

        if (!m_favoriteModel || !m_dbManager) {
            qDebug() << "模型或数据库管理器未初始化";
            return;
        }

        // 从模型中找到并删除
        // QList<Song *> songs = m_favoriteModel->getAllSongs();
        // for(auto &song1 : songs) {

        // }
        for (int i = 0; i < m_favoriteModel->rowCount(); ++i) {
            Song *song1 = m_favoriteModel->getSong(i);
            if (song1 && song1->id() == song->id()) {
                m_favoriteModel->removeSong(i);
                qDebug() << "成功取消喜欢，ID:" << song->id();
                break;
            }
        }
    }
    // song->setIsFavorite(favorite); // 设置歌曲喜欢状态

    m_dbManager->updateSong(song); // 更新数据库信息
}

// Playlist *BackendManager::createPlaylist(const QString &name, const QString &description) {}

void BackendManager::onScanFinished(const QList<Song *> &foundSongs)
{
    // 只更新本地歌曲模型 (Local.qml 使用)
    // SongView.qml 的模型保持不变，维持独立性
    if (m_localSongModel)
    {
        m_localSongModel->loadSongs(foundSongs);
    }

    qDebug() << "扫描完成，发现" << foundSongs.size() << "首歌曲";
    qDebug() << "本地歌曲模型已更新，SongView模型保持独立";
    emit scanFinished();
}

// void BackendManager::onCurrentSongChanged()
// {

// }

void BackendManager::loadAllPlaylists() // 加载已有歌单
{
    if (!m_dbManager || !m_playlistModel || !m_locallistModel)
    {
        return;
    }

    QList<Playlist *> allplaylists = m_dbManager->getAllPlaylists();
    QList<Playlist *> playlists;      // 非新建
    QList<Playlist *> localplaylists; // 新建
    for (auto &list : allplaylists)
    {
        if (!list->local())
        {
            qDebug() << "false";
            playlists.append(list);
        }
        else
        {
            qDebug() << "true";
            localplaylists.append(list);
        }
    }
    m_playlistModel->loadPlaylists(playlists);
    m_locallistModel->loadPlaylists(localplaylists);
}

void BackendManager::loadSongLibrary() // 加载所有歌曲
{
    if (!m_dbManager || !m_songModel)
    {
        return;
    }

    QList<Song *> allsongs = m_dbManager->getAllSongs();
    QList<Song *> favoritesongs;
    for (auto &song : allsongs)
    {
        if (song->isFavorite())
        {
            qDebug() << "喜欢的歌曲";
            favoritesongs.append(song);
        }
    }

    m_songModel->loadSongs(allsongs); // 将其中标记为“我喜欢”的歌曲加入到指定model
    qDebug() << "歌曲加载成功";
    m_favoriteModel->loadSongs(favoritesongs);
    // qDebug() << " 1111111111111111111111111111111111111111111111111111111player加载";
    // m_playerController->loadQueue(allsongs); // 让音乐控制器加载播放列表（测试）
    //  qDebug() << "2222222222222222222222222222222222222222222222222222pasdadada";
}

Playlist *BackendManager::createLocalPlaylist(const QString &listname) // 创建新歌单
{
    qDebug() << "23333333333333333333333" << listname;
    QDateTime dt1 = QDateTime::currentDateTime();
    Playlist *playlist = new Playlist(89, listname, "xinjian", dt1, this);
    // playlist->setName(listname);
    playlist->setLocal(true);                // 新建歌单设置标识
    m_dbManager->addPlaylist(playlist);      // 更新数据库的歌单信息(并且数据库赋予新建歌单真正的id)
    m_locallistModel->addPlaylist(playlist); // 加入本地（我的）歌单model,新建歌单
    return playlist;
}

// 删除本地歌单
void BackendManager::deleteLocalPlaylist(int playlistId)
{
    if (!m_locallistModel || !m_dbManager)
    {
        qDebug() << "模型或数据库管理器未初始化";
        return;
    }

    // 从数据库删除
    if (m_dbManager->deletePlaylist(playlistId))
    {
        // 从模型中找到并删除
        //for(auto &plalist : m_locallistModel)
        for (int i = 0; i < m_locallistModel->rowCount(); ++i)
        {
            Playlist *playlist = m_locallistModel->getPlaylist(i);
            if (playlist && playlist->id() == playlistId)
            {
                m_locallistModel->removePlaylist(i);
                qDebug() << "成功删除歌单，ID:" << playlistId;
                break;
            }
        }
    }
    else
    {
        qDebug() << "删除歌单失败，ID:" << playlistId;
    }
}

// 重命名本地歌单
void BackendManager::renameLocalPlaylist(int playlistId, const QString &newName)
{
    if (!m_locallistModel || !m_dbManager)
    {
        qDebug() << "模型或数据库管理器未初始化";
        return;
    }

    // 从模型中找到歌单
    for (int i = 0; i < m_locallistModel->rowCount(); ++i)
    {
        Playlist *playlist = m_locallistModel->getPlaylist(i);
        if (playlist && playlist->id() == playlistId)
        {
            // 更新歌单名称
            playlist->setName(newName);

            // 更新数据库
            if (m_dbManager->updatePlaylist(playlist))
            {
                qDebug() << "成功重命名歌单，ID:" << playlistId << "新名称:" << newName;
                // 触发模型更新
                m_locallistModel->updatePlaylistAtIndex(i);
            }
            else
            {
                qDebug() << "重命名歌单失败，ID:" << playlistId;
            }
            break;
        }
    }
}
void BackendManager::connectSignals()
{
    // 连接扫描器信号
    // connect(m_scanner, &MusicScanner::scanProgress, this, &BackendManager::scanProgressChanged);
    connect(m_scanner, &MusicScanner::scanFinished, this, &BackendManager::onScanFinished);

    // 连接播放器信号
    // connect(m_playerController, &PlyerController::currentSongChanged, this, &BackendManager::onCurrentSongChanged);
    // connect(m_playerController, &PlayerController::positionChanged, m_lyricsModel, &LyricsModel::updateCurrentLine);
}
