#include "songmodel.h"

SongModel::SongModel(QObject *parent)
    : QAbstractListModel{parent} // 设置父类为QAbstractListModel
{
}

int SongModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_songs.size();
}

/*
QModelIndex 的主要成员函数和用途如下：
row()：返回项的行号。
column()：返回项的列号。
parent()：返回项的父索引，用于构建层级结构的模型。
child()：返回指定行列的子项的索引。
isValid()：检查索引是否有效，即是否引用一个有效的项。
data()：从模型中获取索引对应项的数据。
setData()：将数据设置给索引对应项。
flags()：返回索引对应项的标志，用于指示项的属性，例如是否可编辑、是否可选择等。
*/
QVariant SongModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_songs.size())
    {
        return QVariant();
    }

    Song *song = m_songs.at(index.row());
    if (!song)
    {
        return QVariant();
    }

    switch (role)
    {
    case IdRole:
        return song->id();
    case TitleRole:
        return song->title();
    case ArtistRole:
        return song->artist();
    case AlbumRole:
        return song->album();
    case DurationRole:
        return song->duration();
    case FilePathRole:
        return song->filePath();
    case CoverArtRole:
        // 后期处理歌曲有封面URL后在实现
        //  return song->coverArtPath().isEmpty() ? "qrc:/resources/images/default_cover.png" : song->coverArtPath();
        return song->coverArtUrl();
    case LyricsRole:
        return song->lyricsPath();
    case FormattedDurationRole:
        // return song->formattedDuration();
        return song->durationString();
    case SongObjectRole:
        return QVariant::fromValue(song);
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> SongModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[TitleRole] = "title";
    roles[ArtistRole] = "artist";
    roles[AlbumRole] = "album";
    roles[DurationRole] = "duration";
    roles[FilePathRole] = "filePath";
    roles[CoverArtRole] = "coverArt";
    roles[LyricsRole] = "lyrics";
    roles[FormattedDurationRole] = "formattedDuration";
    // roles[SongObjectRole] = "songObject";
    return roles;
}

void SongModel::loadSongs(const QList<Song *> &songs)
{
    beginResetModel();
    m_songs = songs;
    m_allSongs = songs; // 保存原始列表用于筛选
    endResetModel();
    emit countChanged();

    for (const auto &song: m_songs) {
        qDebug() << "加载歌曲:" << song->title() << "艺术家:" << song->artist();
    }
}

void SongModel::addSong(Song *song)
{
    if (!song || m_songs.contains(song))
    {
        return;
    }

    beginInsertRows(QModelIndex(), m_songs.size(), m_songs.size());
    m_songs.append(song);
    m_allSongs.append(song);
    endInsertRows();
    emit countChanged();
}

void SongModel::removeSong(int index)
{
    if (index < 0 || index >= m_songs.size())
    {
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);
    Song *song = m_songs.at(index);
    m_songs.removeAt(index);
    m_allSongs.removeAll(song);
    endRemoveRows();
    emit countChanged();
}

Song *SongModel::getSong(int index) const
{
    if (index >= 0 && index < m_songs.size())
    {
        return m_songs[index];
    }
    return nullptr;
}

void SongModel::clear()
{
    beginResetModel();
    m_songs.clear();
    m_allSongs.clear();
    endResetModel();
    emit countChanged();
}

void SongModel::sortByTitle()
{
    beginResetModel();
    std::sort(m_songs.begin(), m_songs.end(), [](const Song *a, const Song *b)
              { return a->title().toLower() < b->title().toLower(); });
    endResetModel();
}

void SongModel::sortByArtist()
{
    beginResetModel();
    std::sort(m_songs.begin(), m_songs.end(), [](const Song *a, const Song *b)
              { return a->artist().toLower() < b->artist().toLower(); });
    endResetModel();
}

void SongModel::sortByAlbum()
{
    beginResetModel();
    std::sort(m_songs.begin(), m_songs.end(), [](const Song *a, const Song *b)
              { return a->album().toLower() < b->album().toLower(); });
    endResetModel();
}

void SongModel::filterByKeyword(const QString &keyword)
{
    beginResetModel();

    if (keyword.isEmpty())
    {
        m_songs = m_allSongs;
    }
    else
    {
        m_songs.clear();
        QString lowerKeyword = keyword.toLower();

        for (Song *song : m_allSongs)
        {
            if (song->title().toLower().contains(lowerKeyword) ||
                song->artist().toLower().contains(lowerKeyword) ||
                song->album().toLower().contains(lowerKeyword))
            {
                m_songs.append(song);
            }
        }
    }

    endResetModel();
    emit countChanged();
}
