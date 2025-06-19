#include "playlistmodel.h"
#include "songmodel.h"

PlaylistModel::PlaylistModel(QObject *parent)
    : QAbstractListModel{parent}//设置父类为QAbstractListModel
{}

int PlaylistModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
    return m_playlists.size();
}

QVariant PlaylistModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_playlists.size()) {
        return QVariant();
    }

    Playlist* playlist = m_playlists.at(index.row());
    if (!playlist) {
        return QVariant();
    }

    switch (role) {
    case IdRole:
        return playlist->id();
    case NameRole:
        return playlist->name();
    case DescriptionRole:
        return playlist->description();
    case CoverUrlRole:
        // return playlist->coverUrl().isEmpty() ? "qrc:/resources/images/default_playlist.png" : playlist->coverUrl();
    case SongCountRole:
        return playlist->songCount();
    case CreationDateRole:
        return playlist->creationDate();
    case PlaylistObjectRole:
        return QVariant::fromValue(playlist);
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> PlaylistModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    roles[DescriptionRole] = "description";
    roles[CoverUrlRole] = "coverUrl";
    roles[SongCountRole] = "songCount";
    roles[CreationDateRole] = "creationDate";
    roles[PlaylistObjectRole] = "playlistObject";
    return roles;
}

// void SongModel::loadSongs(const QList<Song*>& songs)
// {
//     beginResetModel();
//     m_songs = songs;
//     m_allSongs = songs; // 保存原始列表用于筛选
//     endResetModel();
//     emit countChanged();
// }

void PlaylistModel::loadPlaylists(const QList<Playlist*>& playlists)
{
    beginResetModel();
    m_playlists = playlists;
    endResetModel();
    emit countChanged();
}

void PlaylistModel::addPlaylist(Playlist* playlist)
{
    if (!playlist || m_playlists.contains(playlist)) {
        return;
    }

    beginInsertRows(QModelIndex(), m_playlists.size(), m_playlists.size());
    m_playlists.append(playlist);
    endInsertRows();
    emit countChanged();
}

void PlaylistModel::removePlaylist(int index)
{
    if (index < 0 || index >= m_playlists.size()) {
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);
    m_playlists.removeAt(index);
    endRemoveRows();
    emit countChanged();
}

Playlist* PlaylistModel::getPlaylist(int index) const
{
    if (index >= 0 && index < m_playlists.size()) {
        return m_playlists.at(index);
    }
    return nullptr;
}

void PlaylistModel::clear()
{
    beginResetModel();
    m_playlists.clear();
    endResetModel();
    emit countChanged();
}
