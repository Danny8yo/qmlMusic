#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>
#include "song.h"
#include "playlist.h"
#include "MusicScanner.h"
#include "songmodel.h"
#include "playlistmodel.h"
#include "PlayerController.h"
#include "DatabaseManager.h"

class BackendManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SongModel *songModel READ songModel CONSTANT)
    Q_PROPERTY(PlaylistModel *playlistModel READ playlistModel CONSTANT)
    Q_PROPERTY(PlayerController *playerController READ playerController CONSTANT)
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
    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

    // 初始化
    Q_INVOKABLE bool initialize();

    // 公开的模型和控制器
    SongModel *songModel() const { return m_songModel; }
    PlaylistModel *playlistModel() const { return m_playlistModel; }
    PlayerController *playerController() const { return m_playerController; }
    //DatabaseManager *dbManager() const { return m_dbManager; }

    // QML可调用方法

    //扫描目录,扫描完后,会将歌曲添加进m_scanner的foundSongs列表中,&foundSongs只能通过信号传递
    Q_INVOKABLE void scanMusicLibrary(const QStringList &directories);
    //ui播放歌单,双击指定id对应的model,让playController播放对应的歌单列表
    Q_INVOKABLE void playSongById(int songId);
    //ui播放歌单,双击指定id对应的model,让playController播放对应的歌单列表
    Q_INVOKABLE void playPlaylist(int playlistId);

    //更新视图
    // Q_INVOKABLE void loadSongLibrary();
    // Q_INVOKABLE void loadAllPlaylists();
    //Q_INVOKABLE Playlist *createPlaylist(const QString &name, const QString &description = "");

    //
    //
    // DatabaseManager测试

signals:
    void scanProgressChanged(int progress);
    void scanFinished();
    //实例化各板块如音乐扫描器、playerController和各种数据模型后发出信号
    void initialized();

private slots:
    //foundSongs是musicScanner扫描目录后添加的歌曲
    void onScanFinished(const QList<Song *> &foundSongs);
    // void onCurrentSongChanged();

private:
    static BackendManager *s_instance;

    // 组件实例
    MusicScanner *m_scanner;
    // QML数据模型
    SongModel *m_songModel;
    PlaylistModel *m_playlistModel;
    PlayerController *m_playerController;

    DatabaseManager *m_dbManager; //进程崩溃了

    void connectSignals();
};
