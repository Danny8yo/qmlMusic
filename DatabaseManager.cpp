#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

extern QString appDir;

DatabaseManager::DatabaseManager(QSqlDatabase database, QObject *parent) : QObject(parent), m_database(database)
{
    if (!m_database.isOpen())
    {
        qDebug() << "Warning: Database connection is not open";
    }

}

// DatabaseManager::~DatabaseManager()
// {
//     //不再关闭数据库连接，由创建者管理
// }

bool DatabaseManager::isDatabaseValid() const
{
    return m_database.isValid() && m_database.isOpen();
}

bool DatabaseManager::executeQuery(const QString &query) //
{
    QSqlQuery sqlQuery(m_database); // 创建查询对象
    if (!sqlQuery.exec(query))
    {
        qDebug() << "Query failed:" << query;
        qDebug() << "Error:" << sqlQuery.lastError().text();
        return false;
    }
    return true;
}

bool DatabaseManager::addSong(Song *song)
{
    if (!song)
        return false;

    QSqlQuery query(m_database);
    query.prepare(R"(INSERT INTO Songs (filePath, title, artist, album, coverUrl)
                    VALUES (?, ?, ?, ?, ?))");
    // “？”对应一个字段值，通过addBindValue绑定实际值，顺序必须与字段列表一致

    // query.addBindValue(song->id());
    query.addBindValue(song->filePath());
    query.addBindValue(song->title());
    query.addBindValue(song->artist());
    query.addBindValue(song->album());
    query.addBindValue(song->coverArtUrl().toString());

    if (query.exec())
    { // 执行
        song->setId(query.lastInsertId().toInt());
        return true;
    }

    qDebug() << "Failed to add song:" << query.lastError().text();
    return false;
}

QList<Song *> DatabaseManager::getAllSongs() // 数据库读取歌曲数据并保存（不具有歌曲列表属性）
{
    QList<Song *> songs;
    QSqlQuery query(m_database);
    query.prepare("SELECT SongId, filePath, title, artist, album, coverUrl FROM Songs ORDER BY title");
    // QSqlQuery query("SELECT * FROM Songs ORDER BY title", m_database);

    if (!query.exec())
    {
        qDebug() << "查询失败:" << query.lastError().text();
        return songs; // 返回空列表
    }
    while (query.next())
    {
        Song *song = new Song(appDir + query.value("filePath").toString(), this);
        song->setId(query.value("SongId").toInt());
        // song->setFilePath(appDir + query.value("filePath").toString());
        song->setTitle(query.value("title").toString());
        song->setArtist(query.value("artist").toString());
        song->setAlbum(query.value("album").toString());
        song->setCoverArtUrl(QUrl("file://" + appDir + query.value("coverUrl").toString()));

        // song->setDuration(query.value("duration").toInt());

        // song->setCoverArtUrl(query.value("cover_art_path").toString());
        // song->setLyricsPath(query.value("lyrics_path").toString());

        songs.append(song);
    }

    return songs;
}

bool DatabaseManager::updateSong(Song *song)
{
    if (!song || song->id() <= 0)
        return false;

    QSqlQuery query(m_database);
    // query.prepare(R"(UPDATE songs SET title=?, artist=?, album=?, duration=?,
    //                  cover_art_path=?, lyrics_path=? WHERE SongId=?)");

    query.prepare(R"(UPDATE Songs SET filePath=?, title=?, artist=?, album=?, coverUrl=? WHERE SongId=?)");
    query.addBindValue(song->filePath());
    query.addBindValue(song->title());
    query.addBindValue(song->artist());
    query.addBindValue(song->album());
    query.addBindValue(song->coverArtUrl().toString());
    query.addBindValue(song->id());

    return query.exec();
}

bool DatabaseManager::removeSong(int songId)
{
    // 复合查询会出现：
    // Failed to execute compound query: QSqlError("", "Parameter count mismatch", "")

    // QSqlQuery query(m_database);
    // query.prepare("BEGIN; "
    // "DELETE FROM PlaylistSongs WHERE SongID = ?; " // 删除歌曲和对应歌单的映射
    // "DELETE FROM Songs WHERE SongId = ?; "
    // "COMMIT;");

    // query.addBindValue(songId);
    // query.addBindValue(songId);

    // if (!query.exec()) {
    // qDebug() << "Failed to execute compound query:" << query.lastError();
    // return false;
    // }

    // return true;

    // 改为单独的事务处理
    m_database.transaction(); // 开始事务

    QSqlQuery query(m_database);

    // 先删除关联表中的记录
    query.prepare("DELETE FROM PlaylistSongs WHERE SongID = ?");
    query.addBindValue(songId);
    if (!query.exec())
    {
        m_database.rollback();
        qDebug() << "Failed to delete from PlaylistSongs:" << query.lastError();
        return false;
    }

    // 再删除主表中的记录
    query.prepare("DELETE FROM Songs WHERE SongId = ?");
    query.addBindValue(songId);
    if (!query.exec())
    {
        m_database.rollback();
        qDebug() << "Failed to delete from Songs:" << query.lastError();
        return false;
    }

    if (!m_database.commit())
    {
        qDebug() << "Commit failed:" << m_database.lastError();
        return false;
    }

    return true;
}

Song *DatabaseManager::getSong(int songId)
{
    QSqlQuery query(m_database);
    query.prepare("SELECT * FROM Songs WHERE SongId=?");
    query.addBindValue(songId);

    if (query.exec() && query.next())
    {
        Song *song = new Song(appDir + query.value("filePath").toString(), this);
        song->setId(query.value("SongId").toInt());
        // song->setFilePath(appDir + query.value("filePath").toString());
        song->setTitle(query.value("title").toString());
        song->setArtist(query.value("artist").toString());
        song->setAlbum(query.value("album").toString());
        song->setCoverArtUrl(QUrl("file://" + appDir + query.value("coverUrl").toString()));

        return song;
    }

    return nullptr;
}

QList<Song *> DatabaseManager::searchSongs(const QString &keyword) // 歌曲可能同名所以返回列表
{
    QList<Song *> songs;
    QSqlQuery query(m_database);
    query.prepare(R"(SELECT * FROM Songs WHERE title LIKE ? OR artist LIKE ? 
                     OR album LIKE ? ORDER BY title)");
    // 标题(title)或艺术家(artist)或专辑 (album)

    QString searchPattern = "%" + keyword + "%";
    query.addBindValue(searchPattern);
    query.addBindValue(searchPattern);
    query.addBindValue(searchPattern);

    if (!query.exec())
    {
        qDebug() << "查询失败:" << query.lastError().text();
        return songs; // 返回空列表
    }
    while (query.next())
    {
        Song *song = new Song(this);
        song->setId(query.value("SongId").toInt());
        song->setTitle(query.value("title").toString());
        song->setArtist(query.value("artist").toString());
        song->setAlbum(query.value("album").toString());
        song->setFilePath(appDir + query.value("filePath").toString());
        song->setCoverArtUrl(QUrl("file://" + appDir + query.value("coverUrl").toString()));
        // song->setLyricsPath(query.value("lyrics_path").toString());
        //  song->setDateAdded(query.value("date_added").toDateTime());
        //  song->setPlayCount(query.value("play_count").toInt());

        songs.append(song);
    }

    return songs;
}

bool DatabaseManager::addPlaylist(Playlist *playlist)
{
    if (!playlist)
        return false;

    QSqlQuery query(m_database);
    query.prepare(R"(INSERT INTO Playlists (name, description, coverUrl, creationDate, ifLocal) 
                     VALUES (?, ?, ?, ?, ?))");

    query.addBindValue(playlist->name());
    query.addBindValue(playlist->description());
    // query.addBindValue(playlist->coverUrl().toString());
    query.addBindValue(playlist->relativeCoverPath());
    // qDebug() << "playlist cover： " << playlist->coverUrl().toString();
    query.addBindValue(playlist->creationDate());
    query.addBindValue(playlist->local());
    // query.addBindValue(playlist->size());

    if (query.exec())
    {
        playlist->setId(query.lastInsertId().toInt());
        
        //与playlist::updateCoverUrl()中的emit coverUrlChanged()信号建立连接
        connect(playlist, &Playlist::coverUrlChanged, this, [this,playlist]() {
            // qDebug() << "!!!!!!!更新 " << playlist->name() << "封面为: " << playlist->relativeCoverPath();
            this->updatePlaylist(playlist);
        });
        
        return true;
    }

    qDebug() << "Failed to add playlist:" << query.lastError().text();
    return false;
}

QList<Playlist *> DatabaseManager::getAllPlaylists()
{
    QList<Playlist *> playlists;
    QSqlQuery query("SELECT * FROM Playlists ORDER BY creationDate DESC", m_database);

    if (!query.exec())
    {
        qDebug() << "查询失败:" << query.lastError().text();
        return playlists; // 返回空列表
    }
    while (query.next())
    {
        Playlist *playlist = getPlaylist(query.value("PlaylistId").toInt());

        if (playlist)
        {
            playlists.append(playlist);
        }
        else
        {
            qDebug() << "无法获取播放列表ID:" << query.value("PlalyistId").toInt();
        }
    }

    return playlists;
}

// QList<Playlist*> DatabaseManager::serchPlaylists(const QString& keyword) {}

bool DatabaseManager::updatePlaylist(Playlist *playlist)
{
    if (!playlist || playlist->id() <= 0)
        return false;

    QSqlQuery query(m_database);
    query.prepare("UPDATE Playlists SET name=?, description=?, coverUrl=?, ifLocal=? WHERE PlaylistId=?");

    query.addBindValue(playlist->name());
    query.addBindValue(playlist->description());
    query.addBindValue(playlist->relativeCoverPath());
    query.addBindValue(playlist->local());
    query.addBindValue(playlist->id());

    return query.exec();
}

bool DatabaseManager::deletePlaylist(int playlistId)
{
    // 改为单独的事务处理，理由和removeSong一致
    m_database.transaction(); // 开始事务

    QSqlQuery query(m_database);

    // 先删除关联表中的记录
    query.prepare("DELETE FROM PlaylistSongs WHERE PlaylistId = ?");
    query.addBindValue(playlistId);
    if (!query.exec())
    {
        m_database.rollback();
        qDebug() << "Failed to delete from PlaylistSongs:" << query.lastError();
        return false;
    }

    // 再删除主表中的记录
    query.prepare("DELETE FROM Playlists WHERE PlaylistId = ?");
    query.addBindValue(playlistId);
    if (!query.exec())
    {
        m_database.rollback();
        qDebug() << "Failed to delete from Playlists:" << query.lastError();
        return false;
    }

    if (!m_database.commit())
    {
        qDebug() << "Commit failed:" << m_database.lastError();
        return false;
    }

    return true;
}

Playlist *DatabaseManager::getPlaylist(int playlistId)
{
    QSqlQuery query(m_database);
    query.prepare("SELECT * FROM Playlists WHERE PlaylistId=?");
    query.addBindValue(playlistId);

    if (query.exec() && query.next())
    {
        Playlist *playlist = new Playlist(this);
        playlist->setId(query.value("PlaylistId").toInt());
        playlist->setName(query.value("name").toString());
        playlist->setDescription(query.value("description").toString());

        // 只有当 coverUrl 不为空时才设置
        QString coverUrlFromDb = query.value("coverUrl").toString();
        if (!coverUrlFromDb.isEmpty())
        {
            playlist->setCoverUrl(QUrl("file://" + appDir + coverUrlFromDb));
        }

        playlist->setCreationDate(query.value("creationDate").toDateTime());
        playlist->setLocal(query.value("ifLocal").toBool());
        QList<int> songIds = searchSongInPlaylist(playlistId);
        QList<Song *> songs;
        // 同时将该歌单的歌曲也初始化
        // 根据searchSongInPlaylist(int playlistId)返回的id列表，去获得歌曲，然后循环遍历添加
        for (auto &item : songIds)
        {
            songs.append(getSong(item));
        }
        playlist->setSongs(songs);

        return playlist;
    }

    return nullptr;
}

QList<int> DatabaseManager::searchSongInPlaylist(int playlistId) // 查询某歌单中所有的歌曲的id
{
    QList<int> songIds;
    QSqlQuery query(m_database);
    query.prepare(R"(SELECT * FROM PlaylistSongs WHERE PlaylistID = ?)");
    query.addBindValue(playlistId);
    // if (query.exec() && query.next()) { songids.append(query.value("SongID").toInt()); }
    if (!query.exec())
    {
        qDebug() << "查询失败:" << query.lastError().text();
        return songIds; // 返回空列表
    }

    while (query.next())
    {
        if (query.isValid())
        {
            songIds.append(query.value("SongID").toInt());
        }
    }
    return songIds;
}
bool DatabaseManager::addSongToPlaylist(int songId, int playlistId) // 中间表格的处理
// 中间表格处理Song与playlist的关系
{
    Song *song = getSong(songId);
    if (!song)
    {
        qDebug() << "The song not exist!";
        return false;
    }
    QSqlQuery query(m_database);

    // 添加歌单和歌曲的映射
    query.prepare(R"(INSERT INTO PlaylistSongs (PlaylistID, SongId, SongOrder)
                     VALUES  (?, ?, ?))");
    // songOrder是该歌曲在目标歌单的位置

    query.addBindValue(playlistId);
    query.addBindValue(songId);
    int order = getPlaylist(playlistId)->songCount();
    query.addBindValue(order);
    // updatePlaylist(getPlaylist(playlistId)); // 更新列表信息

    return query.exec();
}

bool DatabaseManager::removeSongFromPlaylist(int songId, int playlistId)
{
    QSqlQuery query(m_database);
    query.prepare("DELETE FROM PlaylistSongs WHERE SongId=? AND PlaylistID=?");
    query.addBindValue(songId);
    query.addBindValue(playlistId);
    updatePlaylist(getPlaylist(playlistId));
    return query.exec();
}
