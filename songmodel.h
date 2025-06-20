//该类用于定义qml中ListView的每一行model
#pragma once
#include <QObject>
#include <QAbstractListModel>
#include "song.h"
#include <QtQml/qqmlregistration.h>
class SongModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    QML_ELEMENT
public:
    explicit SongModel(QObject *parent = nullptr);

    // 定义角色，QML将通过这些角色名来访问数据
    enum SongRoles
    {
        IdRole = Qt::UserRole + 1,//UserRole是Qt提供的一个起始点，允许开发者定义自己的角色??
        TitleRole,
        ArtistRole,
        AlbumRole,
        FormattedDurationRole,
        CoverArtRole,
        //以下可以不展示给用户
        DurationRole,
        FilePathRole,
        LyricsRole,
        SongObjectRole
    };

    // QAbstractListModel 的必要虚函数
    //QModelIndex，可以通过行号和列号或者父索引来访问数据模型中的特定项
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;// 返回行数
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override; // 返回指定索引角色的数据
    QHash<int, QByteArray> roleNames() const override;//将C++角色枚举映射到QML可以使用的名称

    //
    Q_INVOKABLE void loadSongs(const QList<Song *> &songs);
    Q_INVOKABLE void addSong(Song *song);
    Q_INVOKABLE void removeSong(int index);
    Q_INVOKABLE Song *getSong(int index) const;
    Q_INVOKABLE void clear();

    // 排序和筛选
    Q_INVOKABLE void sortByTitle();
    Q_INVOKABLE void sortByArtist();
    Q_INVOKABLE void sortByAlbum();
    Q_INVOKABLE void filterByKeyword(const QString &keyword);
signals:
    void countChanged();

private:
    QList<Song *> m_songs;//存储歌曲数据列表
    QList<Song *> m_allSongs; // 用于筛选功能

    void refreshModel(); // 刷新模型数据

signals:
};
