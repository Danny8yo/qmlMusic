#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>
#include "song.h"
#include "playlist.h"
#include "MusicScanner.h"
#include "songmodel.h"
#include "playlistmodel.h"
#include "localsongmodel.h"
#include "PlayerController.h"
#include "DatabaseManager.h"
#include "LyricsExtractor.h"
#include <QtQml/qqmlregistration.h>

extern QString appDir;

class BackendManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SongModel *songModel READ songModel CONSTANT)
    Q_PROPERTY(SongModel *favoriteModel READ favoriteModel CONSTANT)
    Q_PROPERTY(LocalSongModel *localSongModel READ localSongModel CONSTANT)
    Q_PROPERTY(PlaylistModel *playlistModel READ playlistModel CONSTANT)
    Q_PROPERTY(PlaylistModel *locallistModel READ locallistModel CONSTANT)
    Q_PROPERTY(PlayerController *playerController READ playerController CONSTANT)
    Q_PROPERTY(LyricsExtractor *lyricsExtractor READ lyricsExtractor CONSTANT)
    Q_PROPERTY(QString appDirPath READ appDirPath CONSTANT)
    QML_ELEMENT
    // QML_SINGLETON  // 使用手动注册以确保稳定性
public:
    explicit BackendManager(QObject *parent = nullptr);
    // 单例模式:某个对象只需要一个实例
    static BackendManager *instance();

    // QML注册为单例
    /*static表示该函数属于类本身，而不是属于类的任何特定实例。你可以直接通过类名来调用它（例如 MyClass::qmlInstance(...)）
    将函数的范围限制在当前的编译单元（定义它的 .cpp 文件）。不过，在 QML 单例注册的上下文中，它几乎总是被暴露给 QML 的类的静态成员函数。*/
    /*QQmlEngine* engine: 一个指向 QQmlEngine 实例的指针。QML 引擎是加载和解释
     QML文档的核心组件。这个参数允许 qmlInstance 函数在单例创建或检索过程中，根据需要与 QML 引擎交互或从中获取信息。*/
    /*QJSEngine* scriptEngine: 一个指向 QJSEngine 实例的指针*/
    static BackendManager *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    // 初始化
    Q_INVOKABLE bool initialize();

    // 公开的模型和控制器
    SongModel *songModel() const { return m_songModel; }
    SongModel *favoriteModel() const { return m_favoriteModel; }
    LocalSongModel *localSongModel() const { return m_localSongModel; }
    PlaylistModel *playlistModel() const { return m_playlistModel; }
    PlaylistModel *locallistModel() const { return m_locallistModel; }
    PlayerController *playerController() const { return m_playerController; }
    LyricsExtractor *lyricsExtractor() const { return m_lyricsExtractor; }
    QString appDirPath() const { return m_appDir; }
    // DatabaseManager *dbManager() const { return m_dbManager; }

    // QML可调用方法

    // 扫描目录,扫描完后,会将歌曲添加进m_scanner的foundSongs列表中,&foundSongs只能通过信号传递
    Q_INVOKABLE void scanMusicLibrary(const QStringList &directories);
    // ui播放歌单,双击指定id对应的model,让playController播放对应的歌单列表
    Q_INVOKABLE void playSongById(int songId);
    // ui播放歌单,双击指定id对应的model,让playController播放对应的歌单列表
    Q_INVOKABLE void playPlaylist(int playlistId);
    Q_INVOKABLE void playPlaylist(QList<Song *> favoritelist); // 直接播放“我的喜欢”列表的歌曲

    // 获取特定歌曲
    Q_INVOKABLE Song *getSongById(int songId);

    // 获取特定播放列表
    Q_INVOKABLE Playlist *getPlaylistById(int playlistId);
    Q_INVOKABLE Playlist *getPlaylistByIndex(int index);
    // 获取本地特定播放列表
    Q_INVOKABLE Playlist *getLocalPlaylistById(int playlistId);
    Q_INVOKABLE Playlist *getLocalPlaylistByIndex(int index);

    // 添加歌曲到播放列表
    Q_INVOKABLE void addSongToPlaylist(Song *song, Playlist *playlist);

    // 设置歌曲喜欢状态
    Q_INVOKABLE void setSongFavorite(Song *song);

    // 更新视图
    Q_INVOKABLE void loadSongLibrary();
    Q_INVOKABLE void loadAllPlaylists();
    // Q_INVOKABLE Playlist *createPlaylist(const QString &name, const QString &description = "");

    // 创建Playlist，Song对象(从数据库导入的只是模拟服务器)
    Q_INVOKABLE Playlist *createLocalPlaylist(const QString &listname); // 创建“我的歌单”时使用
    // Q_INVOKABLE Song *createSong();
    //  删除歌单（本地）
    Q_INVOKABLE void deleteLocalPlaylist(int playlistId); // 删除本地歌单
    Q_INVOKABLE void renameLocalPlaylist(int playlistId, const QString &newName); // 重命名本地歌单
    // Q_INVOKABLE void removeLocalPlaylist(Playlist *playlist);

    // DatabaseManager测试

signals:
    void scanProgressChanged(int progress);
    void scanFinished();
    // 实例化各板块如音乐扫描器、playerController和各种数据模型后发出信号
    void initialized();

private slots:
    // foundSongs是musicScanner扫描目录后添加的歌曲
    void onScanFinished(const QList<Song *> &foundSongs);
    // void onCurrentSongChanged();

private:
    static BackendManager *s_instance;

    // 组件实例
    MusicScanner *m_scanner;
    // QML数据模型
    SongModel *m_songModel;
    LocalSongModel *m_localSongModel;
    SongModel *m_favoriteModel;      // 喜欢的歌曲
    PlaylistModel *m_playlistModel;  // 发现（网页）歌单model,非用户创建的歌单
    PlaylistModel *m_locallistModel; // 本地歌单model
    PlayerController *m_playerController;
    LyricsExtractor *m_lyricsExtractor;
    QString m_appDir = appDir; // 应用程序目录路径

    DatabaseManager *m_dbManager; // 进程崩溃了

    void connectSignals();
};
