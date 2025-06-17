#include "playlist.h"

Playlist::Playlist(QObject* parent)
    : QObject(parent)
    , m_id(-1)
    , m_name("New Playlist")
    , m_creationDate(QDateTime::currentDateTime())
{
}

Playlist::Playlist(const QString& name, QObject* parent)
    : QObject(parent)
    , m_id(-1)
    , m_name(name)
    , m_creationDate(QDateTime::currentDateTime())
{
}

//用于创建自定义歌单
Playlist::Playlist(const int &id,const QString &name, const QString &description,const QDateTime &date,QObject *parent)
    : QObject(parent)
    , m_id(id)
    , m_name(name)
    , m_description(description)
    , m_creationDate(date)
{}

//setters
void Playlist::setId(int id)
{
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void Playlist::setName(const QString& name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

void Playlist::setDescription(const QString& description)
{
    if (m_description != description) {
        m_description = description;
        emit descriptionChanged();
    }
}

void Playlist::setCreationDate(const QDateTime& creationDate)
{
    if (m_creationDate != creationDate) {
        m_creationDate = creationDate;
        emit creationDateChanged();
    }
}

void Playlist::addSong(Song *song)
{
    if (song && !m_songs.contains(song)) {
        m_songs.append(song);
        // qDebug() << "添加歌曲" << song->title();
        emit songsChanged();
        emit songCountChanged();
    }
}

void Playlist::removeSong(int index)
{
    if (index >=0 && index < m_songs.size()) {
        m_songs.removeAt(index);
        emit songsChanged();
        emit songCountChanged();
    }
}

void Playlist::clearSongs()
{
    m_songs.clear();
    emit songsChanged();
    emit songCountChanged();
    // updateCoverUrl();
}

Song *Playlist::getSong(int index) const
{
    if (index >=0 && index<m_songs.size()) {
        return m_songs.at(index);
    }
    qDebug() << "无效的索引:" << index << "歌单歌曲数量:" << m_songs.size();
    return nullptr;
}

QList<Song *> Playlist::getAllSongs() const
{
    return m_songs;
}


