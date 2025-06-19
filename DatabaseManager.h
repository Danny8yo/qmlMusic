#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QString>
#include <QList>
#include "song.h"
#include "playlist.h"

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseManager(QSqlDatabase database, QObject* parent = nullptr);
    //通过构造函数接收数据库连接
    //数据库不在该类创建
    // ~DatabaseManager();
    //检查数据库连接是否有效
    Q_INVOKABLE bool isDatabaseValid() const;

    // 歌曲CRUD操作
    Q_INVOKABLE bool addSong(Song* song);
    Q_INVOKABLE bool updateSong(Song* song);
    Q_INVOKABLE bool removeSong(int songId); // 删除歌曲时，由于中间表的存在，
        // 因此要先判断歌曲所在的歌单（列表）有哪些
        // 最后解除该歌曲与所有歌单的映射(删除列表同理)
    Q_INVOKABLE Song* getSong(int songId);
    Q_INVOKABLE QList<Song*> getAllSongs();
    Q_INVOKABLE QList<Song*> searchSongs(const QString& keyword);

    // 播放列表CRUD操作
    Q_INVOKABLE bool addPlaylist(Playlist* playlist);
    Q_INVOKABLE bool updatePlaylist(Playlist* playlist);
    Q_INVOKABLE bool deletePlaylist(int playlistId);
    Q_INVOKABLE Playlist* getPlaylist(int playlistId);
    Q_INVOKABLE QList<Playlist*> getAllPlaylists();
    //Q_INVOKABLE QList<Playlist*> searchPlaylists(const QString& keyword);

    // 播放列表-歌曲关联(涉及中间表的处理，中间表的描述见开发文档)
    // 中间表是加入了歌单（列表）的歌曲与歌单之间的映射关系
    Q_INVOKABLE bool addSongToPlaylist(int songId, int playlistId);
    Q_INVOKABLE bool removeSongFromPlaylist(int songId, int playlistId);

private:
    QSqlDatabase m_database; //

    QString m_databasePath;

    bool executeQuery(const QString& query); //SQL查询
};
