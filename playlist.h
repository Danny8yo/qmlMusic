#pragma once
#include <QObject>
#include <QString>
#include <QDateTime>
#include <QList>
#include "song.h"

class Playlist : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QDateTime creationDate READ creationDate WRITE setCreationDate NOTIFY creationDateChanged)
    Q_PROPERTY(QString coverUrl READ coverUrl NOTIFY coverUrlChanged)
    Q_PROPERTY(int songCount READ songCount NOTIFY songCountChanged)

public:
    explicit Playlist(QObject* parent = nullptr);
    explicit Playlist(const QString& name, QObject* parent = nullptr);
    //创建所有自定义歌曲列表
    explicit Playlist(const int &id,const QString &name, const QString &description,const QDateTime &date,QObject *parent);

    // Getters
    int id() const { return m_id; }
    QString name() const { return m_name; }
    QString description() const { return m_description; }
    QDateTime creationDate() const { return m_creationDate; }
    QString coverUrl() const { return m_coverUrl; }
    int songCount() const { return m_songs.size(); }

    // Setters
    void setId(int id);
    void setName(const QString& name);
    void setDescription(const QString& description);
    void setCreationDate(const QDateTime& creationDate);

    // 歌曲管理
    Q_INVOKABLE void addSong(Song* song);//添加一首歌到歌单
    Q_INVOKABLE void removeSong(int index);
    Q_INVOKABLE void clearSongs();
    Q_INVOKABLE Song* getSong(int index) const;//获得指定索引的歌曲
    Q_INVOKABLE QList<Song*> getAllSongs() const;
    // Q_INVOKABLE void updateCoverUrl();//设置第一首歌曲为歌单封面

signals:
    void idChanged();
    void nameChanged();
    void descriptionChanged();
    void creationDateChanged();
    void coverUrlChanged();
    void songCountChanged();
    void songsChanged();

private:
    int m_id;
    QString m_name;
    QString m_description;
    QDateTime m_creationDate;
    QString m_coverUrl;
    QList<Song*> m_songs;//用于管理歌曲列表,承接musicScanner move的共享指针
};
