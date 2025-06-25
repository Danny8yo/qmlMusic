#include "playlist.h"

Playlist::Playlist(QObject* parent)
    : QObject(parent)
    , m_id(-1)
    , m_name("New Playlist")
    , m_creationDate(QDateTime::currentDateTime())
{
}

Playlist::Playlist(const QString &name, QObject *parent)
    : QObject(parent)
    , m_id(-1)
    , m_name(name)
    , m_creationDate(QDateTime::currentDateTime())
{
}

//用于创建自定义歌单
Playlist::Playlist(const int &id, const QString &name, const QString &description, const QDateTime &date, QObject *parent)
    : QObject(parent)
    , m_id(id)
    , m_name(name)
    , m_description(description)
    , m_creationDate(date)
    , m_local(true)
{}

//setters
void Playlist::setId(int id)
{
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void Playlist::setLocal(bool local)
{
    if (m_local != local) {
        m_local = local;
        emit localChanged();
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

void Playlist::setCoverUrl(const QUrl &coverUrl)
{
    if (m_coverUrl != coverUrl) {
        m_coverUrl = coverUrl;
        emit coverUrlChanged();
    }
}

void Playlist::setSongs(const QList<Song *> &songs)
{
    if (m_songs != songs) {
        m_songs = songs;
        emit songsChanged();
    }
}
//
void Playlist::addSong(Song *song)
{
    // 检查这是否是添加到列表的第一首歌
    bool isFirstSong = m_songs.isEmpty();
    qDebug() << "添加歌曲";

    if (song && !m_songs.contains(song)) {
        m_songs.append(song);

        qDebug() << "添加歌曲" << song->title();
        emit songsChanged();
        emit songCountChanged();
    }

    // 如果这是第一首歌，并且它有自己的封面
    if (isFirstSong && !song->coverArtUrl().isEmpty()) {
        // 更新内部的封面路径变量
        m_coverUrl = m_songs.at(0)->coverArtUrl();
        qDebug() << "已将歌单封面更换为第一首歌曲" << m_coverUrl;

        // 关键：发射NOTIFY信号！
        // QML中所有绑定到 "coverPath" 属性的UI元素都会自动收到通知并刷新
        emit coverUrlChanged();
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


void Playlist::updateCoverUrl()
{
    QUrl newCoverUrl;
    if (!m_songs.isEmpty() && m_songs.first())
    {
        newCoverUrl = m_songs.first()->coverArtUrl();
    }

    if (newCoverUrl.isEmpty())
    {
        newCoverUrl = "qrc:/resources/images/default_playlist.png";
    }

    if (m_coverUrl != newCoverUrl)
    {
        m_coverUrl = newCoverUrl;
        emit coverUrlChanged();
    }
}


