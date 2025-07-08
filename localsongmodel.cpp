#include "localsongmodel.h"
#include <QDebug>

LocalSongModel::LocalSongModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

LocalSongModel::~LocalSongModel()
{
    clearSongs();
}

int LocalSongModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_songs.size();
}

QVariant LocalSongModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_songs.size()) {
        return QVariant();
    }

    Song *song = m_songs.at(index.row());
    if (!song) {
        return QVariant();
    }

    switch (role) {
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
    case CoverUrlRole:
        return song->coverArtUrl();
    case SongRole:
        return QVariant::fromValue(song);
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> LocalSongModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[TitleRole] = "title";
    roles[ArtistRole] = "artist";
    roles[AlbumRole] = "album";
    roles[DurationRole] = "duration";
    roles[FilePathRole] = "filePath";
    roles[CoverUrlRole] = "coverUrl";
    roles[SongRole] = "song";
    return roles;
}

Song* LocalSongModel::getSong(int index) const
{
    if (index < 0 || index >= m_songs.size()) {
        return nullptr;
    }
    return m_songs.at(index);
}

void LocalSongModel::loadSongs(const QList<Song*> &songs)
{
    beginResetModel();
    
    // 清理现有歌曲
    clearSongs();
    
    // 加载新歌曲
    m_songs = songs;
    
    endResetModel();
    
    updateCount();
    emit songsChanged();
    
    qDebug() << "LocalSongModel: 加载了" << m_songs.size() << "首本地歌曲";
}

void LocalSongModel::clearSongs()
{
    if (m_songs.isEmpty()) {
        return;
    }
    
    beginResetModel();
    m_songs.clear();
    endResetModel();
    
    updateCount();
    emit songsChanged();
}

void LocalSongModel::addSong(Song* song)
{
    if (!song) {
        return;
    }
    
    beginInsertRows(QModelIndex(), m_songs.size(), m_songs.size());
    m_songs.append(song);
    endInsertRows();
    
    updateCount();
    emit songsChanged();
}

void LocalSongModel::removeSong(int index)
{
    if (index < 0 || index >= m_songs.size()) {
        return;
    }
    
    beginRemoveRows(QModelIndex(), index, index);
    m_songs.removeAt(index);
    endRemoveRows();
    
    updateCount();
    emit songsChanged();
}

int LocalSongModel::count() const
{
    return m_songs.size();
}

void LocalSongModel::updateCount()
{
    emit countChanged();
}
