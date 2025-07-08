#pragma once

#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>
#include <QList>
#include <QObject>
#include "playlist.h"

class PlaylistModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit PlaylistModel(QObject *parent = nullptr);

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    QML_ELEMENT

public:
    // 定义角色,QML将通过这些角色名来访问数据
    enum PlaylistRoles
    {
        IdRole = Qt::UserRole + 1,
        NameRole, //歌单名称
        DescriptionRole, //歌单描述
        CoverUrlRole, //歌单封面
        SongCountRole, //歌单歌曲数量
        CreationDateRole, //歌单创建日期
        PlaylistObjectRole //
    };

    // QAbstractListModel 重写
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // 数据操作
    Q_INVOKABLE void loadPlaylists(const QList<Playlist *> &playlists);
    Q_INVOKABLE void addPlaylist(Playlist *playlist);
    Q_INVOKABLE void removePlaylist(int index);
    Q_INVOKABLE Playlist *getPlaylist(int index) const;
    Q_INVOKABLE void clear();
    Q_INVOKABLE void updatePlaylistAtIndex(int index); // 触发指定索引的数据更新

signals:
    void countChanged();

private:
    QList<Playlist *> m_playlists;

signals:
};

