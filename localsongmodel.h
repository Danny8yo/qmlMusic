#pragma once
#include <QAbstractListModel>
#include <QObject>
#include <QList>
#include <QtQml/qqmlregistration.h>
#include "song.h"

class LocalSongModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum SongRoles {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        ArtistRole,
        AlbumRole,
        DurationRole,
        FilePathRole,
        CoverUrlRole,
        SongRole
    };

    explicit LocalSongModel(QObject *parent = nullptr);
    ~LocalSongModel();

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // 公共方法
    Q_INVOKABLE Song* getSong(int index) const;
    Q_INVOKABLE void loadSongs(const QList<Song*> &songs);
    Q_INVOKABLE void clearSongs();
    Q_INVOKABLE void addSong(Song* song);
    Q_INVOKABLE void removeSong(int index);
    int count() const;

signals:
    void countChanged();
    void songsChanged();

private:
    QList<Song*> m_songs;
    void updateCount();
};
