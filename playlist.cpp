#include "playlist.h"

Playlist::Playlist(QObject *parent)
    : QObject(parent), m_id(-1), m_name("New Playlist"), m_creationDate(QDateTime::currentDateTime()), m_coverUrl(QUrl()) // 明确初始化为空的 QUrl
{
}

Playlist::Playlist(const QString &name, QObject *parent)
    : QObject(parent), m_id(-1), m_name(name), m_creationDate(QDateTime::currentDateTime()), m_coverUrl(QUrl()) // 明确初始化为空的 QUrl
{
}

// 用于创建自定义歌单
Playlist::Playlist(const int &id, const QString &name, const QString &description, const QDateTime &date, QObject *parent)
    : QObject(parent), m_id(id), m_name(name), m_description(description), m_creationDate(date), m_local(true), m_coverUrl(QUrl()) // 明确初始化为空的 QUrl
{
}

// setters
void Playlist::setId(int id)
{
    if (m_id != id)
    {
        m_id = id;
        emit idChanged();
    }
}

void Playlist::setLocal(bool local)
{
    if (m_local != local)
    {
        m_local = local;
        emit localChanged();
    }
}
void Playlist::setName(const QString &name)
{
    if (m_name != name)
    {
        m_name = name;
        emit nameChanged();
    }
}

void Playlist::setDescription(const QString &description)
{
    if (m_description != description)
    {
        m_description = description;
        emit descriptionChanged();
    }
}
// coverUrlChanged
void Playlist::setCreationDate(const QDateTime &creationDate)
{
    if (m_creationDate != creationDate)
    {
        m_creationDate = creationDate;
        emit creationDateChanged();
    }
}

void Playlist::setCoverUrl(const QUrl &coverUrl)
{
    if (m_coverUrl != coverUrl)
    {
        m_coverUrl = coverUrl;
        emit coverUrlChanged();
    }
}

void Playlist::setSongs(const QList<Song *> &songs)
{
    if (m_songs != songs)
    {
        m_songs = songs;
        emit songsChanged();

        // 当设置歌曲列表时，自动更新封面
        updateCoverUrl();
    }
}

void Playlist::updateCoverUrl()
{
    // 如果这是第一首歌，并且它有自己的封面，更新播放列表封面
    if (m_songs.size() == 1)
    {
        m_coverUrl = m_songs.first()->coverArtUrl();
        qDebug() << "已将歌单封面更换为第一首歌曲封面:" << m_coverUrl.toString();
        emit coverUrlChanged();
    }
}

//
void Playlist::addSong(Song *song)
{
    if (!song)
    {
        qDebug() << "警告: 尝试添加空歌曲到播放列表";
        return;
    }

    if (!m_songs.contains(song))
    {
        m_songs.append(song);
        qDebug() << "添加歌曲:" << song->title();
        emit songsChanged();
        emit songCountChanged();
        updateCoverUrl();
    }
    else
    {
        qDebug() << "歌曲已存在于播放列表中:" << song->title();
    }
}

void Playlist::removeSong(int index)
{
    if (index >= 0 && index < m_songs.size())
    {
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
    if (index >= 0 && index < m_songs.size())
    {
        return m_songs.at(index);
    }
    qDebug() << "无效的索引:" << index << "歌单歌曲数量:" << m_songs.size();
    return nullptr;
}

QList<Song *> Playlist::getAllSongs() const
{
    return m_songs;
}

// 处理Qurl 成 QString 再裁剪成相对路径
QString Playlist::relativeCoverPath()
{
    // 检查 m_coverUrl 是否有效
    if (m_coverUrl.isEmpty() || !m_coverUrl.isValid())
    {
        qDebug() << "警告: m_coverUrl 为空或无效:" << m_coverUrl.toString();
        return QString(); // 返回空字符串
    }

    // 歌单封面绝对路径
    QString abscoverPath = m_coverUrl.toString();
    qDebug() << "abscover: " << abscoverPath;

    QString anchor = "/test_Music";
    int index = abscoverPath.indexOf(anchor);

    QString resultCoverPath;

    if (index != -1)
    {
        resultCoverPath = abscoverPath.mid(index);
    }
    else
    {
        qDebug() << "警告: 在路径中未找到 /test_Music 锚点";
    }

    // qDebug() << "Original Full Path:" << abscoverPath;
    // qDebug() << "Result Path:" << resultCoverPath;

    return resultCoverPath;
}
